import XCTest
@testable import PortalView

class PortalViewTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        XCTAssertEqual(PortalView().text, "Hello, World!")
    }


    static var allTests : [(String, (PortalViewTests) -> () throws -> Void)] {
        return [
            ("testExample", testExample),
        ]
    }
}
