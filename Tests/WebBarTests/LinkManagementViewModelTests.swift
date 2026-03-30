import Foundation
import XCTest
@testable import WebBar

final class LinkManagementViewModelTests: XCTestCase {
    private final class InMemoryStore: LinkStore {
        var links: [LinkItem] = []

        func load() throws -> [LinkItem] { links }
        func save(_ links: [LinkItem]) throws { self.links = links }

        func append(_ link: LinkItem) throws -> [LinkItem] {
            links.append(link)
            return links
        }

        func update(_ link: LinkItem) throws -> [LinkItem] {
            guard let index = links.firstIndex(where: { $0.id == link.id }) else {
                throw LinkStoreError.notFound
            }
            links[index] = link
            return links
        }

        func delete(id: UUID) throws -> [LinkItem] {
            links.removeAll { $0.id == id }
            return links
        }
    }

    private final class FailingStore: LinkStore {
        struct Failure: LocalizedError {
            var errorDescription: String? { "broken store" }
        }

        func load() throws -> [LinkItem] { throw Failure() }
        func save(_ links: [LinkItem]) throws {}
        func append(_ link: LinkItem) throws -> [LinkItem] { throw Failure() }
        func update(_ link: LinkItem) throws -> [LinkItem] { throw Failure() }
        func delete(id: UUID) throws -> [LinkItem] { throw Failure() }
    }

    private final class MockLaunchService: LaunchAtLoginServing {
        var isEnabled: Bool = false
        func setEnabled(_ enabled: Bool) {
            isEnabled = enabled
        }
    }

    @MainActor
    func testAddAndDeleteFlow() throws {
        let store = InMemoryStore()
        let launch = MockLaunchService()
        let vm = LinkManagementViewModel(store: store, launchService: launch)

        vm.addLink(from: LinkDraft(name: "A", urlString: "https://a.com", emoji: "👌", openMode: .embeddedPanel, reopenBehavior: .homePage))
        XCTAssertEqual(vm.links.count, 1)
        XCTAssertNil(vm.errorMessage)
        XCTAssertEqual(vm.links.first?.openMode, .embeddedPanel)
        XCTAssertEqual(vm.links.first?.reopenBehavior, .homePage)

        let id = try XCTUnwrap(vm.links.first?.id)
        vm.deleteLink(id: id)
        XCTAssertEqual(vm.links.count, 0)
    }

    @MainActor
    func testInvalidURLShowsErrorMessage() {
        let store = InMemoryStore()
        let launch = MockLaunchService()
        let vm = LinkManagementViewModel(store: store, launchService: launch)

        vm.addLink(from: LinkDraft(name: "", urlString: "not a url", emoji: "👌", openMode: .defaultBrowser, reopenBehavior: .restoreLastPage))
        XCTAssertNotNil(vm.errorMessage)
    }

    @MainActor
    func testAddSupportsMoreThanFiveLinks() {
        let store = InMemoryStore()
        let launch = MockLaunchService()
        let vm = LinkManagementViewModel(store: store, launchService: launch)

        (0..<7).forEach { index in
            vm.addLink(from: LinkDraft(name: "L\(index)", urlString: "https://\(index).example.com", emoji: "👌", openMode: .defaultBrowser, reopenBehavior: .restoreLastPage))
        }

        XCTAssertEqual(vm.links.count, 7)
        XCTAssertNil(vm.errorMessage)
    }

    @MainActor
    func testUpdateCanSwitchOpenMode() throws {
        let store = InMemoryStore()
        let launch = MockLaunchService()
        let vm = LinkManagementViewModel(store: store, launchService: launch)

        vm.addLink(from: LinkDraft(name: "Chat", urlString: "https://chatgpt.com", emoji: "👌", openMode: .defaultBrowser, reopenBehavior: .restoreLastPage))
        let id = try XCTUnwrap(vm.links.first?.id)

        vm.updateLink(
            id: id,
            draft: LinkDraft(name: "Chat", urlString: "https://chatgpt.com", emoji: "👌", openMode: .embeddedPanel, reopenBehavior: .homePage)
        )

        XCTAssertEqual(vm.links.first?.openMode, .embeddedPanel)
        XCTAssertEqual(vm.links.first?.reopenBehavior, .homePage)
    }

    @MainActor
    func testToggleLaunchAtLoginUpdatesState() {
        let store = InMemoryStore()
        let launch = MockLaunchService()
        let vm = LinkManagementViewModel(store: store, launchService: launch)

        XCTAssertFalse(vm.launchAtLoginEnabled)
        vm.setLaunchAtLogin(enabled: true)
        XCTAssertTrue(vm.launchAtLoginEnabled)
    }

    @MainActor
    func testLoadFailureStillPublishesEmptyLinksForFallbackStatusItem() {
        let store = FailingStore()
        let launch = MockLaunchService()
        let vm = LinkManagementViewModel(store: store, launchService: launch)
        var publishedLinks: [LinkItem] = [LinkItem(name: "stale", urlString: "https://stale.example")]
        vm.onLinksChanged = { publishedLinks = $0 }

        vm.load()

        XCTAssertEqual(publishedLinks, [])
        XCTAssertEqual(vm.links, [])
        XCTAssertEqual(vm.errorMessage, "读取网址列表失败：broken store")
    }
}
