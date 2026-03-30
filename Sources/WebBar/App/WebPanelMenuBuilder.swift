import AppKit

@MainActor
struct WebPanelMenuBuilder {
    func makeMenu(
        canGoBack: Bool,
        canGoForward: Bool,
        onBack: @escaping () -> Void,
        onForward: @escaping () -> Void,
        onRefresh: @escaping () -> Void,
        onReset: @escaping () -> Void
    ) -> NSMenu {
        let menu = NSMenu()
        menu.addItem(makeItem(title: "返回", enabled: canGoBack, action: onBack))
        menu.addItem(makeItem(title: "前进", enabled: canGoForward, action: onForward))
        menu.addItem(makeItem(title: "刷新", enabled: true, action: onRefresh))
        menu.addItem(makeItem(title: "重新登录", enabled: true, action: onReset))
        return menu
    }

    private func makeItem(title: String, enabled: Bool, action: @escaping () -> Void) -> NSMenuItem {
        let item = NSMenuItem(title: title, action: nil, keyEquivalent: "")
        item.isEnabled = enabled
        let target = MenuActionTarget(action: action)
        item.target = target
        item.action = #selector(MenuActionTarget.invokeAction)
        objc_setAssociatedObject(item, Unmanaged.passUnretained(item).toOpaque(), target, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        return item
    }
}

@MainActor
private final class MenuActionTarget: NSObject {
    private let actionBlock: () -> Void

    init(action: @escaping () -> Void) {
        self.actionBlock = action
    }

    @objc
    func invokeAction() {
        actionBlock()
    }
}
