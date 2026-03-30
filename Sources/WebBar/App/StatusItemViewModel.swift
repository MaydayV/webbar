import Foundation

struct StatusItemViewModel: Equatable {
    let id: UUID
    let link: LinkItem?

    static func make(from links: [LinkItem]) -> [StatusItemViewModel] {
        if links.isEmpty {
            return [StatusItemViewModel(id: UUID(), link: nil)]
        }
        return links.map { StatusItemViewModel(id: $0.id, link: $0) }
    }
}
