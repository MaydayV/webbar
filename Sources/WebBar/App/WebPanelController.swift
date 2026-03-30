import AppKit
import WebKit

@MainActor
protocol WebPanelControlling: AnyObject {
    var representedLinkSignature: String { get }
    func toggle(relativeTo button: NSStatusBarButton?)
    func hide()
}

@MainActor
final class WebPanelController: NSWindowController, WebPanelControlling {
    private let id: UUID
    private let initialURL: URL
    private let reopenBehavior: ReopenBehavior
    private let sessionStore: WebSessionStore
    private let openExternalURL: (URL) -> Void
    private let containerView: WebViewContainerView
    private let menuButton = NSButton()
    private var isPanelPresented = false

    init(
        id: UUID,
        url: URL,
        reopenBehavior: ReopenBehavior,
        sessionStore: WebSessionStore,
        openExternalURL: @escaping (URL) -> Void
    ) throws {
        self.id = id
        self.initialURL = url
        self.reopenBehavior = reopenBehavior
        self.sessionStore = sessionStore
        self.openExternalURL = openExternalURL
        let initialFrame = sessionStore.frame(for: id) ?? NSRect(x: 0, y: 0, width: 420, height: 700)

        let configuration = WKWebViewConfiguration()
        configuration.websiteDataStore = try sessionStore.websiteDataStore(for: id)
        configuration.defaultWebpagePreferences.allowsContentJavaScript = true
        let userContentController = WKUserContentController()
        userContentController.addUserScript(
            WKUserScript(
                source: WebViewPresentationProfile.viewportScriptSource,
                injectionTime: .atDocumentEnd,
                forMainFrameOnly: true
            )
        )
        configuration.userContentController = userContentController

        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.customUserAgent = WebViewPresentationProfile.userAgent(forWidth: initialFrame.width)
        self.containerView = WebViewContainerView(webView: webView)

        let panel = NSPanel(
            contentRect: initialFrame,
            styleMask: [.titled, .closable, .resizable],
            backing: .buffered,
            defer: false
        )
        panel.isFloatingPanel = true
        panel.hidesOnDeactivate = true
        panel.becomesKeyOnlyIfNeeded = false
        panel.isReleasedWhenClosed = false
        panel.title = url.host ?? "WebBar"
        panel.contentView = containerView
        super.init(window: panel)
        panel.delegate = self

        webView.navigationDelegate = self
        webView.uiDelegate = self
        configureCallbacks()
        configureMenuButton()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }

    var representedLinkSignature: String {
        "\(initialURL.absoluteString)|\(reopenBehavior.rawValue)"
    }

    func toggle(relativeTo button: NSStatusBarButton?) {
        guard let window else { return }
        if isPanelPresented {
            hide()
            return
        }

        if window.frame.equalTo(.zero), let savedFrame = sessionStore.frame(for: id) {
            window.setFrame(savedFrame, display: false)
        } else if sessionStore.frame(for: id) == nil, let buttonWindow = button?.window, let screen = buttonWindow.screen {
            let buttonFrame = buttonWindow.convertToScreen(button?.frame ?? .zero)
            let width = window.frame.width
            let height = window.frame.height
            let x = min(max(screen.visibleFrame.minX, buttonFrame.midX - width / 2), screen.visibleFrame.maxX - width)
            let y = max(screen.visibleFrame.minY, buttonFrame.minY - height - 8)
            window.setFrameOrigin(NSPoint(x: x, y: y))
        }

        NSApp.activate(ignoringOtherApps: true)
        showWindow(nil)
        window.orderFrontRegardless()
        window.makeKey()
        isPanelPresented = true
        if WebPanelReopenPolicy.shouldLoadInitialURL(
            currentURL: containerView.webView.url,
            behavior: reopenBehavior
        ) {
            containerView.webView.load(URLRequest(url: initialURL))
        }
    }

    func hide() {
        guard let window else { return }
        window.orderOut(nil)
        isPanelPresented = false
        saveFrame()
    }

    private func configureCallbacks() {
        containerView.onBack = { [weak self] in
            self?.containerView.webView.goBack()
            self?.containerView.updateNavigationState()
        }
        containerView.onForward = { [weak self] in
            self?.containerView.webView.goForward()
            self?.containerView.updateNavigationState()
        }
        containerView.onRefresh = { [weak self] in
            self?.containerView.webView.reload()
        }
        containerView.onReset = { [weak self] in
            guard let self else { return }
            Task { @MainActor [weak self] in
                guard let self else { return }
                try? await self.sessionStore.resetSession(for: self.id)
                self.containerView.webView.load(URLRequest(url: self.initialURL))
            }
        }
    }

    private func configureMenuButton() {
        guard let window else { return }
        let container = NSView(frame: NSRect(x: 0, y: 0, width: 34, height: 24))
        container.translatesAutoresizingMaskIntoConstraints = false

        menuButton.bezelStyle = .texturedRounded
        menuButton.title = "···"
        menuButton.font = .systemFont(ofSize: 14, weight: .semibold)
        menuButton.target = self
        menuButton.action = #selector(showHiddenMenu(_:))
        menuButton.frame = container.bounds
        menuButton.autoresizingMask = [.width, .height]
        container.addSubview(menuButton)

        let accessory = NSTitlebarAccessoryViewController()
        accessory.view = container
        accessory.layoutAttribute = .right
        window.addTitlebarAccessoryViewController(accessory)
    }

    @objc
    private func showHiddenMenu(_ sender: NSButton) {
        let menu = containerView.makeHiddenMenu()
        menu.popUp(positioning: nil, at: NSPoint(x: 0, y: sender.bounds.maxY + 4), in: sender)
    }

    private func saveFrame() {
        if let frame = window?.frame {
            sessionStore.saveFrame(frame, for: id)
        }
    }
}

@MainActor
extension WebPanelController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        containerView.updateNavigationState()
    }

    func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction,
        decisionHandler: @escaping @MainActor (WKNavigationActionPolicy) -> Void
    ) {
        let targetIsMainFrame = navigationAction.targetFrame?.isMainFrame ?? false
        if let url = navigationAction.request.url, WebNavigationPolicy.shouldLoadInCurrentPanel(url: url, targetIsMainFrame: targetIsMainFrame) {
            webView.load(navigationAction.request)
            decisionHandler(.cancel)
            return
        }
        if let url = navigationAction.request.url, WebNavigationPolicy.shouldOpenExternally(url: url, targetIsMainFrame: targetIsMainFrame) {
            openExternalURL(url)
            decisionHandler(.cancel)
            return
        }
        decisionHandler(.allow)
    }
}

@MainActor
extension WebPanelController: WKUIDelegate {
    func webView(
        _ webView: WKWebView,
        createWebViewWith configuration: WKWebViewConfiguration,
        for navigationAction: WKNavigationAction,
        windowFeatures: WKWindowFeatures
    ) -> WKWebView? {
        if let url = navigationAction.request.url {
            if WebNavigationPolicy.shouldLoadInCurrentPanel(url: url, targetIsMainFrame: false) {
                webView.load(navigationAction.request)
            } else {
                openExternalURL(url)
            }
        }
        return nil
    }
}

@MainActor
extension WebPanelController: NSWindowDelegate {
    func windowDidMove(_ notification: Notification) {
        saveFrame()
    }

    func windowDidResize(_ notification: Notification) {
        containerView.webView.customUserAgent = WebViewPresentationProfile.userAgent(forWidth: window?.frame.width ?? 420)
        saveFrame()
    }

    func windowWillClose(_ notification: Notification) {
        isPanelPresented = false
        saveFrame()
    }

    func windowShouldClose(_ sender: NSWindow) -> Bool {
        hide()
        return false
    }

    func windowDidResignKey(_ notification: Notification) {
        guard window?.hidesOnDeactivate == true else { return }
        hide()
    }
}
