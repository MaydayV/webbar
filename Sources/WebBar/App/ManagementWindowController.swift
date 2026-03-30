import AppKit
import SwiftUI

@MainActor
final class ManagementWindowController: NSWindowController {
    init(viewModel: LinkManagementViewModel) {
        let contentView = LinkManagementView(viewModel: viewModel)
        let host = NSHostingController(rootView: contentView)
        let window = NSWindow(contentViewController: host)
        window.title = "WebBar 管理"
        window.styleMask = [.titled, .closable, .miniaturizable, .resizable]
        window.setContentSize(NSSize(width: 760, height: 560))
        window.minSize = NSSize(width: 720, height: 440)
        super.init(window: window)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }

    func present() {
        guard let window else { return }
        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
}
