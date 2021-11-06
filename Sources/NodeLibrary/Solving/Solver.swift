//
//  Solver.swift
//  Solver
//
//  Created by Jure Mocnik Berljavac on 21/09/2021.
//
import Foundation

public protocol FieldProtocol: CaseIterable, Hashable {}

public final class Solver<E, S, F> where E:BaseGroupProtocol, S: BaseDomainShape, F: FieldProtocol {
    public enum Nodes {
        case interior
        case boundary
        case all
        case group(E)
    }
    
    public enum NodesNoGroups {
        case interior
        case boundary
        case all
    }
    
    private var _scalarFieldsType: F.Type?
    private var _vectorFieldsType: Fields2D.Type?
    private var _fields = [ScalarField<E,S,F>]()
    private var _OpIndex = 5 // 0-> dx, 1-> dy, 2-> dxx, 3-> dyy, 4-> lap
    private unowned var _domain: Domain<E, S>
    private var _fieldsDictionary = [F: Int]()
    private var _operatorCoefs: [[Vec<Double>]] //[indexNode][indexOP]
    private let coefsPointer: UnsafeMutableBufferPointer<[Vec<Double>]>
    
    let interior: NodeArray<E>
    let boundary: NodeArray<E>
    let all: NodeArray<E>
    var groups: [E : NodeArray<E>] = [:]
    
    internal var _OpIndices: [UUID: Int] = [:] // not ideal
    internal var _OpIndices_new: [DifferentialOperator<DefaultOp>: Int] = [DifferentialOperator(.der1(.x)): 0, DifferentialOperator(.der1(.y)): 1,
                                                         DifferentialOperator(.der2(.x)): 2, DifferentialOperator(.der2(.y)): 3, DifferentialOperator(.lap): 4] // not ideal
    // pointer for performance reasons
    internal var nodeCount: Int { _domain.count }
    
    internal init(domain: Domain<E, S>, scalarFields: F.Type? , vectorFields: Fields2D.Type?) {
        _domain = domain
        _scalarFieldsType = scalarFields
        _vectorFieldsType = vectorFields
        _operatorCoefs = Array(repeating: [Vec<Double>](repeating: Vec(_data: []), count: 10), count: _domain.count)
        coefsPointer = _operatorCoefs.withUnsafeMutableBufferPointer {$0}
        
        interior = _domain.interior().toArray()
        boundary = _domain.boundary().toArray()
        all = interior + boundary
        for (index, field) in _scalarFieldsType!.allCases.enumerated() {
            _fieldsDictionary[field] = index
            _fields.append(ScalarField(id: field, size: domain.count, solver: self, domain: domain, coefsPointer: coefsPointer))
        }
        let derx = DifferentialOperator(.der1(.x))
        let dery = DifferentialOperator(.der1(.y))
        let derxx = DifferentialOperator(.der2(.x))
        let deryy = DifferentialOperator(.der2(.y))
        let lap = DifferentialOperator(.lap)
        
        for node in all {
            let i = node.index
            _operatorCoefs[i][0] = derx.getCoefs(atIndex: i, from: _domain)
            _operatorCoefs[i][1] = dery.getCoefs(atIndex: i, from: _domain)
            _operatorCoefs[i][2] = derxx.getCoefs(atIndex: i, from: _domain)
            _operatorCoefs[i][3] = deryy.getCoefs(atIndex: i, from: _domain)
            _operatorCoefs[i][4] = lap.getCoefs(atIndex: i, from: _domain)
        }
    }
    convenience init (domain: Domain<E, S>, scalarFields: F.Type?) where E: GroupProtocol { // FIX
        self.init(domain: domain, scalarFields: scalarFields, vectorFields: nil)
        for group in E.allCases {
            groups[group] = _domain.group(group).toArray()
        }
    }
    internal func getFieldIndex(for field: F) -> Int {
        return _fieldsDictionary[field]!
    }
    public func explicitField(_ fieldID: F) -> ScalarField<E,S,F> {
        let index = _fieldsDictionary[fieldID]!
        return _fields[index]
    }
    public func implicitField(_ fieldID: F) -> ImplicitScalarField<E,S,F> {
        return .init(fieldID, solver: self)
    }
    internal func addOperatorReturningIndex(withID id: UUID) -> Int  {
        assert(!_OpIndices.keys.contains(id))
        guard(_OpIndex < 20) else {fatalError("Operator explosion. Do not define OperatorFields inside loops. ")}
        let currentIndex = _OpIndex
        _OpIndices[id] = currentIndex
        _OpIndex += 1
        if _operatorCoefs[0].count <= currentIndex {
            for i in 0..<_operatorCoefs.count {
                _operatorCoefs[i].append(Vec(_data: []))
            }
        }
        return currentIndex
    }
    internal func addOperatorReturningIndex(_ op: DifferentialOperator<DefaultOp>) -> Int  {
        assert(!_OpIndices_new.keys.contains(op))
        guard(_OpIndex < 20) else {fatalError("Operator explosion. Do not define OperatorFields inside loops. ")}
        let currentIndex = _OpIndex
        _OpIndices_new[op] = currentIndex
        _OpIndex += 1
        if _operatorCoefs[0].count <= currentIndex {
            for i in 0..<_operatorCoefs.count {
                _operatorCoefs[i].append(Vec(_data: []))
            }
        }
        return currentIndex
    }
}
// Internal node indices manegement
extension Solver {
    public func nodesNoGrupsToNodes(nodesNoGroups: NodesNoGroups) -> Nodes {
        switch nodesNoGroups {
        case .interior:
            return .interior
        case .boundary:
            return .boundary
        case .all:
            return .all
        }
    }
    
    public func getNodes(nodes: Nodes) -> NodeArray<E> {
        switch nodes {
        case .interior:
            return interior
        case .boundary:
            return boundary
        case .all:
            return all
        case .group(let group):
            return groups[group]!
        }
    }
    
    public func getNodes(nodes: Nodes) -> NodeArray<E> where E == NoGroups {
        switch nodes {
        case .interior:
            return interior
        case .boundary:
            return boundary
        case .all:
            return all
        case .group:
            fatalError("Groups not defined.")
        }
    }
}

// Explicit Solver
extension Solver {
    @inlinable
    public func explicitSolve<LHS, RHS>
    (on nodes: Nodes,
     @EquationBuilder
     expression: () async -> ComputationObject<LHS, RHS>) async
    where E: GroupProtocol, LHS: Explicit&LHSFieldExplicit {
        let result = await expression()
        await ExplicitEquation(forNodesIn: getNodes(nodes: nodes), expression: { result }).applyParallel()
    }
    @inlinable
    public func explicitSolve<LHS, RHS>
    (on nodes: NodesNoGroups,
     @EquationBuilder
     expression: () async -> ComputationObject<LHS, RHS>) async
    where E == NoGroups, LHS: Explicit&LHSFieldExplicit {
        let nodesBase = nodesNoGrupsToNodes(nodesNoGroups: nodes)
        let result = await expression()
        await ExplicitEquation(forNodesIn: getNodes(nodes: nodesBase), expression: { result }).applyParallel()
    }
    @inlinable
    public func explicitSolve<LHS1, LHS2, RHS1, RHS2>
    (on nodes: Nodes,
     @EquationBuilder
     expression: () async -> (ComputationObject<LHS1,RHS1>, ComputationObject<LHS2, RHS2>) ) async
    where LHS1: Explicit&LHSFieldExplicit, LHS2: Explicit&LHSFieldExplicit, E: GroupProtocol{
        let tuple = await expression()
        let equations = ExplicitEquations2(
            first:   ExplicitEquation(forNodesIn: getNodes(nodes: nodes), expression: { tuple.0 }),
            seccond: ExplicitEquation(forNodesIn: getNodes(nodes: nodes), expression: { tuple.1 }))
        await equations.applyAllAndSaveParallel()
    }
    @inlinable
    public func explicitSolve<LHS1, LHS2, RHS1, RHS2>
    (on nodes: NodesNoGroups,
     @EquationBuilder
     expression: () async -> (ComputationObject<LHS1,RHS1>, ComputationObject<LHS2, RHS2>) ) async
    where LHS1: Explicit&LHSFieldExplicit, LHS2: Explicit&LHSFieldExplicit, E == NoGroups{
        let tuple = await expression()
        let nodesBase = nodesNoGrupsToNodes(nodesNoGroups: nodes)
        let equations = ExplicitEquations2(
            first:   ExplicitEquation(forNodesIn: getNodes(nodes: nodesBase), expression: { tuple.0 }),
            seccond: ExplicitEquation(forNodesIn: getNodes(nodes: nodesBase), expression: { tuple.1 }))
        await equations.applyAllAndSaveParallel()
    }
    @inlinable
    public func explicitSolve<LHS1, LHS2, LHS3 ,RHS1, RHS2, RHS3>
    (on nodes: NodesNoGroups,
     @EquationBuilder
     expression: () async -> (ComputationObject<LHS1,RHS1>, ComputationObject<LHS2, RHS2>, ComputationObject<LHS3, RHS3>) ) async
    where LHS1: Explicit&LHSFieldExplicit, LHS2: Explicit&LHSFieldExplicit, LHS3: Explicit&LHSFieldExplicit ,E == NoGroups{
        let tuple = await expression()
        let nodesBase = nodesNoGrupsToNodes(nodesNoGroups: nodes)
        let equations = ExplicitEquations3(
            first:   ExplicitEquation(forNodesIn: getNodes(nodes: nodesBase), expression: { tuple.0 }),
            seccond: ExplicitEquation(forNodesIn: getNodes(nodes: nodesBase), expression: { tuple.1 }),
            third:   ExplicitEquation(forNodesIn: getNodes(nodes: nodesBase), expression: { tuple.2 }))
        await equations.applyAllAndSaveParallel()
    }
//    @inlinable
    public func explicitSolve<LHS1, LHS2, LHS3, LHS4 ,RHS1, RHS2, RHS3, RHS4>
    (on nodes: NodesNoGroups,
     @EquationBuilder
     expression: () async -> (ComputationObject<LHS1,RHS1>, ComputationObject<LHS2, RHS2>, ComputationObject<LHS3, RHS3>, ComputationObject<LHS4, RHS4>) ) async
    where LHS1: Explicit&LHSFieldExplicit, LHS2: Explicit&LHSFieldExplicit, LHS3: Explicit&LHSFieldExplicit, LHS4: Explicit&LHSFieldExplicit, E == NoGroups{
        let tuple = await expression()
        let nodesBase = nodesNoGrupsToNodes(nodesNoGroups: nodes)
        let equations = ExplicitEquations4(
            first:   ExplicitEquation(forNodesIn: getNodes(nodes: nodesBase), expression: { tuple.0 }),
            seccond: ExplicitEquation(forNodesIn: getNodes(nodes: nodesBase), expression: { tuple.1 }),
            third:   ExplicitEquation(forNodesIn: getNodes(nodes: nodesBase), expression: { tuple.2 }),
            fourth:  ExplicitEquation(forNodesIn: getNodes(nodes: nodesBase), expression: { tuple.3 }))
        await equations.applyAllAndSaveParallel()
    }
}
// Implicit Solver
extension Solver {
    public func implicitSet< LHS, RHS>
    (on nodes: Nodes,
     @EquationBuilder
     expression: () -> ComputationObject<LHS,RHS> )
    where E: GroupProtocol, LHS: Implicit&LHSFieldImplicit {
        ImplicitEquation(forNodesIn: getNodes(nodes: nodes), expression: expression).setEquation()
    }
    
    public func implicitSet< LHS, RHS>
    (on nodes: NodesNoGroups,
     @EquationBuilder
     expression: () -> ComputationObject<LHS,RHS> )
    where E==NoGroups, LHS: Implicit&LHSFieldImplicit {
        return ImplicitEquation(forNodesIn: getNodes(nodes: nodesNoGrupsToNodes(nodesNoGroups: nodes)), expression: expression).setEquation()
    }
    
    public func implicitSet< LHS1, RHS1, LHS2, RHS2>
    (on nodes: Nodes,
     @EquationBuilder
     expression: ()->(ComputationObject<LHS1,RHS1>, ComputationObject<LHS2,RHS2>) )
    where E: GroupProtocol, LHS1: Implicit&LHSFieldImplicit, LHS2: Implicit&LHSFieldImplicit {
        let tuple = expression()
        ImplicitEquations2(
            first: ImplicitEquation(forNodesIn: getNodes(nodes: nodes), expression: { tuple.0 }),
            seccond: ImplicitEquation(forNodesIn: getNodes(nodes: nodes), expression: { tuple.1 })).setEquations()
    }
    
    public func implicitSet< LHS1, RHS1, LHS2, RHS2>
    (on nodes: NodesNoGroups,
     @EquationBuilder
     expression: ()->(ComputationObject<LHS1,RHS1>, ComputationObject<LHS2,RHS2>) )
    where E==NoGroups, LHS1: Implicit&LHSFieldImplicit, LHS2: Implicit&LHSFieldImplicit {
        let tuple = expression()
        let nodesBase = nodesNoGrupsToNodes(nodesNoGroups: nodes)
        return ImplicitEquations2(
            first: ImplicitEquation(forNodesIn: getNodes(nodes: nodesBase), expression: { tuple.0 }),
            seccond: ImplicitEquation(forNodesIn: getNodes(nodes: nodesBase), expression: { tuple.1 })).setEquations()
    }
    
    public func implicitSolve(for field: ImplicitScalarField<E,S,F>) async {
        await field.solve()
    }
}
