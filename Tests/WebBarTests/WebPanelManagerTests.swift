import AppKit
import XCTest
@testable import WebBar

@MainActor
final class WebPanelManagerTests: XCTestCase {
    func testOpeningSecondPanelHidesFirstPanel() {
        let firstLink = LinkItem(urlString: "https://deepseek.com", openMode: .embeddedPanel, reopenBehavior: .restoreLastPage)
        let secondLink = LinkItem(urlString: "https://doubao.com", openMode: .embeddedPanel, reopenBehavior: .restoreLastPage)

        let firstPanel = MockPanelController(urlString: firstLink.urlString)
        let secondPanel = MockPanelController(urlString: secondLink.urlString)
        let createdPanels: [UUID: MockPanelController] = [
            firstLink.id: firstPanel,
            secondLink.id: secondPanel
        ]

        let manager = WebPanelManager(
            sessionStore: WebSessionStore(),
            openExternalURL: { _ in },
            panelFactory: { link, _, _ in
                createdPanels[link.id]
            }
        )

        manager.toggle(link: firstLink, relativeTo: nil)
        manager.toggle(link: secondLink, relativeTo: nil)

        XCTAssertEqual(firstPanel.toggleCount, 1)
        XCTAssertEqual(firstPanel.hideCount, 1)
        XCTAssertEqual(secondPanel.toggleCount, 1)
    }

    func testChangingReopenBehaviorRebuildsPanel() {
        let link = LinkItem(urlString: "https://chatgpt.com", openMode: .embeddedPanel, reopenBehavior: .restoreLastPage)
        let updatedLink = LinkItem(
            id: link.id,
            name: link.name,
            urlString: link.urlString,
            iconPreference: link.iconPreference,
            openMode: link.openMode,
            reopenBehavior: .homePage,
            createdAt: link.createdAt,
            updatedAt: link.updatedAt
        )

        let firstPanel = MockPanelController(signature: "\(link.urlString)|\(link.reopenBehavior.rawValue)")
        let secondPanel = MockPanelController(signature: "\(updatedLink.urlString)|\(updatedLink.reopenBehavior.rawValue)")
        var factoryCalls = 0

        let manager = WebPanelManager(
            sessionStore: WebSessionStore(),
            openExternalURL: { _ in },
            panelFactory: { requestedLink, _, _ in
                defer { factoryCalls += 1 }
                return requestedLink.reopenBehavior == .restoreLastPage ? firstPanel : secondPanel
            }
        )

        manager.toggle(link: link, relativeTo: nil)
        manager.toggle(link: updatedLink, relativeTo: nil)

        XCTAssertEqual(factoryCalls, 2)
        XCTAssertEqual(firstPanel.hideCount, 1)
        XCTAssertEqual(secondPanel.toggleCount, 1)
    }

    func testHideAllHidesEveryExistingPanel() {
        let firstLink = LinkItem(urlString: "https://deepseek.com", openMode: .embeddedPanel)
        let secondLink = LinkItem(urlString: "https://doubao.com", openMode: .embeddedPanel)
        let firstPanel = MockPanelController(signature: "\(firstLink.urlString)|\(firstLink.reopenBehavior.rawValue)")
        let secondPanel = MockPanelController(signature: "\(secondLink.urlString)|\(secondLink.reopenBehavior.rawValue)")
        let createdPanels: [UUID: MockPanelController] = [
            firstLink.id: firstPanel,
            secondLink.id: secondPanel
        ]

        let manager = WebPanelManager(
            sessionStore: WebSessionStore(),
            openExternalURL: { _ in },
            panelFactory: { link, _, _ in
                createdPanels[link.id]
            }
        )

        manager.toggle(link: firstLink, relativeTo: nil)
        manager.toggle(link: secondLink, relativeTo: nil)
        manager.hideAll()

        XCTAssertEqual(firstPanel.hideCount, 2)
        XCTAssertEqual(secondPanel.hideCount, 1)
    }
}

@MainActor
private final class MockPanelController: WebPanelControlling {
    let representedLinkSignature: String
    var toggleCount = 0
    var hideCount = 0

    init(urlString: String) {
        self.representedLinkSignature = urlString
    }

    init(signature: String) {
        self.representedLinkSignature = signature
    }

    func toggle(relativeTo button: NSStatusBarButton?) {
        toggleCount += 1
    }

    func hide() {
        hideCount += 1
    }
}
