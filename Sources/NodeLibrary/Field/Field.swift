//
//  Field.swift
//  NodeDomain
//
//  Created by Jure Mocnik Berljavac on 03/11/2021.
//
public protocol Explicit {
    func getData() async -> [Double]
}

public protocol Implicit {
    associatedtype E: BaseGroupProtocol
    func allowOneOverwriteOfMatrixRows(forNodeArray nodeRange: [(index: Int, kind: NodeKind, group: E?, point: Point)])
    func allowOneOverwriteOfRhsRows(forNodeArray nodeRange: [(index: Int, kind: NodeKind, group: E?, point: Point)])
    func setRhsRow(at index: Int, to value: Double)
}

public protocol RHSField {
    subscript(index: Int) -> Double  { get }
}

public protocol LHSField {}

public protocol LHSFieldExplicit: AnyObject, LHSField, Explicit {
    @inlinable
    func update(clousure: @Sendable (inout [Double]) -> Void ) async
}

public protocol LHSFieldImplicit: AnyObject, LHSField, Implicit {
    subscript(index: Int) -> Double  { get set }
}

extension Double: RHSField {
    var coefsSet: Bool {
        true
    }
    typealias GroupType = NoGroups
    func setCoefs(nodeIndices: [Int]) {
        
    }
    func setCoefs(at index: Int) {
    }
    
    func getValue(at index: Int) -> Double {
        self
    }
    
    public subscript(index: Int) -> Double {
        return self
    }
}
