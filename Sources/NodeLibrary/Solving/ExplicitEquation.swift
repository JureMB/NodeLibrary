//
//  ExplicitEquation.swift
//  NodeDomain
//
//  Created by Jure Mocnik Berljavac on 03/11/2021.
//

public final class ExplicitEquation<LHS: LHSFieldExplicit, RHS: RHSField, GroupType: BaseGroupProtocol> {
    public let lhs: LHS
    public let rhs: RHS
    public let nodeRange: [(index: Int, kind: NodeKind, group: GroupType?, point: Point)]
    
    private init(lhs: LHS, rhs: RHS, nodeArray: [(index: Int, kind: NodeKind, group: GroupType?, point: Point)]){
        self.lhs = lhs
        self.rhs = rhs
        self.nodeRange = nodeArray
        
    }
    
    @usableFromInline
    internal convenience init(forNodesIn nodeArray: [(index: Int, kind: NodeKind, group: GroupType?, point: Point)], expression: ()-> ComputationObject<LHS, RHS>) {
        let object = expression()
        self.init(lhs: object.lhs, rhs: object.rhs, nodeArray: nodeArray)
    }
    
    @inlinable
    internal func apply() async {
        await lhs.update{ protectedData in
            for node in nodeRange {
                let i = node.index
                protectedData[i] = rhs[i]
            }
        }
    }
    
    @inlinable
    internal func applyParallel() async {
        await withTaskGroup(of: [(Int, Double)].self) { group in
            group.addTask {
                let array = [(Int, Double)].init(unsafeUninitializedCapacity: self.nodeRange.count/2) { buffer, initializedCount in
                    for (index, _) in  buffer.enumerated() {
                        let node = self.nodeRange[index]
                        let i = node.index
                        buffer.baseAddress!.advanced(by: index).pointee = (i, self.rhs[i])
                        initializedCount += 1
                    }
                }
                return array
            }
            group.addTask {
                let array = [(Int, Double)].init(unsafeUninitializedCapacity: self.nodeRange.count/2) { buffer, initializedCount in
                    for (index, _) in  buffer.enumerated() {
                        let node = self.nodeRange[self.nodeRange.count/2 + index]
                        let i = node.index
                        buffer.baseAddress!.advanced(by: index).pointee = (i, self.rhs[i])
                        initializedCount += 1
                    }
                }
                return array
            }
            for await array in group {
                await lhs.update { lhsData in
                    for (i, value) in array {
                        lhsData[i] = value
                    }
                }
            }
        }
    }
}

public protocol ExplicitUnion {
    func applyAllAndSaveParallel() async
}
@usableFromInline
internal struct ExplicitEquations2<LHS1: LHSFieldExplicit, RHS1: RHSField, LHS2: LHSFieldExplicit, RHS2: RHSField, GroupType: BaseGroupProtocol>: ExplicitUnion{
    public let first: ExplicitEquation<LHS1, RHS1, GroupType>
    public let  seccond: ExplicitEquation<LHS2, RHS2, GroupType>
    @usableFromInline
    internal init(first:  ExplicitEquation<LHS1, RHS1, GroupType>, seccond: ExplicitEquation<LHS2, RHS2, GroupType>) {
        self.first = first
        self.seccond = seccond
    }
    @inlinable
    internal func applyAllAndSaveParallel() async {
        async let a: Void = first.applyParallel()
        async let b: Void = seccond.applyParallel()
        
        await a
        await b
    }

}
@usableFromInline
internal struct ExplicitEquations3<LHS1, LHS2, LHS3, RHS1, RHS2, RHS3, GroupType: BaseGroupProtocol>: ExplicitUnion
where LHS1: LHSFieldExplicit, LHS2: LHSFieldExplicit, LHS3: LHSFieldExplicit,
      RHS1: RHSField, RHS2: RHSField, RHS3: RHSField{
    internal let first: ExplicitEquation<LHS1, RHS1, GroupType>
    internal let seccond: ExplicitEquation<LHS2, RHS2, GroupType>
    internal let third: ExplicitEquation<LHS3, RHS3, GroupType>
    public init(first:  ExplicitEquation<LHS1, RHS1, GroupType>, seccond: ExplicitEquation<LHS2, RHS2, GroupType>, third: ExplicitEquation<LHS3, RHS3, GroupType>) {
        self.first = first
        self.seccond = seccond
        self.third = third
    }
    public func applyAllAndSaveParallel() async {
        async let a: Void = first.apply()
        async let b: Void = seccond.apply()
        async let c: Void = third.apply()
        
        await a
        await b
        await c

    }
}
@usableFromInline
internal struct ExplicitEquations4<LHS1, LHS2, LHS3, LHS4, RHS1, RHS2, RHS3, RHS4 ,GroupType: BaseGroupProtocol>: ExplicitUnion
where LHS1: LHSFieldExplicit, LHS2: LHSFieldExplicit, LHS3: LHSFieldExplicit, LHS4: LHSFieldExplicit,
      RHS1: RHSField, RHS2: RHSField, RHS3: RHSField, RHS4: RHSField{
    let first: ExplicitEquation<LHS1, RHS1, GroupType>
    let seccond: ExplicitEquation<LHS2, RHS2, GroupType>
    let third: ExplicitEquation<LHS3, RHS3, GroupType>
    let fourth: ExplicitEquation<LHS4, RHS4, GroupType>
    @available(macOS 12.0.0, *)
    public func applyAllAndSaveParallel() async {
        async let a: Void = first.apply()
        async let b: Void = seccond.apply()
        async let c: Void = third.apply()
        async let d: Void = fourth.apply()
        
        await a
        await b
        await c
        await d

    }
}
