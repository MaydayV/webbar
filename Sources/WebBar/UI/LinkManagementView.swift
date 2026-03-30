import SwiftUI

struct LinkManagementView: View {
    @ObservedObject var viewModel: LinkManagementViewModel

    @State private var addDraft = LinkDraft()
    @State private var editDraft = LinkDraft()
    @State private var editingID: UUID?
    @State private var isShowingAddEditor = false
    @State private var isShowingEditEditor = false
    private let gridColumns = [GridItem(.adaptive(minimum: 260, maximum: 340), spacing: 12)]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            headerRow
            contentCard
        }
        .padding(14)
        .background(Color(nsColor: .windowBackgroundColor))
        .sheet(isPresented: $isShowingAddEditor) {
            LinkEditorView(
                draft: $addDraft,
                title: "新增网址",
                submitTitle: "保存",
                onSubmit: {
                    viewModel.addLink(from: addDraft)
                    isShowingAddEditor = false
                },
                onCancel: { isShowingAddEditor = false }
            )
        }
        .sheet(isPresented: $isShowingEditEditor) {
            LinkEditorView(
                draft: $editDraft,
                title: "编辑网址",
                submitTitle: "更新",
                onSubmit: {
                    if let id = editingID {
                        viewModel.updateLink(id: id, draft: editDraft)
                    }
                    isShowingEditEditor = false
                },
                onCancel: { isShowingEditEditor = false }
            )
        }
        .frame(minWidth: 760, minHeight: 420)
    }

    private var headerRow: some View {
        HStack(alignment: .top, spacing: 12) {
            titleCard
            launchCard
        }
    }

    private var titleCard: some View {
        HStack(alignment: .top, spacing: 18) {
            VStack(alignment: .leading, spacing: 4) {
                Text("WebBar 网址管理")
                    .font(.title3.weight(.semibold))
                Text("独立图标、独立打开方式、独立网页记忆。")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding(16)
        .frame(maxWidth: .infinity, minHeight: 88, alignment: .topLeading)
        .background(cardBackground)
    }

    private var launchCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("开机启动")
                .font(.caption.weight(.medium))
                .foregroundStyle(.secondary)
            SettingsView(
                launchAtLoginEnabled: $viewModel.launchAtLoginEnabled,
                onLaunchToggle: viewModel.setLaunchAtLogin
            )
        }
        .padding(16)
        .frame(minWidth: 220, idealWidth: 228, maxWidth: 240, minHeight: 88, alignment: .topLeading)
        .background(cardBackground)
    }

    private var contentCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("网址列表")
                    .font(.headline)
                Button("新增网址") {
                    addDraft = LinkDraft()
                    isShowingAddEditor = true
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.small)
                Spacer()
                Text(viewModel.links.isEmpty ? "暂无网址" : "共 \(viewModel.links.count) 个")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            if let message = viewModel.errorMessage {
                Text(message)
                    .font(.subheadline)
                    .foregroundStyle(.red)
            }

            ScrollView {
                LazyVGrid(columns: gridColumns, alignment: .leading, spacing: 12) {
                    ForEach(viewModel.links) { link in
                        LinkRowView(
                            link: link,
                            onEdit: { beginEditing(link) },
                            onDelete: { viewModel.deleteLink(id: link.id) }
                        )
                    }
                }
                .padding(12)
            }
            .scrollIndicators(.hidden)
            .frame(minHeight: 260)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(Color.primary.opacity(0.03))
            )
        }
        .padding(16)
        .background(cardBackground)
    }

    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: 22, style: .continuous)
            .fill(
                LinearGradient(
                    colors: [
                        Color.white.opacity(0.96),
                        Color.white.opacity(0.9)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .strokeBorder(Color.primary.opacity(0.08), lineWidth: 1)
            )
    }

    private func beginEditing(_ link: LinkItem) {
        editingID = link.id
        editDraft = LinkDraft(
            name: link.name ?? "",
            urlString: link.urlString,
            emoji: {
                if case .emoji(let e) = link.iconPreference { return e }
                return "👌"
            }(),
            openMode: link.openMode,
            reopenBehavior: link.reopenBehavior
        )
        isShowingEditEditor = true
    }
}

private struct LinkListIconView: View {
    let link: LinkItem

    var body: some View {
        Group {
            if case .emoji(let value) = link.iconPreference {
                Text(value.isEmpty ? "👌" : value)
                    .font(.title3)
            } else {
                Text("👌")
                    .font(.title3)
            }
        }
    }
}

private struct LinkRowView: View {
    let link: LinkItem
    let onEdit: () -> Void
    let onDelete: () -> Void
    @State private var isHovered = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 10) {
                LinkListIconView(link: link)
                    .frame(width: 34, height: 34)
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(Color.primary.opacity(0.05))
                    )

                VStack(alignment: .leading, spacing: 6) {
                    Text(link.name ?? "未命名")
                        .font(.headline)
                        .lineLimit(2)

                    Text(link.urlString)
                        .font(.system(.caption, design: .monospaced))
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                        .truncationMode(.middle)
                }

                Spacer(minLength: 0)

                if isHovered {
                    HStack(spacing: 6) {
                        Button("编辑", action: onEdit)
                            .buttonStyle(.bordered)
                        Button("删除", role: .destructive, action: onDelete)
                            .buttonStyle(.bordered)
                    }
                    .controlSize(.small)
                    .transition(.opacity.combined(with: .move(edge: .trailing)))
                }
            }

            HStack(spacing: 6) {
                ManagementTag(text: link.openMode.compactLabel)
                if link.openMode == .embeddedPanel {
                    ManagementTag(text: link.reopenBehavior.displayName, subdued: true)
                }
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color.white.opacity(0.82))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .strokeBorder(Color.primary.opacity(0.05), lineWidth: 1)
        )
        .onHover { hovering in
            withAnimation(.easeOut(duration: 0.16)) {
                isHovered = hovering
            }
        }
    }
}

private struct ManagementTag: View {
    let text: String
    var subdued: Bool = false

    var body: some View {
        Text(text)
            .font(.caption.weight(.semibold))
            .foregroundStyle(.secondary)
            .lineLimit(1)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background((subdued ? Color.primary.opacity(0.06) : Color.primary.opacity(0.09)))
            .clipShape(Capsule())
    }
}
