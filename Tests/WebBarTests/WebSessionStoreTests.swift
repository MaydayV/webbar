import AppKit
import XCTest
@testable import WebBar

final class WebSessionStoreTests: XCTestCase {
    private var defaults: UserDefaults!
    private var rootURL: URL!
    private var suiteName: String!

    override func setUpWithError() throws {
        try super.setUpWithError()
        suiteName = "WebSessionStoreTests.\(UUID().uuidString)"
        defaults = UserDefaults(suiteName: suiteName)
        rootURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
    }

    override func tearDownWithError() throws {
        if let defaults, let suiteName {
            defaults.removePersistentDomain(forName: suiteName)
        }
        if let rootURL {
            try? FileManager.default.removeItem(at: rootURL)
        }
        try super.tearDownWithError()
    }

    func testSavesAndLoadsFramePerLink() throws {
        let store = WebSessionStore(defaults: defaults, rootDirectoryURL: rootURL)
        let id = UUID()
        let frame = NSRect(x: 10, y: 20, width: 420, height: 700)

        XCTAssertNil(store.frame(for: id))

        store.saveFrame(frame, for: id)

        XCTAssertEqual(store.frame(for: id), frame)
    }

    func testCreatesDeterministicSeparateStoragePaths() throws {
        let store = WebSessionStore(defaults: defaults, rootDirectoryURL: rootURL)
        let firstID = UUID(uuidString: "AAAAAAAA-BBBB-CCCC-DDDD-EEEEEEEEEEEE")!
        let secondID = UUID(uuidString: "11111111-2222-3333-4444-555555555555")!

        let firstPath = try store.storageDirectory(for: firstID)
        let firstPathAgain = try store.storageDirectory(for: firstID)
        let secondPath = try store.storageDirectory(for: secondID)

        XCTAssertEqual(firstPath, firstPathAgain)
        XCTAssertNotEqual(firstPath, secondPath)
        XCTAssertTrue(firstPath.path.contains(firstID.uuidString.lowercased()))
        XCTAssertTrue(FileManager.default.fileExists(atPath: firstPath.path))
    }
}
