import Foundation

protocol LinkStore {
    func load() throws -> [LinkItem]
    func save(_ links: [LinkItem]) throws
    func append(_ link: LinkItem) throws -> [LinkItem]
    func update(_ link: LinkItem) throws -> [LinkItem]
    func delete(id: UUID) throws -> [LinkItem]
}

enum LinkStoreError: LocalizedError, Equatable {
    case notFound

    var errorDescription: String? {
        switch self {
        case .notFound:
            return "未找到要更新的网址"
        }
    }
}

final class JSONLinkStore: LinkStore {
    private let fileURL: URL
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder
    private let lock = NSLock()

    init(fileURL: URL) {
        self.fileURL = fileURL
        self.encoder = JSONEncoder()
        self.decoder = JSONDecoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
    }

    func load() throws -> [LinkItem] {
        lock.lock()
        defer { lock.unlock() }
        return try loadUnlocked()
    }

    func save(_ links: [LinkItem]) throws {
        lock.lock()
        defer { lock.unlock() }
        try saveUnlocked(links)
    }

    func append(_ link: LinkItem) throws -> [LinkItem] {
        lock.lock()
        defer { lock.unlock() }
        var links = try loadUnlocked()
        links.append(link)
        try saveUnlocked(links)
        return links
    }

    func update(_ link: LinkItem) throws -> [LinkItem] {
        lock.lock()
        defer { lock.unlock() }
        var links = try loadUnlocked()
        guard let index = links.firstIndex(where: { $0.id == link.id }) else {
            throw LinkStoreError.notFound
        }
        links[index] = link
        try saveUnlocked(links)
        return links
    }

    func delete(id: UUID) throws -> [LinkItem] {
        lock.lock()
        defer { lock.unlock() }
        var links = try loadUnlocked()
        links.removeAll { $0.id == id }
        try saveUnlocked(links)
        return links
    }

    private func loadUnlocked() throws -> [LinkItem] {
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            return []
        }
        let data = try Data(contentsOf: fileURL)
        guard data.isEmpty == false else { return [] }
        return try decoder.decode([LinkItem].self, from: data)
    }

    private func saveUnlocked(_ links: [LinkItem]) throws {
        let directory = fileURL.deletingLastPathComponent()
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        let data = try encoder.encode(links)
        try data.write(to: fileURL, options: [.atomic])
    }
}
