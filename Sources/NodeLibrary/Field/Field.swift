//
//  Field.swift
//  NodeDomain
//
//  Created by Jure Mocnik Berljavac on 03/11/2021.
//
public protocol Explicit { // REMOVE THIS / MAKE IT MORE OBVIOUS
    func getData() async -> [Double]
}

public protocol Implicit {
    associatedtype E: BaseGroupProtocol
    func allowOneOverwriteOfMatrixRows(forNodeArray nodeRange: NodeArray<E>)
    func allowOneOverwriteOfRhsRows(forNodeArray nodeRange: NodeArray<E>)
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
    public subscript(index: Int) -> Double {
        return self
    }
}
