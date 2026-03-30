import AppKit

enum EmojiInputCoordinator {
    @MainActor
    static func prepareForReplacement(firstResponder: NSResponder?) {
        guard let textView = firstResponder as? NSTextView else { return }
        textView.selectAll(nil)
    }
}
