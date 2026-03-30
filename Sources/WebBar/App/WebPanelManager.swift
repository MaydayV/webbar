import AppKit
import Foundation

@MainActor
final class WebPanelManager: EmbeddedLinkPresenting {
    private let sessionStore: WebSessionStore
    private let openExternalURL: (URL) -> Void
    private let panelFactory: @MainActor (LinkItem, WebSessionStore, @escaping (URL) -> Void) -> WebPanelControlling?
    private var panels: [UUID: WebPanelControlling] = [:]

    init(
        sessionStore: WebSessionStore,
        openExternalURL: @escaping (URL) -> Void,
        panelFactory: @escaping @MainActor (LinkItem, WebSessionStore, @escaping (URL) -> Void) -> WebPanelControlling? = { link, sessionStore, openExternalURL in
            guard let url = URL(string: link.urlString) else { return nil }
            return try? WebPanelController(
                id: link.id,
                url: url,
                reopenBehavior: link.reopenBehavior,
                sessionStore: sessionStore,
                openExternalURL: openExternalURL
            )
        }
    ) {
        self.sessionStore = sessionStore
        self.openExternalURL = openExternalURL
        self.panelFactory = panelFactory
    }

    func toggle(link: LinkItem, relativeTo button: NSStatusBarButton?) {
        let controller: WebPanelControlling
        let signature = "\(link.urlString)|\(link.reopenBehavior.rawValue)"
        if let existing = panels[link.id], existing.representedLinkSignature == signature {
            controller = existing
        } else if let created = panelFactory(link, sessionStore, openExternalURL) {
            panels[link.id]?.hide()
            panels[link.id] = created
            controller = created
        } else {
            return
        }

        for (id, panel) in panels where id != link.id {
            panel.hide()
        }
        controller.toggle(relativeTo: button)
    }

    func hideAll() {
        for panel in panels.values {
            panel.hide()
        }
    }
}
