////
////  GameViewModel.swift
////  GitQuest
////
////  Created by Ankit Kumar on 04/02/26.
////
//
//import Foundation
//import SwiftUI
//import Observation
//
//// MARK: - Game View Model
//
///// Drives the gameplay loop for a single level.
/////
///// Responsibilities:
///// - Processes player commands against the expected step sequence
///// - Manages terminal output lines and chat messages
///// - Triggers success / error feedback
///// - Provides suggested commands for the hint bar
//@Observable
//@MainActor
//class GameViewModel {
//    
//    // MARK: - Dependencies
//    var gameState: GameState = GameState()
//    
//    // MARK: - Gameplay State
//    var currentStep: Int = 0
//    var terminalOutput: [TerminalLine] = []
//    var commandInput: String = ""
//    var showSuccess: Bool = false
//    var showError: Bool = false
//    var errorMessage: String = ""
//    var chatMessages: [ChatMessage] = []
//    var lastSuccessfulCommand: String = ""
//    
//    var currentPlayingLevel: Level?
//    
//    // MARK: - Level Setup
//    
//    /// Configures the view model to play the given level.
//    func startLevel(_ level: Level) {
//        currentPlayingLevel = level
//        currentStep = 0
//        terminalOutput = []
//        chatMessages = level.initialChat
//        
//        // Welcome message
//        addTerminalOutput("", type: .system)
//        addTerminalOutput("→ \(level.title)", type: .info)
//        addTerminalOutput("", type: .system)
//        
//        if level.requiredSteps.first != nil {
//            addTerminalOutput("Ready? Tap a command below to begin.", type: .instruction)
//        }
//    }
//    
//    // MARK: - Command Processing
//    
//    /// Executes the current `commandInput`, validates it, and advances the step.
//    func executeCommand() {
//        let command = commandInput.trimmingCharacters(in: .whitespaces)
//        guard !command.isEmpty else { return }
//        
//        addTerminalOutput("$ \(command)", type: .command)
//        commandInput = ""
//        
//        let result = processCommand(command)
//        addTerminalOutput(result.message, type: result.success ? .success : .error)
//        
//        if result.success {
//            checkStepCompletion(command)
//        } else {
//            showErrorFeedback(result.message)
//        }
//    }
//    
//    /// Validates `command` against the current step's expected input.
//    private func processCommand(_ command: String) -> CommandResult {
//        guard let level = currentPlayingLevel else {
//            return CommandResult(success: false, message: "No level is active")
//        }
//        
//        guard currentStep < level.requiredSteps.count else {
//            return CommandResult(success: false, message: "Level already completed!")
//        }
//        
//        let step = level.requiredSteps[currentStep]
//        
//        // Check if command matches expected command
//        if command.lowercased().contains(step.expectedCommand.lowercased()) {
//            return processCorrectCommand(command, step: step, level: level)
//        } else {
//            return CommandResult(
//                success: false,
//                message: "Hmm, that's not quite right. \(step.hint)"
//            )
//        }
//    }
//    
//    /// Generates the appropriate terminal-output message for a correct command.
//    private func processCorrectCommand(_ command: String, step: LevelStep, level: Level) -> CommandResult {
//        // Level-specific command handling
//        switch level.id {
//        case 1: // First commit
//            if command.contains("init") {
//                return CommandResult(success: true, message: "Initialized empty Git repository in .git/")
//            } else if command.contains("add") {
//                return CommandResult(success: true, message: "Changes staged for commit")
//            } else if command.contains("commit") {
//                let hash = String(format: "%07x", Int.random(in: 0...0xFFFFFFF))
//                return CommandResult(success: true, message: "[main \(hash)] Initial commit: Add README")
//            }
//            
//        case 2: // Feature branches
//            if command.contains("checkout") {
//                let branchName = extractBranchName(from: command)
//                return CommandResult(success: true, message: "Switched to a new branch '\(branchName)'")
//            } else if command.contains("commit") {
//                let hash = String(format: "%07x", Int.random(in: 0...0xFFFFFFF))
//                return CommandResult(success: true, message: "[feature/dark-mode \(hash)] Add dark mode toggle")
//            }
//            
//        case 3: // Push to GitHub
//            if command.contains("remote") {
//                return CommandResult(success: true, message: "Remote 'origin' added")
//            } else if command.contains("push") {
//                return CommandResult(
//                    success: true,
//                    message: """
//                    Enumerating objects: 5, done.
//                    Counting objects: 100% (5/5), done.
//                    Writing objects: 100% (3/3), 284 bytes | 284.00 KiB/s, done.
//                    Total 3 (delta 0), reused 0 (delta 0)
//                    To https://github.com/pixel-labs/user-profiles.git
//                     * [new branch]      feature/dark-mode -> feature/dark-mode
//                    """
//                )
//            }
//            
//        case 4: // Merge conflict
//            if command.contains("status") {
//                return CommandResult(
//                    success: true,
//                    message: """
//                    On branch main
//                    You have unmerged paths.
//                      (fix conflicts and run "git commit")
//                    
//                    Unmerged paths:
//                      (use "git add <file>...\" to mark resolution)
//                        both modified:   dashboard.js
//                    
//                    no changes added to commit
//                    """
//                )
//            } else if command.contains("add") {
//                return CommandResult(success: true, message: "Conflict in dashboard.js marked as resolved")
//            } else if command.contains("commit") {
//                return CommandResult(
//                    success: true,
//                    message: "[main a7f3c21] Resolve dashboard color conflict — use purple"
//                )
//            }
//            
//        case 5: // Pull
//            if command.contains("pull") {
//                return CommandResult(
//                    success: true,
//                    message: """
//                    remote: Enumerating objects: 5, done.
//                    remote: Counting objects: 100% (5/5), done.
//                    Updating a1b2c3d..e4f5g6h
//                    Fast-forward
//                     refactor.js | 42 +++++++++++++++++++++++++++++++++
//                     1 file changed, 42 insertions(+)
//                    """
//                )
//            }
//            
//        case 6: // Reset
//            if command.contains("reset") {
//                return CommandResult(
//                    success: true,
//                    message: "HEAD is now at a1b2c3d Previous commit"
//                )
//            }
//            
//        case 7: // Merge
//            if command.contains("checkout") {
//                return CommandResult(success: true, message: "Switched to branch 'main'")
//            } else if command.contains("merge") {
//                return CommandResult(
//                    success: true,
//                    message: """
//                    Updating a1b2c3d..e4f5g6h
//                    Fast-forward
//                     settings.js | 15 +++++++++++++++
//                     1 file changed, 15 insertions(+)
//                    """
//                )
//            }
//            
//        default:
//            return CommandResult(success: true, message: "Command executed successfully")
//        }
//        
//        return CommandResult(success: true, message: "Command executed successfully")
//    }
//    
//    /// Advances `currentStep` and triggers chat / completion side-effects.
//    private func checkStepCompletion(_ command: String) {
//        guard let level = currentPlayingLevel else { return }
//        guard currentStep < level.requiredSteps.count else { return }
//        
//        // Track successful command for visualizer updates
//        lastSuccessfulCommand = command
//        
//        let step = level.requiredSteps[currentStep]
//        
//        // Success message
//        addTerminalOutput("", type: .system)
//        addTerminalOutput("✓ " + step.successMessage, type: .success)
//        addTerminalOutput("", type: .system)
//        
//        let completedStepIndex = currentStep
//        currentStep += 1
//        
//        // Append step-specific chat messages
//        if let stepMessages = level.stepChats[completedStepIndex] {
//            for (index, message) in stepMessages.enumerated() {
//                let delay = Double(index) * 0.5
//                Task { @MainActor in
//                    try? await Task.sleep(for: .seconds(delay))
//                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
//                        self.chatMessages.append(message)
//                    }
//                }
//            }
//        }
//        
//        if currentStep >= level.requiredSteps.count {
//            completeLevel()
//        } else {
//            // Next step instruction
//            let nextStep = level.requiredSteps[currentStep]
//            addTerminalOutput("Next: \(nextStep.expectedCommand)", type: .instruction)
//        }
//    }
//    
//    /// Finalises the level: persists progress, shows success overlay.
//    private func completeLevel() {
//        guard let level = currentPlayingLevel else { return }
//        
//        gameState.completeLevel(level.id)
//        
//        addTerminalOutput("", type: .system)
//        addTerminalOutput("🎉 Level Complete!", type: .success)
//        
//        // Show success overlay after short delay
//        Task { @MainActor in
//            try? await Task.sleep(for: .seconds(0.3))
//            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
//                self.showSuccess = true
//            }
//        }
//    }
//    
//    // MARK: - Terminal Management
//    
//    /// Appends a styled line to the terminal output.
//    private func addTerminalOutput(_ text: String, type: TerminalLineType) {
//        terminalOutput.append(TerminalLine(text: text, type: type))
//    }
//    
//    /// Shows and auto-hides the error banner after 2.5 seconds.
//    private func showErrorFeedback(_ message: String) {
//        errorMessage = message
//        withAnimation {
//            showError = true
//        }
//        
//        Task { @MainActor in
//            try? await Task.sleep(for: .seconds(2.5))
//            withAnimation {
//                self.showError = false
//            }
//        }
//    }
//    
//    // MARK: - Helper Methods
//    
//    /// Extracts the last whitespace-separated token as a branch name.
//    private func extractBranchName(from command: String) -> String {
//        let parts = command.split(separator: " ").map(String.init)
//        return parts.last ?? "branch"
//    }
//    
//    // MARK: - Suggested Commands
//    
//    /// Returns the hint commands for the current step of the active level.
//    func getSuggestedCommands() -> [String] {
//        guard let level = currentPlayingLevel else { return [] }
//        guard currentStep < level.requiredSteps.count else { return [] }
//        
//        switch level.id {
//        case 1: // First commit
//            if currentStep == 0 {
//                return ["git init"]
//            } else if currentStep == 1 {
//                return ["git add README.md", "git add ."]
//            } else {
//                return ["git commit -m \"Initial commit: Add README\""]
//            }
//            
//        case 2: // Feature branches
//            if currentStep == 0 {
//                return ["git checkout -b feature/dark-mode"]
//            } else {
//                return ["git commit -m \"Add dark mode toggle to settings\""]
//            }
//            
//        case 3: // Push to GitHub
//            if currentStep == 0 {
//                return ["git remote add origin https://github.com/pixel-labs/user-profiles.git"]
//            } else {
//                return ["git push -u origin feature/dark-mode"]
//            }
//            
//        case 4: // Merge conflict
//            if currentStep == 0 {
//                return ["git status"]
//            } else if currentStep == 1 {
//                return ["git add dashboard.js"]
//            } else {
//                return ["git commit -m \"Resolve dashboard color conflict\""]
//            }
//            
//        case 5: // Pull
//            return ["git pull origin main"]
//            
//        case 6: // Reset
//            return ["git reset HEAD~1", "git reset --soft HEAD~1"]
//            
//        case 7: // Merge
//            if currentStep == 0 {
//                return ["git checkout main"]
//            } else {
//                return ["git merge feature/dark-mode"]
//            }
//            
//        default:
//            return []
//        }
//    }
//}
//
//// MARK: - Supporting Types
//
///// Result of validating a player command.
//struct CommandResult {
//    /// `true` when the command matched the expected step.
//    let success: Bool
//    
//    /// Terminal output message.
//    let message: String
//}
//
///// A single line rendered in the terminal output panel.
//struct TerminalLine: Identifiable {
//    let id = UUID()
//    
//    /// Text content of the line.
//    let text: String
//    
//    /// Semantic type (drives colour and icon).
//    let type: TerminalLineType
//    
//    /// When the line was created (for potential timestamping).
//    let timestamp = Date()
//}
//
///// Semantic categories for terminal output, each with a colour and optional icon.
//enum TerminalLineType {
//    case command
//    case success
//    case error
//    case info
//    case instruction
//    case system
//    
//    /// Colour used when rendering this line type.
//    var color: Color {
//        switch self {
//        case .command: return .blue
//        case .success: return .green
//        case .error: return .red
//        case .info: return .cyan
//        case .instruction: return .yellow
//        case .system: return .gray
//        }
//    }
//    
//    /// Optional SF Symbol shown before the line text.
//    var icon: String? {
//        switch self {
//        case .command: return "chevron.right"
//        case .success: return "checkmark.circle.fill"
//        case .error: return "xmark.circle.fill"
//        case .instruction: return "lightbulb.fill"
//        default: return nil
//        }
//    }
//}





//
//  GameViewModel.swift
//  GitQuest
//
//  Created by Ankit Kumar on 04/02/26.
//

import Foundation
import SwiftUI
import Observation

// MARK: - Game View Model

/// Drives the gameplay loop for a single level.
///
/// Responsibilities:
/// - Processes player commands against the expected step sequence
/// - Manages terminal output lines and chat messages
/// - Triggers success / error feedback
/// - Provides suggested commands for the hint bar
@Observable
@MainActor
class GameViewModel {
    
    // MARK: - Dependencies
    var gameState: GameState = GameState()
    
    // MARK: - Gameplay State
    var currentStep: Int = 0
    var terminalOutput: [TerminalLine] = []
    var commandInput: String = ""
    var showSuccess: Bool = false
    var showError: Bool = false
    var errorMessage: String = ""
    var chatMessages: [ChatMessage] = []
    var lastSuccessfulCommand: String = ""
    
    var currentPlayingLevel: Level?
    
    // MARK: - Level Setup
    
    /// Configures the view model to play the given level.
    func startLevel(_ level: Level) {
        currentPlayingLevel = level
        currentStep = 0
        terminalOutput = []
        chatMessages = level.initialChat
        
        // Welcome message
        addTerminalOutput("", type: .system)
        addTerminalOutput("→ \(level.title)", type: .info)
        addTerminalOutput("", type: .system)
        
        if level.requiredSteps.first != nil {
            addTerminalOutput("Ready? Tap a command below to begin.", type: .instruction)
        }
    }
    
    // MARK: - Command Processing
    
    /// Executes the current `commandInput`, validates it, and advances the step.
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
    
    /// Validates `command` against the current step's expected input.
    private func processCommand(_ command: String) -> CommandResult {
        guard let level = currentPlayingLevel else {
            return CommandResult(success: false, message: "No level is active")
        }
        
        guard currentStep < level.requiredSteps.count else {
            return CommandResult(success: false, message: "Level already completed!")
        }
        
        let step = level.requiredSteps[currentStep]
        
        // Check if command matches expected command
        if command.lowercased().contains(step.expectedCommand.lowercased()) {
            return processCorrectCommand(command, step: step, level: level)
        } else {
            return CommandResult(
                success: false,
                message: "Hmm, that's not quite right. \(step.hint)"
            )
        }
    }
    
    /// Generates the appropriate terminal-output message for a correct command.
    private func processCorrectCommand(_ command: String, step: LevelStep, level: Level) -> CommandResult {
        // Level-specific command handling
        switch level.id {
        case 1: // First commit
            if command.contains("init") {
                return CommandResult(success: true, message: "Initialized empty Git repository in .git/")
            } else if command.contains("add") {
                return CommandResult(success: true, message: "Changes staged for commit")
            } else if command.contains("commit") {
                let hash = String(format: "%07x", Int.random(in: 0...0xFFFFFFF))
                return CommandResult(success: true, message: "[main \(hash)] Initial commit")
            }
            
        case 2: // Feature branches
            if command.contains("checkout") {
                let branchName = extractBranchName(from: command)
                return CommandResult(success: true, message: "Switched to a new branch '\(branchName)'")
            } else if command.contains("commit") {
                let hash = String(format: "%07x", Int.random(in: 0...0xFFFFFFF))
                return CommandResult(success: true, message: "[feature/dark-mode \(hash)] Add dark mode")
            }
            
        case 3: // Push to GitHub
            if command.contains("remote") {
                return CommandResult(success: true, message: "Remote 'origin' added")
            } else if command.contains("push") {
                return CommandResult(
                    success: true,
                    message: """
                    Enumerating objects: 5, done.
                    Counting objects: 100% (5/5), done.
                    Writing objects: 100% (3/3), 284 bytes | 284.00 KiB/s, done.
                    Total 3 (delta 0), reused 0 (delta 0)
                    To https://github.com/pixel-labs/user-profiles.git
                     * [new branch]      feature/dark-mode -> feature/dark-mode
                    """
                )
            }
            
        case 4: // Merge conflict
            if command.contains("status") {
                return CommandResult(
                    success: true,
                    message: """
                    On branch main
                    You have unmerged paths.
                      (fix conflicts and run "git commit")
                    
                    Unmerged paths:
                      (use "git add <file>...\" to mark resolution)
                        both modified:   dashboard.js
                    
                    no changes added to commit
                    """
                )
            } else if command.contains("add") {
                return CommandResult(success: true, message: "Conflict in dashboard.js marked as resolved")
            } else if command.contains("commit") {
                return CommandResult(
                    success: true,
                    message: "[main a7f3c21] Resolve dashboard color conflict — use purple"
                )
            }
            
        case 5: // Pull
            if command.contains("pull") {
                return CommandResult(
                    success: true,
                    message: """
                    remote: Enumerating objects: 5, done.
                    remote: Counting objects: 100% (5/5), done.
                    Updating a1b2c3d..e4f5g6h
                    Fast-forward
                     refactor.js | 42 +++++++++++++++++++++++++++++++++
                     1 file changed, 42 insertions(+)
                    """
                )
            }
            
        case 6: // Reset
            if command.contains("reset") {
                return CommandResult(
                    success: true,
                    message: "HEAD is now at a1b2c3d Previous commit"
                )
            }
            
        case 7: // Merge
            if command.contains("checkout") {
                return CommandResult(success: true, message: "Switched to branch 'main'")
            } else if command.contains("merge") {
                return CommandResult(
                    success: true,
                    message: """
                    Updating a1b2c3d..e4f5g6h
                    Fast-forward
                     settings.js | 15 +++++++++++++++
                     1 file changed, 15 insertions(+)
                    """
                )
            }
            
        default:
            return CommandResult(success: true, message: "Command executed successfully")
        }
        
        return CommandResult(success: true, message: "Command executed successfully")
    }
    
    /// Advances `currentStep` and triggers chat / completion side-effects.
    private func checkStepCompletion(_ command: String) {
        guard let level = currentPlayingLevel else { return }
        guard currentStep < level.requiredSteps.count else { return }
        
        // Track successful command for visualizer updates
        lastSuccessfulCommand = command
        
        let step = level.requiredSteps[currentStep]
        
        // Success message
        addTerminalOutput("", type: .system)
        addTerminalOutput("✓ " + step.successMessage, type: .success)
        addTerminalOutput("", type: .system)
        
        let completedStepIndex = currentStep
        currentStep += 1
        
        // Append step-specific chat messages
        if let stepMessages = level.stepChats[completedStepIndex] {
            for (index, message) in stepMessages.enumerated() {
                let delay = Double(index) * 0.5
                Task { @MainActor in
                    try? await Task.sleep(for: .seconds(delay))
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        self.chatMessages.append(message)
                    }
                }
            }
        }
        
        if currentStep >= level.requiredSteps.count {
            completeLevel()
        } else {
            // Next step instruction
            let nextStep = level.requiredSteps[currentStep]
            addTerminalOutput("Next: \(nextStep.expectedCommand)", type: .instruction)
        }
    }
    
    /// Finalises the level: persists progress, shows success overlay.
    private func completeLevel() {
        guard let level = currentPlayingLevel else { return }
        
        gameState.completeLevel(level.id)
        
        addTerminalOutput("", type: .system)
        addTerminalOutput("🎉 Level Complete!", type: .success)
        
        // Show success overlay after short delay
        Task { @MainActor in
            try? await Task.sleep(for: .seconds(0.3))
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                self.showSuccess = true
            }
        }
    }
    
    // MARK: - Terminal Management
    
    /// Appends a styled line to the terminal output.
    private func addTerminalOutput(_ text: String, type: TerminalLineType) {
        terminalOutput.append(TerminalLine(text: text, type: type))
    }
    
    /// Shows and auto-hides the error banner after 2.5 seconds.
    private func showErrorFeedback(_ message: String) {
        errorMessage = message
        withAnimation {
            showError = true
        }
        
        Task { @MainActor in
            try? await Task.sleep(for: .seconds(2.5))
            withAnimation {
                self.showError = false
            }
        }
    }
    
    // MARK: - Helper Methods
    
    /// Extracts the last whitespace-separated token as a branch name.
    private func extractBranchName(from command: String) -> String {
        let parts = command.split(separator: " ").map(String.init)
        return parts.last ?? "branch"
    }
    
    // MARK: - Suggested Commands
    
    /// Returns the hint commands for the current step of the active level.
    func getSuggestedCommands() -> [String] {
        guard let level = currentPlayingLevel else { return [] }
        guard currentStep < level.requiredSteps.count else { return [] }
        
        switch level.id {
        case 1: // First commit
            if currentStep == 0 {
                return ["git init"]
            } else if currentStep == 1 {
                return ["git add README.md", "git add ."]
            } else {
                return ["git commit -m \"Initial commit\""]
            }
            
        case 2: // Feature branches
            if currentStep == 0 {
                return ["git checkout -b feature/dark-mode"]
            } else {
                return ["git commit -m \"Add dark mode\""]
            }
            
        case 3: // Push to GitHub
            if currentStep == 0 {
                return ["git remote add origin https://github.com/pixel-labs/user-profiles.git"]
            } else {
                return ["git push -u origin feature/dark-mode"]
            }
            
        case 4: // Merge conflict
            if currentStep == 0 {
                return ["git status"]
            } else if currentStep == 1 {
                return ["git add dashboard.js"]
            } else {
                return ["git commit -m \"Resolve conflict\""]
            }
            
        case 5: // Pull
            return ["git pull origin main"]
            
        case 6: // Reset
            return ["git reset HEAD~1", "git reset --soft HEAD~1"]
            
        case 7: // Merge
            if currentStep == 0 {
                return ["git checkout main"]
            } else {
                return ["git merge feature/dark-mode"]
            }
            
        default:
            return []
        }
    }
}

// MARK: - Supporting Types

/// Result of validating a player command.
struct CommandResult {
    /// `true` when the command matched the expected step.
    let success: Bool
    
    /// Terminal output message.
    let message: String
}

/// A single line rendered in the terminal output panel.
struct TerminalLine: Identifiable {
    let id = UUID()
    
    /// Text content of the line.
    let text: String
    
    /// Semantic type (drives colour and icon).
    let type: TerminalLineType
    
    /// When the line was created (for potential timestamping).
    let timestamp = Date()
}

/// Semantic categories for terminal output, each with a colour and optional icon.
enum TerminalLineType {
    case command
    case success
    case error
    case info
    case instruction
    case system
    
    /// Colour used when rendering this line type.
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
    
    /// Optional SF Symbol shown before the line text.
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
