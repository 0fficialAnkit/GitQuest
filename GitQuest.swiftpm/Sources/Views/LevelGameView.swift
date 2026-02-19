//
//  LevelGameView.swift
//  GitQuest
//
//  Dark-themed portrait gameplay layout
//

import SwiftUI

// MARK: - Level Game View

/// Main gameplay screen — combines the Git visualiser, chat feed,
/// repository status card, and console into a single portrait layout.
struct LevelGameView: View {
    let initialLevel: Level
    
    @EnvironmentObject var gameState: GameState
    @EnvironmentObject var repoState: GitRepositoryState
    @StateObject private var viewModel = GameViewModel()
    @Environment(\.dismiss) var dismiss
    
    @State private var currentLevel: Level
    @State private var showExplanationCard = false
    @State private var showLearningSheet = false
    @State private var glowInfoButton = false
    @State private var chatResetId = UUID()
    @State private var showTutorial = false
    
    // Dark palette constants
    private let bgColor = Color(red: 0.07, green: 0.07, blue: 0.09)
    private let cardBg = Color(red: 0.12, green: 0.12, blue: 0.14)
    
    init(level: Level) {
        self.initialLevel = level
        self._currentLevel = State(initialValue: level)
    }
    
    // MARK: - Body
    
    var body: some View {
        ZStack {
            // Full dark background
            bgColor.ignoresSafeArea()
            
            VStack(spacing: 12) {
                // ── DARK HEADER (56pt) ──
                darkHeader
                
                // ── MAIN CONTENT ──
                VStack(spacing: 16) {
                    // ── THE "INTEL" LAYER (Top Row) ──
                    // 50/50 width distribution
                    HStack(spacing: 16) {
                        // Left Column: Chat
                        ChatStoryView(
                            messages: viewModel.chatMessages,
                            resetId: chatResetId
                        )
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                            .tutorialAnchor(.chat)
                        
                        // Right Column: Concept Card
                        if let step = getCurrentStep() {
                            ConceptCardView(
                                command: viewModel.getSuggestedCommands().first ?? step.expectedCommand
                            )
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .tutorialAnchor(.concept)
                        } else {
                            // Completion state placeholder
                            VStack(spacing: 12) {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 40))
                                    .foregroundStyle(Theme.Colors.success)
                                Text("All Steps Complete!")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundStyle(.white)
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(Color(red: 0.12, green: 0.12, blue: 0.14))
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                        }
                    }
                    
                    // ── THE "MAP" LAYER (Middle Row) ──
                    // Balanced Visualizer and Repository State (50/50 width, Equal height)
//
                    HStack(spacing: 12) {
                        GitVisualizerView(repoState: repoState)
                            .frame(maxWidth: .infinity)
                            .frame(height: 280)
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                            .tutorialAnchor(.visualizer)

                        GitStateCard(repoState: repoState)
                            .frame(maxWidth: .infinity)
                            .frame(maxHeight: .infinity)
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                            .tutorialAnchor(.repoState)
                    }
                    .frame(height: 280)

                    // ── THE "TERMINAL" LAYER (Bottom Row) ──
                    consolePanel
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 24)
            }
            
            // Overlays
            successOverlay
            explanationOverlay
            errorOverlay
        }
        .gameTutorial(isShowing: $showTutorial)
        .preferredColorScheme(.dark)
        .navigationBarHidden(true)
        .onAppear {
            viewModel.gameState = gameState
            viewModel.startLevel(currentLevel)
            setupVisualizerState()

            // Show tutorial only once ever (until user resets progress)
            if currentLevel.id == 1, !gameState.hasSeenGameTutorial {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                    withAnimation {
                        showTutorial = true
                    }
                    gameState.hasSeenGameTutorial = true
                }
            }
        }
        .onChange(of: gameState.completedLevels) { _, newValue in
            // Trigger glow when level is completed
            if newValue.contains(currentLevel.id) {
                withAnimation {
                    glowInfoButton = true
                }
                
                // Stop glowing after 1 second
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    withAnimation {
                        glowInfoButton = false
                    }
                }
            }
        }
    }
    
    // MARK: - Dark Header (56pt)
    
    private var darkHeader: some View {
        HStack {
            // Back button
            Button(action: { dismiss() }) {
                HStack(spacing: 4) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                    Text("Back")
                        .font(.system(size: 16, weight: .medium))
                }
                .foregroundStyle(.white.opacity(0.85))
            }
            
            Spacer()
            
            // Level title
            Text(currentLevel.title)
                .font(.system(size: 17, weight: .bold))
                .foregroundStyle(.white)
            
            Spacer()
            
            // Progress
            Text("\(viewModel.currentStep)/\(currentLevel.requiredSteps.count)")
                .font(.system(size: 15, weight: .semibold, design: .monospaced))
                .foregroundStyle(.white.opacity(0.5))
        }
        .padding(.horizontal, 16)
        .frame(height: 56)
        .background(Color(red: 0.10, green: 0.10, blue: 0.12))
    }
    
    // MARK: - Console
    private var consolePanel: some View {
        ZStack(alignment: .topTrailing) {
            ConsoleView(
                commandInput: $viewModel.commandInput,
                terminalOutput: viewModel.terminalOutput,
                suggestedCommands: viewModel.getSuggestedCommands(),
                onExecute: {
                    viewModel.executeCommand()
                    executeOnVisualizer()
                },
                onCommandTap: { command in
                    viewModel.commandInput = command
                }
            )
            
            // Info button — positioned just below the header
            if gameState.completedLevels.contains(currentLevel.id) {
                Button {
                    showLearningSheet = true
                } label: {
                    Image(systemName: "info.circle.fill")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.9))
                        .padding(12)
                        .background(
                            Circle()
                                .fill(Color.blue.opacity(0.2))
                                .shadow(
                                    color: glowInfoButton ? .blue.opacity(0.8) : .clear,
                                    radius: glowInfoButton ? 15 : 0
                                )
                        )
                        .scaleEffect(glowInfoButton ? 1.15 : 1.0)
                }
                .buttonStyle(.plain)
                .padding(.top, 44)      // Position below header (header height ~36-40pt + some spacing)
                .padding(.trailing, 8)   // Distance from right edge
                .animation(.easeInOut(duration: 0.3), value: glowInfoButton)
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
    
    
    // MARK: - Overlay Views
    
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
                .onTapGesture {
                    withAnimation { showExplanationCard = false }
                }
                .transition(.opacity)
            
            CommandExplanationCard(
                level: currentLevel,
                onNextLevel: { transitionToNextLevel() },
                onStayAndExplore: {
                    withAnimation(.easeOut(duration: 0.3)) {
                        showExplanationCard = false
                    }
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
    
    // MARK: - Error Banner
    
    private var errorBanner: some View {
        HStack(spacing: 10) {
            Image(systemName: "xmark.circle.fill")
                .foregroundStyle(GitTheme.red)
            Text(viewModel.errorMessage)
                .font(.system(.body, design: .rounded).weight(.medium))
                .foregroundStyle(.white)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color(red: 0.18, green: 0.10, blue: 0.10))
        )
        .padding(16)
    }
    
    // MARK: - Visualizer State Setup
    
    private func setupVisualizerState() {
        switch currentLevel.id {
        case 1:
            break
        case 2:
            if !repoState.isInitialized {
                repoState.initialize()
                repoState.stageFiles()
                repoState.commit(message: "Initial commit")
            }
        case 3:
            if !repoState.isInitialized {
                repoState.initialize()
                repoState.stageFiles()
                repoState.commit(message: "Initial commit")
                repoState.commit(message: "Add features")
            }
        case 4:
            if !repoState.isInitialized {
                repoState.initialize()
                repoState.stageFiles()
                repoState.commit(message: "Initial commit")
            }
        case 5, 6, 7:
            if !repoState.isInitialized {
                repoState.initialize()
                repoState.stageFiles()
                repoState.commit(message: "Initial commit")
                repoState.commit(message: "Add features")
            }
        default:
            break
        }
    }
    
    // MARK: - Execute on Visualizer
    
    private func executeOnVisualizer() {
        let command = viewModel.terminalOutput.last?.text ?? ""
        
        if command.contains("git init") {
            repoState.initialize()
        } else if command.contains("git add") {
            let files = extractFiles(from: command)
            repoState.stageFiles(files)
        } else if command.contains("git commit") {
            let message = extractCommitMessage(from: command)
            repoState.commit(message: message)
        } else if command.contains("git checkout -b") {
            let branchName = extractBranchName(from: command)
            repoState.createBranch(name: branchName)
        } else if command.contains("git checkout") && !command.contains("-b") {
            let branchName = extractBranchName(from: command)
            repoState.checkout(branch: branchName)
        } else if command.contains("git remote add") {
            repoState.addRemote(name: "origin", url: "https://github.com/...")
        } else if command.contains("git push") {
            repoState.push()
        } else if command.contains("git pull") {
            repoState.pull()
        } else if command.contains("git merge") {
            let branchName = extractBranchName(from: command)
            repoState.merge(branch: branchName)
        } else if command.contains("git status") {
            repoState.status()
        } else if command.contains("git reset") {
            repoState.resetHead()
        }
    }
    
    // MARK: - Helpers
    
    private func getCurrentStep() -> LevelStep? {
        guard viewModel.currentStep < currentLevel.requiredSteps.count else { return nil }
        return currentLevel.requiredSteps[viewModel.currentStep]
    }
    
    private func extractBranchName(from command: String) -> String {
        let parts = command.split(separator: " ").map(String.init)
        return parts.last ?? "feature"
    }
    
    private func extractCommitMessage(from command: String) -> String {
        if let range = command.range(of: "-m \"([^\"]+)\"", options: .regularExpression) {
            let match = command[range]
            return String(match.dropFirst(4).dropLast(1))
        }
        return "Commit"
    }
    
    private func extractFiles(from command: String) -> [String] {
        let parts = command.split(separator: " ").map(String.init)
        if parts.count > 2 {
            return Array(parts[2...])
        }
        return ["."]
    }
    
    // MARK: - Level Transition
    
    private func transitionToNextLevel() {
        guard let nextLevel = currentLevel.nextLevel() else {
            showExplanationCard = false
            return
        }
        
        withAnimation(.easeInOut(duration: 0.4)) {
            showExplanationCard = false
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            chatResetId = UUID()   // ← reset chat scroll to top for new level
            currentLevel = nextLevel
            viewModel.startLevel(nextLevel)
            setupVisualizerState()
        }
    }
}


// MARK: - Steps To Perform Card

struct StepsToPerformCard: View {
    let currentStep: LevelStep?
    let stepNumber: Int
    let totalSteps: Int
    
    private let cardBg = Color(red: 0.12, green: 0.12, blue: 0.14)
    private let headerBg = Color(red: 0.10, green: 0.10, blue: 0.12)
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text("Steps to Perform")
                    .font(.system(size: 13, weight: .bold, design: .monospaced))
                    .foregroundStyle(.white)
                
                Spacer()
                
                Text("[\(stepNumber) of \(totalSteps)]")
                    .font(.system(size: 11, weight: .bold, design: .monospaced))
                    .foregroundStyle(.white.opacity(0.5))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(headerBg)
            
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    if let step = currentStep {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("• STEP \(stepNumber)")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundStyle(GitTheme.blue)
                            
                            Text(extractTaskTitle(from: step.contextMessage))
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundStyle(.white)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        
                        VStack(alignment: .leading, spacing: 6) {
                            Text("COMMAND TO USE")
                                .font(.system(size: 9, weight: .bold))
                                .foregroundStyle(.white.opacity(0.4))
                            
                            Text("▶ \(step.expectedCommand)")
                                .font(.system(size: 11, weight: .bold, design: .monospaced))
                                .foregroundStyle(GitTheme.green)
                                .padding(8)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color.black.opacity(0.3))
                                .clipShape(RoundedRectangle(cornerRadius: 6))
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            HStack(spacing: 4) {
                                Image(systemName: "lightbulb.fill")
                                    .font(.system(size: 10))
                                    .foregroundStyle(GitTheme.yellow)
                                Text("WHY USE THIS?")
                                    .font(.system(size: 9, weight: .bold))
                                    .foregroundStyle(GitTheme.yellow.opacity(0.8))
                            }
                            
                            Text(whyExplanation(for: step.expectedCommand))
                                .font(.system(size: 10, weight: .medium))
                                .foregroundStyle(.white.opacity(0.7))
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    } else {
                        VStack(spacing: 12) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 32))
                                .foregroundStyle(GitTheme.green)
                            Text("All steps complete!")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundStyle(.white)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 20)
                    }
                }
                .padding(16)
            }
        }
        .background(cardBg)
    }
    
    private func extractTaskTitle(from message: String) -> String {
        let components = message.components(separatedBy: "\n\n")
        let cleanText = components.first ?? message
        return cleanText
            .replacingOccurrences(of: "📍 ", with: "")
            .replacingOccurrences(of: "INITIALIZE REPOSITORY", with: "Initialize the repository to start tracking your project")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    private func whyExplanation(for command: String) -> String {
        let cmd = command.lowercased()
        if cmd.contains("git init") {
            return "This creates the hidden .git folder that tracks your project's history."
        } else if cmd.contains("git add") {
            return "This stages your changes, choosing what to include in your next save."
        } else if cmd.contains("git commit") {
            return "This saves your staged changes as a permanent snapshot."
        } else if cmd.contains("git checkout -b") {
            return "This creates a new branch and switches you to it immediately."
        } else if cmd.contains("git checkout") {
            return "This lets you hop between different branches to work on different tasks."
        } else if cmd.contains("git remote") {
            return "This connects your local repo to a server URL."
        } else if cmd.contains("git push") {
            return "This uploads your local snapshots to the server."
        } else if cmd.contains("git pull") {
            return "This downloads and integrates changes from the server."
        } else if cmd.contains("git merge") {
            return "This combines work from one branch into another."
        }
        return "This command updates your repository state."
    }
}

// MARK: - Supporting Views

struct TeamMessageBubble: View {
    let message: String
    
    var body: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(GitTheme.purple)
                .frame(width: 32, height: 32)
                .overlay(
                    Image(systemName: "person.2.fill")
                        .font(.system(size: 14))
                        .foregroundColor(.white)
                )
            
            VStack(alignment: .leading, spacing: 2) {
                Text("Team")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.white.opacity(0.5))
                
                Text(message)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(.white)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(red: 0.15, green: 0.15, blue: 0.18))
        )
        .frame(maxWidth: 280)
    }
}

#Preview {
    LevelGameView(level: Level.allLevels[0])
        .environmentObject(GameState())
        .environmentObject(GitRepositoryState())
}

// MARK: - Learning Content Model (Local to LevelGameView)

private struct LearningContent {
    let concept: String
    let whyItExists: String
    let whenUsed: String
    let realWorldUsage: [String]
    let tips: [String]
    let risks: [String]
    let scenario: String
    
    static func content(for levelId: Int) -> LearningContent {
        switch levelId {
        case 1:
            return LearningContent(
                concept: "A Git repository is a hidden .git folder that tracks every change you make to your project files. Think of it as a time machine for your code.",
                whyItExists: "Without version control, you'd rely on copying folders like 'project_final_v2_REAL'. Git gives you a structured history of every change, who made it, and why.",
                whenUsed: "Every software project starts with git init. It's the very first command you run when creating something new, whether it's a personal script or a startup's codebase.",
                realWorldUsage: [
                    "Every new project at companies like Google, Apple, and Meta starts with initializing a repository",
                    "Open-source projects on GitHub all begin with git init before any code is written",
                    "CI/CD pipelines depend on a valid Git repo to build, test, and deploy automatically",
                    "Even solo developers use repos to safely experiment without losing working code"
                ],
                tips: [
                    "Run git init only once per project — it creates the .git folder that tracks everything",
                    "Use git status constantly — it's your GPS in the Git world",
                    "Add a .gitignore file early to exclude build artifacts, secrets, and OS files",
                    "Commit early and often — small commits are easier to understand and revert",
                    "Write meaningful commit messages from day one — future you will be grateful"
                ],
                risks: [
                    "Deleting the .git folder wipes your entire project history — there's no undo",
                    "Running git init inside an existing repo creates a nested repo, causing confusion",
                    "Forgetting .gitignore can accidentally commit passwords, API keys, or large binary files",
                    "Avoid these by always checking git status before committing"
                ],
                scenario: "It's your first day at a startup. Your tech lead says: 'Set up the new microservice repo.' You run git init, add a .gitignore, make your first commit, and push to GitHub. The CI pipeline picks it up and your service is ready for development. You just laid the foundation for the entire team's workflow."
            )
        case 2:
            return LearningContent(
                concept: "Staging is Git's prep zone. Before committing, you choose exactly which changes to include. It's like reviewing what goes into a package before sealing it.",
                whyItExists: "Not every change belongs in the same commit. Staging lets you group related changes together, keeping your history clean and meaningful.",
                whenUsed: "Every single commit starts with staging. You use git add to select files, then git commit to save them. It's the two-step rhythm of every Git workflow.",
                realWorldUsage: [
                    "Developers stage only bug-fix files separately from feature work for clean pull requests",
                    "Code reviews are much easier when commits are focused — staging makes this possible",
                    "Teams use staging to separate database migrations from application code changes",
                    "git add -p lets you stage individual lines, not just whole files — surgical precision"
                ],
                tips: [
                    "Use git add . carefully — it stages everything, including files you might not want",
                    "Prefer git add <specific-file> to keep commits focused and reviewable",
                    "Use git diff --staged to review exactly what you're about to commit",
                    "Unstage mistakes with git reset HEAD <file> — no changes are lost",
                    "Think of each commit as telling a story — staging helps you write clean chapters"
                ],
                risks: [
                    "git add . can accidentally stage secrets, debug files, or unfinished work",
                    "Forgetting to stage new files means they won't appear in your commit",
                    "Staging and committing mixed changes makes git blame and git bisect harder to use",
                    "Always run git status and git diff --staged before committing to catch mistakes"
                ],
                scenario: "You fixed a login bug AND started a new feature in the same session. Instead of committing everything together, you use git add auth.swift and commit the fix first. Then you stage the feature files separately. Your colleague reviews two clean, focused pull requests instead of one messy blob."
            )
        case 3:
            return LearningContent(
                concept: "Branches are parallel timelines for your code. The main branch stays stable while you experiment freely on a separate branch. When your work is ready, you merge it back.",
                whyItExists: "Without branches, every developer would edit the same files simultaneously, causing constant conflicts. Branches let teams work independently and merge when ready.",
                whenUsed: "Every feature, bug fix, and experiment gets its own branch. It's the foundation of collaborative development — you'll create hundreds of branches in your career.",
                realWorldUsage: [
                    "Feature branches like feature/user-auth keep new work isolated until it's reviewed and tested",
                    "Hotfix branches let teams patch production bugs without disrupting ongoing feature work",
                    "Release branches stabilize code before deployment while new features continue on main",
                    "GitHub Flow and GitFlow are entire workflows built around branching strategies"
                ],
                tips: [
                    "Name branches descriptively: feature/add-login, fix/crash-on-launch, refactor/database-layer",
                    "Keep branches short-lived — merge within days, not weeks, to avoid drift",
                    "Always branch from an up-to-date main to minimize future merge conflicts",
                    "Delete merged branches to keep the repo clean: git branch -d branch-name",
                    "Use git branch -a to see all branches including remote ones"
                ],
                risks: [
                    "Long-lived branches diverge from main, making merges painful or even impossible",
                    "Working directly on main risks breaking the production codebase for everyone",
                    "Forgetting which branch you're on can lead to committing to the wrong place",
                    "Check your branch with git branch before making changes — make it a habit"
                ],
                scenario: "The product manager needs a dark mode feature for the app. You create feature/dark-mode, spend three days building it, and open a pull request. Meanwhile, two other developers ship a bug fix and a performance improvement on their own branches — nobody's work interferes with anyone else's."
            )
        case 4:
            return LearningContent(
                concept: "Merging combines work from different branches into one. It's how isolated features, fixes, and experiments become part of the main codebase.",
                whyItExists: "After branching, you need a way to bring everything back together. Merging integrates completed work while preserving the history of how it was developed.",
                whenUsed: "After a feature is complete and code-reviewed, you merge it into main. This happens multiple times per day on active teams — it's the heartbeat of collaboration.",
                realWorldUsage: [
                    "Pull requests on GitHub are essentially merge proposals — review, approve, then merge",
                    "CI pipelines run tests on the merge result before allowing it into main",
                    "Teams use squash merges to condense messy feature history into one clean commit",
                    "Release managers merge release branches into main and tag them for deployment"
                ],
                tips: [
                    "Always pull the latest main before merging to minimize conflicts",
                    "Use git merge --no-ff to preserve the branch history in the commit graph",
                    "Resolve merge conflicts carefully — don't just accept one side blindly",
                    "Run tests after merging to ensure nothing broke in the integration",
                    "Consider rebasing for a linear history in smaller teams or solo projects"
                ],
                risks: [
                    "Merge conflicts happen when two branches edit the same lines — don't panic, read carefully",
                    "Force-resolving conflicts by always choosing 'ours' or 'theirs' can silently drop code",
                    "Merging untested code into main can break the build for the entire team",
                    "Use git merge --abort if a merge goes wrong — you can always start over cleanly"
                ],
                scenario: "Friday afternoon. Two feature branches need to ship before the weekend release. You merge feature/payments first — clean, no conflicts. Then feature/notifications has a conflict in the shared config file. You carefully resolve it, run the test suite, and merge. Both features ship on time."
            )
        case 5:
            return LearningContent(
                concept: "Remote repositories are copies of your project hosted on servers like GitHub. They let multiple developers share work, back up code, and collaborate across the world.",
                whyItExists: "Local repos live only on your machine. Remotes let you push your work to a shared location, pull others' changes, and ensure code survives laptop failures.",
                whenUsed: "Every collaborative project uses remotes. You push to share your work, pull to get updates, and clone to start working on existing projects.",
                realWorldUsage: [
                    "GitHub, GitLab, and Bitbucket host millions of remote repositories for teams worldwide",
                    "git push deploys code to production servers in many CI/CD pipelines",
                    "Forking creates your own remote copy of an open-source project to contribute to",
                    "Remote backups mean a stolen laptop doesn't mean lost code"
                ],
                tips: [
                    "Set up SSH keys for passwordless push/pull — saves time and is more secure",
                    "Use git remote -v to verify your remote URLs are correct",
                    "Always pull before pushing to avoid rejection errors",
                    "Use git fetch to see what's changed on the remote without modifying your local files",
                    "Name your primary remote 'origin' — it's the universal convention"
                ],
                risks: [
                    "git push --force can overwrite your teammates' commits on the remote — extremely dangerous",
                    "Pushing secrets (API keys, passwords) to a public remote exposes them permanently",
                    "Forgetting to push means your work exists only locally — one disk failure and it's gone",
                    "Use git push --force-with-lease instead of --force — it checks if anyone pushed first"
                ],
                scenario: "You're contributing to an open-source project. You fork the repo, clone it locally, create a branch, make your fix, push to your fork, and open a pull request. The maintainer reviews it, suggests a change, you push an update, and your code gets merged into a project used by thousands of developers."
            )
        case 6:
            return LearningContent(
                concept: "Collaboration in Git means multiple developers working on the same codebase simultaneously. Pull requests, code reviews, and branch protection rules keep everything organized.",
                whyItExists: "Software is built by teams. Git's collaboration features ensure that everyone's work integrates smoothly, code quality stays high, and nothing ships without review.",
                whenUsed: "Every day on a development team. You pull changes, push your work, review others' code, and resolve conflicts. It's the daily rhythm of professional development.",
                realWorldUsage: [
                    "Pull requests are the standard for code review at virtually every tech company",
                    "Branch protection rules prevent direct pushes to main — all changes go through review",
                    "CODEOWNERS files automatically assign reviewers based on which files were changed",
                    "Teams use git stash to save work-in-progress before switching to review a colleague's PR"
                ],
                tips: [
                    "Pull frequently — small, regular syncs prevent massive conflict nightmares",
                    "Write descriptive PR descriptions explaining what changed and why",
                    "Review others' code generously — it improves the whole team's quality",
                    "Use git stash when you need to context-switch quickly without committing",
                    "Establish branch naming conventions with your team early on"
                ],
                risks: [
                    "Not pulling before starting work creates divergent histories and painful merges",
                    "Pushing directly to main bypasses review and can ship bugs to production",
                    "Ignoring merge conflicts or resolving them carelessly loses other people's work",
                    "Communicate with your team when working on shared files to avoid duplicate effort"
                ],
                scenario: "Monday morning standup. Three developers are working on the same service. Developer A pushes a database change, Developer B pulls it before starting their API work, and Developer C reviews both PRs before merging. By Wednesday, all three features are integrated, tested, and deployed. No conflicts, no lost work — just clean collaboration."
            )
        case 7:
            return LearningContent(
                concept: "Merge conflicts happen when Git can't automatically combine changes because two branches modified the same lines. You must manually decide which changes to keep.",
                whyItExists: "When multiple developers edit the same code, Git can merge most changes automatically. But when two people change the exact same lines, only a human can decide the right outcome.",
                whenUsed: "Conflicts arise during merges, rebases, and pulls. They're a normal part of teamwork — experienced developers resolve them quickly because they understand the pattern.",
                realWorldUsage: [
                    "Large teams encounter conflicts daily — especially in shared config files and APIs",
                    "IDE tools like VS Code, Xcode, and IntelliJ have built-in conflict resolution UIs",
                    "git mergetool launches a visual three-way diff for complex conflicts",
                    "Trunk-based development with short-lived branches minimizes conflict frequency"
                ],
                tips: [
                    "Read both sides of the conflict carefully before choosing — understand the intent",
                    "Look for the <<<<<<< ======= >>>>>>> markers — they show exactly where conflicts are",
                    "After resolving, always run tests to ensure the merged code actually works",
                    "Use git log --merge to see which commits caused the conflict",
                    "Communicate with the other developer when resolving non-trivial conflicts"
                ],
                risks: [
                    "Accepting one side blindly can silently delete important code from a teammate",
                    "Leaving conflict markers (<<<<<<) in the code will cause build failures",
                    "Resolving conflicts without understanding context introduces subtle bugs",
                    "Use git merge --abort to start over if you get lost during resolution"
                ],
                scenario: "You and a colleague both updated the app's theme configuration. Git marks the conflict and shows both versions. You see that your colleague changed the primary color while you updated the font. You keep both changes, remove the markers, run the tests — all green. What felt scary the first time is now a 60-second routine."
            )
        default:
            return LearningContent(
                concept: "This concept builds on your growing Git expertise.",
                whyItExists: "Every Git concept exists to solve a real problem in collaborative software development.",
                whenUsed: "You'll use this concept regularly throughout your development career.",
                realWorldUsage: ["Used daily by professional developers worldwide"],
                tips: ["Practice makes perfect — try these commands in a test repository"],
                risks: ["Always use git status to understand your current state before running commands"],
                scenario: "As you grow as a developer, these Git skills become second nature — like typing or reading code."
            )
        }
    }
}

// MARK: - Learning Detail Sheet (Local to LevelGameView)

private struct LearningDetailSheet: View {
    let level: Level
    let content: LearningContent
    
    @State private var appeared = false
    
    private let sheetBg = Color(red: 0.10, green: 0.10, blue: 0.12)
    private let cardBg = Color(red: 0.14, green: 0.14, blue: 0.16)
    private let accentGreen = Color(red: 0.2, green: 0.8, blue: 0.4)
    private let accentBlue = Color(red: 0.3, green: 0.5, blue: 1.0)
    private let accentOrange = Color(red: 1.0, green: 0.6, blue: 0.2)
    private let accentCyan = Color(red: 0.3, green: 0.8, blue: 0.9)
    private let accentPurple = Color(red: 0.7, green: 0.4, blue: 1.0)
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 24) {
                
                // Header
                headerSection
                
                // Concept
                sectionCard(title: "Understanding the Concept", icon: "lightbulb.fill", color: .yellow) {
                    Text(content.concept)
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.85))
                        .lineSpacing(3)
                    
                    Text(content.whyItExists)
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.6))
                        .lineSpacing(2)
                        .padding(.top, 4)
                    
                    Text(content.whenUsed)
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.6))
                        .lineSpacing(2)
                        .padding(.top, 2)
                }
                
                // Real-World Usage
                sectionCard(title: "Real-World Usage", icon: "briefcase.fill", color: accentCyan) {
                    ForEach(content.realWorldUsage, id: \.self) { item in
                        bulletRow(item, color: accentCyan)
                    }
                }
                
                // Pro Tips
                sectionCard(title: "Pro Tips", icon: "bolt.fill", color: accentBlue, tint: accentBlue.opacity(0.08)) {
                    ForEach(content.tips, id: \.self) { tip in
                        bulletRow(tip, color: accentBlue)
                    }
                }
                
                // Risks
                sectionCard(title: "Common Risks", icon: "exclamationmark.triangle.fill", color: accentOrange, tint: accentOrange.opacity(0.08)) {
                    ForEach(content.risks, id: \.self) { risk in
                        bulletRow(risk, color: accentOrange)
                    }
                }
                
                // Mini Scenario
                sectionCard(title: "Real Scenario", icon: "person.2.fill", color: accentPurple) {
                    Text(content.scenario)
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.75))
                        .lineSpacing(3)
                        .italic()
                }
            }
            .padding(20)
            .padding(.bottom, 30)
        }
        .background(sheetBg.ignoresSafeArea())
        .preferredColorScheme(.dark)
        .onAppear {
            withAnimation(.easeOut(duration: 0.4)) {
                appeared = true
            }
        }
    }
    
    // MARK: - Header
    
    private var headerSection: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Theme.Colors.conceptColor(level.concept), Theme.Colors.conceptColor(level.concept).opacity(0.6)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 56, height: 56)
                    .shadow(color: Theme.Colors.conceptColor(level.concept).opacity(0.4), radius: 10)
                
                Image(systemName: level.icon)
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(.white)
                    .scaleEffect(appeared ? 1.0 : 0.95)
            }
            
            VStack(spacing: 4) {
                Text("What You Just Learned")
                    .font(.title3.bold())
                    .foregroundStyle(.white)
                
                Text(level.title)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.white.opacity(0.5))
            }
        }
        .frame(maxWidth: .infinity)
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 6)
    }
    
    // MARK: - Section Card Builder
    
    private func sectionCard<Content: View>(
        title: String,
        icon: String,
        color: Color,
        tint: Color? = nil,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(color)
                
                Text(title)
                    .font(.callout.bold())
                    .foregroundStyle(.white)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                content()
            }
            .padding(tint != nil ? 14 : 0)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                Group {
                    if let tint = tint {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(tint)
                    }
                }
            )
        }
    }
    
    // MARK: - Bullet Row
    
    private func bulletRow(_ text: String, color: Color) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Circle()
                .fill(color.opacity(0.7))
                .frame(width: 5, height: 5)
                .padding(.top, 6)
            
            Text(text)
                .font(.caption)
                .foregroundStyle(.white.opacity(0.75))
                .lineSpacing(2)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}
