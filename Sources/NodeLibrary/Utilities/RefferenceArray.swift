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

//extension RefferenceArray {
//    func lazyZip(with other: RefferenceArray<Element>) -> LazyRefererenceArray<(Element, Element), Element> {
//        return LazyRefererenceArray(start: self.startIndex, end: self.endIndex) { (index) -> (Element, Element) in
////            print("zipping")
//            return (self[index], other[index])
//        }
//    }
//    func add(_ other: RefferenceArray<Element>) -> LazyRefererenceArray<Element, Element> where Element: AdditiveArithmetic {
//        return self.lazyZip(with: other).lazyMap { $0 + $1 }
//    }
//}

//class LazyRefererenceArray<Element, BaseElement>: Collection {
//    typealias Index = Int
////    private var _storage = [RefferenceArray<BaseElement>]()
//    @inline(__always)
//    private var _clousure: (Index) -> Element
//    init(start: Int, end: Int, clousure: @escaping (Index)->Element) {
//        _clousure = clousure
//        startIndex = start
//        endIndex = end
//    }
//    var startIndex: Index
//    var endIndex: Index
//    @inline(__always)
//    subscript(position: Index) -> Element {
//        get {
//            _clousure(position)
//        }
//    }
//    func index(after i: Index) -> Index {
//        return i + 1
//    }
//    @inline(__always)
//    func lazyZip<C: RefferenceArray<BaseElement>>(with other: C) -> LazyRefererenceArray<(Element, BaseElement), BaseElement> {
//        return LazyRefererenceArray<(Element, BaseElement), BaseElement>(start: self.startIndex, end: self.endIndex) { index -> (Element, BaseElement) in
////            print("ziping the lazy array..")
//            let oldElement = self._clousure(index)
//            return (oldElement,  other[index])
//        }
//    }
//    @inline(__always)
//    func lazyZip<C: LazyRefererenceArray<BaseElement, Element>>(with other: C) -> LazyRefererenceArray<(Element, BaseElement), BaseElement> {
//        return LazyRefererenceArray<(Element, BaseElement), BaseElement>(start: self.startIndex, end: self.endIndex) { index -> (Element, BaseElement) in
////            print("ziping the lazy array..")
//            let oldElement = self._clousure(index)
//            return (oldElement,  other[index])
//        }
//    }
//    @inline(__always)
//    func lazyMap<T>(map: @escaping (Element) -> T) -> LazyRefererenceArray<T, BaseElement>{
//        return LazyRefererenceArray<T, BaseElement>(start: self.startIndex, end: self.endIndex) { index -> T in
////            print("maping")
//            let element = self._clousure(index)
//            return map(element)
//        }
//    }
//    @inline(__always)
//    func add(_ other: RefferenceArray<BaseElement>) -> LazyRefererenceArray<Element, Element> where BaseElement: AdditiveArithmetic, Element==BaseElement {
//        return self.lazyZip(with: other).lazyMap { $0 + $1 }
//    }
//    @inline(__always)
//    func add(_ other: LazyRefererenceArray<Element, BaseElement>) -> LazyRefererenceArray<Element, Element> where BaseElement: AdditiveArithmetic, Element==BaseElement {
//        return self.lazyZip(with: other).lazyMap { $0 + $1 }
//    }
//    @inline(__always)
//    func multiply(_ other: LazyRefererenceArray<Element, BaseElement>) -> LazyRefererenceArray<Element, Element> where BaseElement: FloatingPoint, Element==BaseElement {
//        return self.lazyZip(with: other).lazyMap { $0 * $1 }
//    }
//}
//@inline(__always)
//func +<T>(lhs: LazyRefererenceArray<T, T>, rhs: LazyRefererenceArray<T, T>) -> LazyRefererenceArray<T, T> where T: AdditiveArithmetic{
//    return lhs.add(rhs)
//}
//@inline(__always)
//func .*<T>(lhs: LazyRefererenceArray<T, T>, rhs: LazyRefererenceArray<T, T>) -> LazyRefererenceArray<T, T> where T: FloatingPoint{
//    return lhs.multiply(rhs)
//}
