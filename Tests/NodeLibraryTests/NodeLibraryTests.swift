import XCTest
@testable import NodeLibrary

final class NodeLibraryTests: XCTestCase {
    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(NodeLibrary().text, "Hello, World!")
        XCTAssertEqual(NodeLibrary().testIsTrue, true)
    }
}
