import Foundation

enum WebPanelReopenPolicy {
    static func shouldLoadInitialURL(currentURL: URL?, behavior: ReopenBehavior) -> Bool {
        switch behavior {
        case .restoreLastPage:
            return currentURL == nil
        case .homePage:
            return true
        }
    }
}
