//
//  RectangleShapeFiller.swift
//  NodeDomain
//
//  Created by Jure Mocnik Berljavac on 03/11/2021.
//

class RectangleShapeFiller: BaseFiller<RectangleShape> {
    let rectangle: RectangleShape
    
    init(rectangle: RectangleShape) {
        self.rectangle = rectangle
    }
    
    override func fillInterior<E>(of domain: Domain<E,RectangleShape>,by fillBy: FillBy)  {
        fatalError("Rectangle Filler not implemented")
    }
    
    override func fillBoundary<E>(of domain: Domain<E,RectangleShape>,by fillBy: FillBy)  {
        fatalError("Rectangle Filler not implemented")
    }
}

extension RectangleShape {
    public func getFiller() -> some BaseFiller<Self> {
        return RectangleShapeFiller(rectangle: self)
    }
}
