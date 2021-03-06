//
//  ScalarField.swift
//  NodeDomain
//
//  Created by Jure Mocnik Berljavac on 10/10/2021.
//


public final class ScalarField<E:BaseGroupProtocol, S: BaseDomainShape, F: FieldProtocol>:  LHSFieldExplicit {
    private let coefPointer: UnsafeMutableBufferPointer<[Vec<Double>]>
    public var _data: DataActor
    private let _domain: Domain<E,S>
    fileprivate let _solver: Solver<E, S, F>
    
    let fieldID: F
    private let fieldIndex: Int
    var count: Int {_data.count}
    
    internal init(id: F, size: Int, solver: Solver<E,S,F>, domain: Domain<E,S>, coefsPointer: UnsafeMutableBufferPointer<[Vec<Double>]>) {
        _data = DataActor([Double](repeating: 0, count: size))
        _solver = solver
        self._domain = domain
        fieldID = id
        self.coefPointer = coefsPointer
        self.fieldIndex = solver.getFieldIndex(for: fieldID)
    }

    internal func overwrite(with newData: [Double]) async {
        await _data.overwrite(with: newData)
    }
    
    public func copy() async -> ScalarFieldRHS<E,S,F> {
        return await ScalarFieldRHS(_data.getCopy(), coefPointer: coefPointer, domain: _domain, field: self)
    }
    @inlinable
    public func update(clousure : @Sendable (inout [Double]) -> Void) async {
        await _data.update(clousre: clousure)
    }
    
    public func getData() async -> [Double] {
        return await _data.getCopy()
    }
}

public struct ScalarFieldRHS<E: BaseGroupProtocol, S: BaseDomainShape, F: FieldProtocol>: RHSField {
    private let _data: [Double]
    private let _coefPointer: UnsafeMutableBufferPointer<[Vec<Double>]>
    private let _domain: Domain<E, S>
    let field: ScalarField<E,S,F>
    
    fileprivate init(_ data: [Double], coefPointer: UnsafeMutableBufferPointer<[Vec<Double>]>, domain: Domain<E,S>, field: ScalarField<E,S,F>) {
        _data = data
        _coefPointer = coefPointer
        _domain = domain
        self.field = field
    }
    
    public subscript(index: Int) -> Double {
        _data[index]
    }
}

extension ScalarFieldRHS {
    func setCoefs(opIndex: Int, op: DifferentialOperator<DefaultOp>, atIndex index: Int) {
        if _coefPointer[index][opIndex]._data.isEmpty {
            let coefs = op.getCoefs(atIndex: index, from: _domain)
            _coefPointer[index][opIndex] = coefs
        }
    }
    
    func apply(opIndex: Int , atIndex index: Int) -> Double {
        if _coefPointer[index][opIndex]._data.isEmpty {
            fatalError()
        } else {
            var result = 0.0
            for element in _coefPointer[index][opIndex]._data {
                result += element * _data[index]
            }
            return result
        }
    }
}

extension ScalarFieldRHS {
    public func explicitOperatorField(_ op: DifferentialOperator<DefaultOp>) ->OperatorField<E,S, F> {
        return OperatorField(op: op, fieldRHS: self)
    }
    
    public func explicitOperatorField(_ clousure: ()->DifferentialOperator<DefaultOp> ) ->OperatorField<E,S, F> {
        return explicitOperatorField(clousure())
    }
    
    public func callAsFunction(_ op: DifferentialOperator<DefaultOp>) -> OperatorField<E,S, F> {
            return explicitOperatorField(op)
    }
    
    public func callAsFunction(_ clousure: ()->DifferentialOperator<DefaultOp>) -> OperatorField<E,S, F> {
            return explicitOperatorField(clousure())
    }
}

public struct OperatorField<E: BaseGroupProtocol, S: BaseDomainShape, F: FieldProtocol>: RHSField, Explicit {
    let op: DifferentialOperator<DefaultOp>
    private let opInddex: Int
    private let field: ScalarField<E,S,F>
    private let fieldRHS: ScalarFieldRHS<E,S,F>
    fileprivate init (op: DifferentialOperator<DefaultOp>, fieldRHS: ScalarFieldRHS<E,S,F>) {
        var tempIndex: Int?
        self.op = op
        self.fieldRHS = fieldRHS
        self.field = fieldRHS.field
        // get index from dictionary
        tempIndex = field._solver._OpIndices_new[op]
        
        if tempIndex == nil {
            opInddex = field._solver.addOperatorReturningIndex(op )
            setCoefs()
        } else {
            opInddex = tempIndex!
        }
    }
    
    public subscript(index: Int) -> Double {
        return fieldRHS.apply(opIndex: opInddex, atIndex: index)
    }
    
    func setCoefs() {
        for node in field._solver.all {
            setCoefs(at: node.index)
        }
    }
    
    func setCoefs(at index: Int) {
        fieldRHS.setCoefs(opIndex: opInddex, op: op, atIndex: index)
    }
    
    public func getData() async -> [Double] {
        return await field.getData()
    }
}

public struct AddedExplicitField<RHS1,RHS2>: RHSField where RHS1: RHSField, RHS2: RHSField {
    public let opField1: RHS1
    public let opField2: RHS2
    @inlinable
    public subscript(index: Int) -> Double {
        return opField1[index] + opField2[index]
    }
}

public func +<RHS1,RHS2>(lhs: RHS1, rhs: RHS2 ) -> AddedExplicitField<RHS1,RHS2>
where RHS1: RHSField, RHS2: RHSField {
    return AddedExplicitField(opField1: lhs, opField2: rhs)
}
