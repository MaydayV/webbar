import AppKit
import Foundation
import WebKit

final class WebSessionStore {
    private let defaults: UserDefaults
    private let rootDirectoryURL: URL

    init(
        defaults: UserDefaults = .standard,
        rootDirectoryURL: URL? = nil
    ) {
        self.defaults = defaults
        if let rootDirectoryURL {
            self.rootDirectoryURL = rootDirectoryURL
        } else {
            let applicationSupport = FileManager.default.urls(
                for: .applicationSupportDirectory,
                in: .userDomainMask
            ).first ?? URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
            self.rootDirectoryURL = applicationSupport
                .appendingPathComponent("WebBar", isDirectory: true)
                .appendingPathComponent("WebSessions", isDirectory: true)
        }
    }

    func frame(for id: UUID) -> NSRect? {
        guard
            let value = defaults.string(forKey: frameKey(for: id)),
            let rect = NSRectFromString(value) as NSRect?
        else {
            return nil
        }
        return rect.equalTo(.zero) ? nil : rect
    }

    func saveFrame(_ frame: NSRect, for id: UUID) {
        defaults.set(NSStringFromRect(frame), forKey: frameKey(for: id))
    }

    func storageDirectory(for id: UUID) throws -> URL {
        let directory = rootDirectoryURL
            .appendingPathComponent(id.uuidString.lowercased(), isDirectory: true)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        return directory
    }

    @MainActor
    func websiteDataStore(for id: UUID) throws -> WKWebsiteDataStore {
        _ = try storageDirectory(for: id)
        return WKWebsiteDataStore(forIdentifier: id)
    }

    func dataStoreIdentifier(for id: UUID) -> String {
        "com.tongkaisun.WebBar.session.\(id.uuidString.lowercased())"
    }

    @MainActor
    func resetSession(for id: UUID) async throws {
        let dataStore = try websiteDataStore(for: id)
        let records = await withCheckedContinuation { continuation in
            dataStore.fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
                continuation.resume(returning: records)
            }
        }
        await withCheckedContinuation { continuation in
            dataStore.removeData(
                ofTypes: WKWebsiteDataStore.allWebsiteDataTypes(),
                for: records
            ) {
                continuation.resume()
            }
        }
    }

    private func frameKey(for id: UUID) -> String {
        "webPanelFrame.\(id.uuidString.lowercased())"
    }
}
