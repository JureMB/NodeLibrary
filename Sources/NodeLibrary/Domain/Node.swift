//
//  Point.swift
//  NodeDomain
//
//  Created by Jure Mocnik Berljavac on 18/09/2021.
//
import Foundation

public enum NodeKind {
    case interior, boundary
}

public struct Node<E: BaseGroupProtocol>: Identifiable {
    public let id = UUID()
    public let coord: Point
    public let kind: NodeKind
    public let group: E?

    init(at point: Point, nodeKind: NodeKind , group: E? = nil){
        checkNoGroups()
        coord = point
        kind = nodeKind
        self.group = group
    }
}

extension Node: CustomStringConvertible {
    public var description: String {
        if let group = group {
            return "Node(x: \(coord.x), y: \(coord.y), kind: \(kind), group: \(group)"
        } else {
            return "Node(x: \(coord.x), y: \(coord.y), kind: \(kind))"
        }
    }
}
public struct Point {
    public let x: Double
    public let y: Double
    
    public init(x: Double, y: Double) {
        self.x = x
        self.y = y
    }
}
extension Point: ExpressibleByArrayLiteral {
    public init(arrayLiteral elements: Double...) {
        assert(elements.count == 2)
        x = elements[0]
        y = elements[1]
    }
}
extension Point {
    public var abs: Double { sqrt( self.x * self.x + self.y * self.y) }
}

public func +(lhs: Point, rhs: Point) -> Point{
    return Point(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
}

public func -(lhs: Point, rhs: Point) -> Point{
    return Point(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
}

public func *(lhs: Double, rhs: Point) -> Point{
    return Point(x: lhs * rhs.x, y: lhs * rhs.y)
}



