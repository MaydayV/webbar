import XCTest
@testable import WebBar

final class StatusBarPresentationTests: XCTestCase {
    func testEmojiLinksUseTextInStatusBar() {
        let link = LinkItem(name: "Chat", urlString: "https://example.com", iconPreference: .emoji("🤖"))
        let presentation = StatusBarPresentation.make(for: link)

        XCTAssertEqual(presentation.title, "🤖")
        XCTAssertFalse(presentation.usesImage)
    }

    func testLegacyFaviconLinksFallbackToDefaultEmojiText() {
        let link = LinkItem(name: "Legacy", urlString: "https://example.com", iconPreference: .favicon)
        let presentation = StatusBarPresentation.make(for: link)

        XCTAssertEqual(presentation.title, "👌")
        XCTAssertFalse(presentation.usesImage)
    }
}
