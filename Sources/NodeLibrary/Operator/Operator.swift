//
//  Operators_new.swift
//  NodeDomain
//
//  Created by Jure Mocnik Berljavac on 31/10/2021.
//


public protocol OperatorProtocol: Hashable {
    func getCoefs<E,S>(atIndex index: Int, from domain: Domain<E,S>) -> Vec<Double>
    where E: BaseGroupProtocol, S: BaseDomainShape
}

public enum Axis: Hashable {
    case x, y
}

public enum SelectOp<CustomOp: OperatorProtocol>: OperatorProtocol {
    case id
    case der1(Axis)
    case der2(Axis)
    case lap
    case custom(CustomOp)
    
    public func getCoefs<E: BaseGroupProtocol, S: BaseDomainShape>(atIndex index: Int, from domain: Domain<E,S>) -> Vec<Double> {
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
        case .custom (let customOp):
            return customOp.getCoefs(atIndex: index, from: domain) // no implementation here
        }
    }
}

public struct DifferentialOperator<CustomOp: OperatorProtocol>: Hashable {
    public let op: SelectOp<CustomOp>
    public var set: Set<DifferentialOperator>
    
    public init(_ op: SelectOp<CustomOp>, subOps: Set<DifferentialOperator> = []) {
        self.set = subOps
        self.op = op
    }
    
    public init(_ op: SelectOp<CustomOp>) where CustomOp == DefaultOp {
        self.init(op, subOps: [])
        }
    
    internal func getCoefs<E, S>(atIndex index: Int, from domain: Domain<E, S>) -> Vec<Double> where E : BaseGroupProtocol, S : BaseDomainShape {
        return op.getCoefs(atIndex: index, from: domain)
    }
    
    internal mutating func multiply(by op: DifferentialOperator) {
        if set.isEmpty {
            self.set.update(with: op)
        } else {
            var op_array = Array(set)
            for (index, _) in op_array.enumerated() {
                op_array[index].multiply(by: op)
            }
            set = Set(op_array)
        }
    }
}

// sugar for call site
extension DifferentialOperator {
    public static var lap:   DifferentialOperator { .init(.lap)      }
    public static var id:    DifferentialOperator { .init(.id)       }
    public static var der1x: DifferentialOperator { .init(.der1(.x)) }
    public static var der1y: DifferentialOperator { .init(.der1(.y)) }
    public static var der2x: DifferentialOperator { .init(.der2(.x)) }
    public static var der2y: DifferentialOperator { .init(.der2(.y)) }
}

public func +<C>(lhs: DifferentialOperator<C>, rhs: DifferentialOperator<C> ) -> DifferentialOperator<C>{
    return DifferentialOperator<C>(.id, subOps: [lhs, rhs])
}

public func *<C>(lhs: DifferentialOperator<C>, rhs: DifferentialOperator<C> ) -> DifferentialOperator<C> {
    var result = lhs
    result.multiply(by: rhs)
    return result
}
