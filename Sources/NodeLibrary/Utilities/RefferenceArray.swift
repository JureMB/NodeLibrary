//
//  RefferenceArray.swift
//  NodeDomain
//
//  Created by Jure Mocnik Berljavac on 15/09/2021.
//

infix operator .* : MultiplicationPrecedence

public final class RefferenceArray<Element>: Collection, ExpressibleByArrayLiteral {
    public typealias Index = Array<Element>.Index
    fileprivate var array: [Element]
    public var startIndex: Index {array.startIndex}
    public var endIndex: Index { array.endIndex}
    public subscript(position: Index) -> Element {
        get {
            array[position]
        }
        set {
            array[position] = newValue
        }
    }
    public func index(after i: Index) -> Index {
        return array.index(after: i)
    }
    init() {
        self.array = []
    }
    init(_ array: [Element]) {
        self.array = array
    }
    public init(arrayLiteral elements: Element...) {
        self.array = elements
    }
    
}
extension RefferenceArray {
    func append(_ newElement: Element) {
        array.append(newElement)
    }
    func removeAll() {
        array.removeAll()
    }
    func remove(at index: Index) {
        array.remove(at: index)
    }
    func remove(at indices: [Index]) { // O(self.coun)
        let indices_set = Set(indices)
        array = array
            .enumerated()
            .filter{ !indices_set.contains($0.offset) }
            .map({ $0.element })
    }
}
extension RefferenceArray: CustomStringConvertible {
    public var description: String {array.description}
}
