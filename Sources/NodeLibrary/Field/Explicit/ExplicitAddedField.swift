//
//  File.swift
//  
//
//  Created by Jure Mocnik Berljavac on 06/11/2021.
//
//public struct AddedExplicitField<RHS1,RHS2>: RHSField where RHS1: RHSField, RHS2: RHSField {
//    public let opField1: RHS1
//    public let opField2: RHS2
//    @inlinable
//    public subscript(index: Int) -> Double {
//        return opField1[index] + opField2[index]
//    }
//}
//
//public func +<RHS1,RHS2>(lhs: RHS1, rhs: RHS2 ) -> AddedExplicitField<RHS1,RHS2>
//where RHS1: RHSField, RHS2: RHSField {
//    return AddedExplicitField(opField1: lhs, opField2: rhs)
//}
