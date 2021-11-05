//
//  CompositShape.swift
//  NodeDomain
//
//  Created by Jure Mocnik Berljavac on 03/11/2021.
//

extension DomainShape {
    func add<S: DomainShape> (_ other: S) -> some DomainShape {
        return UnionShape(base: self, other: other)
    }
    
    func substract<S: DomainShape> (_ other: S) -> some DomainShape {
        return DifferenceShape(base: self, other: other)
    }
}

func +<S1, S2>(lhs:S1, rhs: S2) -> some DomainShape where S1: DomainShape, S2: DomainShape {
    return lhs.add(rhs)
}

func -<S1, S2>(lhs:S1, rhs: S2) -> some DomainShape where S1: DomainShape, S2: DomainShape {
    return lhs.substract(rhs)
}

fileprivate struct UnionShape<S1: DomainShape, S2: DomainShape>: DomainShape {
    private let base: S1
    private let other: S2
    let bounds: Bounds
    
    init(base: S1, other: S2) {
        self.base = base
        self.other = other
        self.bounds = Bounds(xLow: min(base.bounds.xLow, other.bounds.xLow), xHigh: max(base.bounds.xHigh, other.bounds.xHigh), yLow: min(base.bounds.yLow, other.bounds.yLow), yHigh: max(base.bounds.yHigh, other.bounds.yHigh))
    }
    
    func boundaryContains(point: Point) -> Bool {
        let shape1Boundary = base.boundaryContains(point: point) && !other.interiorContains(point: point)
        let shape2Boundary = other.boundaryContains(point: point) && !base.interiorContains(point: point)
        return shape1Boundary || shape2Boundary
            
    }
    
    func interiorContains(point: Point) -> Bool {
        return base.interiorContains(point: point) || other.interiorContains(point: point)
    }
}
fileprivate struct DifferenceShape<S1: DomainShape, S2: DomainShape>: DomainShape {
    private let base: S1
    private let other: S2
    let bounds: Bounds
    
    init(base: S1, other: S2) {
        self.base = base
        self.other = other
        self.bounds = Bounds(xLow: min(base.bounds.xLow, other.bounds.xLow), xHigh: max(base.bounds.xHigh, other.bounds.xHigh), yLow: min(base.bounds.yLow, other.bounds.yLow), yHigh: max(base.bounds.yHigh, other.bounds.yHigh))
    }
    
    func boundaryContains(point: Point) -> Bool {
        let shape1Boundary = base.boundaryContains(point: point) && !other.interiorContains(point: point)
        let shape2Boundary = other.boundaryContains(point: point) && base.interiorContains(point: point)
        return shape1Boundary || shape2Boundary
            
    }
    
    func interiorContains(point: Point) -> Bool {
        return base.interiorContains(point: point) && !other.interiorContains(point: point)
    }
}
