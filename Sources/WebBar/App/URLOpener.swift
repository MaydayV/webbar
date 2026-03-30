import AppKit
import Foundation

protocol URLOpener {
    func open(_ url: URL) -> Bool
}

@MainActor
protocol EmbeddedLinkPresenting {
    func toggle(link: LinkItem, relativeTo button: NSStatusBarButton?)
}

struct SystemURLOpener: URLOpener {
    func open(_ url: URL) -> Bool {
        NSWorkspace.shared.open(url)
    }
}

@MainActor
struct LinkOpenDispatcher {
    let urlOpener: URLOpener
    let embeddedPresenter: EmbeddedLinkPresenting

    func open(link: LinkItem, relativeTo button: NSStatusBarButton?) -> Bool {
        guard let url = URL(string: link.urlString) else {
            return false
        }

        switch link.openMode {
        case .defaultBrowser:
            return urlOpener.open(url)
        case .embeddedPanel:
            embeddedPresenter.toggle(link: link, relativeTo: button)
            return true
        }
    }
}
