import Foundation

enum WebNavigationPolicy {
    static func shouldLoadInCurrentPanel(url: URL, targetIsMainFrame: Bool) -> Bool {
        guard targetIsMainFrame == false else { return false }
        return ["http", "https"].contains(url.scheme?.lowercased() ?? "")
    }

    static func shouldOpenExternally(url: URL, targetIsMainFrame: Bool) -> Bool {
        guard targetIsMainFrame == false else { return false }
        return shouldLoadInCurrentPanel(url: url, targetIsMainFrame: targetIsMainFrame) == false
    }
}
