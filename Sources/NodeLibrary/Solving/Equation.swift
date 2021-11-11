//
//  Equation.swift
//  NodeDomain
//
//  Created by Jure Mocnik Berljavac on 10/10/2021.
//

import Foundation

public struct ComputationObject<LHS: LHSField, RHS: RHSField>{
    public let lhs: LHS
    public let rhs: RHS
    @usableFromInline
    internal init (lhs: LHS, rhs: RHS) {
        self.lhs = lhs
        self.rhs = rhs
    }
}

extension LHSField {
    @inlinable
    public func isEqualTo<RHS: RHSField>(_ rhs: RHS) -> ComputationObject<Self, RHS> {
        return ComputationObject(lhs: self, rhs: rhs)
    }
}

@inlinable
public func ==<LHS: LHSField, RHS: RHSField>(lhs: LHS, rhs: RHS) -> ComputationObject<LHS, RHS> {
    return lhs.isEqualTo(rhs)
}

@resultBuilder
public enum EquationBuilder {
    @inlinable
    public static func buildBlock<LHS,RHS>(_ v: ComputationObject<LHS,RHS>) -> ComputationObject<LHS,RHS>
    { v }
    @inlinable
    public static func buildBlock<LHS1,RHS1, LHS2, RHS2>(_ v: ComputationObject<LHS1,RHS1>, _ u: ComputationObject<LHS2,RHS2>)
    -> (ComputationObject<LHS1,RHS1>,ComputationObject<LHS2,RHS2>)
    { (v,u) }
    @inlinable
    public static func buildBlock<LHS1,RHS1, LHS2, RHS2, LHS3, RHS3>
    (_ v: ComputationObject<LHS1,RHS1>, _ u: ComputationObject<LHS2,RHS2>, _ w: ComputationObject<LHS3,RHS3>)
    -> (ComputationObject<LHS1,RHS1>,ComputationObject<LHS2,RHS2>,ComputationObject<LHS3,RHS3>)
    { (v,u,w) }
    @inlinable
    public static func buildBlock<LHS1,RHS1, LHS2, RHS2, LHS3, RHS3, LHS4, RHS4>
    (_ v: ComputationObject<LHS1,RHS1>, _ u: ComputationObject<LHS2,RHS2>, _ w: ComputationObject<LHS3,RHS3>, _ z: ComputationObject<LHS4, RHS4>)
    -> (ComputationObject<LHS1,RHS1>,ComputationObject<LHS2,RHS2>,ComputationObject<LHS3,RHS3>, ComputationObject<LHS4, RHS4>)
    { (v,u,w,z) }
}
