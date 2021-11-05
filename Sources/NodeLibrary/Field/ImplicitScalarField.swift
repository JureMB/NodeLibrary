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
    
    fileprivate var matrixIsSet: [Bool]
    fileprivate var rhsIsSet: [Bool]
    
    internal init(_ field: F, solver: Solver<E,S,F>) {
        self.field = field
        self.solver = solver
        _rhs = .init(repeating: 0, count: solver.nodeCount)
        _matrix = .init(repeating: 0, count: solver.nodeCount)
        matrixIsSet = .init(repeating: false, count: solver.nodeCount)
        rhsIsSet = .init(repeating: false, count: solver.nodeCount)
        result = solver.explicitField(field)
    }
    
    func implicitOperatorField(_ op: DifferentialOperator<DefaultOp>) -> ImplicitOperatorField<E,S,F>{
        return ImplicitOperatorField(op: op, field: self)
    }
    
    func implicitOperatorField(fromExpression expression: ()->DifferentialOperator<DefaultOp>) -> ImplicitOperatorField<E,S,F>{
        return implicitOperatorField(expression())
    }
    
    func callAsFunction(_ op: DifferentialOperator<DefaultOp>) -> ImplicitOperatorField<E,S,F> {
        return implicitOperatorField(op)
    }
    
    func callAsFunction(fromExpression expression: ()->DifferentialOperator<DefaultOp>) -> ImplicitOperatorField<E,S,F> {
        return implicitOperatorField(expression())
    }
    
    @available(macOS 12.0.0, *)
    func getResult() async -> ScalarFieldRHS<E,S,F> {
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

extension ImplicitScalarField: Implicit {
    func setMatrixRow(at index: Int, op: DifferentialOperator<DefaultOp>) { // set
        guard( !matrixIsSet[index]) else {  fatalError("Matrix value for index \(index) already set. To overwrite rhs values use method 'allowOneOverwriteOfMatrixRows'.")}
//        #if DEBUG
        matrixIsSet[index] = true
//        #endif
    }
    
    func setMatrixRowToIdentity(at index: Int) { // set
        setMatrixRow(at: index, op: DifferentialOperator(.id))
    }
    
    public func setRhsRow(at index: Int, to value: Double) {
        guard( !rhsIsSet[index]) else {fatalError("Rhs value for index \(index) already set. To overwrite rhs values use method 'allowOneOverwriteOfRhsRows'.") }
        _rhs[index] = value
//        #if DEBUG
        rhsIsSet[index] = true
//        #endif
    }
    @available(macOS 12.0.0, *)
    func solve() async {
        for (index, (nodeMatIsSet, nodeRhsIsSet)) in zip(matrixIsSet, rhsIsSet).enumerated() {
            guard( nodeMatIsSet && nodeRhsIsSet) else { fatalError("All nodes were not set. Found unset node at index \(index).")}
        }
        await result.overwrite(with: Array(repeating: 1, count: result.count))
    }
}

extension ImplicitScalarField {
    public func allowOneOverwriteOfMatrixRows(forNodeArray nodeRange: [(index: Int, kind: NodeKind, group: E?, point: Point)]) {
        for node in nodeRange {
            let index = node.index
            matrixIsSet[index] = false
        }
    }
    
    public func allowOneOverwriteOfRhsRows(forNodeArray nodeRange: [(index: Int, kind: NodeKind, group: E?, point: Point)]) {
        for node in nodeRange {
            let index = node.index
            rhsIsSet[index] = false
        }
    }
    
    func allowOneOverwriteOfMatrixRows<Seq>(forNodes nodeRange: NodeSequence<E, Seq>) where Seq: Sequence {
//        #if DEBUG
        for node in nodeRange {
            let index = node.index
            matrixIsSet[index] = false
        }
//        #endif
    }
    
    func allowOneOverwriteOfRhsRows<Seq>(forNodes nodeRange: NodeSequence<E,Seq>) where Seq: Sequence {
        for node in nodeRange {
            let index = node.index
            rhsIsSet[index] = false
        }
    }
    
    func fieldIsSet<Seq>(forNodes nodeRange: NodeSequence<E,Seq>){
        for node in nodeRange {
            let index = node.index
            rhsIsSet[index] = false
            matrixIsSet[index] = false
        }
    }
}

class ImplicitOperatorField<E: BaseGroupProtocol, S: BaseDomainShape, F: FieldProtocol>: LHSFieldImplicit {

    func update(clousure: @Sendable (inout [Double]) -> Void) async {
        fatalError()
    }
    
    private unowned let field: ImplicitScalarField<E, S, F>
    
    let op: DifferentialOperator<DefaultOp>
    fileprivate init(op: DifferentialOperator<DefaultOp>, field: ImplicitScalarField<E,S,F>){
        self.op = op
        self.field = field
    }
    
    subscript(index: Int) -> Double {
        get {
            fatalError()
        }
        set {
            guard( !field.matrixIsSet[index] && !field.matrixIsSet[index]) else {
                    fatalError("Can't implicitly overwrite already set row \(index). To overwrite a row use explicit 'setMatrixRow...' or 'setRhsRow' methods.")
            }
            field.setMatrixRow(at: index, op: op)
            field.setRhsRow(at: index, to: newValue)
        }
    }
}

extension ImplicitOperatorField: Implicit {
    func allowOneOverwriteOfMatrixRows(forNodeArray nodeRange: [(index: Int, kind: NodeKind, group: E?, point: Point)]) {
        field.allowOneOverwriteOfMatrixRows(forNodeArray: nodeRange)
    }
    
    func allowOneOverwriteOfRhsRows(forNodeArray nodeRange: [(index: Int, kind: NodeKind, group: E?, point: Point)]) {
        field.allowOneOverwriteOfRhsRows(forNodeArray: nodeRange)
    }
    
    func setRhsRow(at index: Int, to value: Double) {
        field.setRhsRow(at: index, to: value)
    }
    
    fileprivate func setMatrixRow( at index: Int, to other_op: DifferentialOperator<DefaultOp>) { // set
        field.setMatrixRow(at: index, op: other_op)
    }
    
    func setMatrixRowToThisOperator(at index: Int) { // set
        field.setMatrixRow(at: index, op: op)
    }
}

class AddedImplicitOperatorField<E: BaseGroupProtocol, S: BaseDomainShape, F: FieldProtocol>: LHSFieldImplicit {
    fileprivate let opField1: ImplicitOperatorField<E,S,F>
    fileprivate let opField2: ImplicitOperatorField<E,S,F>
    
    fileprivate init(opField1: ImplicitOperatorField<E,S,F>, opField2: ImplicitOperatorField<E,S,F>){
        self.opField1 = opField1
        self.opField2 = opField2
    }
    
    subscript(index: Int) -> Double {
        get {
            fatalError()
        }
        set {
            opField1.setMatrixRow(at: index, to: opField1.op + opField2.op)
            opField1.setRhsRow(at: index, to: newValue)
        }
    }
}
extension AddedImplicitOperatorField: Implicit {
    func setRhsRow(at index: Int, to value: Double) {
        opField1.setRhsRow(at: index, to: value)
    }
    
    func allowOneOverwriteOfMatrixRows(forNodeArray nodeRange: [(index: Int, kind: NodeKind, group: E?, point: Point)]) {
        opField1.allowOneOverwriteOfMatrixRows(forNodeArray: nodeRange)
    }
    
    func allowOneOverwriteOfRhsRows(forNodeArray nodeRange: [(index: Int, kind: NodeKind, group: E?, point: Point)]) {
        opField1.allowOneOverwriteOfRhsRows(forNodeArray: nodeRange)
    }
}

func +<E: BaseGroupProtocol, S: BaseDomainShape, F: FieldProtocol>(lhs: ImplicitOperatorField<E,S,F>, rhs: ImplicitOperatorField<E,S,F>) -> AddedImplicitOperatorField<E,S,F> {
    return AddedImplicitOperatorField(opField1: lhs, opField2: rhs)
}
