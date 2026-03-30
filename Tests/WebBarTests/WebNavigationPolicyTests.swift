import XCTest
@testable import WebBar

final class WebNavigationPolicyTests: XCTestCase {
    func testTargetBlankHttpURLLoadsInCurrentPanel() throws {
        let url = try XCTUnwrap(URL(string: "https://chat.deepseek.com/sign-in"))

        XCTAssertTrue(WebNavigationPolicy.shouldLoadInCurrentPanel(url: url, targetIsMainFrame: false))
        XCTAssertFalse(WebNavigationPolicy.shouldOpenExternally(url: url, targetIsMainFrame: false))
    }

    func testCustomSchemeStillOpensExternally() throws {
        let url = try XCTUnwrap(URL(string: "obsidian://open"))

        XCTAssertFalse(WebNavigationPolicy.shouldLoadInCurrentPanel(url: url, targetIsMainFrame: false))
        XCTAssertTrue(WebNavigationPolicy.shouldOpenExternally(url: url, targetIsMainFrame: false))
    }
}
