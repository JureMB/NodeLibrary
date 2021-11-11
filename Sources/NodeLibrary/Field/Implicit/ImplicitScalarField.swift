//
//  ImplicitScalarField.swift
//  NodeDomain
//
//  Created by Jure Mocnik Berljavac on 10/10/2021.
//
public final class ImplicitScalarField<E,S,F>: LHSFieldImplicit
where E: BaseGroupProtocol, S: BaseDomainShape, F: FieldProtocol {
    private let field: F
    private let op = DifferentialOperator(.id)
    private unowned let solver: Solver<E, S, F>
    private var _rhs: [Double]
    private var _matrix: [Double] // dummy var FIX
    private let result: ScalarField<E,S,F>
    
    internal var matrixIsSet: [Bool]
    internal var rhsIsSet: [Bool]
    
    internal init(_ field: F, solver: Solver<E,S,F>) {
        self.field = field
        self.solver = solver
        _rhs = .init(repeating: 0, count: solver.nodeCount)
        _matrix = .init(repeating: 0, count: solver.nodeCount)
        matrixIsSet = .init(repeating: false, count: solver.nodeCount)
        rhsIsSet = .init(repeating: false, count: solver.nodeCount)
        result = solver.explicitField(field)
    }
    
    public func implicitOperatorField(_ op: DifferentialOperator<DefaultOp>) -> ImplicitOperatorField<E,S,F> {
        return ImplicitOperatorField(op: op, field: self)
    }
    
    public func implicitOperatorField(fromExpression expression: () -> DifferentialOperator<DefaultOp>)
    -> ImplicitOperatorField<E,S,F> {
        return implicitOperatorField(expression())
    }
    
    public func callAsFunction(_ op: DifferentialOperator<DefaultOp>)
    -> ImplicitOperatorField<E,S,F> {
        return implicitOperatorField(op)
    }
    
    public func callAsFunction(fromExpression expression: () -> DifferentialOperator<DefaultOp>)
    -> ImplicitOperatorField<E,S,F> {
        return implicitOperatorField(expression())
    }
    
    public func getResult() async -> some RHSField {
        await result.copy()
    }
    
    public subscript(index: Int) -> Double {
        get {
            fatalError()
        }
        set {
            guard( !matrixIsSet[index] && !matrixIsSet[index]) else {
                    fatalError("Can't implicitly overwrite already set row \(index). To overwrite a row use explicit 'setMatrixRow...' or 'setRhsRow' methods.")
            }
            setMatrixRow(at: index, op: self.op)
            setRhsRow(at: index, to: newValue)
        }
    }
}

extension ImplicitScalarField {
    public func setMatrixRow(at index: Int, op: DifferentialOperator<DefaultOp>) { // set
        guard( !matrixIsSet[index]) else {  fatalError("Matrix value for index \(index) already set. To overwrite rhs values use method 'allowOneOverwriteOfMatrixRows'.")}
//        #if DEBUG
        matrixIsSet[index] = true
//        #endif
    }
    
    public func setMatrixRowToIdentity(at index: Int) { // set
        setMatrixRow(at: index, op: DifferentialOperator(.id))
    }
    
    public func setRhsRow(at index: Int, to value: Double) {
        guard( !rhsIsSet[index]) else {fatalError("Rhs value for index \(index) already set. To overwrite rhs values use method 'allowOneOverwriteOfRhsRows'.") }
        _rhs[index] = value
//        #if DEBUG
        rhsIsSet[index] = true
//        #endif
    }
    
    public func solve() async {
        for (index, (nodeMatIsSet, nodeRhsIsSet)) in zip(matrixIsSet, rhsIsSet).enumerated() {
            guard( nodeMatIsSet && nodeRhsIsSet) else { fatalError("All nodes were not set. Found unset node at index \(index).")}
        }
        await result.overwrite(with: Array(repeating: 1, count: result.count))
    }
}

extension ImplicitScalarField {
    public func allowOneOverwriteOfMatrixRows(forNodeArray nodeRange: NodeArray<E>) {
        for node in nodeRange {
            let index = node.index
            matrixIsSet[index] = false
        }
    }
    
    public func allowOneOverwriteOfRhsRows(forNodeArray nodeRange: NodeArray<E>) {
        for node in nodeRange {
            let index = node.index
            rhsIsSet[index] = false
        }
    }
    
    public func allowOneOverwriteOfMatrixRows<Seq>(forNodes nodeRange: NodeSequence<E, Seq>)
    where Seq: Sequence {
//        #if DEBUG
        for node in nodeRange {
            let index = node.index
            matrixIsSet[index] = false
        }
//        #endif
    }
    
    public func allowOneOverwriteOfRhsRows<Seq>(forNodes nodeRange: NodeSequence<E,Seq>)
    where Seq: Sequence {
        for node in nodeRange {
            let index = node.index
            rhsIsSet[index] = false
        }
    }
    
    public func fieldIsSet<Seq>(forNodes nodeRange: NodeSequence<E,Seq>){
        for node in nodeRange {
            let index = node.index
            rhsIsSet[index] = false
            matrixIsSet[index] = false
        }
    }
}
