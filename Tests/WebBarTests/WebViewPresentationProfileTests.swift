import XCTest
@testable import WebBar

final class WebViewPresentationProfileTests: XCTestCase {
    func testUsesMobileUserAgentForCompactPanel() {
        let userAgent = WebViewPresentationProfile.userAgent(forWidth: 420)

        XCTAssertTrue(userAgent.contains("iPhone"))
        XCTAssertTrue(userAgent.contains("Mobile"))
    }

    func testViewportScriptInjectsDeviceWidthMetaTag() {
        let source = WebViewPresentationProfile.viewportScriptSource

        XCTAssertTrue(source.contains("meta[name=\"viewport\"]"))
        XCTAssertTrue(source.contains("width=device-width"))
        XCTAssertTrue(source.contains("initial-scale=1"))
    }
}
