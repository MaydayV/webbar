import AppKit
import WebKit

@MainActor
final class WebViewContainerView: NSView {
    let webView: WKWebView
    private let menuBuilder = WebPanelMenuBuilder()
    private var canGoBack = false
    private var canGoForward = false

    var onBack: (() -> Void)?
    var onForward: (() -> Void)?
    var onRefresh: (() -> Void)?
    var onReset: (() -> Void)?

    init(webView: WKWebView) {
        self.webView = webView
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        setUp()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }

    func updateNavigationState() {
        canGoBack = webView.canGoBack
        canGoForward = webView.canGoForward
    }

    private func setUp() {
        webView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(webView)
        NSLayoutConstraint.activate([
            webView.leadingAnchor.constraint(equalTo: leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: trailingAnchor),
            webView.topAnchor.constraint(equalTo: topAnchor),
            webView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        updateNavigationState()
    }

    func makeHiddenMenu() -> NSMenu {
        menuBuilder.makeMenu(
            canGoBack: canGoBack,
            canGoForward: canGoForward,
            onBack: { [weak self] in self?.onBack?() },
            onForward: { [weak self] in self?.onForward?() },
            onRefresh: { [weak self] in self?.onRefresh?() },
            onReset: { [weak self] in self?.onReset?() }
        )
    }
}
