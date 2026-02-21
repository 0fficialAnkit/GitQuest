////
////  GitVisualizerView.swift
////  GitQuest
////
////  Interactive 2D Git graph showing commits, branches, and HEAD
////
//
//import SwiftUI
//
//// MARK: - Git Visualizer View
//
///// Interactive 2D Git graph that visualises commits, branch pointers,
///// and HEAD. Tapping a commit node opens a detail inspector.
//struct GitVisualizerView: View {
//    
//    var repoState: GitRepositoryState
//    
//    private let commitSize: CGFloat = 40
//    private let commitSpacing: CGFloat = 80
//    private let branchSpacing: CGFloat = 42
//    private let headIndicatorHeight: CGFloat = 20
//    
//    @State private var selectedCommit: GitCommit?
//    @State private var showVisualizerGuide = false
//    
//    var body: some View {
//        VStack(spacing: 0) {
//            
//            visualizerHeader
//            
//            if repoState.isInitialized {
//                
//                ScrollViewReader { proxy in
//                    
//                    ScrollView(.horizontal) {
//                        commitGraph
//                            .padding(.horizontal, 20)
//                            .padding(.vertical, 16)
//                    }
//                    .scrollIndicators(.hidden)
//                    .onChange(of: repoState.commits.count) { _ , _ in
//                        if let last = repoState.commits.last {
//                            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
//                                proxy.scrollTo(last.id, anchor: .center)
//                            }
//                        }
//                    }
//                    .onChange(of: repoState.branches.count) { _ , _ in
//                        if let lastCommit = repoState.commits.last {
//                            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
//                                proxy.scrollTo(lastCommit.id, anchor: .center)
//                            }
//                        }
//                    }
//                }
//                .frame(maxHeight: .infinity)
//                
//            } else {
//                emptyStateView
//            }
//            
//            if let commit = selectedCommit {
//                commitInspector(commit)
//            }
//        }
//        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
//        .background(
//            RoundedRectangle(cornerRadius: 20)
//                .fill(GitTheme.darkBackground)
//        )
//        .sheet(isPresented: $showVisualizerGuide) {
//            VisualizerGuideSheet()
//        }
//    }
//}
//
////////////////////////////////////////////////////////////////
//// MARK: HEADER
////////////////////////////////////////////////////////////////
//
//extension GitVisualizerView {
//    
//    private var visualizerHeader: some View {
//        HStack {
//            
//            // Branch badge (GitHub-style)
//            HStack(spacing: 6) {
//                Image(systemName: "arrow.triangle.branch")
//                    .font(.system(size: 12, weight: .semibold))
//                    .foregroundStyle(currentBranchColor)
//                
//                Text(repoState.currentBranch)
//                    .font(.system(size: 13, weight: .semibold))
//                    .foregroundStyle(.white)
//            }
//            .padding(.horizontal, 10)
//            .padding(.vertical, 5)
//            .background(
//                Capsule()
//                    .fill(currentBranchColor.opacity(0.25))
//                    .overlay(
//                        Capsule()
//                            .stroke(currentBranchColor.opacity(0.5), lineWidth: 1)
//                    )
//            )
//            
//            Spacer()
//            
//            // Stats badges
//            HStack(spacing: 12) {
//                StatBadge(icon: "circle.fill", value: "\(repoState.commits.count)", color: GitTheme.blue)
//                StatBadge(icon: "arrow.triangle.branch", value: "\(repoState.branches.count)", color: GitTheme.purple)
//                
//                if repoState.hasRemote {
//                    Image(systemName: "cloud.fill")
//                        .font(.system(size: 12))
//                        .foregroundStyle(GitTheme.cyan)
//                }
//                
//                // Help Button
//                Button {
//                    showVisualizerGuide = true
//                } label: {
//                    Image(systemName: "questionmark.circle.fill")
//                        .font(.system(size: 25, weight: .medium))
//                        .foregroundStyle(.white.opacity(0.5))
//                        .padding(1)
//                }
//            }
//        }
//        .padding(.horizontal, 14)
//        .padding(.vertical, 10)
////        .background(Color(white: 0.15))
//        .background(Color(red: 0.10, green: 0.10, blue: 0.12))
//    }
//}
//
//// MARK: - Stat Badge
//// ... (lines 116-130 remain same)
//private struct StatBadge: View {
//    let icon: String
//    let value: String
//    let color: Color
//    
//    var body: some View {
//        HStack(spacing: 4) {
//            Image(systemName: icon)
//                .font(.system(size: 9))
//            Text(value)
//                .font(.system(size: 11, weight: .medium))
//        }
//        .foregroundStyle(color.opacity(0.9))
//    }
//}
//
////////////////////////////////////////////////////////////////
//// MARK: COMMIT GRAPH
////////////////////////////////////////////////////////////////
//
//extension GitVisualizerView {
//    
//    private var commitGraph: some View {
//        VStack(alignment: .leading, spacing: branchSpacing) {
//            ForEach(repoState.branches) { branch in
//                branchRow(branch: branch)
//            }
//        }
//        .frame(minHeight: 120)
//        .padding(.vertical, 4)
//    }
//    
//    private func branchRow(branch: GitBranch) -> some View {
//        
//        let branchCommits = commitsForBranch(branch)
//        
//        return HStack(spacing: 0) {
//            
//            Text(branch.name)
//                .font(.system(size: 11, weight: .medium))
//                .foregroundStyle(branch.color)
//                .frame(width: 110, alignment: .trailing)
//                .padding(.trailing, 16)
//                .padding(.top, headIndicatorHeight / 2) // Align with commit circles
//            
//            HStack(alignment: .top, spacing: 0) {
//                if branchCommits.isEmpty {
//                    // Show empty branch indicator
//                    VStack(spacing: 0) {
//                        Color.clear.frame(height: headIndicatorHeight)
//                        Circle()
//                            .stroke(branch.color.opacity(0.4), lineWidth: 2)
//                            .frame(width: commitSize, height: commitSize)
//                            .overlay(
//                                Text("—")
//                                    .font(.system(size: 16, weight: .medium))
//                                    .foregroundStyle(branch.color.opacity(0.5))
//                            )
//                    }
//                    .frame(width: commitSpacing, alignment: .center)
//                } else {
//                    ForEach(Array(branchCommits.enumerated()), id: \.element.id) { index, commit in
//                        
//                        commitNode(commit: commit, branch: branch, isLast: index == branchCommits.count - 1)
//                            .id(commit.id)
//                        
//                        // Connecting line between commits
//                        if index < branchCommits.count - 1 {
//                            VStack(spacing: 0) {
//                                Color.clear.frame(height: headIndicatorHeight)
//                                Rectangle()
//                                    .fill(branch.color.opacity(0.6))
//                                    .frame(width: commitSpacing - commitSize, height: 2.5)
//                                    .frame(height: commitSize + 6, alignment: .center)
//                            }
//                        }
//                    }
//                }
//            }
//            
//            Spacer(minLength: 20)
//        }
//        .frame(height: headIndicatorHeight + commitSize + 24) // Fixed height for consistent alignment
//        .padding(.vertical, 1)
//        .animation(.easeInOut, value: repoState.currentBranch)
//        .animation(.easeInOut, value: repoState.branches.count)
//    }
//}
//
////////////////////////////////////////////////////////////////
//// MARK: COMMIT NODE
////////////////////////////////////////////////////////////////
//
//extension GitVisualizerView {
//    
//    private func commitNode(commit: GitCommit, branch: GitBranch, isLast: Bool) -> some View {
//        
//        let isHead = isLast && branch.id == repoState.currentBranch
//        
//        return VStack(spacing: 0) {
//            
//            // Fixed-height HEAD indicator area for consistent alignment
//            VStack(spacing: 0) {
//                if isHead {
//                    HStack(spacing: 3) {
//                        Circle()
//                            .fill(GitTheme.green)
//                            .frame(width: 5, height: 5)
//                        Text("HEAD")
//                            .font(.system(size: 7, weight: .bold))
//                            .foregroundStyle(.white)
//                    }
//                    .padding(.horizontal, 6)
//                    .padding(.vertical, 2)
//                    .background(
//                        Capsule()
//                            .fill(Color.white.opacity(0.15))
//                            .overlay(
//                                Capsule()
//                                    .stroke(GitTheme.green.opacity(0.6), lineWidth: 1)
//                            )
//                    )
//                }
//            }
//            .frame(height: headIndicatorHeight)
//            
//            // Commit circle area
//            VStack(spacing: 6) {
//                // Commit node with shadow and glow
//                ZStack {
//                    // Outer glow for new commits
//                    if commit.isNew {
//                        Circle()
//                            .fill(branch.color.opacity(0.3))
//                            .frame(width: commitSize + 12, height: commitSize + 12)
//                            .blur(radius: 6)
//                    }
//                    
//                    // Shadow circle
//                    Circle()
//                        .fill(Color.black.opacity(0.4))
//                        .frame(width: commitSize, height: commitSize)
//                        .offset(y: 2)
//                    
//                    // Main commit circle
//                    Circle()
//                        .fill(
//                            LinearGradient(
//                                colors: [branch.color, branch.color.opacity(0.7)],
//                                startPoint: .topLeading,
//                                endPoint: .bottomTrailing
//                            )
//                        )
//                        .frame(width: commitSize, height: commitSize)
//                        .overlay(
//                            Circle()
//                                .stroke(Color.white.opacity(0.3), lineWidth: 1.5)
//                        )
//                    
//                    // New commit ring
//                    if commit.isNew {
//                        Circle()
//                            .stroke(Color.white, lineWidth: 2.5)
//                            .frame(width: commitSize - 4, height: commitSize - 4)
//                    }
//                    
//                    // Commit hash
//                    Text(String(commit.id.prefix(4)))
//                        .font(.system(size: 10, weight: .bold))
//                        .foregroundStyle(.white)
//                }
//                .scaleEffect(commit.isNew ? 1.1 : 1.0)
//                .animation(.spring(response: 0.5, dampingFraction: 0.6), value: commit.isNew)
//                .onTapGesture {
//                    withAnimation(.spring(response: 0.3)) {
//                        selectedCommit = selectedCommit?.id == commit.id ? nil : commit
//                    }
//                }
//                
//                // Commit message
//                Text(commit.message)
//                    .font(.system(size: 9, weight: .medium))
//                    .foregroundStyle(Color.white.opacity(0.7))
//                    .frame(width: commitSize + 40)
//                    .lineLimit(1)
//                    .truncationMode(.tail)
//            }
//        }
//        .frame(width: commitSpacing, alignment: .center)
//    }
//}
//
////////////////////////////////////////////////////////////////
//// MARK: COMMIT INSPECTOR
////////////////////////////////////////////////////////////////
//
//extension GitVisualizerView {
//    
//    private func commitInspector(_ commit: GitCommit) -> some View {
//        HStack(spacing: 12) {
//            // Commit indicator
//            Circle()
//                .fill(GitTheme.blue)
//                .frame(width: 10, height: 10)
//            
//            VStack(alignment: .leading, spacing: 2) {
//                Text(commit.message)
//                    .font(.system(size: 13, weight: .semibold))
//                    .foregroundStyle(.white)
//                
//                HStack(spacing: 8) {
//                    Text(commit.id)
//                        .font(.system(size: 11))
//                        .foregroundStyle(GitTheme.yellow)
//                    
//                    if let parent = commit.parentId {
//                        Text("← \(parent)")
//                            .font(.system(size: 10))
//                            .foregroundStyle(Color.white.opacity(0.4))
//                    }
//                }
//            }
//            
//            Spacer()
//            
//            Button {
//                withAnimation { selectedCommit = nil }
//            } label: {
//                Image(systemName: "xmark.circle.fill")
//                    .foregroundStyle(Color.white.opacity(0.4))
//            }
//        }
//        .padding(.horizontal, 14)
//        .padding(.vertical, 10)
//        .background(Color.white.opacity(0.08))
//        .transition(.move(edge: .bottom).combined(with: .opacity))
//    }
//}
//
////////////////////////////////////////////////////////////////
//// MARK: EMPTY STATE
////////////////////////////////////////////////////////////////
//
//extension GitVisualizerView {
//    
//    private var emptyStateView: some View {
//        VStack(spacing: 16) {
//            ZStack {
//                Circle()
//                    .fill(GitTheme.gray.opacity(0.1))
//                    .frame(width: 70, height: 70)
//                
//                Image(systemName: "folder.badge.questionmark")
//                    .font(.system(size: 32))
//                    .foregroundStyle(GitTheme.gray.opacity(0.6))
//            }
//            
//            VStack(spacing: 6) {
//                Text("No Repository")
//                    .font(.system(size: 15, weight: .semibold))
//                    .foregroundStyle(Color.white.opacity(0.7))
//                
//                Text("Run 'git init' to begin")
//                    .font(.system(size: 12, weight: .medium))
//                    .foregroundStyle(GitTheme.orange.opacity(0.8))
//            }
//        }
//        .frame(maxWidth: .infinity)
//        .frame(height: 180)
//        .background(GitTheme.darkBackground)
//    }
//}
//
////////////////////////////////////////////////////////////////
//// MARK: HELPERS
////////////////////////////////////////////////////////////////
//
//extension GitVisualizerView {
//    
//    private var currentBranchColor: Color {
//        repoState.branches.first(where: {
//            $0.id == repoState.currentBranch
//        })?.color ?? Theme.Colors.primary
//    }
//    
//    private func commitsForBranch(_ branch: GitBranch) -> [GitCommit] {
//        guard let headId = branch.headCommitId else { return [] }
//        
//        var result: [GitCommit] = []
//        var currentId: String? = headId
//        
//        while let id = currentId,
//              let commit = repoState.commits.first(where: { $0.id == id }) {
//            
//            result.insert(commit, at: 0)
//            currentId = commit.parentId
//        }
//        
//        return result
//    }
//}
//
////////////////////////////////////////////////////////////////
//// MARK: VISUALIZER GUIDE SHEET
////////////////////////////////////////////////////////////////
//
//struct VisualizerGuideSheet: View {
//    @Environment(\.dismiss) var dismiss
//    
//    var body: some View {
//        ZStack(alignment: .topTrailing) {
//            Color(red: 0.10, green: 0.10, blue: 0.12)
//                .ignoresSafeArea()
//            
//            VStack(alignment: .leading, spacing: 24) {
//                // Header
//                Text("Understanding the Git Graph")
//                    .font(.system(size: 18, weight: .bold))
//                    .foregroundStyle(.white)
//                    .padding(.top, 10)
//                
//                ScrollView {
//                    VStack(alignment: .leading, spacing: 20) {
//                        guideSection(
//                            title: "Commits (Circles)",
//                            description: "Each colored circle represents a saved snapshot (commit) in your project history. The 4-character code is the commit's unique ID.",
//                            icon: AnyView(
//                                Circle()
//                                    .fill(GitTheme.blue)
//                                    .frame(width: 12, height: 12)
//                                    .overlay(Circle().stroke(.white.opacity(0.5), lineWidth: 1))
//                            )
//                        )
//                        
//                        guideSection(
//                            title: "Branches (Rows)",
//                            description: "Each horizontal row is a separate branch - a parallel timeline of your work. Branch names appear on the left.",
//                            icon: AnyView(
//                                Image(systemName: "arrow.triangle.branch")
//                                    .font(.system(size: 10, weight: .bold))
//                                    .foregroundStyle(GitTheme.purple)
//                            )
//                        )
//                        
//                        guideSection(
//                            title: "Connections (Lines)",
//                            description: "Lines connect commits in chronological order, showing the project's evolution from left to right.",
//                            icon: AnyView(
//                                Rectangle()
//                                    .fill(GitTheme.purple.opacity(0.5))
//                                    .frame(width: 15, height: 2)
//                            )
//                        )
//                        
//                        guideSection(
//                            title: "HEAD Badge",
//                            description: "The green 'HEAD' label marks where you currently are in the project - your active commit.",
//                            icon: AnyView(
//                                Text("HEAD")
//                                    .font(.system(size: 7, weight: .bold))
//                                    .padding(.horizontal, 4)
//                                    .padding(.vertical, 2)
//                                    .background(Capsule().stroke(GitTheme.green, lineWidth: 1))
//                                    .foregroundStyle(GitTheme.green)
//                            )
//                        )
//                        
//                        guideSection(
//                            title: "Colors",
//                            description: "Each branch has its own color to help you visually track different lines of work.",
//                            icon: AnyView(
//                                HStack(spacing: 4) {
//                                    Circle().fill(GitTheme.blue).frame(width: 8, height: 8)
//                                    Circle().fill(GitTheme.purple).frame(width: 8, height: 8)
//                                    Circle().fill(GitTheme.orange).frame(width: 8, height: 8)
//                                }
//                            )
//                        )
//                    }
//                    .padding(.bottom, 30)
//                }
//                .scrollIndicators(.hidden)
//            }
//            .padding(24)
//            
//            // Close button
//            Button {
//                dismiss()
//            } label: {
//                Image(systemName: "xmark.circle.fill")
//                    .font(.system(size: 24))
//                    .foregroundStyle(.white.opacity(0.3))
//                    .padding(16)
//            }
//        }
//        .presentationDetents([.medium])
//        .presentationDragIndicator(.visible)
//    }
//    private func guideSection(title: String, description: String, icon: AnyView) -> some View {
//        HStack(alignment: .top, spacing: 12) {
//            // Icon container with fixed width
//            icon
//                .frame(width: 30, alignment: .center)
//            
//            VStack(alignment: .leading, spacing: 6) {
//                Text(title)
//                    .font(.system(size: 13, weight: .semibold))
//                    .foregroundStyle(.white)
//                
//                Text(description)
//                    .font(.system(size: 12, weight: .regular))
//                    .foregroundStyle(.white.opacity(0.7))
//                    .lineSpacing(4)
//                    .fixedSize(horizontal: false, vertical: true)
//            }
//        }
//        .frame(maxWidth: .infinity, alignment: .leading)
//        .padding(.horizontal, 14)
//        .padding(.vertical, 14)
//        .background(
//            RoundedRectangle(cornerRadius: 12)
//                .fill(Color.white.opacity(0.04))
//        )
//    }
//}
//
////////////////////////////////////////////////////////////////
//// MARK: PREVIEW
////////////////////////////////////////////////////////////////
//
//#Preview {
//    let state = GitRepositoryState()
//    
//    GitVisualizerView(repoState: state)
////        .frame(height: 320)
////        .padding()
//        .onAppear {
//            state.initialize()
//            state.stageFiles()
//            state.commit(message: "Initial commit")
//            state.commit(message: "Add login")
//            state.createBranch(name: "feature")
//            state.commit(message: "Feature work")
//        }
//}







//
//  GitVisualizerView.swift
//  GitQuest
//
//  Full git-graph visualizer: lane layout, bezier connections,
//  merge arcs, animated HEAD, staging indicator, action banner.
//

import SwiftUI

// MARK: - Private Layout Model

/// Computed position for a single commit in the 2-D canvas.
private struct CommitLayout: Identifiable {
    let commit:      GitCommit
    let lane:        Int       // horizontal row (0 = main)
    let globalIndex: Int       // x-axis position (chronological order)
    let center:      CGPoint   // pixel center in the canvas
    let color:       Color
    var id: String { commit.id }
}

// MARK: - Git Visualizer View

struct GitVisualizerView: View {

    var repoState: GitRepositoryState

    // Layout constants
    private let r:    CGFloat = 18   // node radius
    private let hSp:  CGFloat = 80   // horizontal spacing (center-to-center)
    private let vSp:  CGFloat = 62   // vertical spacing (lane-to-lane)
    private let lPad: CGFloat = 36   // left canvas padding
    private let tPad: CGFloat = 50   // top padding (room for HEAD badge above)

    @State private var selectedCommit: GitCommit?
    @State private var pulseOn   = false
    @State private var showGuide = false

    // MARK: – Lane & Color Maps

    private var branchLanes: [String: Int] {
        var result: [String: Int] = [:]
        var next = 1
        for branch in repoState.branches where branch.name == "main" { result["main"] = 0 }
        if result.isEmpty, let first = repoState.branches.first { result[first.name] = 0; next = 1 }
        for branch in repoState.branches where branch.name != "main" {
            if result[branch.name] == nil { result[branch.name] = next; next += 1 }
        }
        return result
    }

    private var colorMap: [String: Color] {
        Dictionary(uniqueKeysWithValues: repoState.branches.map { ($0.name, $0.color) })
    }

    // MARK: – Computed Layouts

    private var layouts: [CommitLayout] {
        let l = branchLanes; let c = colorMap
        return repoState.commits.enumerated().map { idx, commit in
            let lane  = l[commit.branch] ?? 0
            let color = c[commit.branch] ?? GitTheme.purple
            return CommitLayout(
                commit:      commit,
                lane:        lane,
                globalIndex: idx,
                center:      CGPoint(x: lPad + CGFloat(idx) * hSp,
                                     y: tPad + CGFloat(lane) * vSp),
                color:       color
            )
        }
    }

    private var byId: [String: CommitLayout] {
        Dictionary(uniqueKeysWithValues: layouts.map { ($0.id, $0) })
    }

    private var headLayout: CommitLayout? {
        guard let branch = repoState.branches.first(where: { $0.name == repoState.currentBranch }),
              let headId = branch.headCommitId else { return nil }
        return byId[headId]
    }

    private var canvasSize: CGSize {
        let maxLane   = branchLanes.values.max() ?? 0
        let commitCnt = max(repoState.commits.count, 1)
        let w = lPad + CGFloat(commitCnt) * hSp + 190
        let h = tPad + CGFloat(maxLane + 1) * vSp + 32
        return CGSize(width: max(w, 280), height: max(h, 120))
    }

    /// Dashed arcs for merge commits.
    private var mergeArcs: [(from: CommitLayout, to: CommitLayout)] {
        layouts.compactMap { node in
            guard node.commit.message.hasPrefix("Merge branch '") else { return nil }
            let rest = node.commit.message.dropFirst("Merge branch '".count)
            guard let eq = rest.firstIndex(of: "'") else { return nil }
            let src = String(rest[..<eq])
            let candidates = layouts.filter { $0.commit.branch == src && $0.globalIndex < node.globalIndex }
            guard let tip = candidates.last else { return nil }
            return (from: tip, to: node)
        }
    }

    // MARK: – Body

    var body: some View {
        VStack(spacing: 0) {
            headerBar

            if repoState.isInitialized {
                graphScroller

                if let commit = selectedCommit {
                    Divider().overlay(Color.white.opacity(0.08))
                    commitInspector(commit)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                } else if let action = repoState.lastAction {
                    Divider().overlay(Color.white.opacity(0.08))
                    actionStrip(action)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            } else {
                emptyState
            }
        }
        .background(RoundedRectangle(cornerRadius: 20).fill(GitTheme.darkBackground))
        .sheet(isPresented: $showGuide) { VisualizerGuideSheet() }
        .onAppear { pulseOn = true }
    }

    // MARK: – Graph Scroller

    private var graphScroller: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                graphCanvas
                    .frame(width: canvasSize.width, height: canvasSize.height)
            }
            .onChange(of: repoState.commits.count) { _, _ in
                if let last = layouts.last {
                    withAnimation(.spring(response: 0.5)) { proxy.scrollTo(last.id, anchor: .trailing) }
                }
            }
            .onChange(of: repoState.currentBranch) { _, _ in
                if let head = headLayout {
                    withAnimation(.spring()) { proxy.scrollTo(head.id, anchor: .center) }
                }
            }
        }
        .frame(maxHeight: .infinity)
    }

    // MARK: – Graph Canvas

    private var graphCanvas: some View {
        ZStack(alignment: .topLeading) {
            Canvas { ctx, _ in drawLaneTracks(&ctx) }
                .frame(width: canvasSize.width, height: canvasSize.height)

            Canvas { ctx, _ in drawConnections(&ctx) }
                .frame(width: canvasSize.width, height: canvasSize.height)

            Canvas { ctx, _ in drawMergeArcs(&ctx) }
                .frame(width: canvasSize.width, height: canvasSize.height)

            if repoState.hasRemote    { remoteOriginView }
            if repoState.commits.isEmpty { initPlaceholder }

            ForEach(layouts) { node in
                commitNodeView(node).id(node.id)
            }

            ForEach(repoState.branches) { branch in
                branchLabelView(for: branch)
            }
        }
    }

    // MARK: – Canvas Drawing

    private func drawLaneTracks(_ ctx: inout GraphicsContext) {
        for (branchName, lane) in branchLanes {
            guard let color = colorMap[branchName] else { continue }
            let laneNodes = layouts.filter { $0.lane == lane }
            guard laneNodes.count >= 2,
                  let first = laneNodes.first, let last = laneNodes.last else { continue }
            var p = Path()
            p.move(to: first.center); p.addLine(to: last.center)
            ctx.stroke(p, with: .color(color.opacity(0.07)), lineWidth: 8)
        }
    }

    private func drawConnections(_ ctx: inout GraphicsContext) {
        for node in layouts {
            guard let parentId = node.commit.parentId,
                  let parent   = byId[parentId] else { continue }
            let from = CGPoint(x: parent.center.x + r, y: parent.center.y)
            let to   = CGPoint(x: node.center.x   - r, y: node.center.y)
            var p = Path()
            if parent.lane == node.lane {
                p.move(to: from); p.addLine(to: to)
                ctx.stroke(p, with: .color(node.color.opacity(0.72)), lineWidth: 2.5)
            } else {
                let dx = to.x - from.x
                p.move(to: from)
                p.addCurve(to: to,
                           control1: CGPoint(x: from.x + dx * 0.55, y: from.y),
                           control2: CGPoint(x: to.x   - dx * 0.2,  y: to.y))
                ctx.stroke(p, with: .color(node.color.opacity(0.62)), lineWidth: 2.5)
            }
        }
    }

    private func drawMergeArcs(_ ctx: inout GraphicsContext) {
        for arc in mergeArcs {
            let from = CGPoint(x: arc.from.center.x + r, y: arc.from.center.y)
            let to   = CGPoint(x: arc.to.center.x   - r, y: arc.to.center.y)
            var p = Path()
            p.move(to: from)
            p.addCurve(to: to,
                       control1: CGPoint(x: to.x, y: from.y),
                       control2: CGPoint(x: to.x - 18, y: to.y))
            ctx.stroke(p, with: .color(arc.from.color.opacity(0.68)),
                       style: StrokeStyle(lineWidth: 2.2, dash: [5, 3.5]))

            // Arrowhead
            let angle  = atan2(to.y - from.y, to.x - from.x)
            let arrowL: CGFloat = 9
            var arrow  = Path()
            arrow.move(to: to)
            arrow.addLine(to: CGPoint(x: to.x - arrowL * cos(angle - 0.45),
                                      y: to.y - arrowL * sin(angle - 0.45)))
            arrow.move(to: to)
            arrow.addLine(to: CGPoint(x: to.x - arrowL * cos(angle + 0.45),
                                      y: to.y - arrowL * sin(angle + 0.45)))
            ctx.stroke(arrow, with: .color(arc.from.color.opacity(0.7)), lineWidth: 1.8)
        }
    }

    // MARK: – Special Overlays

    private var remoteOriginView: some View {
        let mainNodes = layouts.filter { branchLanes[$0.commit.branch] == 0 }
        guard let lastMain = mainNodes.last else { return AnyView(EmptyView()) }
        return AnyView(
            VStack(spacing: 3) {
                Image(systemName: "cloud.fill")
                    .font(.system(size: 22))
                    .foregroundStyle(LinearGradient(
                        colors: [GitTheme.cyan, GitTheme.blue], startPoint: .top, endPoint: .bottom))
                    .shadow(color: GitTheme.cyan.opacity(0.45), radius: 6)
                Text("origin")
                    .font(.system(size: 8, weight: .semibold, design: .monospaced))
                    .foregroundStyle(GitTheme.cyan.opacity(0.65))
            }
            .position(x: lastMain.center.x + hSp * 0.85, y: lastMain.center.y - 36)
        )
    }

    private var initPlaceholder: some View {
        ZStack {
            Circle()
                .strokeBorder(style: StrokeStyle(lineWidth: 2, dash: [5, 4]))
                .foregroundStyle(GitTheme.gray.opacity(0.35))
                .frame(width: r * 2, height: r * 2)
            Text("...")
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(GitTheme.gray.opacity(0.5))
        }
        .position(x: lPad, y: tPad)
    }

    // MARK: – Commit Node View

    private func commitNodeView(_ node: CommitLayout) -> some View {
        let isHead     = headLayout?.id == node.id
        let isNew      = node.commit.isNew
        let isStaged   = isHead && !repoState.stagedFiles.isEmpty
        let isSelected = selectedCommit?.id == node.id
        let d = r * 2

        return ZStack {
            // Ambient glow (new commits)
            if isNew {
                Circle()
                    .fill(node.color.opacity(0.28))
                    .frame(width: d + 22, height: d + 22)
                    .blur(radius: 10)
            }

            // Rotating staging ring
            if isStaged {
                Circle()
                    .stroke(
                        AngularGradient(
                            colors: [GitTheme.yellow, GitTheme.orange, GitTheme.yellow],
                            center: .center),
                        lineWidth: 3)
                    .frame(width: d + 14, height: d + 14)
                    .rotationEffect(.degrees(pulseOn ? 360 : 0))
                    .animation(.linear(duration: 2.8).repeatForever(autoreverses: false), value: pulseOn)
            }

            // Selection ring
            if isSelected {
                Circle()
                    .stroke(.white.opacity(0.6), lineWidth: 2.5)
                    .frame(width: d + 7, height: d + 7)
            }

            // Main commit circle
            Circle()
                .fill(LinearGradient(
                    colors: [node.color.opacity(0.95), node.color.opacity(0.6)],
                    startPoint: .topLeading, endPoint: .bottomTrailing))
                .frame(width: d, height: d)
                .overlay(Circle().stroke(.white.opacity(isNew ? 0.55 : 0.22), lineWidth: 1.5))
                .shadow(color: node.color.opacity(isNew ? 0.65 : 0.28), radius: isNew ? 10 : 4)

            // Short hash
            Text(String(node.commit.id.prefix(4)))
                .font(.system(size: 9, weight: .bold, design: .monospaced))
                .foregroundStyle(.white.opacity(0.92))

            // HEAD badge
            if isHead {
                headBadgeView
                    .offset(y: -(r + 17))
            }

            // Staged file chips
            if isStaged {
                HStack(spacing: 2) {
                    ForEach(0..<min(repoState.stagedFiles.count, 3), id: \.self) { _ in
                        RoundedRectangle(cornerRadius: 2)
                            .fill(GitTheme.yellow.opacity(0.9))
                            .frame(width: 5, height: 7)
                    }
                    if repoState.stagedFiles.count > 3 {
                        Text("+\(repoState.stagedFiles.count - 3)")
                            .font(.system(size: 7, weight: .bold))
                            .foregroundStyle(GitTheme.yellow)
                    }
                }
                .offset(y: r + 11)
            }

            // Commit message label
            Text(node.commit.message)
                .font(.system(size: isSelected ? 9.5 : 8.5, weight: isSelected ? .medium : .regular))
                .foregroundStyle(isSelected ? .white.opacity(0.9) : .white.opacity(0.42))
                .lineLimit(isSelected ? 2 : 1)
                .multilineTextAlignment(.center)
                .frame(width: max(d + 48, 80))
                .background {
                    if isSelected {
                        RoundedRectangle(cornerRadius: 5)
                            .fill(Color.black.opacity(0.6))
                            .padding(.horizontal, -5).padding(.vertical, -2)
                    }
                }
                .offset(y: r + (isStaged ? 26 : 14))
        }
        .scaleEffect(isNew ? 1.1 : 1.0)
        .animation(.spring(response: 0.45, dampingFraction: 0.6), value: isNew)
        .frame(width: d + 34, height: d + 34)
        .position(node.center)
        .onTapGesture {
            withAnimation(.spring(response: 0.3)) {
                selectedCommit = selectedCommit?.id == node.id ? nil : node.commit
            }
        }
    }

    private var headBadgeView: some View {
        HStack(spacing: 3) {
            Circle().fill(GitTheme.green).frame(width: 5, height: 5)
            Text("HEAD")
                .font(.system(size: 7.5, weight: .bold))
                .foregroundStyle(.white)
        }
        .padding(.horizontal, 7).padding(.vertical, 3)
        .background(
            Capsule()
                .fill(Color.black.opacity(0.65))
                .overlay(Capsule().stroke(GitTheme.green.opacity(0.9), lineWidth: 1.2))
        )
        .shadow(color: GitTheme.green.opacity(0.55), radius: 5)
        .scaleEffect(pulseOn ? 1.06 : 1.0)
        .animation(.easeInOut(duration: 1.1).repeatForever(autoreverses: true), value: pulseOn)
    }

    // MARK: – Branch Label View

    @ViewBuilder
    private func branchLabelView(for branch: GitBranch) -> some View {
        if let lane   = branchLanes[branch.name],
           let headId = branch.headCommitId,
           let head   = byId[headId] {

            let isActive = branch.name == repoState.currentBranch
            let cx = head.center.x + r + 68
            let cy = tPad + CGFloat(lane) * vSp

            HStack(spacing: 4) {
                if isActive {
                    Circle().fill(GitTheme.green).frame(width: 5, height: 5)
                } else {
                    Image(systemName: "arrow.triangle.branch")
                        .font(.system(size: 7, weight: .semibold))
                        .foregroundStyle(branch.color.opacity(0.7))
                }
                Text(branch.name)
                    .font(.system(size: 9, weight: isActive ? .bold : .medium))
                    .lineLimit(1)
                    .foregroundStyle(isActive ? .white : branch.color.opacity(0.85))
            }
            .padding(.horizontal, 7).padding(.vertical, 3.5)
            .background(
                RoundedRectangle(cornerRadius: 5)
                    .fill(branch.color.opacity(isActive ? 0.28 : 0.10))
                    .overlay(RoundedRectangle(cornerRadius: 5)
                        .stroke(branch.color.opacity(isActive ? 0.65 : 0.28), lineWidth: 1))
            )
            .fixedSize()
            .position(x: cx, y: cy)
            .animation(.spring(response: 0.45), value: isActive)
        }
    }

    // MARK: – Header Bar

    private var headerBar: some View {
        HStack {
            let bColor = repoState.branches.first(where: { $0.name == repoState.currentBranch })?.color ?? GitTheme.purple
            HStack(spacing: 5) {
                Image(systemName: "arrow.triangle.branch").font(.system(size: 11, weight: .semibold))
                Text(repoState.currentBranch).font(.system(size: 12, weight: .semibold))
            }
            .foregroundStyle(bColor)
            .padding(.horizontal, 10).padding(.vertical, 5)
            .background(Capsule().fill(bColor.opacity(0.2))
                .overlay(Capsule().stroke(bColor.opacity(0.5), lineWidth: 1)))

            Spacer()

            HStack(spacing: 10) {
                StatBadge(icon: "circle.fill",           value: "\(repoState.commits.count)",  color: GitTheme.blue)
                StatBadge(icon: "arrow.triangle.branch", value: "\(repoState.branches.count)", color: GitTheme.purple)
                if repoState.hasRemote {
                    Image(systemName: "cloud.fill").font(.system(size: 11)).foregroundStyle(GitTheme.cyan)
                }
                if !repoState.stagedFiles.isEmpty {
                    HStack(spacing: 3) {
                        Image(systemName: "tray.and.arrow.down.fill").font(.system(size: 10))
                        Text("\(repoState.stagedFiles.count)").font(.system(size: 10, weight: .bold))
                    }
                    .foregroundStyle(GitTheme.yellow)
                }
                Button { showGuide = true } label: {
                    Image(systemName: "questionmark.circle.fill")
                        .font(.system(size: 22)).foregroundStyle(.white.opacity(0.4))
                }
            }
        }
        .padding(.horizontal, 14).padding(.vertical, 10)
        .background(Color(red: 0.10, green: 0.10, blue: 0.12))
        .fixedSize(horizontal: false, vertical: true)
    }

    // MARK: – Action Strip

    private func actionStrip(_ action: GitAction) -> some View {
        HStack(spacing: 10) {
            ZStack {
                Circle().fill(actionColor(action.type).opacity(0.18)).frame(width: 28, height: 28)
                Image(systemName: actionIcon(action.type))
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(actionColor(action.type))
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(action.command)
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .foregroundStyle(actionColor(action.type))
                Text(action.explanation)
                    .font(.system(size: 10))
                    .foregroundStyle(.white.opacity(0.55))
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer()
        }
        .padding(.horizontal, 14).padding(.vertical, 9)
        .background(Color.white.opacity(0.04))
        .animation(.easeInOut, value: action.command)
    }

    // MARK: – Commit Inspector

    private func commitInspector(_ commit: GitCommit) -> some View {
        HStack(spacing: 10) {
            Circle()
                .fill(colorMap[commit.branch] ?? GitTheme.blue)
                .frame(width: 9, height: 9)
            VStack(alignment: .leading, spacing: 2) {
                Text(commit.message)
                    .font(.system(size: 12, weight: .semibold)).foregroundStyle(.white)
                HStack(spacing: 8) {
                    Text(commit.id)
                        .font(.system(size: 10, design: .monospaced)).foregroundStyle(GitTheme.yellow)
                    Text(commit.branch)
                        .font(.system(size: 10)).foregroundStyle(.white.opacity(0.45))
                    if let p = commit.parentId {
                        Text("← \(p.prefix(4))")
                            .font(.system(size: 10, design: .monospaced)).foregroundStyle(.white.opacity(0.3))
                    }
                }
            }
            Spacer()
            Button { withAnimation { selectedCommit = nil } } label: {
                Image(systemName: "xmark.circle.fill").foregroundStyle(.white.opacity(0.35))
            }
        }
        .padding(.horizontal, 14).padding(.vertical, 10)
        .background(Color.white.opacity(0.06))
    }

    // MARK: – Empty State

    private var emptyState: some View {
        VStack(spacing: 14) {
            ZStack {
                Circle().fill(GitTheme.gray.opacity(0.1)).frame(width: 64, height: 64)
                Image(systemName: "folder.badge.questionmark")
                    .font(.system(size: 28)).foregroundStyle(GitTheme.gray.opacity(0.6))
            }
            VStack(spacing: 5) {
                Text("No Repository")
                    .font(.system(size: 14, weight: .semibold)).foregroundStyle(.white.opacity(0.7))
                Text("Run 'git init' to begin")
                    .font(.system(size: 11, weight: .medium)).foregroundStyle(GitTheme.orange.opacity(0.8))
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: – Helpers

    private func actionIcon(_ type: GitAction.ActionType) -> String {
        switch type {
        case .initialize: return "folder.badge.plus"
        case .commit:     return "circle.fill"
        case .branch:     return "arrow.triangle.branch"
        case .checkout:   return "arrow.right.circle.fill"
        case .merge:      return "arrow.triangle.merge"
        case .push:       return "arrow.up.circle.fill"
        case .pull:       return "arrow.down.circle.fill"
        case .reset:      return "clock.arrow.circlepath"
        case .add:        return "plus.square.fill"
        case .status:     return "magnifyingglass"
        }
    }

    private func actionColor(_ type: GitAction.ActionType) -> Color {
        switch type {
        case .initialize: return GitTheme.purple
        case .commit:     return GitTheme.green
        case .branch:     return GitTheme.blue
        case .checkout:   return GitTheme.cyan
        case .merge:      return GitTheme.orange
        case .push:       return GitTheme.cyan
        case .pull:       return GitTheme.blue
        case .reset:      return GitTheme.red
        case .add:        return GitTheme.yellow
        case .status:     return GitTheme.gray
        }
    }
}

// MARK: - Stat Badge

private struct StatBadge: View {
    let icon: String
    let value: String
    let color: Color
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon).font(.system(size: 9))
            Text(value).font(.system(size: 11, weight: .medium))
        }
        .foregroundStyle(color.opacity(0.9))
    }
}

// MARK: - Visualizer Guide Sheet

struct VisualizerGuideSheet: View {
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ZStack(alignment: .topTrailing) {
            Color(red: 0.10, green: 0.10, blue: 0.12).ignoresSafeArea()
            VStack(alignment: .leading, spacing: 22) {
                Text("Understanding the Git Graph")
                    .font(.system(size: 18, weight: .bold)).foregroundStyle(.white)
                    .padding(.top, 10)
                ScrollView {
                    VStack(alignment: .leading, spacing: 14) {
                        guideRow(
                            icon: AnyView(Circle().fill(GitTheme.blue).frame(width: 12, height: 12)),
                            title: "Commits  (Circles)",
                            desc: "Each circle is a saved snapshot. The 4-char code is the short hash.")
                        guideRow(
                            icon: AnyView(Image(systemName: "arrow.triangle.branch").font(.system(size: 11)).foregroundStyle(GitTheme.purple)),
                            title: "Branches  (Rows)",
                            desc: "Each horizontal lane is a parallel timeline. main is always at the top.")
                        guideRow(
                            icon: AnyView(Rectangle().fill(GitTheme.purple.opacity(0.5)).frame(width: 18, height: 2.5)),
                            title: "Connections  (Lines)",
                            desc: "Solid lines = parent → child on same lane. Curved lines = branch fork.")
                        guideRow(
                            icon: AnyView(Rectangle().fill(GitTheme.orange.opacity(0.5)).frame(width: 18, height: 2).overlay(
                                Path { p in p.move(to: CGPoint(x:0,y:1)); p.addLine(to: CGPoint(x:18,y:1)) }
                                    .stroke(style: StrokeStyle(dash:[4,3])).foregroundStyle(GitTheme.orange))),
                            title: "Merge Arcs  (Dashed)",
                            desc: "Dashed curves + arrowhead show a branch being merged back into another.")
                        guideRow(
                            icon: AnyView(Text("HEAD").font(.system(size: 7, weight: .bold)).padding(.horizontal, 5).padding(.vertical, 2)
                                .background(Capsule().stroke(GitTheme.green, lineWidth: 1)).foregroundStyle(GitTheme.green)),
                            title: "HEAD Badge",
                            desc: "Pulsing green badge above the commit you're currently on. Moves on checkout.")
                        guideRow(
                            icon: AnyView(Circle().stroke(GitTheme.yellow, lineWidth: 2.5).frame(width: 14, height: 14)),
                            title: "Staging Ring  (Spinning Gold)",
                            desc: "Rotating gold ring = files are staged (git add) but not yet committed.")
                        guideRow(
                            icon: AnyView(Image(systemName: "cloud.fill").font(.system(size: 13)).foregroundStyle(GitTheme.cyan)),
                            title: "Origin Cloud",
                            desc: "Appears when a remote is configured. Represents your GitHub repository.")
                    }
                    .padding(.bottom, 30)
                }
                .scrollIndicators(.hidden)
            }
            .padding(24)
            Button { dismiss() } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 24)).foregroundStyle(.white.opacity(0.3)).padding(16)
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }

    private func guideRow(icon: AnyView, title: String, desc: String) -> some View {
        HStack(alignment: .top, spacing: 14) {
            icon.frame(width: 28, alignment: .center)
            VStack(alignment: .leading, spacing: 5) {
                Text(title).font(.system(size: 13, weight: .semibold)).foregroundStyle(.white)
                Text(desc).font(.system(size: 12)).foregroundStyle(.white.opacity(0.65)).lineSpacing(3)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: 12).fill(Color.white.opacity(0.04)))
    }
}

// MARK: - Preview

#Preview("Full Workflow") {
    let state = GitRepositoryState()
    return GitVisualizerView(repoState: state)
        .frame(height: 380)
        .onAppear {
            state.initialize()
            state.stageFiles(["README.md"])
            state.commit(message: "Initial commit")
            state.commit(message: "Add settings")
            state.createBranch(name: "feature/dark-mode")
            state.stageFiles(["settings.js"])
            state.commit(message: "Add dark mode")
            state.checkout(branch: "main")
            state.commit(message: "Fix login bug")
            state.merge(branch: "feature/dark-mode")
        }
}
