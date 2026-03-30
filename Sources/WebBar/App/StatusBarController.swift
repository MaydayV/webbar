import AppKit
import Foundation

@MainActor
final class StatusBarController: NSObject {
    private let errorFeedback: ErrorFeedback
    private let dispatcher: LinkOpenDispatcher
    private let onManage: () -> Void
    private let onQuit: () -> Void

    private var statusItems: [UUID: NSStatusItem] = [:]
    private var buttonToID: [ObjectIdentifier: UUID] = [:]
    private var linksByID: [UUID: LinkItem] = [:]
    private var controlItemID: UUID?

    init(
        errorFeedback: ErrorFeedback,
        dispatcher: LinkOpenDispatcher,
        onManage: @escaping () -> Void,
        onQuit: @escaping () -> Void
    ) {
        self.errorFeedback = errorFeedback
        self.dispatcher = dispatcher
        self.onManage = onManage
        self.onQuit = onQuit
    }

    func render(links: [LinkItem]) {
        let viewModels = StatusItemViewModel.make(from: links)
        linksByID = Dictionary(uniqueKeysWithValues: links.map { ($0.id, $0) })

        let wantedIDs = Set(viewModels.map(\.id))
        let currentIDs = Set(statusItems.keys)
        for id in currentIDs.subtracting(wantedIDs) {
            removeStatusItem(id: id)
        }

        for viewModel in viewModels {
            if statusItems[viewModel.id] == nil {
                let item = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
                statusItems[viewModel.id] = item
                configureButton(item.button, id: viewModel.id)
            }

            guard let item = statusItems[viewModel.id], let button = item.button else { continue }
            if let link = viewModel.link {
                let presentation = StatusBarPresentation.make(for: link)
                button.image = nil
                button.title = presentation.title
                button.toolTip = link.name ?? link.urlString
                controlItemID = nil
            } else {
                button.image = EmojiIconRenderer().render(emoji: "👌").asTemplateImage()
                button.title = ""
                button.toolTip = "WebBar 管理"
                controlItemID = viewModel.id
            }
        }
    }

    private func configureButton(_ button: NSStatusBarButton?, id: UUID) {
        guard let button else { return }
        button.target = self
        button.action = #selector(handleButtonAction(_:))
        button.sendAction(on: [.leftMouseUp, .rightMouseUp])
        buttonToID[ObjectIdentifier(button)] = id
    }

    private func removeStatusItem(id: UUID) {
        if let item = statusItems[id] {
            NSStatusBar.system.removeStatusItem(item)
        }
        statusItems[id] = nil
    }

    @objc
    private func handleButtonAction(_ sender: NSStatusBarButton) {
        guard let id = buttonToID[ObjectIdentifier(sender)] else { return }
        let isRightClick = NSApp.currentEvent?.type == .rightMouseUp
        if isRightClick {
            showContextMenu(for: id)
            return
        }

        if id == controlItemID {
            onManage()
            return
        }

        guard let link = linksByID[id] else {
            errorFeedback.presentOpenFailure(for: "无效网址", button: sender)
            return
        }

        let ok = dispatcher.open(link: link, relativeTo: sender)
        if ok == false {
            errorFeedback.presentOpenFailure(for: link.urlString, button: sender)
        }
    }

    private func showContextMenu(for id: UUID) {
        guard let item = statusItems[id] else { return }
        let menu = NSMenu()

        let manage = NSMenuItem(title: "管理网址", action: #selector(handleManageAction), keyEquivalent: "")
        manage.target = self
        menu.addItem(manage)

        menu.addItem(NSMenuItem.separator())

        let quit = NSMenuItem(title: "退出 WebBar", action: #selector(handleQuitAction), keyEquivalent: "")
        quit.target = self
        menu.addItem(quit)

        item.menu = menu
        item.button?.performClick(nil)
        item.menu = nil
    }

    @objc
    private func handleManageAction() {
        onManage()
    }

    @objc
    private func handleQuitAction() {
        onQuit()
    }
}
