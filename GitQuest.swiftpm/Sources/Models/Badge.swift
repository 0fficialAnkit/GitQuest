import SwiftUI

// MARK: - Achievement Badge Model

/// Represents a single achievement that a player can unlock while progressing through GitQuest.
struct Badge: Identifiable {
    let id: String
    let title: String
    let description: String
    let icon: String
    let color: Color

    /// Determines whether this badge should be considered earned given the current game state.
    let criteria: (GameState) -> Bool
}

extension Badge {
    /// The full catalog of badges available in the game.
    @MainActor
    static let allBadges: [Badge] = [
        Badge(
            id: "first_commit",
            title: "First Commit",
            description: "Initialize a repository and make your first commit.",
            icon: "folder.fill.badge.plus",
            color: GitTheme.purple,
            criteria: { $0.completedLevels.contains(1) }
        ),
        Badge(
            id: "branch_master",
            title: "Branch Master",
            description: "Create and switch to a new branch.",
            icon: "arrow.triangle.branch",
            color: GitTheme.green,
            criteria: { $0.completedLevels.contains(2) }
        ),
        Badge(
            id: "remote_pro",
            title: "Remote Pro",
            description: "Push your work to a remote repository.",
            icon: "cloud.fill",
            color: GitTheme.cyan,
            criteria: { $0.completedLevels.contains(3) }
        ),
        Badge(
            id: "conflict_resolver",
            title: "Conflict Resolver",
            description: "Resolve your first merge conflict.",
            icon: "exclamationmark.triangle.fill",
            color: GitTheme.red,
            criteria: { $0.completedLevels.contains(4) }
        ),
        Badge(
            id: "stash_master",
            title: "Stash Master",
            description: "Stash and restore changes with git stash.",
            icon: "archivebox.fill",
            color: GitTheme.blue,
            criteria: { $0.completedLevels.contains(8) }
        ),
        Badge(
            id: "cherry_pick_master",
            title: "Cherry-Pick Master",
            description: "Cherry-pick a commit from another branch.",
            icon: "arrow.triangle.branch",
            color: GitTheme.pink,
            criteria: { $0.completedLevels.contains(9) }
        ),
        Badge(
            id: "tag_champion",
            title: "Tag Champion",
            description: "Create and push a release tag.",
            icon: "tag.fill",
            color: GitTheme.yellow,
            criteria: { $0.completedLevels.contains(10) }
        ),
        Badge(
            id: "flawless_run",
            title: "Flawless Run",
            description: "Complete a level without a single mistake.",
            icon: "sparkles",
            color: GitTheme.orange,
            criteria: { $0.hasPerfectRun }
        ),
        Badge(
            id: "git_master",
            title: "Git Master",
            description: "Complete every level in GitQuest.",
            icon: "trophy.fill",
            color: GitTheme.yellow,
            criteria: { $0.completedLevels.count == Level.allLevels.count }
        )
    ]
}
