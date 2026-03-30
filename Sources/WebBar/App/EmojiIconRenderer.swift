import AppKit

struct EmojiIconRenderer {
    func render(emoji: String, pointSize: CGFloat = 13, side: CGFloat = 18) -> NSImage {
        let image = NSImage(size: NSSize(width: side, height: side))
        image.lockFocus()
        defer { image.unlockFocus() }

        NSColor.clear.setFill()
        NSBezierPath(rect: NSRect(x: 0, y: 0, width: side, height: side)).fill()

        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .center

        let attributes: [NSAttributedString.Key: Any] = [
            .font: NSFont.systemFont(ofSize: pointSize, weight: .regular),
            .foregroundColor: NSColor.labelColor,
            .paragraphStyle: paragraph
        ]
        let text = emoji.isEmpty ? "👌" : emoji
        let attributed = NSAttributedString(string: text, attributes: attributes)
        attributed.draw(in: NSRect(x: 0, y: 1, width: side, height: side))

        image.isTemplate = true
        return image
    }
}
