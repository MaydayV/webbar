import AppKit
import Foundation

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    private var viewModel: LinkManagementViewModel?
    private var managementWindowController: ManagementWindowController?
    private var statusBarController: StatusBarController?
    private var webPanelManager: WebPanelManager?

    func applicationDidFinishLaunching(_ notification: Notification) {
        let storeURL = Self.storeURL()
        let store = JSONLinkStore(fileURL: storeURL)
        let launchService = LaunchAtLoginService()
        let vm = LinkManagementViewModel(store: store, launchService: launchService)
        let sessionStore = WebSessionStore()

        let windowController = ManagementWindowController(viewModel: vm)
        managementWindowController = windowController
        viewModel = vm
        let panelManager = WebPanelManager(
            sessionStore: sessionStore,
            openExternalURL: { url in
                NSWorkspace.shared.open(url)
            }
        )
        webPanelManager = panelManager

        let statusController = StatusBarController(
            errorFeedback: ErrorFeedback(),
            dispatcher: LinkOpenDispatcher(
                urlOpener: SystemURLOpener(),
                embeddedPresenter: panelManager
            ),
            onManage: { [weak windowController, weak panelManager] in
                panelManager?.hideAll()
                windowController?.present()
            },
            onQuit: {
                NSApp.terminate(nil)
            }
        )
        statusBarController = statusController

        vm.onLinksChanged = { [weak statusController] links in
            statusController?.render(links: links)
        }
        vm.load()
    }

    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        if flag == false {
            webPanelManager?.hideAll()
            managementWindowController?.present()
        }
        return true
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        false
    }

    private static func storeURL() -> URL {
        let support = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
            ?? URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
        return support
            .appendingPathComponent("WebBar", isDirectory: true)
            .appendingPathComponent("links.json")
    }
}
