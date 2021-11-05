public struct NodeLibrary {
    public private(set) var text = "Hello, World!"
    public private(set) var testIsTrue = true
    static func makeDomain() -> Domain<NoGroups,NoShape> {
        return Domain()
    }
    public init() {
    }
    
}
