//
//  File.swift
//  
//
//  Created by Jure Mocnik Berljavac on 06/11/2021.
//
public final class AddedImplicitOperatorField<E: BaseGroupProtocol, S: BaseDomainShape, F: FieldProtocol>: LHSFieldImplicit {
    fileprivate let opField1: ImplicitOperatorField<E,S,F>
    fileprivate let opField2: ImplicitOperatorField<E,S,F>
    
    fileprivate init(opField1: ImplicitOperatorField<E,S,F>, opField2: ImplicitOperatorField<E,S,F>){
        self.opField1 = opField1
        self.opField2 = opField2
    }
    
    public subscript(index: Int) -> Double {
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
    public func setRhsRow(at index: Int, to value: Double) {
        opField1.setRhsRow(at: index, to: value)
    }
    
    public func allowOneOverwriteOfMatrixRows(forNodeArray nodeRange: [(index: Int, kind: NodeKind, group: E?, point: Point)]) {
        opField1.allowOneOverwriteOfMatrixRows(forNodeArray: nodeRange)
    }
    
    public func allowOneOverwriteOfRhsRows(forNodeArray nodeRange: [(index: Int, kind: NodeKind, group: E?, point: Point)]) {
        opField1.allowOneOverwriteOfRhsRows(forNodeArray: nodeRange)
    }
}

public func +<E: BaseGroupProtocol, S: BaseDomainShape, F: FieldProtocol>(lhs: ImplicitOperatorField<E,S,F>, rhs: ImplicitOperatorField<E,S,F>) -> AddedImplicitOperatorField<E,S,F> {
    return AddedImplicitOperatorField(opField1: lhs, opField2: rhs)
}
