//
//  GitStateCard.swift
//  GitQuest
//
//  Live-updating repository status card
//

import SwiftUI

// MARK: - Git State Card

/// Live-updating card that displays the current repository status.
///
/// Shows initialisation state, current branch, commit count,
/// staged files, remote connection, and a mini visualiser guide.
struct GitStateCard: View {
    
    var repoState: GitRepositoryState
    
    @State private var prevCommitCount: Int = 0
    @State private var prevBranch: String = ""
    @State private var prevStaged: Int = 0
    @State private var highlightedRow: String? = nil
    
    // Dark palette
    private let cardBg = Color(red: 0.12, green: 0.12, blue: 0.14)
    private let headerBg = Color(red: 0.10, green: 0.10, blue: 0.12)
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // ── HEADER ──
            statusHeader
            
            // ── COMPACT CONTENT ──
            VStack(spacing: 0) {
                compactStateRow(
                    id: "repo",
                    icon: "folder.badge.gearshape",
                    label: "Repo",
                    value: repoState.isInitialized ? "Init" : "None",
                    statusColor: repoState.isInitialized ? GitTheme.green : GitTheme.gray
                )
                
                compactStateRow(
                    id: "branch",
                    icon: "arrow.triangle.branch",
                    label: "Branch",
                    value: repoState.isInitialized ? repoState.currentBranch : "—",
                    statusColor: branchColor
                )
                
                compactStateRow(
                    id: "commits",
                    icon: "checkmark.circle",
                    label: "Commits",
                    value: "\(repoState.commits.count)",
                    statusColor: repoState.commits.isEmpty ? GitTheme.gray : GitTheme.blue
                )
                
                compactStateRow(
                    id: "staged",
                    icon: "tray.and.arrow.down",
                    label: "Staged",
                    value: stagedFilesText,
                    statusColor: repoState.stagedFiles.isEmpty ? GitTheme.gray : GitTheme.yellow
                )
                
                compactStateRow(
                    id: "remote",
                    icon: "cloud",
                    label: "Remote",
                    value: repoState.hasRemote ? repoState.remoteName : "None",
                    statusColor: repoState.hasRemote ? GitTheme.cyan : GitTheme.gray
                )
            }
            .padding(.vertical, 4)
            // Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(cardBg)
        )
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
        .onChange(of: repoState.isInitialized) { _, _ in
            flashRow("repo")
        }
        .onChange(of: repoState.hasRemote) { _, _ in
            flashRow("remote")
        }
    }
    
    // MARK: - Header
    
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
    
    // MARK: - Compact State Row
    
    private func compactStateRow(
        id: String,
        icon: String,
        label: String,
        value: String,
        statusColor: Color
    ) -> some View {
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
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(isHighlighted ? statusColor.opacity(0.12) : Color.clear)
        )
    }
    
    // MARK: - Flash Animation
    
    private func flashRow(_ id: String) {
        withAnimation(.easeIn(duration: 0.15)) {
            highlightedRow = id
        }
        Task { @MainActor in
            try? await Task.sleep(for: .seconds(0.8))
            withAnimation(.easeOut(duration: 0.4)) {
                if highlightedRow == id {
                    highlightedRow = nil
                }
            }
        }
    }
    
    // MARK: - Computed Properties
    
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

// MARK: - Git Theme Colors

/// Colour palette for Git-related UI elements (branches, indicators, labels).
enum GitTheme {
    static let orange = Color(red: 0.96, green: 0.58, blue: 0.12)
    static let green = Color(red: 0.24, green: 0.72, blue: 0.39)
    static let blue = Color(red: 0.18, green: 0.50, blue: 0.93)
    static let purple = Color(red: 0.56, green: 0.27, blue: 0.68)
    static let cyan = Color(red: 0.20, green: 0.67, blue: 0.86)
    static let yellow = Color(red: 0.90, green: 0.72, blue: 0.15)
    static let gray = Color(red: 0.55, green: 0.55, blue: 0.57)
    static let red = Color(red: 0.86, green: 0.24, blue: 0.24)
    
    static let darkBackground = Color(red: 0.11, green: 0.12, blue: 0.14)
    static let headerBackground = Color(red: 0.10, green: 0.10, blue: 0.12)
}
