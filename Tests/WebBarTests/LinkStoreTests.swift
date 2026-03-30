import Foundation
import XCTest
@testable import WebBar

final class LinkStoreTests: XCTestCase {
    private var tempDirectory: URL!
    private var fileURL: URL!

    override func setUpWithError() throws {
        try super.setUpWithError()
        tempDirectory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString, isDirectory: true)
        fileURL = tempDirectory.appendingPathComponent("links.json")
    }

    override func tearDownWithError() throws {
        if let tempDirectory {
            try? FileManager.default.removeItem(at: tempDirectory)
        }
        try super.tearDownWithError()
    }

    func testSaveLoadRoundTripAndOrder() throws {
        let store = JSONLinkStore(fileURL: fileURL)
        let first = LinkItem(name: "A", urlString: "https://a.com", openMode: .defaultBrowser)
        let second = LinkItem(name: "B", urlString: "mailto:b@example.com", openMode: .embeddedPanel)

        try store.save([first, second])
        let loaded = try store.load()

        XCTAssertEqual(loaded.map(\.id), [first.id, second.id])
        XCTAssertEqual(loaded[0].urlString, "https://a.com")
        XCTAssertEqual(loaded[0].openMode, .defaultBrowser)
        XCTAssertEqual(loaded[0].reopenBehavior, .restoreLastPage)
        XCTAssertEqual(loaded[1].urlString, "mailto:b@example.com")
        XCTAssertEqual(loaded[1].openMode, .embeddedPanel)
        XCTAssertEqual(loaded[1].reopenBehavior, .restoreLastPage)
    }

    func testAppendUpdateDelete() throws {
        let store = JSONLinkStore(fileURL: fileURL)
        let first = LinkItem(name: "A", urlString: "https://a.com", openMode: .defaultBrowser)
        let second = LinkItem(name: "B", urlString: "https://b.com", openMode: .embeddedPanel)

        _ = try store.append(first)
        _ = try store.append(second)

        var edited = second
        edited.urlString = "obsidian://vault"
        edited.openMode = .defaultBrowser
        edited.reopenBehavior = .homePage
        edited.updatedAt = .now

        let updated = try store.update(edited)
        XCTAssertEqual(updated[1].urlString, "obsidian://vault")
        XCTAssertEqual(updated[1].openMode, .defaultBrowser)
        XCTAssertEqual(updated[1].reopenBehavior, .homePage)

        let afterDelete = try store.delete(id: first.id)
        XCTAssertEqual(afterDelete.count, 1)
        XCTAssertEqual(afterDelete[0].id, second.id)
    }

    func testLoadBackfillsDefaultOpenModeForLegacyData() throws {
        let legacyJSON = """
        [
          {
            "createdAt" : 796527499.562681,
            "iconPreference" : {
              "type" : "favicon"
            },
            "id" : "C09EECB1-4CB5-4010-A2C1-75BFE9406CA8",
            "name" : "Legacy",
            "updatedAt" : 796529946.465829,
            "urlString" : "https://example.com"
          }
        ]
        """
        try FileManager.default.createDirectory(at: tempDirectory, withIntermediateDirectories: true)
        try legacyJSON.data(using: .utf8)?.write(to: fileURL)

        let store = JSONLinkStore(fileURL: fileURL)
        let loaded = try store.load()

        XCTAssertEqual(loaded.count, 1)
        XCTAssertEqual(loaded.first?.openMode, .defaultBrowser)
        XCTAssertEqual(loaded.first?.reopenBehavior, .restoreLastPage)
        XCTAssertEqual(loaded.first?.urlString, "https://example.com")
    }
}
