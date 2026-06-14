import SwiftUI




// MARK: - Internal Visual Models

/// Represents a single commit node in the branching graph visualization.
struct VNode: Identifiable, Equatable {
    let id: String
    let message: String
    let branch: String
    let lane: Int
    let column: Int
    let parentId: String?
    let color: Color
    var style: VNodeStyle
}

/// Defines the appearance style of a commit node on the graph.
enum VNodeStyle: Equatable {
    case normal
    case head
    case staged
    case conflict
    case remote
    case merge
    case dimmed
}

/// Represents a horizontal branch lane in the visualization.
struct VLane: Identifiable, Equatable {
    let id: String
    let lane: Int
    let color: Color
    var isActive: Bool
    var isDimmed: Bool
}

/// Represents the dashed curved arc indicating a branch being merged into another.
struct VMergeArc: Identifiable, Equatable {
    let id: String
    let fromNodeId: String
    let toNodeId: String
    let color: Color
}

/// Represents a visual animation arrow for remote network operations (push/pull).
struct VArrow: Identifiable, Equatable {
    enum Direction: Equatable { case up, down }
    let id: String
    let direction: Direction
    let color: Color
}

/// Represents the visual state of a connected remote (e.g., origin).
struct VRemote: Equatable {
    var isVisible: Bool
    var isSynced: Bool
    var anchorNodeId: String?
}

/// The complete aggregated state model of the visualizer graph at any point in time.
struct VGraphModel: Equatable {
    var lanes: [VLane]      = []
    var nodes: [VNode]      = []
    var arcs:  [VMergeArc] = []
    var headNodeId: String?
    var floatingHead: Bool  = false
    var remote: VRemote     = VRemote(isVisible: false, isSynced: false)
    var arrows: [VArrow]   = []
}

// MARK: - Graph Builder Logic

/// A stateless helper that translates the core `GitRepositoryState` into a layout-ready `VGraphModel`.
enum VGraphBuilder {

    @MainActor static func build(from repo: GitRepositoryState) -> VGraphModel {
        var model = VGraphModel()
        guard repo.isInitialized else { return model }

        var laneMap: [String: Int] = [:]
        var colorMap: [String: Color] = [:]
        var laneIndex = 0
        for branch in repo.branches {
            let assignedLane: Int
            if branch.name == "main" || branch.name == "master" {
                assignedLane = 0
            } else {
                if laneMap[branch.name] == nil { laneIndex += 1 }
                assignedLane = laneMap[branch.name] ?? laneIndex
            }
            laneMap[branch.name] = assignedLane
            colorMap[branch.name] = branch.color
        }

        let mergedBranches = mergedBranchNames(repo)
        for branch in repo.branches {
            let lane = laneMap[branch.name] ?? 0
            model.lanes.append(VLane(
                id:       branch.name,
                lane:     lane,
                color:    branch.color,
                isActive: branch.name == repo.currentBranch,
                isDimmed: mergedBranches.contains(branch.name)
            ))
        }

        let currentBranch = repo.branches.first(where: { $0.name == repo.currentBranch })
        let headCommitId  = currentBranch?.headCommitId

        if repo.commits.isEmpty {
            model.floatingHead = true
            return model
        }

        for (col, commit) in repo.commits.enumerated() {
            let lane  = laneMap[commit.branch] ?? 0
            let color = colorMap[commit.branch] ?? .purple
            let isHead   = commit.id == headCommitId
            let isStaged = isHead && !repo.stagedFiles.isEmpty

            let style = nodeStyle(
                commit:   commit,
                isHead:   isHead,
                isStaged: isStaged,
                isDimmed: mergedBranches.contains(commit.branch) && !isHead,
                repo:     repo
            )

            model.nodes.append(VNode(
                id:       commit.id,
                message:  commit.message,
                branch:   commit.branch,
                lane:     lane,
                column:   col,
                parentId: commit.parentId,
                color:    color,
                style:    style
            ))
        }

        model.headNodeId  = headCommitId
        model.floatingHead = false

        for node in model.nodes where node.message.hasPrefix("Merge branch '") {
            let rest = node.message.dropFirst("Merge branch '".count)
            if let eq = rest.firstIndex(of: "'") {
                let srcBranch = String(rest[..<eq])
                if let tip = model.nodes.last(where: { $0.branch == srcBranch && $0.column < node.column }) {
                    let color = colorMap[srcBranch] ?? .orange
                    model.arcs.append(VMergeArc(
                        id:         "\(tip.id)->\(node.id)",
                        fromNodeId: tip.id,
                        toNodeId:   node.id,
                        color:      color
                    ))
                }
            }
        }

        if repo.hasRemote {
            let anchor = model.nodes.filter { laneMap[$0.branch] == 0 }.last
            let action = repo.lastAction
            let isSynced = action?.type == .push
            model.remote = VRemote(
                isVisible:    true,
                isSynced:     isSynced,
                anchorNodeId: anchor?.id
            )

            if action?.type == .push {
                model.arrows = [VArrow(id: "push", direction: .up, color: GitTheme.cyan)]
            } else if action?.type == .pull {
                model.arrows = [VArrow(id: "pull", direction: .down, color: GitTheme.blue)]
            }
        }

        return model
    }

    @MainActor private static func nodeStyle(
        commit: GitCommit,
        isHead: Bool,
        isStaged: Bool,
        isDimmed: Bool,
        repo: GitRepositoryState
    ) -> VNodeStyle {
        let isMerge = commit.message.hasPrefix("Merge branch '")
        let isRemotePull = commit.message == "Remote changes"

        if isDimmed   { return .dimmed }
        if isMerge    { return .merge }
        if isRemotePull { return .remote }
        if isStaged   { return .staged }
        if isHead     {

            if let action = repo.lastAction, action.type == .status { return .conflict }
            return .head
        }
        return .normal
    }

    @MainActor private static func mergedBranchNames(_ repo: GitRepositoryState) -> Set<String> {
        var result = Set<String>()
        for commit in repo.commits where commit.message.hasPrefix("Merge branch '") {
            let rest = commit.message.dropFirst("Merge branch '".count)
            if let eq = rest.firstIndex(of: "'") {
                result.insert(String(rest[..<eq]))
            }
        }
        return result
    }
}

// MARK: - Graph Layout Engine

/// Manages the coordinate space, padding, and positioning logic for graph rendering.
struct VLayout {
    let nodeRadius: CGFloat  = 20
    let hSpacing:   CGFloat  = 88
    let vSpacing:   CGFloat  = 64
    let leftPad:    CGFloat  = 40
    let topPad:     CGFloat  = 56

    func center(for node: VNode) -> CGPoint {
        CGPoint(
            x: leftPad + CGFloat(node.column) * hSpacing,
            y: topPad  + CGFloat(node.lane)   * vSpacing
        )
    }

    func placeholderCenter(lane: Int = 0) -> CGPoint {
        CGPoint(x: leftPad, y: topPad + CGFloat(lane) * vSpacing)
    }

    func canvasSize(model: VGraphModel) -> CGSize {
        let maxCol  = model.nodes.map(\.column).max() ?? 0
        let maxLane = model.nodes.map(\.lane).max()   ?? 0
        let w = leftPad + CGFloat(maxCol + 1) * hSpacing + 200
        let h = topPad  + CGFloat(maxLane + 1) * vSpacing + 40
        return CGSize(width: max(w, 300), height: max(h, 130))
    }
}




// MARK: - Main Visualizer View

/// Renders a dynamic, horizontally scrolling visual graph of the Git repository state.
struct GitVisualizerView: View {

    var repoState: GitRepositoryState

    @State private var currentModel:  VGraphModel = VGraphModel()
    @State private var previousModel: VGraphModel = VGraphModel()

    @State private var pulseHead       = false
    @State private var spinStage       = false
    @State private var pushArrowOffset: CGFloat = 0
    @State private var pullArrowOffset: CGFloat = 0
    @State private var arrowOpacity:   Double   = 0

    @State private var selectedNodeId: String?
    @State private var showGuide = false

    private let layout = VLayout()

    var body: some View {
        VStack(spacing: 0) {
            headerBar
            Divider().background(Color.white.opacity(0.06))

            if repoState.isInitialized {
                graphScroller
                    .frame(maxHeight: .infinity)
                actionFooter
            } else {
                emptyState
                    .frame(maxHeight: .infinity)
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(GitTheme.darkBackground)
        )
        .sheet(isPresented: $showGuide) { VisualizerGuideSheet() }
        .onAppear { pulseHead = true; spinStage = true }

        .onChange(of: repoState.commits.count)        { _,_ in rebuildModel() }
        .onChange(of: repoState.currentBranch)        { _,_ in rebuildModel() }
        .onChange(of: repoState.stagedFiles.count)    { _,_ in rebuildModel() }
        .onChange(of: repoState.hasRemote)            { _,_ in rebuildModel() }
        .onChange(of: repoState.isInitialized)        { _,_ in rebuildModel() }
        .onChange(of: repoState.lastAction?.command)  { _,_ in rebuildModel() }
        .onAppear { rebuildModel() }
    }

    private func rebuildModel() {
        let newModel = VGraphBuilder.build(from: repoState)
        guard newModel != currentModel else { return }
        previousModel = currentModel

        if newModel.arrows.contains(where: { $0.direction == .up }) {
            animatePushArrow()
        }
        if newModel.arrows.contains(where: { $0.direction == .down }) {
            animatePullArrow()
        }

        withAnimation(.spring(response: 0.45, dampingFraction: 0.72)) {
            currentModel = newModel
        }
    }

    private func animatePushArrow() {
        arrowOpacity = 1
        pushArrowOffset = 0
        withAnimation(.easeIn(duration: 0.7)) {
            pushArrowOffset = -48
        }
        withAnimation(.easeIn(duration: 0.7).delay(0.5)) {
            arrowOpacity = 0
        }
    }

    private func animatePullArrow() {
        arrowOpacity = 1
        pullArrowOffset = 0
        withAnimation(.easeOut(duration: 0.7)) {
            pullArrowOffset = 48
        }
        withAnimation(.easeOut(duration: 0.7).delay(0.5)) {
            arrowOpacity = 0
        }
    }

    private var graphScroller: some View {
        let size = layout.canvasSize(model: currentModel)
        return ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                ZStack(alignment: .topLeading) {
                    graphCanvas(size: size)
                        .frame(width: size.width, height: size.height)
                }
            }
            .onChange(of: currentModel.headNodeId) { _, headId in
                if let headId {
                    withAnimation(.spring()) { proxy.scrollTo(headId, anchor: .center) }
                }
            }
        }
    }

    @ViewBuilder
    private func graphCanvas(size: CGSize) -> some View {

        Canvas { ctx, _ in drawLaneTracks(&ctx) }

        Canvas { ctx, _ in drawConnections(&ctx) }

        Canvas { ctx, _ in drawMergeArcs(&ctx) }

        if currentModel.remote.isVisible {
            remoteOverlay
        }

        if currentModel.nodes.isEmpty && currentModel.floatingHead == false {
            initPlaceholder
        } else if currentModel.floatingHead {
            floatingHeadView
        }

        ForEach(currentModel.nodes) { node in
            nodeView(node)
                .id(node.id)
                .transition(
                    node.style == .dimmed
                        ? .opacity
                        : .asymmetric(
                            insertion:  .scale(scale: 0.4).combined(with: .opacity),
                            removal:    .scale(scale: 0.1).combined(with: .opacity)
                        )
                )
        }

        ForEach(currentModel.lanes) { lane in
            branchLabel(lane)
        }
    }

    private func nodeCenter(_ nodeId: String) -> CGPoint? {
        currentModel.nodes.first(where: { $0.id == nodeId }).map { layout.center(for: $0) }
    }

    private func drawLaneTracks(_ ctx: inout GraphicsContext) {
        for lane in currentModel.lanes {
            let laneNodes = currentModel.nodes.filter { $0.lane == lane.lane }
            guard let first = laneNodes.first, let last = laneNodes.last else { continue }
            var p = Path()
            p.move(to: layout.center(for: first))
            p.addLine(to: layout.center(for: last))
            ctx.stroke(p, with: .color(lane.color.opacity(lane.isDimmed ? 0.04 : 0.08)), lineWidth: 10)
        }
    }

    private func drawConnections(_ ctx: inout GraphicsContext) {
        let r = layout.nodeRadius
        for node in currentModel.nodes {
            guard let parentId = node.parentId,
                  let parent   = currentModel.nodes.first(where: { $0.id == parentId }) else { continue }
            let from = CGPoint(x: layout.center(for: parent).x + r, y: layout.center(for: parent).y)
            let to   = CGPoint(x: layout.center(for: node).x   - r, y: layout.center(for: node).y)
            var p = Path()
            if parent.lane == node.lane {
                p.move(to: from); p.addLine(to: to)
                let alpha: Double = node.style == .dimmed ? 0.22 : 0.72
                ctx.stroke(p, with: .color(node.color.opacity(alpha)), lineWidth: 2.5)
            } else {
                let dx = to.x - from.x
                p.move(to: from)
                p.addCurve(
                    to:       to,
                    control1: CGPoint(x: from.x + dx * 0.6, y: from.y),
                    control2: CGPoint(x: to.x   - dx * 0.2, y: to.y)
                )
                ctx.stroke(p, with: .color(node.color.opacity(0.65)), lineWidth: 2.5)
            }
        }
    }

    private func drawMergeArcs(_ ctx: inout GraphicsContext) {
        let r = layout.nodeRadius
        for arc in currentModel.arcs {
            guard let fromPt = nodeCenter(arc.fromNodeId),
                  let toPt   = nodeCenter(arc.toNodeId) else { continue }
            let from = CGPoint(x: fromPt.x + r, y: fromPt.y)
            let to   = CGPoint(x: toPt.x   - r, y: toPt.y)
            var p = Path()
            p.move(to: from)
            p.addCurve(to: to,
                       control1: CGPoint(x: to.x,      y: from.y),
                       control2: CGPoint(x: to.x - 14, y: to.y))
            ctx.stroke(p,
                with: .color(arc.color.opacity(0.72)),
                style: StrokeStyle(lineWidth: 2.2, dash: [5, 3.5]))

            let angle  = atan2(to.y - from.y, to.x - from.x)
            let len: CGFloat = 9
            var arrow = Path()
            arrow.move(to: to)
            arrow.addLine(to: CGPoint(x: to.x - len * cos(angle - 0.45),
                                       y: to.y - len * sin(angle - 0.45)))
            arrow.move(to: to)
            arrow.addLine(to: CGPoint(x: to.x - len * cos(angle + 0.45),
                                       y: to.y - len * sin(angle + 0.45)))
            ctx.stroke(arrow, with: .color(arc.color.opacity(0.75)), lineWidth: 1.8)
        }
    }

    @ViewBuilder
    private var remoteOverlay: some View {
        if let anchorId = currentModel.remote.anchorNodeId,
           let anchor = currentModel.nodes.first(where: { $0.id == anchorId }) {
            let pt = layout.center(for: anchor)
            ZStack {

                if currentModel.arrows.contains(where: { $0.direction == .up }) {
                    Image(systemName: "arrow.up")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(GitTheme.cyan)
                        .offset(y: pushArrowOffset)
                        .opacity(arrowOpacity)
                        .position(x: pt.x, y: pt.y - 30)
                }

                if currentModel.arrows.contains(where: { $0.direction == .down }) {
                    Image(systemName: "arrow.down")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(GitTheme.blue)
                        .offset(y: pullArrowOffset)
                        .opacity(arrowOpacity)
                        .position(x: pt.x, y: pt.y - 54)
                }

                VStack(spacing: 2) {
                    Image(systemName: currentModel.remote.isSynced ? "checkmark.icloud.fill" : "icloud")
                        .font(.system(size: 24))
                        .foregroundStyle(LinearGradient(
                            colors: [GitTheme.cyan, GitTheme.blue],
                            startPoint: .top, endPoint: .bottom))
                        .shadow(color: GitTheme.cyan.opacity(0.5), radius: 7)
                    Text("origin")
                        .font(.system(size: 8, weight: .semibold, design: .monospaced))
                        .foregroundStyle(GitTheme.cyan.opacity(0.65))
                }
                .position(x: pt.x + layout.hSpacing * 0.85, y: pt.y - 40)
            }
        }
    }

    private var initPlaceholder: some View {
        let pt = layout.placeholderCenter()
        return ZStack {
            Circle()
                .strokeBorder(style: StrokeStyle(lineWidth: 2, dash: [5, 4]))
                .foregroundStyle(GitTheme.gray.opacity(0.4))
                .frame(width: 40, height: 40)
            Text("···")
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(GitTheme.gray.opacity(0.5))
        }
        .position(pt)
        .transition(.opacity)
    }

    private var floatingHeadView: some View {
        let pt = layout.placeholderCenter()
        return VStack(spacing: 6) {
            headBadge
            ZStack {
                Circle()
                    .strokeBorder(style: StrokeStyle(lineWidth: 2, dash: [5, 4]))
                    .foregroundStyle(GitTheme.gray.opacity(0.4))
                    .frame(width: 40, height: 40)

                if !repoState.stagedFiles.isEmpty {
                    Circle()
                        .stroke(
                            AngularGradient(
                                colors: [GitTheme.yellow, GitTheme.orange, GitTheme.yellow],
                                center: .center),
                            lineWidth: 3)
                        .frame(width: 52, height: 52)
                        .rotationEffect(.degrees(spinStage ? 360 : 0))
                        .animation(.linear(duration: 2.5).repeatForever(autoreverses: false), value: spinStage)
                    fileChips(count: repoState.stagedFiles.count)
                        .offset(y: 34)
                }
                Text("···")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(GitTheme.gray.opacity(0.5))
            }
        }
        .position(x: pt.x, y: pt.y)
        .transition(.scale(scale: 0.5).combined(with: .opacity))
    }

    @ViewBuilder
    private func nodeView(_ node: VNode) -> some View {
        let pt = layout.center(for: node)
        let r  = layout.nodeRadius
        let d  = r * 2
        let isHead = node.id == currentModel.headNodeId

        ZStack {

            if node.style == .head || node.style == .staged || node.style == .merge {
                Circle()
                    .fill(node.color.opacity(0.25))
                    .frame(width: d + 24, height: d + 24)
                    .blur(radius: 10)
            }

            if node.style == .staged {
                Circle()
                    .stroke(
                        AngularGradient(
                            colors: [GitTheme.yellow, GitTheme.orange, GitTheme.yellow],
                            center: .center),
                        lineWidth: 3.5)
                    .frame(width: d + 16, height: d + 16)
                    .rotationEffect(.degrees(spinStage ? 360 : 0))
                    .animation(.linear(duration: 2.5).repeatForever(autoreverses: false), value: spinStage)
            }

            if node.style == .conflict {
                Circle()
                    .stroke(GitTheme.red.opacity(0.8), lineWidth: 2.5)
                    .frame(width: d + 14, height: d + 14)
            }

            if selectedNodeId == node.id {
                Circle()
                    .stroke(.white.opacity(0.55), lineWidth: 2.5)
                    .frame(width: d + 8, height: d + 8)
            }

            Circle()
                .fill(mainFill(for: node))
                .frame(width: d, height: d)
                .overlay(
                    Circle().stroke(
                        mainStroke(for: node),
                        lineWidth: node.style == .merge ? 2 : 1.5)
                )
                .shadow(
                    color: node.color.opacity(isHead ? 0.65 : 0.25),
                    radius: isHead ? 10 : 4
                )
                .opacity(node.style == .dimmed ? 0.35 : 1.0)

            Text(String(node.id.prefix(4)))
                .font(.system(size: 9, weight: .bold, design: .monospaced))
                .foregroundStyle(.white.opacity(node.style == .dimmed ? 0.4 : 0.92))

            if node.style == .conflict {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 11))
                    .foregroundStyle(GitTheme.red)
                    .offset(x: r - 2, y: -(r - 2))
            }
            if node.style == .remote {
                Image(systemName: "arrow.down.circle.fill")
                    .font(.system(size: 11))
                    .foregroundStyle(GitTheme.blue)
                    .offset(x: r - 2, y: -(r - 2))
            }

            if isHead && !currentModel.floatingHead {
                headBadge
                    .offset(y: -(r + 18))
            }

            if node.style == .staged {
                fileChips(count: repoState.stagedFiles.count)
                    .offset(y: r + 14)
            }

            commitLabel(node)
                .offset(y: r + (node.style == .staged ? 36 : 16))
        }
        .frame(width: d + 44, height: d + 44)
        .position(pt)
        .scaleEffect(isHead && node.style != .dimmed ? 1.08 : 1.0)
        .animation(.spring(response: 0.45, dampingFraction: 0.65), value: isHead)
        .onTapGesture {
            withAnimation(.spring(response: 0.3)) {
                selectedNodeId = selectedNodeId == node.id ? nil : node.id
            }
        }
    }

    private func mainFill(for node: VNode) -> AnyShapeStyle {
        if node.style == .merge {

            return AnyShapeStyle(LinearGradient(
                colors: [node.color, node.color.opacity(0.5), GitTheme.orange],
                startPoint: .topLeading,
                endPoint:   .bottomTrailing))
        }
        return AnyShapeStyle(LinearGradient(
            colors: [node.color.opacity(node.style == .dimmed ? 0.5 : 0.95),
                     node.color.opacity(node.style == .dimmed ? 0.3 : 0.6)],
            startPoint: .topLeading,
            endPoint:   .bottomTrailing))
    }

    private func mainStroke(for node: VNode) -> some ShapeStyle {
        if node.style == .merge {
            return AnyShapeStyle(LinearGradient(
                colors: [.white.opacity(0.6), GitTheme.orange.opacity(0.5)],
                startPoint: .topLeading,
                endPoint:   .bottomTrailing))
        }
        return AnyShapeStyle(Color.white.opacity(node.style == .dimmed ? 0.1 : 0.3))
    }

    private var headBadge: some View {
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
        .scaleEffect(pulseHead ? 1.06 : 1.0)
        .animation(.easeInOut(duration: 1.1).repeatForever(autoreverses: true), value: pulseHead)
    }

    @ViewBuilder
    private func fileChips(count: Int) -> some View {
        HStack(spacing: 2) {
            ForEach(0..<min(count, 3), id: \.self) { _ in
                RoundedRectangle(cornerRadius: 2)
                    .fill(GitTheme.yellow.opacity(0.9))
                    .frame(width: 5, height: 8)
            }
            if count > 3 {
                Text("+\(count - 3)")
                    .font(.system(size: 7, weight: .bold))
                    .foregroundStyle(GitTheme.yellow)
            }
        }
    }

    @ViewBuilder
    private func commitLabel(_ node: VNode) -> some View {
        let isSelected = selectedNodeId == node.id
        Text(node.message)
            .font(.system(size: isSelected ? 9.5 : 8.5,
                          weight: isSelected ? .medium : .regular))
            .foregroundStyle(node.style == .dimmed
                ? .white.opacity(0.25)
                : (isSelected ? .white.opacity(0.9) : .white.opacity(0.5)))
            .lineLimit(isSelected ? 2 : 1)
            .multilineTextAlignment(.center)
            .frame(width: layout.nodeRadius * 2 + 60)
            .background {
                if isSelected {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.black.opacity(0.65))
                        .padding(.horizontal, -5).padding(.vertical, -2)
                }
            }
    }

    @ViewBuilder
    private func branchLabel(_ lane: VLane) -> some View {
        let branchNodes = currentModel.nodes.filter { $0.branch == lane.id }
        if let tip = branchNodes.last {
            let pt = layout.center(for: tip)
            let labelX = pt.x + layout.nodeRadius + 62

            HStack(spacing: 4) {
                if lane.isActive {
                    Circle().fill(GitTheme.green).frame(width: 5, height: 5)
                } else {
                    Image(systemName: lane.isDimmed ? "checkmark" : "arrow.triangle.branch")
                        .font(.system(size: 7, weight: .semibold))
                        .foregroundStyle(lane.color.opacity(lane.isDimmed ? 0.4 : 0.75))
                }
                Text(lane.id)
                    .font(.system(size: 9, weight: lane.isActive ? .bold : .medium))
                    .foregroundStyle(lane.isActive ? .white : lane.color.opacity(lane.isDimmed ? 0.4 : 0.85))
                    .lineLimit(1)
            }
            .padding(.horizontal, 7).padding(.vertical, 3.5)
            .background(
                RoundedRectangle(cornerRadius: 5)
                    .fill(lane.color.opacity(lane.isActive ? 0.28 : (lane.isDimmed ? 0.04 : 0.10)))
                    .overlay(
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(lane.color.opacity(lane.isActive ? 0.65 : (lane.isDimmed ? 0.15 : 0.28)), lineWidth: 1)
                    )
            )
            .fixedSize()
            .position(x: labelX, y: layout.topPad + CGFloat(lane.lane) * layout.vSpacing)
            .opacity(lane.isDimmed ? 0.45 : 1)
            .animation(.spring(response: 0.45), value: lane.isActive)
            .animation(.easeInOut, value: lane.isDimmed)
        }
    }

    // MARK: - Headers and Footers

    @ViewBuilder
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
                statBadge("circle.fill",           "\(repoState.commits.count)",  GitTheme.blue)
                statBadge("arrow.triangle.branch", "\(repoState.branches.count)", GitTheme.purple)
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
                        .font(.system(size: 22)).foregroundStyle(.white.opacity(0.38))
                }
            }
        }
        .padding(.horizontal, 14).padding(.vertical, 10)
        .background(Theme.Colors.headerBackground)
    }

    private func statBadge(_ icon: String, _ value: String, _ color: Color) -> some View {
        HStack(spacing: 4) {
            Image(systemName: icon).font(.system(size: 9))
            Text(value).font(.system(size: 11, weight: .medium))
        }
        .foregroundStyle(color.opacity(0.9))
    }

    @ViewBuilder
    private var actionFooter: some View {
        if let action = repoState.lastAction {
            Divider().background(Color.white.opacity(0.06))
            HStack(spacing: 10) {
                ZStack {
                    Circle().fill(footerColor(action.type).opacity(0.18)).frame(width: 28, height: 28)
                    Image(systemName: footerIcon(action.type))
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(footerColor(action.type))
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text(action.command)
                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                        .foregroundStyle(footerColor(action.type))
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
    }

    private func footerIcon(_ type: GitAction.ActionType) -> String {
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
        case .stash:      return "archivebox.fill"
        case .cherryPick: return "doc.on.doc.fill"
        case .tag:        return "tag.fill"
        case .cleanup:    return "trash.fill"
        case .revert:     return "arrow.uturn.backward.circle.fill"
        case .inspect:    return "magnifyingglass"
        }
    }

    private func footerColor(_ type: GitAction.ActionType) -> Color {
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
        case .stash:      return GitTheme.yellow
        case .cherryPick: return GitTheme.pink
        case .tag:        return GitTheme.green
        case .cleanup:    return GitTheme.orange
        case .revert:     return GitTheme.red
        case .inspect:    return GitTheme.gray
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle().fill(GitTheme.gray.opacity(0.1)).frame(width: 68, height: 68)
                Image(systemName: "folder.badge.questionmark")
                    .font(.system(size: 30)).foregroundStyle(GitTheme.gray.opacity(0.6))
            }
            VStack(spacing: 6) {
                Text("No Repository")
                    .font(.system(size: 15, weight: .semibold)).foregroundStyle(.white.opacity(0.7))
                Text("Run 'git init' to begin")
                    .font(.system(size: 12, weight: .medium)).foregroundStyle(GitTheme.orange.opacity(0.8))
            }
        }
        .frame(maxWidth: .infinity)
    }
}




// MARK: - Help Overlays

/// A modal sheet presenting a legend to help users interpret the visualizer's symbols.
struct VisualizerGuideSheet: View {
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ZStack(alignment: .topTrailing) {
            Theme.Colors.headerBackground.ignoresSafeArea()
            VStack(alignment: .leading, spacing: 22) {
                Text("Understanding the Git Graph")
                    .font(.system(size: 18, weight: .bold)).foregroundStyle(.white)
                    .padding(.top, 10)
                ScrollView {
                    VStack(alignment: .leading, spacing: 14) {
                        row(icon: AnyView(Circle().fill(GitTheme.blue).frame(width: 12, height: 12)),
                            title: "Commits (Circles)",
                            desc: "Each circle is a saved snapshot. The 4-char code is the short hash.")
                        row(icon: AnyView(Image(systemName: "arrow.triangle.branch").font(.system(size: 11)).foregroundStyle(GitTheme.purple)),
                            title: "Branches (Lanes)",
                            desc: "Each horizontal lane is a parallel timeline. main is always at the top.")
                        row(icon: AnyView(Text("HEAD").font(.system(size: 6, weight: .bold)).lineLimit(1)
                            .fixedSize()
                            .layoutPriority(1).padding(.horizontal, 5).padding(.vertical, 2)
                                .background(Capsule().stroke(GitTheme.green, lineWidth: 2)).foregroundStyle(GitTheme.green)),
                            title: "HEAD Badge (Pulsing Green)",
                            desc: "Shows where you currently are. Moves on checkout or new commits.")
                        row(icon: AnyView(Circle().stroke(GitTheme.yellow, lineWidth: 2.5).frame(width: 14, height: 14)),
                            title: "Staging Ring (Spinning Gold)",
                            desc: "Rotating gold ring means files are staged (git add) but not committed yet.")
                        row(icon: AnyView(Image(systemName: "exclamationmark.triangle.fill").font(.system(size: 13)).foregroundStyle(GitTheme.red)),
                            title: "Conflict Badge",
                            desc: "Warning badge on HEAD when a merge conflict is detected.")
                        row(icon: AnyView(Image(systemName: "icloud").font(.system(size: 13)).foregroundStyle(GitTheme.cyan)),
                            title: "Origin Cloud",
                            desc: "Appears when a remote is configured. Syncs visually after git push.")
                        row(icon: AnyView(Rectangle().fill(GitTheme.orange.opacity(0.7)).frame(width: 18, height: 2)),
                            title: "Merge Arcs (Dashed)",
                            desc: "Dashed curved line + arrowhead showing a branch merged into another.")
                        row(icon: AnyView(Circle().fill(GitTheme.purple.opacity(0.3)).frame(width: 12, height: 12)),
                            title: "Dimmed Branch",
                            desc: "A branch that has been fully merged is visually de-emphasized.")
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

    private func row(icon: AnyView, title: String, desc: String) -> some View {
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

#Preview("Full Workflow") {
    let state = GitRepositoryState()
    return GitVisualizerView(repoState: state)
        .frame(height: 420)
        .preferredColorScheme(.dark)
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
            state.addRemote(name: "origin", url: "https://github.com/example/repo.git")
            state.push()
            state.merge(branch: "feature/dark-mode")
        }
}

#Preview("Level 1 - Init") {
    let state = GitRepositoryState()
    return GitVisualizerView(repoState: state)
        .frame(height: 260)
        .preferredColorScheme(.dark)
        .onAppear {
            state.initialize()
        }
}

#Preview("Level 1 - Staged, no commit") {
    let state = GitRepositoryState()
    return GitVisualizerView(repoState: state)
        .frame(height: 260)
        .preferredColorScheme(.dark)
        .onAppear {
            state.initialize()
            state.stageFiles(["README.md", "main.swift"])
        }
}
