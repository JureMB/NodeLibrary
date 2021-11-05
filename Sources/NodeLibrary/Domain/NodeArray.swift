//
//  NodeArray.swift
//  NodeDomain
//
//  Created by Jure Mocnik Berljavac on 03/11/2021.
//
import Foundation

protocol NodeDataProtocol {
    associatedtype GroupType: BaseGroupProtocol
    var index: Int { get }
    var kind: NodeKind { get }
    var coord: Point { get }
    var group: GroupType? {get}
    
}

public struct NodeData<GroupType>: NodeDataProtocol where GroupType: BaseGroupProtocol {
    let index: Int
    let id: UUID
    var kind: NodeKind
    var coord: Point
    var group: GroupType?
    
    init(index: Int, node: Node<GroupType>) {
        self.index = index
        self.id = node.id
        self.kind = node.kind
        self.coord = node.coord
        self.group = node.group
    }
    
}

public struct NodeIterator<GroupType: BaseGroupProtocol, S: Sequence>: IteratorProtocol where S.Element == NodeData<GroupType>{
    public typealias Element = NodeData<GroupType>
    private var wrappedIterator: S.Iterator
    
    init(itterator: S.Iterator) {
        wrappedIterator = itterator
    }
    
    mutating public func next() -> NodeData<GroupType>? {
        wrappedIterator.next()
    }
}

public typealias NodeArray<GroupType: BaseGroupProtocol> = [(index: Int, kind: NodeKind, group: GroupType?, point: Point)]
public struct NodeSequence<GroupType: BaseGroupProtocol, S: Sequence>: Sequence where S.Element == NodeData<GroupType> {
    public typealias Element = NodeData<GroupType>
    public typealias Iterator = NodeIterator<GroupType, S>
    
    fileprivate var wrappedSequence: S
    
    init(groupType: GroupType.Type, sequence: S){
        wrappedSequence = sequence
    }
    
    public func makeIterator() -> Iterator {
        NodeIterator(itterator: wrappedSequence.makeIterator())
    }
    
    public func toArray() -> [(index: Int, kind: NodeKind, group: GroupType?, point: Point)]{
        var result = [(index: Int, kind: NodeKind, group: GroupType?, point: Point)]()
        for node in self {
            result.append((index: node.index, kind: node.kind, group: node.group , point: node.coord))
        }
        return result
    }
}
