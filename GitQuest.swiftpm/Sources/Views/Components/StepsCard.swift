//
//  StepsCard.swift
//  GitQuest
//
//  Step-by-step educational guide card for current level step
//

import SwiftUI

struct StepsCard: View {
    let currentStep: LevelStep?
    let stepNumber: Int
    let totalSteps: Int
    
    // Dark palette
    private let cardBg = Color(red: 0.12, green: 0.12, blue: 0.14)
    private let headerBg = Color(red: 0.10, green: 0.10, blue: 0.12)
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // ── HEADER ──
            stepsHeader
            
            // Content area
            VStack(alignment: .leading, spacing: 10) {
                if let step = currentStep {
                    // 1. WHAT TO DO
                    VStack(alignment: .leading, spacing: 4) {
                        headerLabel("WHAT TO DO", color: .white.opacity(0.4))
                        Text(extractTaskTitle(from: step.contextMessage))
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(.white)
                            .lineLimit(2)
                    }
                    
                    // 2. COMMAND TO USE
                    VStack(alignment: .leading, spacing: 6) {
                        headerLabel("COMMAND TO USE", icon: "terminal.fill", color: GitTheme.green)
                        commandBox(step.expectedCommand)
                    }
                    
                    // 3. WHY USE THIS?
                    VStack(alignment: .leading, spacing: 4) {
                        headerLabel("WHY USE THIS?", icon: "lightbulb.fill", color: GitTheme.yellow)
                        Text(whyExplanation(for: step.expectedCommand))
                            .font(.system(size: 10, weight: .medium))
                            .foregroundStyle(.white.opacity(0.7))
                            .lineLimit(2)
                    }
                    
                    // 4. EXPECTED OUTCOME
                    VStack(alignment: .leading, spacing: 4) {
                        headerLabel("EXPECTED OUTCOME", icon: "flag.fill", color: GitTheme.cyan)
                        Text(outcomeExplanation(for: step.expectedCommand))
                            .font(.system(size: 10, weight: .medium))
                            .foregroundStyle(.white.opacity(0.7))
                            .lineLimit(2)
                    }
                } else {
                    // Completion state
                    completionView
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            Spacer(minLength: 0)
        }
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(cardBg)
        )
    }
    
    // MARK: - Header
    
    private var stepsHeader: some View {
        HStack(spacing: 8) {
            Image(systemName: "list.bullet.clipboard.fill")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(GitTheme.blue)
            
            Text("Steps")
                .font(.system(size: 15, weight: .bold, design: .monospaced))
                .foregroundStyle(.white)
            
            Spacer()
            
            Text("STEP \(stepNumber) OF \(totalSteps)")
                .font(.system(size: 11, weight: .bold, design: .monospaced))
                .foregroundStyle(.white.opacity(0.5))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(headerBg)
    }
    
    // MARK: - Components
    
    private func headerLabel(_ text: String, icon: String? = nil, color: Color) -> some View {
        HStack(spacing: 4) {
            if let icon = icon {
                Image(systemName: icon)
                    .font(.system(size: 9))
                    .foregroundStyle(color)
            }
            Text(text)
                .font(.system(size: 9, weight: .bold))
                .foregroundStyle(color.opacity(0.8))
        }
    }
    
    private func commandBox(_ command: String) -> some View {
        Text(command)
            .font(.system(size: 10, weight: .semibold, design: .monospaced))
            .foregroundStyle(GitTheme.green)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color.black.opacity(0.3))
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(GitTheme.green.opacity(0.2), lineWidth: 1)
                    )
            )
    }
    
    private var completionView: some View {
        VStack(spacing: 8) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 30))
                .foregroundStyle(GitTheme.green)
            
            Text("All Steps Complete!")
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(.white)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
    }
    
    // MARK: - Helpers
    
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
            return "This creates the hidden .git folder that tracks your project's history. Essential for any Git work."
        } else if cmd.contains("git add") {
            return "This stages your changes, essentially telling Git which specific files you want to include in your next save."
        } else if cmd.contains("git commit") {
            return "This saves your staged changes as a permanent snapshot. It's like a save point in a game."
        } else if cmd.contains("git checkout -b") {
            return "This creates a new branch (parallel timeline) and switches you to it immediately."
        } else if cmd.contains("git checkout") {
            return "This lets you hop between different branches to work on different tasks separately."
        } else if cmd.contains("git remote") {
            return "This connects your local repository to a server URL so you can share code with others."
        } else if cmd.contains("git push") {
            return "This uploads your local snapshots to the server so your team can access them."
        } else if cmd.contains("git pull") {
            return "This downloads and integrates the latest changes from the server into your work."
        } else if cmd.contains("git merge") {
            return "This combines work from one branch into another, integrating your completed features."
        }
        return "This command updates your repository state and keeps your project history organized."
    }
    
    private func outcomeExplanation(for command: String) -> String {
        let cmd = command.lowercased()
        if cmd.contains("git init") {
            return "A new hidden .git directory is created, and your project becomes a Git repository."
        } else if cmd.contains("git add") {
            return "Files are moved to the 'Staging Area'. Git is now watching these specific changes."
        } else if cmd.contains("git commit") {
            return "A permanent snapshot is saved with a unique ID. Your progress is now part of the history."
        } else if cmd.contains("git checkout -b") {
            return "A new branch line appears in the visualizer, and you are moved onto it."
        } else if cmd.contains("git checkout") {
            return "The 'HEAD' marker moves to the target branch. Your files update to match."
        } else if cmd.contains("git remote") {
            return "Your local project is linked to a URL. You can now communicate with servers."
        } else if cmd.contains("git push") {
            return "Your local commits are uploaded. Your team can now see and download your work."
        } else if cmd.contains("git pull") {
            return "New work from the server is downloaded and merged into your local files."
        } else if cmd.contains("git merge") {
            return "Changes from the target branch are integrated into your current branch."
        }
        return "The repository state will update to reflect your command's successful execution."
    }
}
