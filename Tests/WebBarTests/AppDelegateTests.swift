import AppKit
import XCTest
@testable import WebBar

@MainActor
final class AppDelegateTests: XCTestCase {
    func testMenuBarAppDoesNotTerminateWhenLastWindowCloses() {
        let delegate = AppDelegate()
        let application = NSApplication.shared

        XCTAssertFalse(delegate.applicationShouldTerminateAfterLastWindowClosed(application))
    }
}
