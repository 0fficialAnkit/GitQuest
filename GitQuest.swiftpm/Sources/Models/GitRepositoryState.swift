import Foundation
import SwiftUI
import Observation

// MARK: - Core Data Models

/// Represents a single commit in the repository's history.
struct GitCommit: Identifiable, Equatable {
    let id: String
    let message: String
    let branch: String
    let parentId: String?
    let timestamp: Date
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

/// Represents a branch pointing to a specific commit.
struct GitBranch: Identifiable, Equatable {
    let id: String
    var headCommitId: String?
    let color: Color
    var isNew: Bool = false
    var name: String { id }
}

/// Represents an action taking place on the repository for educational breakdown.
struct GitAction {
    let command: String
    let explanation: String
    let type: ActionType

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

/// A snapshot capturing the exact repository state for undo/redo or level resets.
struct GitRepositorySnapshot {
    var isInitialized: Bool
    var commits: [GitCommit]
    var branches: [GitBranch]
    var currentBranch: String
    var stagedFiles: [String]
    var hasRemote: Bool
    var remoteName: String
}

// MARK: - Repository State Manager

/// Manages the in-memory state of the simulated Git repository.
@Observable
@MainActor
class GitRepositoryState {

    // MARK: - Published Properties

    var isInitialized: Bool = false
    var commits: [GitCommit] = []
    var branches: [GitBranch] = []
    
    /// The name of the branch currently checked out.
    var currentBranch: String = "main"
    
    /// Files currently added to the staging area.
    var stagedFiles: [String] = []
    
    var hasRemote: Bool = false
    var remoteName: String = "origin"
    
    /// The last action performed, used for visual feedback.
    var lastAction: GitAction?
    
    /// Stores states for levels to allow resetting to specific milestones.
    private var levelSnapshots: [Int: GitRepositorySnapshot] = [:]

    // MARK: - Computed Properties

    /// Retrieves the commit currently pointed to by HEAD (current branch).
    var headCommit: GitCommit? {
        guard let branch = branches.first(where: { $0.id == currentBranch }),
              let headId = branch.headCommitId else { return nil }
        return commits.first(where: { $0.id == headId })
    }

    /// Maps branch names to their entire linear commit history.
    var commitsByBranch: [String: [GitCommit]] {
        var result: [String: [GitCommit]] = [:]
        for branch in branches {
            result[branch.id] = commitsForBranch(branch.id)
        }
        return result
    }

    // MARK: - Snapshot Management

    /// Generates a snapshot of the current state.
    func makeSnapshot() -> GitRepositorySnapshot {
        GitRepositorySnapshot(
            isInitialized: isInitialized,
            commits: commits,
            branches: branches,
            currentBranch: currentBranch,
            stagedFiles: stagedFiles,
            hasRemote: hasRemote,
            remoteName: remoteName
        )
    }

    /// Overwrites state with a previously saved snapshot.
    func restore(from snapshot: GitRepositorySnapshot) {
        isInitialized = snapshot.isInitialized
        commits = snapshot.commits
        branches = snapshot.branches
        currentBranch = snapshot.currentBranch
        stagedFiles = snapshot.stagedFiles
        hasRemote = snapshot.hasRemote
        remoteName = snapshot.remoteName
        lastAction = nil
    }

    func saveSnapshot(forLevel levelId: Int) {
        levelSnapshots[levelId] = makeSnapshot()
    }

    func snapshot(forLevel levelId: Int) -> GitRepositorySnapshot? {
        levelSnapshots[levelId]
    }

    func hasSnapshot(forLevel levelId: Int) -> Bool {
        levelSnapshots[levelId] != nil
    }

    // MARK: - Simulated Git Operations

    /// Simulates `git init`.
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

    /// Simulates `git add`.
    func stageFiles(_ files: [String] = ["."]) {
        stagedFiles = files
        lastAction = GitAction(
            command: "git add \(files.joined(separator: " "))",
            explanation: "Staged files for commit. Think of this as putting items in a shopping cart before checkout.",
            type: .add
        )
    }

    /// Simulates `git commit -m`.
    func commit(message: String) {
        clearNewFlags()
        let parentId = headCommit?.id
        let newCommit = GitCommit(message: message, branch: currentBranch, parentId: parentId)
        commits.append(newCommit)
        
        // Update the current branch pointer
        if let index = branches.firstIndex(where: { $0.id == currentBranch }) {
            branches[index].headCommitId = newCommit.id
        }
        
        stagedFiles.removeAll() // Clear staging area after committing
        
        lastAction = GitAction(
            command: "git commit -m \"\(message)\"",
            explanation: "Created commit '\(newCommit.id)'. Your changes are now saved in Git's history.",
            type: .commit
        )
    }

    /// Simulates `git checkout -b <branch>`.
    func createBranch(name: String) {
        clearNewFlags()
        let color = colorForBranch(name)
        let newBranch = GitBranch(id: name, headCommitId: headCommit?.id, color: color, isNew: true)
        branches.append(newBranch)
        currentBranch = name
        lastAction = GitAction(
            command: "git checkout -b \(name)",
            explanation: "Created and switched to new branch '\(name)'. It points to the same commit as before.",
            type: .branch
        )
    }

    /// Simulates `git checkout <branch>`.
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

    /// Simulates `git merge <branch>`.
    func merge(branch: String) {
        clearNewFlags()
        guard let sourceBranch = branches.first(where: { $0.id == branch }),
              sourceBranch.headCommitId != nil else { return }
              
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

    /// Simulates `git remote add <name> <url>`.
    func addRemote(name: String, url: String) {
        hasRemote = true
        remoteName = name
        lastAction = GitAction(
            command: "git remote add \(name) \(url)",
            explanation: "Connected to remote '\(name)'. Your local repo now knows about the GitHub repository.",
            type: .push
        )
    }

    /// Simulates `git push`.
    func push() {
        lastAction = GitAction(
            command: "git push -u \(remoteName) \(currentBranch)",
            explanation: "Pushed '\(currentBranch)' to remote. Your commits are now on GitHub for others to see.",
            type: .push
        )
    }

    /// Simulates `git pull`.
    func pull() {
        clearNewFlags()
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

    /// Simulates `git reset HEAD~1`.
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

    /// Simulates `git status`.
    func status() {
        let staged = stagedFiles.isEmpty ? "nothing staged" : stagedFiles.joined(separator: ", ")
        lastAction = GitAction(
            command: "git status",
            explanation: "On branch '\(currentBranch)'. Staged: \(staged).",
            type: .status
        )
    }

    /// Wipes out all repository data.
    func resetAll() {
        isInitialized = false
        commits.removeAll()
        branches.removeAll()
        currentBranch = "main"
        stagedFiles.removeAll()
        hasRemote = false
        lastAction = nil
    }

    // MARK: - Private Utilities

    /// Resets animation highlighting flags.
    private func clearNewFlags() {
        for i in commits.indices {
            commits[i].isNew = false
        }
        for i in branches.indices {
            branches[i].isNew = false
        }
    }

    /// Traverses commit history backwards via parent IDs.
    private func commitsForBranch(_ branchName: String) -> [GitCommit] {
        guard let branch = branches.first(where: { $0.id == branchName }),
              let headId = branch.headCommitId else { return [] }
              
        var result: [GitCommit] = []
        var currentId: String? = headId
        
        while let id = currentId, let commit = commits.first(where: { $0.id == id }) {
            result.insert(commit, at: 0) // Prepend to preserve chronological order
            currentId = commit.parentId
        }
        return result
    }

    /// Assigns consistent visually distinct colors to branches.
    private func colorForBranch(_ name: String) -> Color {
        let colors: [Color] = [.green, .blue, .orange, .pink, .cyan, .mint, .indigo]
        let hash = abs(name.hashValue)
        return colors[hash % colors.count]
    }
}
