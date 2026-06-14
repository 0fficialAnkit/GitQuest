import SwiftUI

/// Main level screen: chat, concept card, Git graph, repo card, console, and overlays for success, explanation, errors, and learning sheet.
struct LevelGameView: View {
    let initialLevel: Level

    @Environment(GameState.self) var gameState
    @Environment(GitRepositoryState.self) var repoState
    @State private var viewModel = GameViewModel()
    @Environment(\.dismiss) var dismiss

    @State private var currentLevel: Level
    @State private var showExplanationCard = false
    @State private var showCompletedInfoOverlay = false
    @State private var showLearningSheet = false
    @State private var glowInfoButton = false
    @State private var chatResetId = UUID()
    @State private var showTutorial = false
    @State private var isInPracticeMode = false

    @State private var correctPulse = false
    @State private var shakeError = false
    @State private var errorFlash = false

    private let bgColor = Theme.Colors.background
    private let cardBg  = Theme.Colors.cardBackground

    init(level: Level) {
        self.initialLevel = level
        self._currentLevel = State(initialValue: level)
    }

    var body: some View {
        ZStack {
            bgColor.ignoresSafeArea()

            RadialGradient(
                colors: [Color.blue.opacity(0.18), .clear],
                center: .center,
                startRadius: 10,
                endRadius: 500
            )
            .ignoresSafeArea()
            .allowsHitTesting(false)


            VStack(spacing: 12) {
                VStack(spacing: 16) {
                    HStack(spacing: 16) {
                        ChatStoryView(
                            messages: viewModel.chatMessages,
                            resetId: chatResetId
                        )
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(RoundedRectangle(cornerRadius: 24, style: .continuous).fill(.regularMaterial))
                        .overlay(RoundedRectangle(cornerRadius: 24, style: .continuous).stroke(Color.white.opacity(0.12), lineWidth: 1))
                        .overlay(alignment: .top) { cardShine(cornerRadius: 24) }
                        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                        .shadow(color: Color.black.opacity(0.2), radius: 18, y: 10)
                        .tutorialAnchor(.chat)

                        if let step = getCurrentStep() {
                            ConceptCardView(
                                command: viewModel.getSuggestedCommands().first ?? step.expectedCommand
                            )
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(RoundedRectangle(cornerRadius: 24, style: .continuous).fill(.regularMaterial))
                            .overlay(RoundedRectangle(cornerRadius: 24, style: .continuous).stroke(Color.white.opacity(0.12), lineWidth: 1))
                            .overlay(alignment: .top) { cardShine(cornerRadius: 24) }
                            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                            .shadow(color: Color.black.opacity(0.2), radius: 18, y: 10)
                            .tutorialAnchor(.concept)
                        } else {
                            VStack(spacing: 12) {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 40))
                                    .foregroundStyle(Theme.Colors.success)
                                Text("All Steps Complete!")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundStyle(.primary)
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(RoundedRectangle(cornerRadius: 24, style: .continuous).fill(.regularMaterial))
                            .overlay(RoundedRectangle(cornerRadius: 24, style: .continuous).stroke(Color.white.opacity(0.12), lineWidth: 1))
                            .overlay(alignment: .top) { cardShine(cornerRadius: 24) }
                            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                            .shadow(color: Color.black.opacity(0.2), radius: 18, y: 10)
                        }
                    }

                    HStack(spacing: 12) {
                        GitVisualizerView(repoState: repoState)
                            .frame(maxWidth: .infinity)
                            .frame(height: 340)
                            .background(RoundedRectangle(cornerRadius: 24, style: .continuous).fill(.regularMaterial))
                            .overlay(RoundedRectangle(cornerRadius: 24, style: .continuous).stroke(Color.white.opacity(0.12), lineWidth: 1))
                            .overlay(alignment: .top) { cardShine(cornerRadius: 24) }
                            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                            .shadow(color: Color.black.opacity(0.2), radius: 18, y: 10)
                            .tutorialAnchor(.visualizer)

                        GitStateCard(repoState: repoState)
                            .frame(maxWidth: .infinity)
                            .frame(maxHeight: .infinity)
                            .background(RoundedRectangle(cornerRadius: 24, style: .continuous).fill(.regularMaterial))
                            .overlay(RoundedRectangle(cornerRadius: 24, style: .continuous).stroke(Color.white.opacity(0.12), lineWidth: 1))
                            .overlay(alignment: .top) { cardShine(cornerRadius: 24) }
                            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                            .shadow(color: Color.black.opacity(0.2), radius: 18, y: 10)
                            .tutorialAnchor(.repoState)
                    }
                    .frame(height: 340)

                    consolePanel
                        .offset(x: shakeError ? 8 : 0)
                        .overlay(
                            RoundedRectangle(cornerRadius: 24, style: .continuous)
                                .fill(Color.red.opacity(0.12))
                                .opacity(errorFlash ? 1 : 0)
                                .allowsHitTesting(false)
                        )
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 8)
            }
            .padding(.top, 12)
            .blur(radius: showCompletedInfoOverlay ? 10 : 0)
            .allowsHitTesting(!showCompletedInfoOverlay)

            successOverlay
            explanationOverlay
            errorOverlay
            completedInfoOverlay
        }
        .gameTutorial(isShowing: $showTutorial)
        .preferredColorScheme(.dark)
        .navigationTitle(currentLevel.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Text("\(viewModel.currentStep)/\(currentLevel.requiredSteps.count)")
                    .font(.system(size: 15, weight: .semibold))
            }
        }
        .onAppear {
            viewModel.gameState = gameState
            if !isInPracticeMode {
                viewModel.startLevel(currentLevel)
                setupVisualizerState()
            }
            if gameState.completedLevels.contains(currentLevel.id) && !isInPracticeMode {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.85)) {
                    showCompletedInfoOverlay = true
                }
            }
            if currentLevel.id == 1 && !UserDefaults.standard.bool(forKey: "hasSeenGameTutorial") {
                Task { @MainActor in
                    try? await Task.sleep(for: .seconds(0.8))
                    withAnimation { showTutorial = true }
                }
            }
        }
        .onChange(of: gameState.completedLevels) { _, newValue in
            if newValue.contains(currentLevel.id) {
                withAnimation { glowInfoButton = true }
                Task { @MainActor in
                    try? await Task.sleep(for: .seconds(1.0))
                    withAnimation { glowInfoButton = false }
                }
            }
        }
        .onChange(of: viewModel.currentStep) { oldVal, newVal in
            guard newVal > oldVal else { return }
            correctPulse = true
            Task { @MainActor in
                try? await Task.sleep(for: .seconds(0.45))
                correctPulse = false
            }
        }
        .onChange(of: viewModel.showError) { _, isError in
            guard isError else { return }
            withAnimation(.easeInOut(duration: 0.06).repeatCount(5, autoreverses: true)) {
                shakeError = true
            }
            errorFlash = true
            Task { @MainActor in
                try? await Task.sleep(for: .seconds(0.35))
                withAnimation(.easeOut(duration: 0.2)) {
                    shakeError = false
                    errorFlash = false
                }
            }
        }
        .onChange(of: viewModel.lastSuccessfulCommand) { _, command in
            guard !command.isEmpty else { return }
            executeOnVisualizer(command: command)
        }
        .onChange(of: viewModel.showSuccess) { _, isSuccess in
            guard isSuccess else { return }
            if !isInPracticeMode {
                repoState.saveSnapshot(forLevel: currentLevel.id)
            } else {
                isInPracticeMode = false
            }
        }
    }

    // MARK: - Card Shine Helper

    @ViewBuilder
    private func cardShine(cornerRadius: CGFloat) -> some View {
        LinearGradient(
            colors: [Color.white.opacity(0.25), Color.white.opacity(0.05), .clear],
            startPoint: .top,
            endPoint: .bottom
        )
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        .blendMode(.overlay)
        .allowsHitTesting(false)
    }

    // MARK: - Console Panel

    private var consolePanel: some View {
        ZStack(alignment: .topTrailing) {
            ConsoleView(
                commandInput: $viewModel.commandInput,
                terminalOutput: viewModel.terminalOutput,
                suggestedCommands: viewModel.getSuggestedCommands(),
                onExecute: { viewModel.executeCommand() },
                onCommandTap: { command in viewModel.commandInput = command }
            )
            .background(RoundedRectangle(cornerRadius: 24, style: .continuous).fill(.regularMaterial))
            .overlay(RoundedRectangle(cornerRadius: 24, style: .continuous).stroke(Color.white.opacity(0.12), lineWidth: 1))
            .overlay(alignment: .top) { cardShine(cornerRadius: 24) }
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            .disabled(showTutorial)
            .opacity(showTutorial ? 0.5 : 1.0)
            .animation(.easeInOut(duration: 0.3), value: showTutorial)
            .shadow(color: Color.black.opacity(0.2), radius: 18, y: 10)

            if gameState.completedLevels.contains(currentLevel.id) && !isInPracticeMode {
                Button { showLearningSheet = true } label: {
                    Image(systemName: "info.circle.fill")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.9))
                        .padding(12)
                        .background(
                            Circle()
                                .fill(.ultraThinMaterial)
                                .overlay(Circle().stroke(Color.white.opacity(0.18), lineWidth: 1))
                        )
                        .shadow(color: Color.black.opacity(0.18), radius: 10, y: 6)
                        .shadow(color: Color.cyan.opacity(0.7), radius: 12)
                        .shadow(color: Color.blue.opacity(0.5), radius: 24)
                        .scaleEffect(1.1)
                        .animation(
                            .easeInOut(duration: 1.2).repeatForever(autoreverses: true),
                            value: gameState.completedLevels.contains(currentLevel.id)
                        )
                }
                .buttonStyle(TapScaleButtonStyle())
                .padding(.top, 44)
                .padding(.trailing, 8)
            }
        }
        .sheet(isPresented: $showLearningSheet) {
            LearningDetailSheet(
                level: currentLevel,
                content: LearningContent.content(for: currentLevel.id)
            )
            .presentationDetents([.medium, .large])
            .presentationCornerRadius(28)
            .presentationDragIndicator(.visible)
        }
        .tutorialAnchor(.console)
    }

    // MARK: - Overlays

    @ViewBuilder
    private var successOverlay: some View {
        if viewModel.showSuccess {
            Color.black.opacity(0.5)
                .ignoresSafeArea()
                .transition(.opacity)

            SuccessOverlay(level: currentLevel) {
                viewModel.showSuccess = false
                withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                    showExplanationCard = true
                }
            }
            .transition(.scale.combined(with: .opacity))
        }
    }

    @ViewBuilder
    private var explanationOverlay: some View {
        if showExplanationCard {
            Color.black.opacity(0.5)
                .ignoresSafeArea()
                .onTapGesture { withAnimation { showExplanationCard = false } }
                .transition(.opacity)

            CommandExplanationCard(
                level: currentLevel,
                isLastLevel: currentLevel.id == Level.allLevels.last?.id,
                onNextLevel: { transitionToNextLevel() },
                onStayAndExplore: {
                    withAnimation(.easeOut(duration: 0.3)) { showExplanationCard = false }
                },
                onDismiss: { showExplanationCard = false }
            )
            .transition(.move(edge: .bottom).combined(with: .opacity))
        }
    }

    @ViewBuilder
    private var errorOverlay: some View {
        if viewModel.showError {
            VStack {
                errorBanner
                Spacer()
            }
            .transition(.move(edge: .top).combined(with: .opacity))
        }
    }

    private var errorBanner: some View {
        HStack(spacing: 10) {
            Image(systemName: "xmark.circle.fill")
                .foregroundStyle(GitTheme.red)
            Text(viewModel.errorMessage)
                .font(.system(.body, design: .default).weight(.medium))
                .foregroundStyle(.primary)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.regularMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(Color.white.opacity(0.14), lineWidth: 1)
                )
        )
        .shadow(color: Color.black.opacity(0.2), radius: 14, y: 8)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .padding(16)
    }

    @ViewBuilder
    private var completedInfoOverlay: some View {
        if showCompletedInfoOverlay {
            ZStack {
                Color.black.opacity(0.55)
                    .ignoresSafeArea()

                CompletedInfoCard(
                    level: currentLevel,
                    content: LearningContent.content(for: currentLevel.id),
                    onPracticeAgain: { startPracticeSession() }
                )
                .frame(maxWidth: 620)
                .padding(.horizontal, 24)
                .padding(.vertical, 32)
                .transition(.scale(scale: 0.96).combined(with: .opacity))
            }
        }
    }

    // MARK: - Visualizer Setup

    private func setupVisualizerState() {
        if !isInPracticeMode, let savedSnapshot = repoState.snapshot(forLevel: currentLevel.id) {
            repoState.restore(from: savedSnapshot)
            return
        }
        repoState.resetAll()
        switch currentLevel.id {
        case 1:
            break
        case 2:
            repoState.initialize()
            repoState.stageFiles(["README.md"])
            repoState.commit(message: "Initial commit")
        case 3:
            repoState.initialize()
            repoState.stageFiles(["README.md"])
            repoState.commit(message: "Initial commit")
            repoState.createBranch(name: "feature/dark-mode")
            repoState.stageFiles(["settings.js"])
            repoState.commit(message: "Add dark mode")
            repoState.checkout(branch: "main")
        case 4:
            repoState.initialize()
            repoState.stageFiles(["README.md"])
            repoState.commit(message: "Initial commit")
            repoState.createBranch(name: "feature/dashboard")
            repoState.stageFiles(["dashboard.js"])
            repoState.commit(message: "Add dashboard")
            repoState.checkout(branch: "main")
        case 5:
            repoState.initialize()
            repoState.stageFiles(["README.md"])
            repoState.commit(message: "Initial commit")
            repoState.commit(message: "Add settings")
            repoState.addRemote(name: "origin", url: "https://github.com/gitquest-labs/user-profiles.git")
        case 6:
            repoState.initialize()
            repoState.stageFiles(["README.md"])
            repoState.commit(message: "Initial commit")
            repoState.commit(message: "Add refactor")
            repoState.stageFiles([".env"])
            repoState.commit(message: "OOPS: .env keys")
        case 7:
            repoState.initialize()
            repoState.stageFiles(["README.md"])
            repoState.commit(message: "Initial commit")
            repoState.createBranch(name: "feature/dark-mode")
            repoState.stageFiles(["settings.js"])
            repoState.commit(message: "Add dark mode")
            repoState.checkout(branch: "main")
        case 8:
            repoState.initialize()
            repoState.stageFiles(["README.md"])
            repoState.commit(message: "Initial commit")
            repoState.commit(message: "Add settings page")
            repoState.stageFiles(["settings.js", "theme.js"])
        case 9:
            repoState.initialize()
            repoState.stageFiles(["README.md"])
            repoState.commit(message: "Initial commit")
            repoState.createBranch(name: "hotfix/null-check")
            repoState.stageFiles(["auth.js"])
            repoState.commit(message: "Fix null pointer in auth check")
        case 10:
            repoState.initialize()
            repoState.stageFiles(["README.md"])
            repoState.commit(message: "Initial commit")
            repoState.commit(message: "Add dark mode")
            repoState.addRemote(name: "origin", url: "https://github.com/gitquest-labs/user-profiles.git")
        case 11:
            repoState.initialize()
            repoState.stageFiles(["README.md", "node_modules/"])
            repoState.commit(message: "Initial commit (includes node_modules)")
        case 12:
            repoState.initialize()
            repoState.stageFiles(["README.md"])
            repoState.commit(message: "Initial commit")
            repoState.commit(message: "Add settings")
            repoState.stageFiles(["api.js"])
            repoState.commit(message: "Refactor API client (breaks build)")
            repoState.addRemote(name: "origin", url: "https://github.com/gitquest-labs/user-profiles.git")
            repoState.push()
        case 13:
            repoState.initialize()
            repoState.stageFiles(["README.md"])
            repoState.commit(message: "Initial commit")
            repoState.commit(message: "Add checkout flow")
            repoState.commit(message: "Refactor checkout validation")
        default:
            break
        }
    }

    // MARK: - Visualizer Command Execution

    private func executeOnVisualizer(command: String) {
        guard !command.isEmpty else { return }
        let cmd = command.lowercased()
        if cmd.contains("git init") {
            repoState.initialize()
        } else if cmd.contains("git stash") {
            if cmd.contains("pop") {
                repoState.stashPop()
            } else {
                repoState.stash()
            }
        } else if cmd.contains("git cherry-pick") {
            repoState.cherryPick(message: "Fix null pointer in auth check")
        } else if cmd.contains("git tag") {
            repoState.addTag(name: extractBranchName(from: command, afterFlag: nil))
        } else if cmd.contains("git rm") {
            repoState.untrack(files: [extractBranchName(from: command, afterFlag: nil)])
        } else if cmd.contains("git revert") {
            repoState.revert()
        } else if cmd.contains("git log") {
            repoState.inspectHistory(
                command: "git log --oneline",
                explanation: "Displayed the commit history - a quick way to see what changed and when."
            )
        } else if cmd.contains("git blame") {
            repoState.inspectHistory(
                command: "git blame checkout.js",
                explanation: "Showed which commit last modified each line of the file - perfect for tracking down regressions."
            )
        } else if cmd.contains("git add") {
            repoState.stageFiles(extractFiles(from: command))
        } else if cmd.contains("git commit") {
            repoState.commit(message: extractCommitMessage(from: command))
        } else if cmd.contains("git checkout -b") {
            repoState.createBranch(name: extractBranchName(from: command, afterFlag: "-b"))
        } else if cmd.contains("git checkout") {
            repoState.checkout(branch: extractBranchName(from: command, afterFlag: nil))
        } else if cmd.contains("git remote add") {
            let parts = command.split(separator: " ").map(String.init)
            repoState.addRemote(
                name: parts.count > 3 ? parts[3] : "origin",
                url:  parts.count > 4 ? parts[4] : "https://github.com/..."
            )
        } else if cmd.contains("git push") {
            if currentLevel.id == 10 {
                repoState.pushTag(name: extractBranchName(from: command, afterFlag: nil))
            } else {
                repoState.push()
            }
        } else if cmd.contains("git pull") {
            repoState.pull()
        } else if cmd.contains("git merge") {
            repoState.merge(branch: extractBranchName(from: command, afterFlag: nil))
        } else if cmd.contains("git status") {
            repoState.status()
        } else if cmd.contains("git reset") {
            repoState.resetHead()
        }
    }

    // MARK: - Private Helpers

    private func getCurrentStep() -> LevelStep? {
        guard viewModel.currentStep < currentLevel.requiredSteps.count else { return nil }
        return currentLevel.requiredSteps[viewModel.currentStep]
    }

    private func extractBranchName(from command: String, afterFlag flag: String?) -> String {
        let parts = command.trimmingCharacters(in: .whitespaces).split(separator: " ").map(String.init)
        if let flag, let idx = parts.firstIndex(of: flag), parts.indices.contains(idx + 1) {
            return parts[idx + 1]
        }
        return parts.last ?? "branch"
    }

    private func extractCommitMessage(from command: String) -> String {
        let cleaned = command.hasPrefix("$ ") ? String(command.dropFirst(2)) : command
        if let start = cleaned.firstIndex(of: "\""),
           let end   = cleaned.lastIndex(of: "\""),
           start != end {
            return String(cleaned[cleaned.index(after: start)..<end])
        }
        return "Update"
    }

    private func extractFiles(from command: String) -> [String] {
        let parts = command.split(separator: " ").map(String.init)
        return parts.count > 2 ? Array(parts[2...]) : ["."]
    }

    private func transitionToNextLevel() {
        guard let nextLevel = currentLevel.nextLevel() else {
            showExplanationCard = false
            return
        }
        withAnimation(.easeInOut(duration: 0.4)) { showExplanationCard = false }
        Task { @MainActor in
            try? await Task.sleep(for: .seconds(0.4))
            chatResetId = UUID()
            isInPracticeMode = false
            showCompletedInfoOverlay = false
            currentLevel = nextLevel
            viewModel.startLevel(nextLevel)
            setupVisualizerState()
        }
    }

    private func startPracticeSession() {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            showCompletedInfoOverlay = false
        }
        isInPracticeMode = true
        showExplanationCard = false
        showLearningSheet = false
        glowInfoButton = false
        correctPulse = false
        shakeError = false
        errorFlash = false

        Task { @MainActor in
            try? await Task.sleep(for: .seconds(0.3))
            viewModel.startLevel(currentLevel)
            viewModel.showSuccess = false
            viewModel.showError = false
            viewModel.errorMessage = ""
            setupVisualizerState()
            try? await Task.sleep(for: .seconds(0.1))
            chatResetId = UUID()
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        LevelGameView(level: Level.allLevels[0])
            .environment(GameState())
            .environment(GitRepositoryState())
    }
    .preferredColorScheme(.dark)
}
