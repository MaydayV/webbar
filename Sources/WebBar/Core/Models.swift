import Foundation

enum OpenMode: String, Codable, Equatable, Sendable, CaseIterable {
    case defaultBrowser
    case embeddedPanel

    var displayName: String {
        switch self {
        case .defaultBrowser:
            return "默认浏览器"
        case .embeddedPanel:
            return "内嵌弹窗"
        }
    }

    var compactLabel: String {
        switch self {
        case .defaultBrowser:
            return "默认浏览器"
        case .embeddedPanel:
            return "内嵌弹窗"
        }
    }
}

enum ReopenBehavior: String, Codable, Equatable, Sendable, CaseIterable {
    case restoreLastPage
    case homePage

    var displayName: String {
        switch self {
        case .restoreLastPage:
            return "恢复上次页面"
        case .homePage:
            return "每次打开首页"
        }
    }

    var descriptionText: String {
        switch self {
        case .restoreLastPage:
            return "关闭弹窗后再次打开，会回到你上次停留的页面。"
        case .homePage:
            return "每次打开弹窗时，都从你设置的网址重新开始。"
        }
    }
}

enum IconPreference: Codable, Equatable, Sendable {
    case favicon
    case emoji(String)

    private enum CodingKeys: String, CodingKey {
        case type
        case value
    }

    private enum Kind: String, Codable {
        case favicon
        case emoji
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let kind = try container.decode(Kind.self, forKey: .type)
        switch kind {
        case .favicon:
            self = .favicon
        case .emoji:
            self = .emoji(try container.decode(String.self, forKey: .value))
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .favicon:
            try container.encode(Kind.favicon, forKey: .type)
        case .emoji(let value):
            try container.encode(Kind.emoji, forKey: .type)
            try container.encode(value, forKey: .value)
        }
    }
}

struct LinkItem: Codable, Equatable, Identifiable, Sendable {
    let id: UUID
    var name: String?
    var urlString: String
    var iconPreference: IconPreference
    var openMode: OpenMode
    var reopenBehavior: ReopenBehavior
    let createdAt: Date
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        name: String? = nil,
        urlString: String,
        iconPreference: IconPreference = .emoji("👌"),
        openMode: OpenMode = .defaultBrowser,
        reopenBehavior: ReopenBehavior = .restoreLastPage,
        createdAt: Date = .now,
        updatedAt: Date = .now
    ) {
        self.id = id
        self.name = name
        self.urlString = urlString
        self.iconPreference = iconPreference
        self.openMode = openMode
        self.reopenBehavior = reopenBehavior
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    private enum CodingKeys: String, CodingKey {
        case id
        case name
        case urlString
        case iconPreference
        case openMode
        case reopenBehavior
        case createdAt
        case updatedAt
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decodeIfPresent(String.self, forKey: .name)
        urlString = try container.decode(String.self, forKey: .urlString)
        switch try container.decodeIfPresent(IconPreference.self, forKey: .iconPreference) {
        case .emoji(let value):
            iconPreference = .emoji(value.isEmpty ? "👌" : value)
        default:
            iconPreference = .emoji("👌")
        }
        openMode = try container.decodeIfPresent(OpenMode.self, forKey: .openMode) ?? .defaultBrowser
        reopenBehavior = try container.decodeIfPresent(ReopenBehavior.self, forKey: .reopenBehavior) ?? .restoreLastPage
        createdAt = try container.decode(Date.self, forKey: .createdAt)
        updatedAt = try container.decode(Date.self, forKey: .updatedAt)
    }
}
