//
//  ImplicitEquation.swift
//  NodeDomain
//
//  Created by Jure Mocnik Berljavac on 03/11/2021.
//

import Foundation

public final class ImplicitEquation<LHS: LHSFieldImplicit, RHS: RHSField, GroupType: BaseGroupProtocol> {
    private init(lhs: LHS, rhs: RHS, nodeArray: [(index: Int, kind: NodeKind, group: GroupType?, point: Point)]){
        self.lhs = lhs
        self.rhs = rhs
        self.nodeRange = nodeArray
    }
    convenience init(forNodesIn nodeArray: [(index: Int, kind: NodeKind, group: GroupType?, point: Point)], expression: ()-> ComputationObject<LHS, RHS>){
        let object = expression()
        self.init(lhs: object.lhs, rhs: object.rhs, nodeArray: nodeArray)
    }
    private let lhs: LHS
    private let rhs: RHS
    private let nodeRange: [(index: Int, kind: NodeKind, group: GroupType?, point: Point)]
    
    func setEquation() {
        for node in nodeRange {
            let i = node.index
            lhs[i] = rhs[i]
        }
    }
    func updateLHSAndRHS() where LHS.E == GroupType {
        lhs.allowOneOverwriteOfRhsRows(forNodeArray: nodeRange)
        lhs.allowOneOverwriteOfMatrixRows(forNodeArray: nodeRange)
        for node in nodeRange {
            let i = node.index
            lhs[i] = rhs[i]
        }
    }
    func updateRHS()  where LHS.E == GroupType{
        lhs.allowOneOverwriteOfRhsRows(forNodeArray: nodeRange)
        for node in nodeRange {
            let i = node.index
            lhs.setRhsRow(at: i, to: rhs[i])
        }
    }
    func updateRHS<ShapeType: BaseDomainShape, FieldType: FieldProtocol>(to rhs: ScalarFieldRHS<GroupType, ShapeType, FieldType>) where LHS.E == GroupType {
        lhs.allowOneOverwriteOfRhsRows(forNodeArray: nodeRange)
        for node in nodeRange {
            let i = node.index
            lhs.setRhsRow(at: i, to: rhs[i])
        }
    }
}

@usableFromInline
internal struct ImplicitEquations2<LHS1: LHSFieldImplicit, LHS2: LHSFieldImplicit, RHS1: RHSField, RHS2: RHSField, GroupType: BaseGroupProtocol> {
    let first: ImplicitEquation<LHS1, RHS1, GroupType>
    let seccond: ImplicitEquation<LHS2, RHS2, GroupType>
    
    func setEquations(){
        first.setEquation()
        seccond.setEquation()
    }
    
}

extension ImplicitEquations2 where LHS1.E == GroupType, LHS2.E == GroupType {
    func updateLHSsAndRHSs() {
        first.updateLHSAndRHS()
        seccond.updateLHSAndRHS()
    }
    func updateRHSs()
    {
        first.updateRHS()
        seccond.updateRHS()
    }
}
