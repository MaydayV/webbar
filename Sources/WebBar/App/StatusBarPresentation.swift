import Foundation

struct StatusBarPresentation {
    let title: String
    let usesImage: Bool

    static func make(for link: LinkItem) -> StatusBarPresentation {
        switch link.iconPreference {
        case .emoji(let emoji):
            let value = emoji.trimmingCharacters(in: .whitespacesAndNewlines)
            return StatusBarPresentation(title: value.isEmpty ? "👌" : value, usesImage: false)
        case .favicon:
            return StatusBarPresentation(title: "👌", usesImage: false)
        }
    }
}
