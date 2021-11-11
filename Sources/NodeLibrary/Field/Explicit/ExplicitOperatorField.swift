//
//  File.swift
//  
//
//  Created by Jure Mocnik Berljavac on 06/11/2021.
//
internal struct OperatorField<E: BaseGroupProtocol, S: BaseDomainShape, F: FieldProtocol>: RHSField, Explicit {
    let op: DifferentialOperator<DefaultOp>
    @usableFromInline
    internal let opInddex: Int
    private let _solver: Solver<E,S,F>
    private let field: ScalarField<E,S,F>
    @usableFromInline
    internal let fieldRHS: ScalarFieldRHS<E,S,F>
    internal init (op: DifferentialOperator<DefaultOp>, fieldRHS: ScalarFieldRHS<E,S,F>, solver: Solver<E,S,F>) {
        var tempIndex: Int?
        self.op = op
        self.fieldRHS = fieldRHS
        self.field = fieldRHS.field
        self._solver = solver
        // get index from dictionary
        tempIndex = _solver._OpIndices_new[op]
        
        if tempIndex == nil {
            opInddex = _solver.addOperatorReturningIndex(op )
            setCoefs()
        } else {
            opInddex = tempIndex!
        }
    }
    @inlinable
    public subscript(index: Int) -> Double {
        return fieldRHS.apply(opIndex: opInddex, atIndex: index)
    }
    
    func setCoefs() {
        for node in _solver._all {
            setCoefs(at: node.index)
        }
    }
    
    func setCoefs(at index: Int) {
        fieldRHS.setCoefs(opIndex: opInddex, op: op, atIndex: index)
    }
    
    public func getData() async -> [Double] {
        return await field.getData()
    }
}
