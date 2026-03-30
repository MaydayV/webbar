import AppKit
import SwiftUI

struct LinkEditorView: View {
    private enum Field: Hashable {
        case name
        case url
        case emoji
    }

    @Binding var draft: LinkDraft
    let title: String
    let submitTitle: String
    let onSubmit: () -> Void
    let onCancel: () -> Void
    @FocusState private var focusedField: Field?

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.headline)

            TextField("名称（可选）", text: $draft.name)
                .focused($focusedField, equals: .name)
            HStack(spacing: 8) {
                TextField("URL（例如 https://example.com）", text: $draft.urlString)
                    .focused($focusedField, equals: .url)
                Button("粘贴网址") {
                    pasteURLFromClipboard()
                }
                .keyboardShortcut("v", modifiers: [.command])
                .help("从剪贴板粘贴网址")
            }

            HStack(spacing: 8) {
                TextField("Emoji（例如 👌）", text: $draft.emoji)
                    .focused($focusedField, equals: .emoji)
                Button("选择 Emoji") {
                    focusedField = .emoji
                    DispatchQueue.main.async {
                        EmojiInputCoordinator.prepareForReplacement(firstResponder: NSApp.keyWindow?.firstResponder)
                        NSApp.orderFrontCharacterPalette(nil)
                    }
                }
                .help("打开 macOS 内置 Emoji 与符号面板")
            }

            VStack(alignment: .leading, spacing: 6) {
                Text("打开方式")
                    .font(.subheadline.weight(.semibold))
                Picker("", selection: $draft.openMode) {
                    ForEach(OpenMode.allCases, id: \.self) { mode in
                        Text(mode.displayName).tag(mode)
                    }
                }
                .pickerStyle(.segmented)
                .labelsHidden()

                Text(draft.openMode == .embeddedPanel ? "点击状态栏图标后以内嵌网页弹窗打开，并保留该站点登录状态。" : "点击状态栏图标后交给系统默认浏览器打开。")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            VStack(alignment: .leading, spacing: 6) {
                Text("再次打开时")
                    .font(.subheadline.weight(.semibold))
                Picker("", selection: $draft.reopenBehavior) {
                    ForEach(ReopenBehavior.allCases, id: \.self) { behavior in
                        Text(behavior.displayName).tag(behavior)
                    }
                }
                .pickerStyle(.segmented)
                .labelsHidden()
                .disabled(draft.openMode != .embeddedPanel)

                Text(draft.openMode == .embeddedPanel ? draft.reopenBehavior.descriptionText : "这个设置仅在“内嵌弹窗”模式下生效。")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            HStack {
                Button("取消", action: onCancel)
                Spacer()
                Button(submitTitle, action: onSubmit)
                    .keyboardShortcut(.defaultAction)
            }
        }
        .padding(14)
        .frame(minWidth: 360)
        .onAppear {
            focusedField = .url
        }
        .onChange(of: draft.emoji) { _, newValue in
            let normalized = normalizeEmojiInput(newValue)
            if normalized != newValue {
                draft.emoji = normalized
            }
        }
    }

    private func pasteURLFromClipboard() {
        if let value = NSPasteboard.general.string(forType: .string) {
            draft.urlString = value.trimmingCharacters(in: .whitespacesAndNewlines)
        }
    }

    private func normalizeEmojiInput(_ value: String) -> String {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.isEmpty == false else { return "" }
        return String(trimmed.prefix(1))
    }
}
