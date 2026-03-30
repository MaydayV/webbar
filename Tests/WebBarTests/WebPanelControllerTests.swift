import AppKit
import XCTest
@testable import WebBar

@MainActor
final class WebPanelControllerTests: XCTestCase {
    func testWindowCloseButtonHidesPanelInsteadOfDestroyingIt() throws {
        let suiteName = UUID().uuidString
        let defaults = UserDefaults(suiteName: suiteName)!
        defer { defaults.removePersistentDomain(forName: suiteName) }

        let store = WebSessionStore(
            defaults: defaults,
            rootDirectoryURL: FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString, isDirectory: true)
        )
        let controller = try WebPanelController(
            id: UUID(),
            url: try XCTUnwrap(URL(string: "https://example.com")),
            reopenBehavior: .restoreLastPage,
            sessionStore: store,
            openExternalURL: { _ in }
        )

        controller.toggle(relativeTo: nil)
        let window = try XCTUnwrap(controller.window)
        XCTAssertTrue(window.isVisible)

        let shouldClose = controller.windowShouldClose(window)

        XCTAssertFalse(shouldClose)
        XCTAssertNotNil(controller.window)
        XCTAssertFalse(controller.window?.isVisible ?? true)
    }

    func testFirstClickAfterDeactivateShowsPanelAgain() throws {
        let suiteName = UUID().uuidString
        let defaults = UserDefaults(suiteName: suiteName)!
        defer { defaults.removePersistentDomain(forName: suiteName) }

        let store = WebSessionStore(
            defaults: defaults,
            rootDirectoryURL: FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString, isDirectory: true)
        )
        let controller = try WebPanelController(
            id: UUID(),
            url: try XCTUnwrap(URL(string: "https://example.com")),
            reopenBehavior: .restoreLastPage,
            sessionStore: store,
            openExternalURL: { _ in }
        )

        controller.toggle(relativeTo: nil)
        let window = try XCTUnwrap(controller.window)
        XCTAssertTrue(window.isVisible)

        controller.windowDidResignKey(Notification(name: NSWindow.didResignKeyNotification, object: window))
        controller.toggle(relativeTo: nil)

        XCTAssertTrue(window.isVisible)
    }
}
