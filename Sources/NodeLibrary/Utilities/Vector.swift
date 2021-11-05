public struct Vec<T: FloatingPoint> {
    var _data: [T]
    subscript(index: Int) -> T {
        get {
            _data[index]
        }
        set {
            _data[index] = newValue
        }
    }
    func dot(other: Vec) -> T {
        guard self._data.count == other._data.count else {
            fatalError()
        }
        var result: T = .zero
        for i in 0..<self._data.count {
            result += self._data[i]*other._data[i]
        }
        return result
    }
}
func +=<T: AdditiveArithmetic>(lhs: inout Vec<T>, rhs: Vec <T>) {
    for i in 0..<lhs._data.count {
        lhs[i] += rhs[i]
    }
}
func +<T: AdditiveArithmetic>(lhs: Vec<T>, rhs: Vec <T>) ->Vec<T> {
    var result = Vec(_data: [T](repeating: T.zero, count: lhs._data.count))
    for i in 0..<lhs._data.count {
        result[i] = lhs[i] + rhs[i]
    }
    return result
}
