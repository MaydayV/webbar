import AppKit
import XCTest
@testable import WebBar

@MainActor
final class EmojiInputCoordinatorTests: XCTestCase {
    func testPrepareForReplacementSelectsEntireExistingEmoji() {
        let textView = NSTextView()
        textView.string = "👌"
        textView.setSelectedRange(NSRange(location: 1, length: 0))

        EmojiInputCoordinator.prepareForReplacement(firstResponder: textView)

        XCTAssertEqual(textView.selectedRange(), NSRange(location: 0, length: textView.string.utf16.count))
    }
}
