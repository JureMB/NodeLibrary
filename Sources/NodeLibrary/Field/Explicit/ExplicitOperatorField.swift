//
//  File.swift
//  
//
//  Created by Jure Mocnik Berljavac on 06/11/2021.
//
//public struct OperatorField<E: BaseGroupProtocol, S: BaseDomainShape, F: FieldProtocol>: RHSField, Explicit {
//    let op: DifferentialOperator<DefaultOp>
//    private let opInddex: Int
//    private let field: ScalarField<E,S,F>
//    private let fieldRHS: ScalarFieldRHS<E,S,F>
//    internal init (op: DifferentialOperator<DefaultOp>, fieldRHS: ScalarFieldRHS<E,S,F>) {
//        var tempIndex: Int?
//        self.op = op
//        self.fieldRHS = fieldRHS
//        self.field = fieldRHS.field
//        // get index from dictionary
//        tempIndex = field._solver._OpIndices_new[op]
//        
//        if tempIndex == nil {
//            opInddex = field._solver.addOperatorReturningIndex(op )
//            setCoefs()
//        } else {
//            opInddex = tempIndex!
//        }
//    }
//    
//    public subscript(index: Int) -> Double {
//        return fieldRHS.apply(opIndex: opInddex, atIndex: index)
//    }
//    
//    func setCoefs() {
//        for node in field._solver.all {
//            setCoefs(at: node.index)
//        }
//    }
//    
//    func setCoefs(at index: Int) {
//        fieldRHS.setCoefs(opIndex: opInddex, op: op, atIndex: index)
//    }
//    
//    public func getData() async -> [Double] {
//        return await field.getData()
//    }
//}
