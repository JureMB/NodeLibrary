//
//  RectangleShape.swift
//  NodeDomain
//
//  Created by Jure Mocnik Berljavac on 03/11/2021.
//

extension BaseDomainShape where Self == RectangleShape {
    static func rectangle(start: Point, end: Point) -> RectangleShape{
        return RectangleShape(startPoint: start, endPoint: end)
    }
}

public struct RectangleShape: DomainShape {
    public let start: Point
    public let end: Point
    var dl: Double
    public let bounds: Bounds
    
    init(startPoint: Point, endPoint: Point, tolerance: Double = 0.001) {
        assert(endPoint.x > startPoint.x)
        assert(endPoint.y > startPoint.y)
        self.start = startPoint
        self.end = endPoint
        print("rectangle start", start)
        print("rectangle end", end)
//        print("id: ", id)
        self.dl = min(end.x-start.x, end.y-start.y) * tolerance
        self.bounds = Bounds(xLow: start.x, xHigh: end.x, yLow: start.x, yHigh: end.y)
    }
    
    public func boundaryContains(point: Point) -> Bool {
        let xNearStartRange = (start.x - dl)...(start.x + dl)
        let xNearEndRange = (end.x - dl)...(end.x + dl)
        let yNearStartRange = (start.y - dl)...(start.y + dl)
        let yNearEndRange = (end.y - dl)...(end.y + dl)
        
        switch (point.x, point.y) {
        case (xNearStartRange, start.y...end.y ):
            return true
        case (xNearEndRange, start.y...end.y ):
            return true
        case (start.x...end.x, yNearStartRange):
            return true
        case (start.x...end.x, yNearEndRange):
            return true
        default:
            return false
        }
    }
    
    public func interiorContains(point: Point) -> Bool {
        let xIsIn: Bool
        let yIsIn: Bool
        
        switch point.x {
        case start.x...end.x:
            xIsIn = true
        default:
            xIsIn = false
        }
//        print("y_start = ",start.y, "y_end=", end.y)
//        if start.y > 0.01 {fatalError()}
        switch point.y {
        case start.y...end.y:
            yIsIn = true
        default:
            yIsIn = false
        }
        
        return xIsIn && yIsIn
    }
}
