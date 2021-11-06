//
//  File.swift
//  
//
//  Created by Jure Mocnik Berljavac on 06/11/2021.
//
public final class ImplicitOperatorField<E: BaseGroupProtocol, S: BaseDomainShape, F: FieldProtocol>: LHSFieldImplicit {

    func update(clousure: @Sendable (inout [Double]) -> Void) async {
        fatalError()
    }
    
    private unowned let field: ImplicitScalarField<E, S, F>
    
    let op: DifferentialOperator<DefaultOp>
    internal init(op: DifferentialOperator<DefaultOp>, field: ImplicitScalarField<E,S,F>){
        self.op = op
        self.field = field
    }
    
    public subscript(index: Int) -> Double {
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
    public func allowOneOverwriteOfMatrixRows(forNodeArray nodeRange: [(index: Int, kind: NodeKind, group: E?, point: Point)]) {
        field.allowOneOverwriteOfMatrixRows(forNodeArray: nodeRange)
    }
    
    public func allowOneOverwriteOfRhsRows(forNodeArray nodeRange: [(index: Int, kind: NodeKind, group: E?, point: Point)]) {
        field.allowOneOverwriteOfRhsRows(forNodeArray: nodeRange)
    }
    
    public func setRhsRow(at index: Int, to value: Double) {
        field.setRhsRow(at: index, to: value)
    }
    
    public func setMatrixRow( at index: Int, to other_op: DifferentialOperator<DefaultOp>) { // set
        field.setMatrixRow(at: index, op: other_op)
    }
    
    public func setMatrixRowToThisOperator(at index: Int) { // set
        field.setMatrixRow(at: index, op: op)
    }
}
