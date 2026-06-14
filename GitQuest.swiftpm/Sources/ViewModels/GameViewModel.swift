import Foundation
import SwiftUI
import Observation

// MARK: - Helper Models

/// Represents the result of a git command execution, including its success state and output message.
struct CommandResult {
    let success: Bool
    let message: String
}

/// A single line of output in the terminal console.
struct TerminalLine: Identifiable {
    let id = UUID()
    let text: String
    let type: TerminalLineType
}

/// Defines the visual styling and semantic meaning of a terminal line.
enum TerminalLineType {
    case command
    case success
    case error
    case info
    case instruction
    case system
}

// MARK: - Main View Model

/// Manages the core game state, including terminal interactions, command processing, and level progression.
@Observable
@MainActor
class GameViewModel {

    // MARK: - Published Properties

    /// The overall progress state across different levels.
    var gameState: GameState = GameState()
    
    /// The current step index within the active level.
    var currentStep: Int = 0
    
    /// History of all terminal lines currently displayed.
    var terminalOutput: [TerminalLine] = []
    
    /// The ongoing user input for the terminal block.
    var commandInput: String = ""
    
    /// UI state flags for showing success overlays and error feedback.
    var showSuccess: Bool = false
    var showError: Bool = false
    var errorMessage: String = ""
    
    /// Chat messages displayed in the current level's story progression.
    var chatMessages: [ChatMessage] = []
    
    /// Keeps track of the last successfully ran command.
    var lastSuccessfulCommand: String = ""
    
    /// The level currently being played.
    var currentPlayingLevel: Level?

    /// Tracks whether the current level has been played without any failed command attempts.
    var levelHasErrors: Bool = false

    // MARK: - Level Management

    /// Initializes and starts a new level, resetting necessary states and displaying initial output.
    func startLevel(_ level: Level) {
        currentPlayingLevel = level
        currentStep = 0
        terminalOutput = []
        levelHasErrors = false
        
        // Initialize chat messages with slightly staggered timestamps
        chatMessages = level.initialChat.enumerated().map { index, msg in
            ChatMessage(sender: msg.sender, text: msg.text, timestamp: Date().addingTimeInterval(Double(index)))
        }
        
        // Display initial terminal greetings
        addTerminalOutput("", type: .system)
        addTerminalOutput("→ \(level.title)", type: .info)
        addTerminalOutput("", type: .system)
        
        if level.requiredSteps.first != nil {
            addTerminalOutput("Ready? Tap a command below to begin.", type: .instruction)
        }
    }

    // MARK: - User Intents

    /// Triggered when the user submits a command to the terminal.
    func executeCommand() {
        let command = commandInput.trimmingCharacters(in: .whitespaces)
        guard !command.isEmpty else { return }
        
        // Echo the command to the terminal
        addTerminalOutput("$ \(command)", type: .command)
        commandInput = ""
        
        // Process the command and get the result
        let result = processCommand(command)
        addTerminalOutput(result.message, type: result.success ? .success : .error)
        
        // Update game flow based on success
        if result.success {
            checkStepCompletion(command)
        } else {
            showErrorFeedback(result.message)
        }
    }

    /// Provides context-aware command suggestions based on the current level and step.
    func getSuggestedCommands() -> [String] {
        guard let level = currentPlayingLevel else { return [] }
        guard currentStep < level.requiredSteps.count else { return [] }
        
        // Hardcoded suggestions matching specific level identifiers and steps
        switch level.id {
        case 1:
            if currentStep == 0 { return ["git init"] }
            if currentStep == 1 { return ["git add README.md", "git add ."] }
            return ["git commit -m \"Initial commit\""]
        case 2:
            if currentStep == 0 { return ["git checkout -b feature/dark-mode"] }
            return ["git commit -m \"Add dark mode\""]
        case 3:
            if currentStep == 0 { return ["git remote add origin https://github.com/gitquest-labs/user-profiles.git"] }
            return ["git push -u origin feature/dark-mode"]
        case 4:
            if currentStep == 0 { return ["git status"] }
            if currentStep == 1 { return ["git add dashboard.js"] }
            return ["git commit -m \"Resolve conflict\""]
        case 5:
            return ["git pull origin main"]
        case 6:
            return ["git reset HEAD~1", "git reset --soft HEAD~1"]
        case 7:
            if currentStep == 0 { return ["git checkout main"] }
            return ["git merge feature/dark-mode"]
        case 8:
            if currentStep == 0 { return ["git stash"] }
            return ["git stash pop"]
        case 9:
            if currentStep == 0 { return ["git checkout main"] }
            return ["git cherry-pick a1b2c3d"]
        case 10:
            if currentStep == 0 { return ["git tag v1.0"] }
            return ["git push origin v1.0"]
        case 11:
            if currentStep == 0 { return ["git rm -r --cached node_modules"] }
            if currentStep == 1 { return ["git add .gitignore"] }
            return ["git commit -m \"Remove node_modules from tracking\""]
        case 12:
            return ["git revert HEAD"]
        case 13:
            if currentStep == 0 { return ["git log --oneline"] }
            return ["git blame checkout.js"]
        default:
            return []
        }
    }

    // MARK: - Command Processing Logic

    /// Validates a command against the expected input for the current step.
    private func processCommand(_ command: String) -> CommandResult {
        guard let level = currentPlayingLevel else {
            return CommandResult(success: false, message: "No level is active")
        }
        guard currentStep < level.requiredSteps.count else {
            return CommandResult(success: false, message: "Level already completed!")
        }
        
        let step = level.requiredSteps[currentStep]
        
        // Flexible validation: Check if user input contains the expected command text
        if command.lowercased().contains(step.expectedCommand.lowercased()) {
            return processCorrectCommand(command, step: step, level: level)
        }
        
        return CommandResult(success: false, message: "Hmm, that's not quite right. \(step.hint)")
    }

    /// Handles successful command execution and returns simulated git output based on the level.
    private func processCorrectCommand(_ command: String, step: LevelStep, level: Level) -> CommandResult {
        switch level.id {
        case 1:
            if command.contains("init") {
                return CommandResult(success: true, message: "Initialized empty Git repository in .git/")
            }
            if command.contains("add") {
                return CommandResult(success: true, message: "Changes staged for commit")
            }
            if command.contains("commit") {
                let hash = String(format: "%07x", Int.random(in: 0...0xFFFFFFF))
                return CommandResult(success: true, message: "[main \(hash)] Initial commit")
            }
        case 2:
            if command.contains("checkout") {
                let branchName = extractBranchName(from: command)
                return CommandResult(success: true, message: "Switched to a new branch '\(branchName)'")
            }
            if command.contains("commit") {
                let hash = String(format: "%07x", Int.random(in: 0...0xFFFFFFF))
                return CommandResult(success: true, message: "[feature/dark-mode \(hash)] Add dark mode")
            }
        case 3:
            if command.contains("remote") {
                return CommandResult(success: true, message: "Remote 'origin' added")
            }
            if command.contains("push") {
                return CommandResult(success: true, message: """
                Enumerating objects: 5, done.
                Counting objects: 100% (5/5), done.
                Writing objects: 100% (3/3), 284 bytes | 284.00 KiB/s, done.
                Total 3 (delta 0), reused 0 (delta 0)
                To https://github.com/gitquest-labs/user-profiles.git
                 * [new branch]      feature/dark-mode -> feature/dark-mode
                """)
            }
        case 4:
            if command.contains("status") {
                return CommandResult(success: true, message: """
                On branch main
                You have unmerged paths.
                  (fix conflicts and run "git commit")
                Unmerged paths:
                  (use "git add <file>..." to mark resolution)
                    both modified:   dashboard.js
                no changes added to commit
                """)
            }
            if command.contains("add") {
                return CommandResult(success: true, message: "Conflict in dashboard.js marked as resolved")
            }
            if command.contains("commit") {
                return CommandResult(success: true, message: "[main a7f3c21] Resolve dashboard color conflict - use purple")
            }
        case 5:
            if command.contains("pull") {
                return CommandResult(success: true, message: """
                remote: Enumerating objects: 5, done.
                remote: Counting objects: 100% (5/5), done.
                Updating a1b2c3d..e4f5g6h
                Fast-forward
                 refactor.js | 42 +++++++++++++++++++++++++++++++++
                 1 file changed, 42 insertions(+)
                """)
            }
        case 6:
            if command.contains("reset") {
                return CommandResult(success: true, message: "HEAD is now at a1b2c3d Previous commit")
            }
        case 7:
            if command.contains("checkout") {
                return CommandResult(success: true, message: "Switched to branch 'main'")
            }
            if command.contains("merge") {
                return CommandResult(success: true, message: """
                Updating a1b2c3d..e4f5g6h
                Fast-forward
                 settings.js | 15 +++++++++++++++
                 1 file changed, 15 insertions(+)
                """)
            }
        case 8:
            if command.contains("pop") {
                return CommandResult(success: true, message: """
                Dropped refs/stash@{0}
                On branch main
                Changes not staged for commit:
                  modified: settings.js
                  modified: theme.js
                """)
            }
            if command.contains("stash") {
                return CommandResult(success: true, message: "Saved working directory and index state WIP on main: a1b2c3d Add settings page")
            }
        case 9:
            if command.contains("checkout") {
                return CommandResult(success: true, message: "Switched to branch 'main'")
            }
            if command.contains("cherry-pick") {
                let hash = String(format: "%07x", Int.random(in: 0...0xFFFFFFF))
                return CommandResult(success: true, message: """
                [main \(hash)] Fix null pointer in auth check
                 1 file changed, 3 insertions(+), 1 deletion(-)
                """)
            }
        case 10:
            if command.contains("push") {
                return CommandResult(success: true, message: """
                To https://github.com/gitquest-labs/user-profiles.git
                 * [new tag]         v1.0 -> v1.0
                """)
            }
            if command.contains("tag") {
                return CommandResult(success: true, message: "Created tag 'v1.0' pointing at the current commit")
            }
        case 11:
            if command.contains("rm") {
                return CommandResult(success: true, message: """
                rm 'node_modules/react/index.js'
                rm 'node_modules/react/package.json'
                rm 'node_modules/...' (1,204 files)
                """)
            }
            if command.contains("add") {
                return CommandResult(success: true, message: "Changes staged for commit")
            }
            if command.contains("commit") {
                return CommandResult(success: true, message: """
                [main b3f8a21] Remove node_modules from tracking
                 1,205 files changed, 0 insertions(+), 58213 deletions(-)
                """)
            }
        case 12:
            if command.contains("revert") {
                let hash = String(format: "%07x", Int.random(in: 0...0xFFFFFFF))
                return CommandResult(success: true, message: """
                [main \(hash)] Revert "Refactor API client (breaks build)"
                 1 file changed, 12 insertions(+), 4 deletions(-)
                 This reverts commit a1b2c3d.
                """)
            }
        case 13:
            if command.contains("blame") {
                return CommandResult(success: true, message: """
                a1b2c3d (Maya Chen  2 days ago) 40) function validateCart(items) {
                c4f9a2e (Maya Chen  yesterday)  41)   if (!items.length) return false
                c4f9a2e (Maya Chen  yesterday)  42)   return items.every(i => i.qty > 0 && i.price >= 0)
                """)
            }
            if command.contains("log") {
                return CommandResult(success: true, message: """
                c4f9a2e Refactor checkout validation
                e29b3d1 Add checkout flow
                a1b2c3d Initial commit
                """)
            }
        default:
            break
        }
        return CommandResult(success: true, message: "Command executed successfully")
    }

    // MARK: - Game Flow Control

    /// Verifies if a valid command advances the step, appending new chat messages and checking for level completion.
    private func checkStepCompletion(_ command: String) {
        guard let level = currentPlayingLevel else { return }
        guard currentStep < level.requiredSteps.count else { return }
        
        lastSuccessfulCommand = command
        let step = level.requiredSteps[currentStep]
        
        // Print success text
        addTerminalOutput("", type: .system)
        addTerminalOutput("✓ " + step.successMessage, type: .success)
        addTerminalOutput("", type: .system)
        
        let completedStepIndex = currentStep
        currentStep += 1
        
        // Append story chat messages with a staggered animation delay
        if let stepMessages = level.stepChats[completedStepIndex] {
            for (index, message) in stepMessages.enumerated() {
                let delay = Double(index) * 0.5
                Task { @MainActor in
                    try? await Task.sleep(for: .seconds(delay))
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        self.chatMessages.append(message.withCurrentTimestamp())
                    }
                }
            }
        }
        
        // Check if level is finished
        if currentStep >= level.requiredSteps.count {
            completeLevel()
        } else {
            let nextStep = level.requiredSteps[currentStep]
            addTerminalOutput("Next: \(nextStep.expectedCommand)", type: .instruction)
        }
    }

    /// Executed when the user successfully finishes all steps in a level.
    private func completeLevel() {
        guard let level = currentPlayingLevel else { return }
        gameState.completeLevel(level.id, perfect: !levelHasErrors)
        
        addTerminalOutput("", type: .system)
        addTerminalOutput("🎉 Level Complete!", type: .success)
        
        // Brief delay before presenting the success overlay
        Task { @MainActor in
            try? await Task.sleep(for: .seconds(0.3))
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                self.showSuccess = true
            }
        }
    }

    // MARK: - View Helpers

    /// Appends a new line to the terminal.
    private func addTerminalOutput(_ text: String, type: TerminalLineType) {
        terminalOutput.append(TerminalLine(text: text, type: type))
    }

    /// Triggers the error feedback overlay temporarily.
    private func showErrorFeedback(_ message: String) {
        levelHasErrors = true
        errorMessage = message
        withAnimation { showError = true }
        
        Task { @MainActor in
            try? await Task.sleep(for: .seconds(2.5))
            withAnimation { self.showError = false }
        }
    }

    /// A helper method to parse the branch name from a checkout command.
    private func extractBranchName(from command: String) -> String {
        let parts = command.split(separator: " ").map(String.init)
        if let bIndex = parts.firstIndex(of: "-b"), bIndex + 1 < parts.count {
            return parts[bIndex + 1]
        }
        return parts.last ?? "branch"
    }
}
