//
//  DomainShape.swift
//  NodeDomain
//
//  Created by Jure Mocnik Berljavac on 18/09/2021.
//

import Foundation

public protocol BaseDomainShape {}

public struct NoShape: BaseDomainShape {}

public protocol DomainShape: Fillable { //implicitly conforms to BaseDomainShape
    var bounds: Bounds { get }
    func boundaryContains(point: Point) -> Bool
    func interiorContains(point: Point) -> Bool
}

public struct Bounds {
    let xLow:Double
    let xHigh: Double
    let yLow: Double
    let yHigh: Double
}





