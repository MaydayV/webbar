import Foundation
import XCTest
@testable import WebBar

final class WebPanelReopenPolicyTests: XCTestCase {
    func testRestoreLastPageOnlyLoadsHomeWhenWebViewHasNotLoadedYet() {
        XCTAssertTrue(WebPanelReopenPolicy.shouldLoadInitialURL(currentURL: nil, behavior: .restoreLastPage))
        XCTAssertFalse(
            WebPanelReopenPolicy.shouldLoadInitialURL(
                currentURL: URL(string: "https://chatgpt.com/conversation"),
                behavior: .restoreLastPage
            )
        )
    }

    func testHomePageAlwaysLoadsConfiguredURLAgain() {
        XCTAssertTrue(WebPanelReopenPolicy.shouldLoadInitialURL(currentURL: nil, behavior: .homePage))
        XCTAssertTrue(
            WebPanelReopenPolicy.shouldLoadInitialURL(
                currentURL: URL(string: "https://chatgpt.com/conversation"),
                behavior: .homePage
            )
        )
    }
}
