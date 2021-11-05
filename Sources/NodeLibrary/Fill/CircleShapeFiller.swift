//
//  CircleShapeFiller.swift
//  NodeDomain
//
//  Created by Jure Mocnik Berljavac on 03/11/2021.
//

class CircleShapeFiller: BaseFiller<CircleShape> {
    let circle: CircleShape
    
    init(circle: CircleShape) {
        self.circle = circle
    }
    override func fillInterior<E>(of domain: Domain<E,CircleShape>, by fillBy: FillBy) {
        fatalError("Circle Filler not implemented")
    }
    override func fillBoundary<E>(of domain: Domain<E,CircleShape>, by fillBy: FillBy)  {
        fatalError("Circle Filler not implemented")
    }
}

extension CircleShape {
    public func getFiller() -> some BaseFiller<Self> {
        return CircleShapeFiller(circle: self)
    }
}
