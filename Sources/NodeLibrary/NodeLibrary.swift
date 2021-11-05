public struct NodeLibrary {
    public private(set) var text = "Hello, World!"
    static func makeDomain() -> Domain<NoGroups,NoShape> {
        return Domain()
    }
    public init() {
    }
    
}
