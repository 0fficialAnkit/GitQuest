import SwiftUI

// MARK: - Git Cheat Sheet

/// A searchable reference of every Git command taught across all GitQuest levels.
struct CheatSheetView: View {
    @State private var searchText = ""

    private var entries: [CheatSheetEntry] {
        Level.allLevels.flatMap { level in
            level.commandExplanation.commands.map { detail in
                CheatSheetEntry(level: level, detail: detail)
            }
        }
    }

    private var filteredEntries: [CheatSheetEntry] {
        guard !searchText.isEmpty else { return entries }
        let query = searchText.lowercased()
        return entries.filter {
            $0.detail.command.lowercased().contains(query) ||
            $0.detail.description.lowercased().contains(query) ||
            $0.level.title.lowercased().contains(query)
        }
    }

    var body: some View {
        ZStack {
            BackgroundView(
                colors: [
                    Theme.Colors.primary.opacity(0.3),
                    Theme.Colors.secondary.opacity(0.3)
                ],
                animation: true
            )

            VStack(spacing: Theme.Spacing.md) {
                header

                searchField

                if filteredEntries.isEmpty {
                    Spacer()
                    VStack(spacing: Theme.Spacing.sm) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 36))
                            .foregroundStyle(Theme.Colors.textTertiary)
                        Text("No commands match \"\(searchText)\"")
                            .font(Theme.Typography.body)
                            .foregroundStyle(Theme.Colors.textSecondary)
                    }
                    Spacer()
                } else {
                    ScrollView(.vertical) {
                        LazyVStack(spacing: Theme.Spacing.sm) {
                            ForEach(filteredEntries) { entry in
                                CheatSheetRow(entry: entry)
                            }
                        }
                        .padding(.horizontal, Theme.Spacing.lg)
                        .padding(.bottom, Theme.Spacing.xl)
                    }
                    .scrollIndicators(.hidden)
                }
            }
            .padding(.top, Theme.Spacing.xl)
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .preferredColorScheme(.dark)
    }

    private var header: some View {
        VStack(spacing: Theme.Spacing.xs) {
            Text("Git Cheat Sheet")
                .font(Theme.Typography.title)
                .foregroundStyle(
                    LinearGradient(
                        colors: [Theme.Colors.primary, Theme.Colors.secondary],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )

            Text("Every command from your journey, in one place")
                .font(Theme.Typography.h3)
                .foregroundStyle(Theme.Colors.textTertiary)
        }
        .padding(.horizontal, Theme.Spacing.lg)
    }

    private var searchField: some View {
        HStack(spacing: Theme.Spacing.sm) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(Theme.Colors.textSecondary)

            TextField("Search commands or concepts", text: $searchText)
                .foregroundStyle(Theme.Colors.textPrimary)
                .autocorrectionDisabled()

            if !searchText.isEmpty {
                Button {
                    searchText = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(Theme.Colors.textTertiary)
                }
            }
        }
        .padding(Theme.Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(Color.white.opacity(0.12), lineWidth: 1)
                )
        )
        .padding(.horizontal, Theme.Spacing.lg)
    }
}

// MARK: - Entry Model

private struct CheatSheetEntry: Identifiable {
    let level: Level
    let detail: CommandDetail

    var id: String { "\(level.id)-\(detail.command)" }
}

// MARK: - Row

private struct CheatSheetRow: View {
    let entry: CheatSheetEntry

    private var color: Color {
        Theme.Colors.conceptColor(entry.level.concept)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            HStack(alignment: .top) {
                Text(entry.detail.command)
                    .font(.system(.body, design: .monospaced).weight(.semibold))
                    .foregroundStyle(color)
                    .padding(.horizontal, Theme.Spacing.sm)
                    .padding(.vertical, 4)
                    .background(
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .fill(color.opacity(0.12))
                    )

                Spacer()

                Text(entry.level.title)
                    .font(Theme.Typography.small)
                    .foregroundStyle(Theme.Colors.textTertiary)
            }

            Text(entry.detail.description)
                .font(Theme.Typography.caption)
                .foregroundStyle(Theme.Colors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)

            Link(destination: entry.level.referenceURL) {
                HStack(spacing: 4) {
                    Text("git-scm.com docs")
                        .font(Theme.Typography.small)
                    Image(systemName: "arrow.up.right")
                        .font(.system(size: 10, weight: .semibold))
                }
                .foregroundStyle(GitTheme.green)
            }
        }
        .padding(Theme.Spacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.regularMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
    }
}

#Preview("Cheat Sheet") {
    NavigationStack {
        CheatSheetView()
    }
    .preferredColorScheme(.dark)
}
