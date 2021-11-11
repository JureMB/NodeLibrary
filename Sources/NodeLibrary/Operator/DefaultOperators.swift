//
//  DefaultOperators.swift
//  NodeDomain
//
//  Created by Jure Mocnik Berljavac on 03/11/2021.
//
public enum DefaultOp: OperatorProtocol {
    public func getCoefs<E, S>(atIndex index: Int, from domain: Domain<E, S>) -> Vec<Double> where E : BaseGroupProtocol, S : BaseDomainShape {
        fatalError() // should never be called
    }
}
