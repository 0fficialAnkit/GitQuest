import Foundation
import SwiftUI
import Observation

struct CommandResult {
    let success: Bool
    let message: String
}

struct TerminalLine: Identifiable {
    let id = UUID()
    let text: String
    let type: TerminalLineType
    let timestamp = Date()
}

enum TerminalLineType {
    case command
    case success
    case error
    case info
    case instruction
    case system

    var color: Color {
        switch self {
        case .command: return .blue
        case .success: return .green
        case .error: return .red
        case .info: return .cyan
        case .instruction: return .yellow
        case .system: return .gray
        }
    }

    var icon: String? {
        switch self {
        case .command: return "chevron.right"
        case .success: return "checkmark.circle.fill"
        case .error: return "xmark.circle.fill"
        case .instruction: return "lightbulb.fill"
        default: return nil
        }
    }
}

@Observable
@MainActor
class GameViewModel {
    var gameState: GameState = GameState()
    var currentStep: Int = 0
    var terminalOutput: [TerminalLine] = []
    var commandInput: String = ""
    var showSuccess: Bool = false
    var showError: Bool = false
    var errorMessage: String = ""
    var chatMessages: [ChatMessage] = []
    var lastSuccessfulCommand: String = ""
    var currentPlayingLevel: Level?

    func startLevel(_ level: Level) {
        currentPlayingLevel = level
        currentStep = 0
        terminalOutput = []
        chatMessages = level.initialChat.enumerated().map { index, msg in
            ChatMessage(sender: msg.sender, text: msg.text, timestamp: Date().addingTimeInterval(Double(index)))
        }
        addTerminalOutput("", type: .system)
        addTerminalOutput("→ \(level.title)", type: .info)
        addTerminalOutput("", type: .system)
        if level.requiredSteps.first != nil {
            addTerminalOutput("Ready? Tap a command below to begin.", type: .instruction)
        }
    }

    func executeCommand() {
        let command = commandInput.trimmingCharacters(in: .whitespaces)
        guard !command.isEmpty else { return }
        addTerminalOutput("$ \(command)", type: .command)
        commandInput = ""
        let result = processCommand(command)
        addTerminalOutput(result.message, type: result.success ? .success : .error)
        if result.success {
            checkStepCompletion(command)
        } else {
            showErrorFeedback(result.message)
        }
    }

    func getSuggestedCommands() -> [String] {
        guard let level = currentPlayingLevel else { return [] }
        guard currentStep < level.requiredSteps.count else { return [] }
        switch level.id {
        case 1:
            if currentStep == 0 { return ["git init"] }
            if currentStep == 1 { return ["git add README.md", "git add ."] }
            return ["git commit -m \"Initial commit\""]
        case 2:
            if currentStep == 0 { return ["git checkout -b feature/dark-mode"] }
            return ["git commit -m \"Add dark mode\""]
        case 3:
            if currentStep == 0 { return ["git remote add origin https://github.com/pixel-labs/user-profiles.git"] }
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
        default:
            return []
        }
    }

    private func processCommand(_ command: String) -> CommandResult {
        guard let level = currentPlayingLevel else {
            return CommandResult(success: false, message: "No level is active")
        }
        guard currentStep < level.requiredSteps.count else {
            return CommandResult(success: false, message: "Level already completed!")
        }
        let step = level.requiredSteps[currentStep]
        if command.lowercased().contains(step.expectedCommand.lowercased()) {
            return processCorrectCommand(command, step: step, level: level)
        }
        return CommandResult(success: false, message: "Hmm, that's not quite right. \(step.hint)")
    }

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
                To https://github.com/pixel-labs/user-profiles.git
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
                  (use "git add <file>...\" to mark resolution)
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
        default:
            break
        }
        return CommandResult(success: true, message: "Command executed successfully")
    }

    private func checkStepCompletion(_ command: String) {
        guard let level = currentPlayingLevel else { return }
        guard currentStep < level.requiredSteps.count else { return }
        lastSuccessfulCommand = command
        let step = level.requiredSteps[currentStep]
        addTerminalOutput("", type: .system)
        addTerminalOutput("✓ " + step.successMessage, type: .success)
        addTerminalOutput("", type: .system)
        let completedStepIndex = currentStep
        currentStep += 1
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
        if currentStep >= level.requiredSteps.count {
            completeLevel()
        } else {
            let nextStep = level.requiredSteps[currentStep]
            addTerminalOutput("Next: \(nextStep.expectedCommand)", type: .instruction)
        }
    }

    private func completeLevel() {
        guard let level = currentPlayingLevel else { return }
        gameState.completeLevel(level.id)
        addTerminalOutput("", type: .system)
        addTerminalOutput("🎉 Level Complete!", type: .success)
        Task { @MainActor in
            try? await Task.sleep(for: .seconds(0.3))
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                self.showSuccess = true
            }
        }
    }

    private func addTerminalOutput(_ text: String, type: TerminalLineType) {
        terminalOutput.append(TerminalLine(text: text, type: type))
    }

    private func showErrorFeedback(_ message: String) {
        errorMessage = message
        withAnimation { showError = true }
        Task { @MainActor in
            try? await Task.sleep(for: .seconds(2.5))
            withAnimation { self.showError = false }
        }
    }

    private func extractBranchName(from command: String) -> String {
        let parts = command.split(separator: " ").map(String.init)
        if let bIndex = parts.firstIndex(of: "-b"), bIndex + 1 < parts.count {
            return parts[bIndex + 1]
        }
        return parts.last ?? "branch"
    }
}
