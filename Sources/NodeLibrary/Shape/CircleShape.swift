//
//  CircleShape.swift
//  NodeDomain
//
//  Created by Jure Mocnik Berljavac on 03/11/2021.
//
extension BaseDomainShape where Self == CircleShape {
    public static func circle(centre: Point, radius: Double) -> CircleShape{
        return CircleShape(centre: centre, radius: radius)
    }
}

public struct CircleShape: DomainShape {
    public let centre: Point
    public let radius: Double
    var dr: Double
    public let bounds: Bounds
    
    init(centre: Point, radius: Double, tolerance: Double = 0.001) {
        assert(radius > 0)
        self.centre = centre
        self.radius = radius
        self.dr = radius * tolerance
        self.bounds = Bounds(xLow: centre.x - radius, xHigh: centre.x + radius, yLow: centre.y - radius, yHigh: centre.y + radius)
    }
    
    public func boundaryContains(point: Point) -> Bool {
        let node_radius = (point - centre).abs
        switch node_radius {
        case radius-dr...radius+dr:
            return true
        default:
            return false
        }
    }
    
    public func interiorContains(point: Point) -> Bool {
        let node_radius = (point - centre).abs
        switch node_radius {
        case 0...radius:
            return true
        default:
            return false
        }
        
    }
}
