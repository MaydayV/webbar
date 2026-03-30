import AppKit
import XCTest
@testable import WebBar

final class LinkOpenDispatcherTests: XCTestCase {
    private struct MockOpener: URLOpener {
        var didOpen = false
        func open(_ url: URL) -> Bool { didOpen }
    }

    @MainActor
    private final class MockPresenter: EmbeddedLinkPresenting {
        var toggledLinkID: UUID?

        func toggle(link: LinkItem, relativeTo button: NSStatusBarButton?) {
            toggledLinkID = link.id
        }
    }

    @MainActor
    func testDefaultBrowserModeUsesURLOpener() {
        let presenter = MockPresenter()
        let dispatcher = LinkOpenDispatcher(
            urlOpener: MockOpener(didOpen: true),
            embeddedPresenter: presenter
        )
        let link = LinkItem(urlString: "https://example.com", openMode: .defaultBrowser)

        XCTAssertTrue(dispatcher.open(link: link, relativeTo: nil))
        XCTAssertNil(presenter.toggledLinkID)
    }

    @MainActor
    func testEmbeddedModeTogglesPresenter() {
        let presenter = MockPresenter()
        let dispatcher = LinkOpenDispatcher(
            urlOpener: MockOpener(didOpen: false),
            embeddedPresenter: presenter
        )
        let link = LinkItem(urlString: "https://example.com", openMode: .embeddedPanel)

        XCTAssertTrue(dispatcher.open(link: link, relativeTo: nil))
        XCTAssertEqual(presenter.toggledLinkID, link.id)
    }

    @MainActor
    func testInvalidURLReturnsFalse() {
        let presenter = MockPresenter()
        let dispatcher = LinkOpenDispatcher(
            urlOpener: MockOpener(didOpen: true),
            embeddedPresenter: presenter
        )
        let link = LinkItem(urlString: "", openMode: .defaultBrowser)

        XCTAssertFalse(dispatcher.open(link: link, relativeTo: nil))
        XCTAssertNil(presenter.toggledLinkID)
    }
}
