//
//  Operators_new.swift
//  NodeDomain
//
//  Created by Jure Mocnik Berljavac on 31/10/2021.
//


public protocol CustomOperatorProtocol: Hashable {
    func getCoefs<E: BaseGroupProtocol, S: BaseDomainShape>(atIndex index: Int, from domain: Domain<E,S>) -> Vec<Double>
}
public enum Axis {
    case x, y
}
public enum SelectOp<CustomOp: CustomOperatorProtocol> {
    case id
    case der1(Axis)
    case der2(Axis)
    case lap
    case custom(CustomOp)
}

public struct DifferentialOperator<CustomOp: CustomOperatorProtocol>: Hashable {
    let type: OperatorEnum
    let axis: Axis?
    let custom: CustomOp?
    var set: Set<DifferentialOperator>
    
    public init(_ op: SelectOp<CustomOp>, subOps: Set<DifferentialOperator> = []) {
        set = subOps
        switch op {
        case .id:
            type = .id
            axis = nil
            custom = nil
        case .der1(let ax):
            type = .der1
            axis = ax
            custom = nil
        case .der2(let ax):
            type = .der2
            axis = ax
            custom = nil
        case .lap:
            type = .lap
            axis = nil
            custom = nil
        case .custom(let customOp):
            type = .custom
            axis = nil
            custom = customOp
        }
    }
    
    public init(_ op: SelectOp<CustomOp>) where CustomOp == DefaultOp {
        self.init(op, subOps: [])
        }
    
    internal func getCoefs<E, S>(atIndex index: Int, from domain: Domain<E, S>) -> Vec<Double> where E : BaseGroupProtocol, S : BaseDomainShape {
        switch type {
        case .custom:
            return custom!.getCoefs(atIndex: index, from: domain)
        default:
            return type.getCoefs(atIndex: index, from: domain)
        }
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
