import XCTest
@testable import WebBar

final class ValidationTests: XCTestCase {
    private let validator = LinkValidator()

    func testAcceptsURLsWithDifferentSchemes() throws {
        XCTAssertNoThrow(try validator.validateURLString("https://example.com"))
        XCTAssertNoThrow(try validator.validateURLString("http://example.com"))
        XCTAssertNoThrow(try validator.validateURLString("mailto:hello@example.com"))
        XCTAssertNoThrow(try validator.validateURLString("obsidian://open?vault=notes"))
    }

    func testRejectsEmptyURL() {
        XCTAssertThrowsError(try validator.validateURLString("   ")) { error in
            XCTAssertEqual(error as? LinkValidationError, .emptyURL)
        }
    }

    func testRejectsMalformedURL() {
        XCTAssertThrowsError(try validator.validateURLString("not a url")) { error in
            XCTAssertEqual(error as? LinkValidationError, .missingScheme)
        }
    }

    func testCreateValidationNoLongerLimitsCount() throws {
        XCTAssertNoThrow(try validator.validateCreate(urlString: "https://a.com", currentCount: 5))
        XCTAssertNoThrow(try validator.validateCreate(urlString: "https://a.com", currentCount: 50))
    }
}
