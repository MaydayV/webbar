import AppKit

extension NSImage {
    func asTemplateImage() -> NSImage {
        let copied = copy() as? NSImage ?? self
        copied.isTemplate = true
        return copied
    }
}
