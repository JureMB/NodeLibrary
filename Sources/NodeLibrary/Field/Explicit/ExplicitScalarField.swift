//
//  ScalarField.swift
//  NodeDomain
//
//  Created by Jure Mocnik Berljavac on 10/10/2021.
//


public final class ScalarField<E:BaseGroupProtocol, S: BaseDomainShape, F: FieldProtocol>:  LHSFieldExplicit {
    private let coefPointer: UnsafeMutableBufferPointer<[Vec<Double>]>
    private let _domain: Domain<E,S>
    private let fieldIndex: Int
    
    fileprivate let _solver: Solver<E, S, F>
    
    @usableFromInline
    internal var _data: DataActor
    
    public let fieldID: F
    public var count: Int {_data.count}
    
    internal init(id: F, size: Int, solver: Solver<E,S,F>, domain: Domain<E,S>,
                  coefsPointer: UnsafeMutableBufferPointer<[Vec<Double>]>) {
        self._data = DataActor([Double](repeating: 0, count: size))
        self._solver = solver
        self._domain = domain
        self.fieldID = id
        self.coefPointer = coefsPointer
        self.fieldIndex = solver.getFieldIndex(for: fieldID)
    }

    internal func overwrite(with newData: [Double]) async {
        await _data.overwrite(with: newData)
    }
    
    public func copy() async -> some RHSField {
        return await _copy()
    }
    
    internal func _copy() async -> ScalarFieldRHS<E,S,F> {
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

internal struct ScalarFieldRHS<E: BaseGroupProtocol, S: BaseDomainShape, F: FieldProtocol>: RHSField {
    private let _data: [Double]
    private let _coefPointer: UnsafeMutableBufferPointer<[Vec<Double>]>
    private let _domain: Domain<E, S>
    let field: ScalarField<E,S,F>
    
    fileprivate init(_ data: [Double], coefPointer: UnsafeMutableBufferPointer<[Vec<Double>]>,
                     domain: Domain<E,S>, field: ScalarField<E,S,F>) {
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
    
    @usableFromInline
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
    public func explicitOperatorField(_ op: DifferentialOperator<DefaultOp>) -> some RHSField {
        return OperatorField(op: op, fieldRHS: self, solver: field._solver)
    }
    
    public func explicitOperatorField(_ clousure: ()->DifferentialOperator<DefaultOp> )
    -> some RHSField {
        return explicitOperatorField(clousure())
    }
    
    public func callAsFunction(_ op: DifferentialOperator<DefaultOp>) -> some RHSField {
            return explicitOperatorField(op)
    }
    
    public func callAsFunction(_ clousure: ()->DifferentialOperator<DefaultOp>) -> some RHSField {
            return explicitOperatorField(clousure())
    }
}
extension ScalarField {
    public func explicitOperatorField(_ op: DifferentialOperator<DefaultOp>) async -> some RHSField {
        return OperatorField(op: op, fieldRHS: await _copy(), solver: _solver)
    }
    
    public func explicitOperatorField(_ clousure: ()->DifferentialOperator<DefaultOp> ) async
    -> some RHSField {
        return await explicitOperatorField(clousure())
    }
    
    public func callAsFunction(_ op: DifferentialOperator<DefaultOp>) async  -> some RHSField {
        return await explicitOperatorField(op)
    }
    
    public func callAsFunction(_ clousure: ()->DifferentialOperator<DefaultOp>) async
    -> some RHSField {
        return await explicitOperatorField(clousure())
    }
}

