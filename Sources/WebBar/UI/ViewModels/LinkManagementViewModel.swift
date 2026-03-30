import Foundation
import SwiftUI

struct LinkDraft: Equatable {
    var name: String = ""
    var urlString: String = ""
    var emoji: String = "👌"
    var openMode: OpenMode = .defaultBrowser
    var reopenBehavior: ReopenBehavior = .restoreLastPage
}

@MainActor
final class LinkManagementViewModel: ObservableObject {
    @Published var links: [LinkItem] = []
    @Published var errorMessage: String?
    @Published var launchAtLoginEnabled: Bool

    let validator: LinkValidator
    private let store: LinkStore
    private let launchService: LaunchAtLoginServing

    var onLinksChanged: (([LinkItem]) -> Void)?

    init(
        store: LinkStore,
        validator: LinkValidator = LinkValidator(),
        launchService: LaunchAtLoginServing
    ) {
        self.store = store
        self.validator = validator
        self.launchService = launchService
        self.launchAtLoginEnabled = launchService.isEnabled
        load()
    }

    func load() {
        do {
            links = try store.load()
            errorMessage = nil
            onLinksChanged?(links)
        } catch {
            links = []
            errorMessage = "读取网址列表失败：\(error.localizedDescription)"
            onLinksChanged?(links)
        }
    }

    func addLink(from draft: LinkDraft) {
        do {
            _ = try validator.validateCreate(urlString: draft.urlString, currentCount: links.count)
            let item = LinkItem(
                name: sanitizedName(draft.name),
                urlString: draft.urlString.trimmingCharacters(in: .whitespacesAndNewlines),
                iconPreference: .emoji(normalizedEmoji(from: draft.emoji)),
                openMode: draft.openMode,
                reopenBehavior: draft.reopenBehavior
            )
            links = try store.append(item)
            errorMessage = nil
            onLinksChanged?(links)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func updateLink(id: UUID, draft: LinkDraft) {
        do {
            _ = try validator.validateUpdate(urlString: draft.urlString)
            guard var existing = links.first(where: { $0.id == id }) else { return }
            existing.name = sanitizedName(draft.name)
            existing.urlString = draft.urlString.trimmingCharacters(in: .whitespacesAndNewlines)
            existing.iconPreference = .emoji(normalizedEmoji(from: draft.emoji))
            existing.openMode = draft.openMode
            existing.reopenBehavior = draft.reopenBehavior
            existing.updatedAt = .now
            links = try store.update(existing)
            errorMessage = nil
            onLinksChanged?(links)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func deleteLink(id: UUID) {
        do {
            links = try store.delete(id: id)
            errorMessage = nil
            onLinksChanged?(links)
        } catch {
            errorMessage = "删除失败：\(error.localizedDescription)"
        }
    }

    func setLaunchAtLogin(enabled: Bool) {
        launchService.setEnabled(enabled)
        launchAtLoginEnabled = launchService.isEnabled
    }

    func clearError() {
        errorMessage = nil
    }

    private func sanitizedName(_ value: String) -> String? {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }

    private func normalizedEmoji(from value: String) -> String {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? "👌" : trimmed
    }
}
