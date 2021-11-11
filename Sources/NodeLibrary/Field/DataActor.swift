//
//  DataActor.swift
//  NodeDomain
//
//  Created by Jure Mocnik Berljavac on 03/11/2021.
//

// Helper actor to protect muttable state of 'Field' classes
@usableFromInline
internal actor DataActor: ExpressibleByArrayLiteral {
    private var _data: [Double]
    let count: Int
    
    init(_ data: [Double]) {
        _data = data
        count = data.count
    }
    
    public init(arrayLiteral elements: Double...) {
        _data = elements
        count = elements.count
    }
    
    subscript(index: Int) -> Double {
        get {
            _data[index]
        }
        set {
            _data[index] = newValue
        }
    }
    
    func getCopy() -> [Double] {
        return _data
    }
    
    func overwrite(with array: [Double]) {
        guard array.count == _data.count else {fatalError()}
        for (index, value) in array.enumerated() {
            _data[index] = value
        }
    }
    @usableFromInline
    internal func update(clousre: @Sendable (inout [Double]) -> ()) {
        clousre(&_data)
    }
}
