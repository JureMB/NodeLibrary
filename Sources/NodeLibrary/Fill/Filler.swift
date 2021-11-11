//
//  Fill.swift
//  NodeDomain
//
//  Created by Jure Mocnik Berljavac on 18/09/2021.
//
public protocol Fillable: BaseDomainShape {
    associatedtype CostomFiller: BaseFiller<Self>
    func getFiller() -> CostomFiller
}

extension DomainShape {
    func getFiller() -> GeneralFiller<Self> {
        return GeneralFiller(shape: self)
    }
}

public enum SwitchFiller<S:DomainShape> {
    case generalFiller
    case seccondGeneralFiller
    case customGeneralFiller(fillerType: GeneralFiller<S>.Type)
    case shapeSpecifiedFiller
    case completlyCostomFiller(filler: BaseFiller<S>)
}

public enum FillBy {
    case step(_ step: Double )
    case density(_ density: (Point) -> Double)
}

open class BaseFiller<S: BaseDomainShape> {
    func fillInterior<E>(of domain: Domain<E,S>, by fillBy: FillBy) where S: Fillable {
        fatalError("Override this method.")
    }
    
    func fillBoundary<E>(of domain: Domain<E,S>, by fillBy: FillBy) where S: Fillable {
        fatalError("Override this method.")
    }
}






