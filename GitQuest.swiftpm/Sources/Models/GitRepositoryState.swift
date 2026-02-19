//
//  GitRepositoryState.swift
//  GitQuest
//
//  Stateful Git repository model that persists across levels
//

import Foundation
import SwiftUI
import Observation

// MARK: - Git Commit

/// A single snapshot in the repository's commit history.
///
/// Each commit has a short hash `id`, a descriptive `message`,
/// the `branch` it was created on, and an optional `parentId`
/// linking it to the previous commit.
struct GitCommit: Identifiable, Equatable {
    /// Short hex hash used as a unique identifier (e.g. `"a3f7bc2"`).
    let id: String
    
    /// Human-readable commit message.
    let message: String
    
    /// Name of the branch this commit belongs to.
    let branch: String
    
    /// Hash of the parent commit, or `nil` for the initial commit.
    let parentId: String?
    
    /// Creation time (used for display ordering).
    let timestamp: Date
    
    /// When `true` the visualiser highlights this commit with a glow ring.
    var isNew: Bool = false
    
    init(id: String = UUID().uuidString.prefix(7).lowercased(),
         message: String,
         branch: String,
         parentId: String? = nil) {
        self.id = String(id)
        self.message = message
        self.branch = branch
        self.parentId = parentId
        self.timestamp = Date()
        self.isNew = true
    }
}

// MARK: - Git Branch

/// Represents a named branch pointer in the repository.
struct GitBranch: Identifiable, Equatable {
    /// Branch name (also serves as the unique identifier).
    let id: String
    
    /// Hash of the commit this branch currently points to.
    var headCommitId: String?
    
    /// Visualiser colour assigned to this branch.
    let color: Color
    
    /// Whether this branch was just created (triggers entrance animation).
    var isNew: Bool = false
    
    /// Convenience alias for `id`.
    var name: String { id }
}

// MARK: - Git Action

/// Describes the most recent Git operation for UI feedback purposes.
struct GitAction {
    /// The raw command string (e.g. `"git commit -m \"Init\""`).
    let command: String
    
    /// A beginner-friendly explanation of what the command did.
    let explanation: String
    
    /// Semantic category of the action.
    let type: ActionType
    
    /// Categorises Git operations for icon / colour mapping.
    enum ActionType {
        case initialize
        case commit
        case branch
        case checkout
        case merge
        case push
        case pull
        case reset
        case add
        case status
    }
}

// MARK: - Git Repository State

/// Observable model representing the entire state of a simulated Git repository.
///
/// Properties drive the Visualiser, Repository Status card, and
/// Console views. The class is `@MainActor` because all mutations originate
/// from SwiftUI callbacks.
@Observable
@MainActor
class GitRepositoryState {
    
    // MARK: - State
    
    /// Whether `git init` has been run.
    var isInitialized: Bool = false
    
    /// Ordered list of all commits in the repository.
    var commits: [GitCommit] = []
    
    /// All branches that currently exist.
    var branches: [GitBranch] = []
    
    /// Name of the currently checked-out branch.
    var currentBranch: String = "main"
    
    /// Files that have been staged with `git add`.
    var stagedFiles: [String] = []
    
    /// Whether a remote has been configured.
    var hasRemote: Bool = false
    
    /// Name of the configured remote (defaults to `"origin"`).
    var remoteName: String = "origin"
    
    /// The most recent action for display in the UI.
    var lastAction: GitAction?
    
    // MARK: - Computed Properties
    
    /// The commit that `HEAD` currently points to on the active branch.
    var headCommit: GitCommit? {
        guard let branch = branches.first(where: { $0.id == currentBranch }),
              let headId = branch.headCommitId else { return nil }
        return commits.first(where: { $0.id == headId })
    }
    
    /// Groups all reachable commits by branch name.
    var commitsByBranch: [String: [GitCommit]] {
        var result: [String: [GitCommit]] = [:]
        for branch in branches {
            result[branch.id] = commitsForBranch(branch.id)
        }
        return result
    }
    
    // MARK: - Git Operations
    
    /// Simulates `git init` — creates the default `main` branch.
    func initialize() {
        guard !isInitialized else { return }
        
        isInitialized = true
        branches = [GitBranch(id: "main", headCommitId: nil, color: .purple)]
        currentBranch = "main"
        
        lastAction = GitAction(
            command: "git init",
            explanation: "Initialized a new Git repository. A hidden .git folder is created to track all your changes.",
            type: .initialize
        )
        
        clearNewFlags()
    }
    
    /// Simulates `git add` — stages the given files.
    func stageFiles(_ files: [String] = ["."]) {
        stagedFiles = files
        
        lastAction = GitAction(
            command: "git add \(files.joined(separator: " "))",
            explanation: "Staged files for commit. Think of this as putting items in a shopping cart before checkout.",
            type: .add
        )
    }
    
    /// Simulates `git commit` — creates a new commit on the current branch.
    func commit(message: String) {
        clearNewFlags()
        
        let parentId = headCommit?.id
        let newCommit = GitCommit(
            message: message,
            branch: currentBranch,
            parentId: parentId
        )
        
        commits.append(newCommit)
        
        // Update branch head
        if let index = branches.firstIndex(where: { $0.id == currentBranch }) {
            branches[index].headCommitId = newCommit.id
        }
        
        stagedFiles.removeAll()
        
        lastAction = GitAction(
            command: "git commit -m \"\(message)\"",
            explanation: "Created commit '\(newCommit.id)'. Your changes are now saved in Git's history.",
            type: .commit
        )
    }
    
    /// Simulates `git checkout -b` — creates a new branch and switches to it.
    func createBranch(name: String) {
        clearNewFlags()
        
        let color = colorForBranch(name)
        let newBranch = GitBranch(
            id: name,
            headCommitId: headCommit?.id,
            color: color,
            isNew: true
        )
        
        branches.append(newBranch)
        currentBranch = name
        
        lastAction = GitAction(
            command: "git checkout -b \(name)",
            explanation: "Created and switched to new branch '\(name)'. It points to the same commit as before.",
            type: .branch
        )
    }
    
    /// Simulates `git checkout` — switches to an existing branch.
    func checkout(branch: String) {
        clearNewFlags()
        
        guard branches.contains(where: { $0.id == branch }) else { return }
        currentBranch = branch
        
        lastAction = GitAction(
            command: "git checkout \(branch)",
            explanation: "Switched to branch '\(branch)'. Your working directory now reflects this branch.",
            type: .checkout
        )
    }
    
    /// Simulates `git merge` — creates a merge commit on the current branch.
    func merge(branch: String) {
        clearNewFlags()
        
        guard let sourceBranch = branches.first(where: { $0.id == branch }),
              let _ = sourceBranch.headCommitId else { return }
        
        // Create merge commit
        let mergeCommit = GitCommit(
            message: "Merge branch '\(branch)' into \(currentBranch)",
            branch: currentBranch,
            parentId: headCommit?.id
        )
        
        commits.append(mergeCommit)
        
        if let index = branches.firstIndex(where: { $0.id == currentBranch }) {
            branches[index].headCommitId = mergeCommit.id
        }
        
        lastAction = GitAction(
            command: "git merge \(branch)",
            explanation: "Merged '\(branch)' into '\(currentBranch)'. Both branches' changes are now combined.",
            type: .merge
        )
    }
    
    /// Simulates `git remote add` — registers a remote repository.
    func addRemote(name: String, url: String) {
        hasRemote = true
        remoteName = name
        
        lastAction = GitAction(
            command: "git remote add \(name) \(url)",
            explanation: "Connected to remote '\(name)'. Your local repo now knows about the GitHub repository.",
            type: .push
        )
    }
    
    /// Simulates `git push` — uploads the current branch to the remote.
    func push() {
        lastAction = GitAction(
            command: "git push -u \(remoteName) \(currentBranch)",
            explanation: "Pushed '\(currentBranch)' to remote. Your commits are now on GitHub for others to see.",
            type: .push
        )
    }
    
    /// Simulates `git pull` — downloads and applies a remote commit.
    func pull() {
        clearNewFlags()
        
        // Simulate receiving a commit
        let pullCommit = GitCommit(
            message: "Remote changes",
            branch: currentBranch,
            parentId: headCommit?.id
        )
        
        commits.append(pullCommit)
        
        if let index = branches.firstIndex(where: { $0.id == currentBranch }) {
            branches[index].headCommitId = pullCommit.id
        }
        
        lastAction = GitAction(
            command: "git pull \(remoteName) \(currentBranch)",
            explanation: "Pulled latest changes from remote. Your local branch is now up to date.",
            type: .pull
        )
    }
    
    /// Simulates `git reset HEAD~1` — removes the last commit.
    func resetHead() {
        clearNewFlags()
        
        guard commits.count > 1 else { return }
        
        commits.removeLast()
        
        if let index = branches.firstIndex(where: { $0.id == currentBranch }) {
            branches[index].headCommitId = commits.last?.id
        }
        
        lastAction = GitAction(
            command: "git reset HEAD~1",
            explanation: "Undid the last commit. Your changes are still in files but not committed.",
            type: .reset
        )
    }
    
    /// Simulates `git status` — reports the current branch and staged files.
    func status() {
        let staged = stagedFiles.isEmpty ? "nothing staged" : stagedFiles.joined(separator: ", ")
        
        lastAction = GitAction(
            command: "git status",
            explanation: "On branch '\(currentBranch)'. Staged: \(staged).",
            type: .status
        )
    }
    
    // MARK: - Reset
    
    /// Wipes all repository state back to a blank slate (used on level restart).
    func resetAll() {
        isInitialized = false
        commits.removeAll()
        branches.removeAll()
        currentBranch = "main"
        stagedFiles.removeAll()
        hasRemote = false
        lastAction = nil
    }
    
    // MARK: - Private Helpers
    
    /// Clears the `isNew` highlight flag on all commits and branches.
    private func clearNewFlags() {
        for i in commits.indices {
            commits[i].isNew = false
        }
        for i in branches.indices {
            branches[i].isNew = false
        }
    }
    
    /// Walks the parent chain from a branch's HEAD to collect its commit history.
    private func commitsForBranch(_ branchName: String) -> [GitCommit] {
        guard let branch = branches.first(where: { $0.id == branchName }),
              let headId = branch.headCommitId else { return [] }
        
        var result: [GitCommit] = []
        var currentId: String? = headId
        
        while let id = currentId, let commit = commits.first(where: { $0.id == id }) {
            result.insert(commit, at: 0)
            currentId = commit.parentId
        }
        
        return result
    }
    
    /// Deterministically maps a branch name to a colour via hashing.
    private func colorForBranch(_ name: String) -> Color {
        let colors: [Color] = [.green, .blue, .orange, .pink, .cyan, .mint, .indigo]
        let hash = abs(name.hashValue)
        return colors[hash % colors.count]
    }
}
