//
//  DefaultOperators.swift
//  NodeDomain
//
//  Created by Jure Mocnik Berljavac on 03/11/2021.
//
public enum DefaultOp: CustomOperatorProtocol {
    public func getCoefs<E, S>(atIndex index: Int, from domain: Domain<E, S>) -> Vec<Double> where E : BaseGroupProtocol, S : BaseDomainShape {
        fatalError() // should never be called
    }
}

enum OperatorEnum {
    case id
    case der1
    case der2
    case lap
    case custom
    
    func getCoefs<E: BaseGroupProtocol, S: BaseDomainShape>(atIndex index: Int, from domain: Domain<E,S>) -> Vec<Double> {
        switch self {
        case .id:
            let neigbours = domain.getNeigboursIndices(forIndex: index)
            let coefs = Vec(_data: Array(repeating: 0.0, count: neigbours.count))
            return coefs // fix!
        case .der1:
            let neigbours = domain.getNeigboursIndices(forIndex: index)
            // let coefs = Vec([0, 0, 0.. node.neigbours.count ])
            let coefs = Vec(_data: Array(repeating: 1.0, count: neigbours.count))
            // for index in 0..<node.neigbours.count
                //node.getStructure() // from neigbours positions
                //coefs[index] = CoefFromStructureForDer2(Axis)
            return coefs
        case .der2:
            let neigbours = domain.getNeigboursIndices(forIndex: index)
            // let coefs = Vec([0, 0, 0.. node.neigbours.count ])
            let coefs = Vec(_data: Array(repeating: 1.0, count: neigbours.count))
            // for index in 0..<node.neigbours.count
                //node.getStructure() // from neigbours positions
                //coefs[index] = CoefFromStructureForDer2(Axis)
            return coefs
        case .lap:
            return DifferentialOperator(.der2(.x)).getCoefs(atIndex: index, from: domain) + DifferentialOperator(.der2(.y)).getCoefs(atIndex: index, from: domain)
        case .custom:
            fatalError() // no implementation here
        }
    }
}
