//
//  GitVisualizerView.swift
//  GitQuest
//
//  Interactive 2D Git graph showing commits, branches, and HEAD
//

import SwiftUI

// MARK: - Git Visualizer View

/// Interactive 2D Git graph that visualises commits, branch pointers,
/// and HEAD. Tapping a commit node opens a detail inspector.
struct GitVisualizerView: View {
    
    var repoState: GitRepositoryState
    
    private let commitSize: CGFloat = 40
    private let commitSpacing: CGFloat = 80
    private let branchSpacing: CGFloat = 42
    private let headIndicatorHeight: CGFloat = 20
    
    @State private var selectedCommit: GitCommit?
    @State private var showVisualizerGuide = false
    
    var body: some View {
        VStack(spacing: 0) {
            
            visualizerHeader
            
            if repoState.isInitialized {
                
                ScrollViewReader { proxy in
                    
                    ScrollView(.horizontal) {
                        commitGraph
                            .padding(.horizontal, 20)
                            .padding(.vertical, 16)
                    }
                    .scrollIndicators(.hidden)
                    .onChange(of: repoState.commits.count) { _ , _ in
                        if let last = repoState.commits.last {
                            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                                proxy.scrollTo(last.id, anchor: .center)
                            }
                        }
                    }
                    .onChange(of: repoState.branches.count) { _ , _ in
                        if let lastCommit = repoState.commits.last {
                            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                                proxy.scrollTo(lastCommit.id, anchor: .center)
                            }
                        }
                    }
                }
                .frame(maxHeight: .infinity)
                
            } else {
                emptyStateView
            }
            
            if let commit = selectedCommit {
                commitInspector(commit)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(GitTheme.darkBackground)
        )
        .sheet(isPresented: $showVisualizerGuide) {
            VisualizerGuideSheet()
        }
    }
}

//////////////////////////////////////////////////////////////
// MARK: HEADER
//////////////////////////////////////////////////////////////

extension GitVisualizerView {
    
    private var visualizerHeader: some View {
        HStack {
            
            // Branch badge (GitHub-style)
            HStack(spacing: 6) {
                Image(systemName: "arrow.triangle.branch")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(currentBranchColor)
                
                Text(repoState.currentBranch)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.white)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(
                Capsule()
                    .fill(currentBranchColor.opacity(0.25))
                    .overlay(
                        Capsule()
                            .stroke(currentBranchColor.opacity(0.5), lineWidth: 1)
                    )
            )
            
            Spacer()
            
            // Stats badges
            HStack(spacing: 12) {
                StatBadge(icon: "circle.fill", value: "\(repoState.commits.count)", color: GitTheme.blue)
                StatBadge(icon: "arrow.triangle.branch", value: "\(repoState.branches.count)", color: GitTheme.purple)
                
                if repoState.hasRemote {
                    Image(systemName: "cloud.fill")
                        .font(.system(size: 12))
                        .foregroundStyle(GitTheme.cyan)
                }
                
                // Help Button
                Button {
                    showVisualizerGuide = true
                } label: {
                    Image(systemName: "questionmark.circle.fill")
                        .font(.system(size: 25, weight: .medium))
                        .foregroundStyle(.white.opacity(0.5))
                        .padding(1)
                }
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
//        .background(Color(white: 0.15))
        .background(Color(red: 0.10, green: 0.10, blue: 0.12))
    }
}

// MARK: - Stat Badge
// ... (lines 116-130 remain same)
private struct StatBadge: View {
    let icon: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 9))
            Text(value)
                .font(.system(size: 11, weight: .medium))
        }
        .foregroundStyle(color.opacity(0.9))
    }
}

//////////////////////////////////////////////////////////////
// MARK: COMMIT GRAPH
//////////////////////////////////////////////////////////////

extension GitVisualizerView {
    
    private var commitGraph: some View {
        VStack(alignment: .leading, spacing: branchSpacing) {
            ForEach(repoState.branches) { branch in
                branchRow(branch: branch)
            }
        }
        .frame(minHeight: 120)
        .padding(.vertical, 4)
    }
    
    private func branchRow(branch: GitBranch) -> some View {
        
        let branchCommits = commitsForBranch(branch)
        
        return HStack(spacing: 0) {
            
            Text(branch.name)
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(branch.color)
                .frame(width: 110, alignment: .trailing)
                .padding(.trailing, 16)
                .padding(.top, headIndicatorHeight / 2) // Align with commit circles
            
            HStack(alignment: .top, spacing: 0) {
                if branchCommits.isEmpty {
                    // Show empty branch indicator
                    VStack(spacing: 0) {
                        Color.clear.frame(height: headIndicatorHeight)
                        Circle()
                            .stroke(branch.color.opacity(0.4), lineWidth: 2)
                            .frame(width: commitSize, height: commitSize)
                            .overlay(
                                Text("—")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundStyle(branch.color.opacity(0.5))
                            )
                    }
                    .frame(width: commitSpacing, alignment: .center)
                } else {
                    ForEach(Array(branchCommits.enumerated()), id: \.element.id) { index, commit in
                        
                        commitNode(commit: commit, branch: branch, isLast: index == branchCommits.count - 1)
                            .id(commit.id)
                        
                        // Connecting line between commits
                        if index < branchCommits.count - 1 {
                            VStack(spacing: 0) {
                                Color.clear.frame(height: headIndicatorHeight)
                                Rectangle()
                                    .fill(branch.color.opacity(0.6))
                                    .frame(width: commitSpacing - commitSize, height: 2.5)
                                    .frame(height: commitSize + 6, alignment: .center)
                            }
                        }
                    }
                }
            }
            
            Spacer(minLength: 20)
        }
        .frame(height: headIndicatorHeight + commitSize + 24) // Fixed height for consistent alignment
        .padding(.vertical, 1)
        .animation(.easeInOut, value: repoState.currentBranch)
        .animation(.easeInOut, value: repoState.branches.count)
    }
}

//////////////////////////////////////////////////////////////
// MARK: COMMIT NODE
//////////////////////////////////////////////////////////////

extension GitVisualizerView {
    
    private func commitNode(commit: GitCommit, branch: GitBranch, isLast: Bool) -> some View {
        
        let isHead = isLast && branch.id == repoState.currentBranch
        
        return VStack(spacing: 0) {
            
            // Fixed-height HEAD indicator area for consistent alignment
            VStack(spacing: 0) {
                if isHead {
                    HStack(spacing: 3) {
                        Circle()
                            .fill(GitTheme.green)
                            .frame(width: 5, height: 5)
                        Text("HEAD")
                            .font(.system(size: 7, weight: .bold))
                            .foregroundStyle(.white)
                    }
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(
                        Capsule()
                            .fill(Color.white.opacity(0.15))
                            .overlay(
                                Capsule()
                                    .stroke(GitTheme.green.opacity(0.6), lineWidth: 1)
                            )
                    )
                }
            }
            .frame(height: headIndicatorHeight)
            
            // Commit circle area
            VStack(spacing: 6) {
                // Commit node with shadow and glow
                ZStack {
                    // Outer glow for new commits
                    if commit.isNew {
                        Circle()
                            .fill(branch.color.opacity(0.3))
                            .frame(width: commitSize + 12, height: commitSize + 12)
                            .blur(radius: 6)
                    }
                    
                    // Shadow circle
                    Circle()
                        .fill(Color.black.opacity(0.4))
                        .frame(width: commitSize, height: commitSize)
                        .offset(y: 2)
                    
                    // Main commit circle
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [branch.color, branch.color.opacity(0.7)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: commitSize, height: commitSize)
                        .overlay(
                            Circle()
                                .stroke(Color.white.opacity(0.3), lineWidth: 1.5)
                        )
                    
                    // New commit ring
                    if commit.isNew {
                        Circle()
                            .stroke(Color.white, lineWidth: 2.5)
                            .frame(width: commitSize - 4, height: commitSize - 4)
                    }
                    
                    // Commit hash
                    Text(String(commit.id.prefix(4)))
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(.white)
                }
                .scaleEffect(commit.isNew ? 1.1 : 1.0)
                .animation(.spring(response: 0.5, dampingFraction: 0.6), value: commit.isNew)
                .onTapGesture {
                    withAnimation(.spring(response: 0.3)) {
                        selectedCommit = selectedCommit?.id == commit.id ? nil : commit
                    }
                }
                
                // Commit message
                Text(commit.message)
                    .font(.system(size: 9, weight: .medium))
                    .foregroundStyle(Color.white.opacity(0.7))
                    .frame(width: commitSize + 40)
                    .lineLimit(1)
                    .truncationMode(.tail)
            }
        }
        .frame(width: commitSpacing, alignment: .center)
    }
}

//////////////////////////////////////////////////////////////
// MARK: COMMIT INSPECTOR
//////////////////////////////////////////////////////////////

extension GitVisualizerView {
    
    private func commitInspector(_ commit: GitCommit) -> some View {
        HStack(spacing: 12) {
            // Commit indicator
            Circle()
                .fill(GitTheme.blue)
                .frame(width: 10, height: 10)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(commit.message)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.white)
                
                HStack(spacing: 8) {
                    Text(commit.id)
                        .font(.system(size: 11))
                        .foregroundStyle(GitTheme.yellow)
                    
                    if let parent = commit.parentId {
                        Text("← \(parent)")
                            .font(.system(size: 10))
                            .foregroundStyle(Color.white.opacity(0.4))
                    }
                }
            }
            
            Spacer()
            
            Button {
                withAnimation { selectedCommit = nil }
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .foregroundStyle(Color.white.opacity(0.4))
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(Color.white.opacity(0.08))
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }
}

//////////////////////////////////////////////////////////////
// MARK: EMPTY STATE
//////////////////////////////////////////////////////////////

extension GitVisualizerView {
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(GitTheme.gray.opacity(0.1))
                    .frame(width: 70, height: 70)
                
                Image(systemName: "folder.badge.questionmark")
                    .font(.system(size: 32))
                    .foregroundStyle(GitTheme.gray.opacity(0.6))
            }
            
            VStack(spacing: 6) {
                Text("No Repository")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Color.white.opacity(0.7))
                
                Text("Run 'git init' to begin")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(GitTheme.orange.opacity(0.8))
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 180)
        .background(GitTheme.darkBackground)
    }
}

//////////////////////////////////////////////////////////////
// MARK: HELPERS
//////////////////////////////////////////////////////////////

extension GitVisualizerView {
    
    private var currentBranchColor: Color {
        repoState.branches.first(where: {
            $0.id == repoState.currentBranch
        })?.color ?? Theme.Colors.primary
    }
    
    private func commitsForBranch(_ branch: GitBranch) -> [GitCommit] {
        guard let headId = branch.headCommitId else { return [] }
        
        var result: [GitCommit] = []
        var currentId: String? = headId
        
        while let id = currentId,
              let commit = repoState.commits.first(where: { $0.id == id }) {
            
            result.insert(commit, at: 0)
            currentId = commit.parentId
        }
        
        return result
    }
}

//////////////////////////////////////////////////////////////
// MARK: VISUALIZER GUIDE SHEET
//////////////////////////////////////////////////////////////

struct VisualizerGuideSheet: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            Color(red: 0.10, green: 0.10, blue: 0.12)
                .ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 24) {
                // Header
                Text("Understanding the Git Graph")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(.white)
                    .padding(.top, 10)
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        guideSection(
                            title: "Commits (Circles)",
                            description: "Each colored circle represents a saved snapshot (commit) in your project history. The 4-character code is the commit's unique ID.",
                            icon: AnyView(
                                Circle()
                                    .fill(GitTheme.blue)
                                    .frame(width: 12, height: 12)
                                    .overlay(Circle().stroke(.white.opacity(0.5), lineWidth: 1))
                            )
                        )
                        
                        guideSection(
                            title: "Branches (Rows)",
                            description: "Each horizontal row is a separate branch - a parallel timeline of your work. Branch names appear on the left.",
                            icon: AnyView(
                                Image(systemName: "arrow.triangle.branch")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundStyle(GitTheme.purple)
                            )
                        )
                        
                        guideSection(
                            title: "Connections (Lines)",
                            description: "Lines connect commits in chronological order, showing the project's evolution from left to right.",
                            icon: AnyView(
                                Rectangle()
                                    .fill(GitTheme.purple.opacity(0.5))
                                    .frame(width: 15, height: 2)
                            )
                        )
                        
                        guideSection(
                            title: "HEAD Badge",
                            description: "The green 'HEAD' label marks where you currently are in the project - your active commit.",
                            icon: AnyView(
                                Text("HEAD")
                                    .font(.system(size: 7, weight: .bold))
                                    .padding(.horizontal, 4)
                                    .padding(.vertical, 2)
                                    .background(Capsule().stroke(GitTheme.green, lineWidth: 1))
                                    .foregroundStyle(GitTheme.green)
                            )
                        )
                        
                        guideSection(
                            title: "Colors",
                            description: "Each branch has its own color to help you visually track different lines of work.",
                            icon: AnyView(
                                HStack(spacing: 4) {
                                    Circle().fill(GitTheme.blue).frame(width: 8, height: 8)
                                    Circle().fill(GitTheme.purple).frame(width: 8, height: 8)
                                    Circle().fill(GitTheme.orange).frame(width: 8, height: 8)
                                }
                            )
                        )
                    }
                    .padding(.bottom, 30)
                }
                .scrollIndicators(.hidden)
            }
            .padding(24)
            
            // Close button
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 24))
                    .foregroundStyle(.white.opacity(0.3))
                    .padding(16)
            }
        }
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
    }
    private func guideSection(title: String, description: String, icon: AnyView) -> some View {
        HStack(alignment: .top, spacing: 12) {
            // Icon container with fixed width
            icon
                .frame(width: 30, alignment: .center)
            
            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.white)
                
                Text(description)
                    .font(.system(size: 12, weight: .regular))
                    .foregroundStyle(.white.opacity(0.7))
                    .lineSpacing(4)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 14)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.04))
        )
    }
}

//////////////////////////////////////////////////////////////
// MARK: PREVIEW
//////////////////////////////////////////////////////////////

#Preview {
    let state = GitRepositoryState()
    
    GitVisualizerView(repoState: state)
//        .frame(height: 320)
//        .padding()
        .onAppear {
            state.initialize()
            state.stageFiles()
            state.commit(message: "Initial commit")
            state.commit(message: "Add login")
            state.createBranch(name: "feature")
            state.commit(message: "Feature work")
        }
}
