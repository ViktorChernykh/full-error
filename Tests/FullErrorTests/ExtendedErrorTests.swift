@testable import FullError
import XCTest

final class FullErrorTests: XCTestCase {
    static var allTests = [
        ("testFullError", testFullError),
    ]
    
    func testFullError() {
        let error = ErrorResponse(code: "emailIsAlreadyConfirmed", reason: "Email is already connected with other account.", failures: nil)
        
        XCTAssertEqual(error.code, "emailIsAlreadyConfirmed")
    }
}
