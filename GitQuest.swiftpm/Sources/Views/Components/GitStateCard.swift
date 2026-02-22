import SwiftUI

/// Compact panel showing repo status: init, branch, commit count, staged files, and remote. Highlights rows when values change.
struct GitStateCard: View {
    var repoState: GitRepositoryState

    // MARK: - State (for change detection / flash animation)

    @State private var prevCommitCount: Int = 0
    @State private var prevBranch: String = ""
    @State private var prevStaged: Int = 0
    @State private var highlightedRow: String?

    private let cardBg = Theme.Colors.cardBackground
    private let headerBg = Theme.Colors.headerBackground

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            statusHeader
            Divider().background(Color.white.opacity(0.06))
            VStack(spacing: 0) {
                compactStateRow(id: "repo", icon: "folder.badge.gearshape", label: "Repo", value: repoState.isInitialized ? "Init" : "None", statusColor: repoState.isInitialized ? GitTheme.green : GitTheme.gray)
                compactStateRow(id: "branch", icon: "arrow.triangle.branch", label: "Branch", value: repoState.isInitialized ? repoState.currentBranch : "-", statusColor: branchColor)
                compactStateRow(id: "commits", icon: "checkmark.circle", label: "Commits", value: "\(repoState.commits.count)", statusColor: repoState.commits.isEmpty ? GitTheme.gray : GitTheme.blue)
                compactStateRow(id: "staged", icon: "tray.and.arrow.down", label: "Staged", value: stagedFilesText, statusColor: repoState.stagedFiles.isEmpty ? GitTheme.gray : GitTheme.yellow)
                compactStateRow(id: "remote", icon: "cloud", label: "Remote", value: repoState.hasRemote ? repoState.remoteName : "None", statusColor: repoState.hasRemote ? GitTheme.cyan : GitTheme.gray)
            }
            .padding(.vertical, 4)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(RoundedRectangle(cornerRadius: 16).fill(cardBg))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .onChange(of: repoState.commits.count) { _, newValue in
            if newValue != prevCommitCount {
                prevCommitCount = newValue
                flashRow("commits")
            }
        }
        .onChange(of: repoState.currentBranch) { _, newValue in
            if newValue != prevBranch {
                prevBranch = newValue
                flashRow("branch")
            }
        }
        .onChange(of: repoState.stagedFiles.count) { _, newValue in
            if newValue != prevStaged {
                prevStaged = newValue
                flashRow("staged")
            }
        }
        .onChange(of: repoState.isInitialized) { _, _ in flashRow("repo") }
        .onChange(of: repoState.hasRemote) { _, _ in flashRow("remote") }
    }

    // MARK: - Subviews

    private var statusHeader: some View {
        HStack(spacing: 8) {
            Image(systemName: "folder.fill")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(GitTheme.orange)
            Text("Repository")
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(.white)
            Spacer()
            Text(statusLabel)
                .font(.system(size: 9, weight: .bold))
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(statusDotColor.opacity(0.2))
                .foregroundStyle(statusDotColor)
                .clipShape(Capsule())
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 14)
        .background(headerBg)
    }

    private func compactStateRow(id: String, icon: String, label: String, value: String, statusColor: Color) -> some View {
        let isHighlighted = highlightedRow == id
        return HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(statusColor)
                .frame(width: 30)
            Text(label)
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(.white.opacity(0.6))
            Spacer()
            Text(value)
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(statusColor)
                .lineLimit(1)
        }
        .padding(.horizontal, 12)
        .frame(maxHeight: .infinity)
        .padding(.vertical, 6)
        .background(RoundedRectangle(cornerRadius: 6).fill(isHighlighted ? statusColor.opacity(0.12) : Color.clear))
    }

    private func flashRow(_ id: String) {
        withAnimation(.easeIn(duration: 0.15)) {
            highlightedRow = id
        }
        Task { @MainActor in
            try? await Task.sleep(for: .seconds(0.8))
            withAnimation(.easeOut(duration: 0.4)) {
                if highlightedRow == id { highlightedRow = nil }
            }
        }
    }

    private var statusDotColor: Color {
        if !repoState.isInitialized { return GitTheme.gray }
        if !repoState.stagedFiles.isEmpty { return GitTheme.yellow }
        return GitTheme.green
    }

    private var statusLabel: String {
        if !repoState.isInitialized { return "Inactive" }
        if !repoState.stagedFiles.isEmpty { return "Changes Pending" }
        return "Active"
    }

    private var branchColor: Color {
        guard repoState.isInitialized else { return GitTheme.gray }
        return repoState.branches.first(where: { $0.id == repoState.currentBranch })?.color ?? GitTheme.purple
    }

    private var stagedFilesText: String {
        if repoState.stagedFiles.isEmpty { return "None" }
        let count = repoState.stagedFiles.count
        if repoState.stagedFiles.contains(".") { return "All files" }
        return "\(count) file\(count == 1 ? "" : "s")"
    }
}
