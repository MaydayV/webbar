import AppKit
import XCTest
@testable import WebBar

@MainActor
final class WebPanelMenuBuilderTests: XCTestCase {
    func testBuildsHiddenMenuWithNavigationActions() {
        let menu = WebPanelMenuBuilder().makeMenu(
            canGoBack: false,
            canGoForward: true,
            onBack: {},
            onForward: {},
            onRefresh: {},
            onReset: {}
        )

        XCTAssertEqual(menu.items.map { $0.title }, ["返回", "前进", "刷新", "重新登录"])
        XCTAssertFalse(try XCTUnwrap(menu.items.first as NSMenuItem?).isEnabled)
        XCTAssertTrue(try XCTUnwrap(menu.items.dropFirst().first as NSMenuItem?).isEnabled)
    }
}
