import Foundation
import Observation

// MARK: - Game State

/// Manages the persistence and state of the overall game progression.
@Observable
@MainActor
class GameState {

    // MARK: - Constants

    /// Keys used for UserDefaults storage.
    private enum StorageKey {
        static let completedLevels = "completedLevels"
        static let hasCompletedTutorial = "hasCompletedTutorial"
        static let earnedBadges = "earnedBadges"
        static let hasPerfectRun = "hasPerfectRun"
    }

    // MARK: - Published Properties

    /// A set of all level IDs that have been successfully completed.
    /// Automatically persists to UserDefaults upon modification.
    var completedLevels: Set<Int> {
        didSet { persist() }
    }

    /// Indicates whether the user has finished the initial git tutorial.
    /// Automatically persists to UserDefaults upon modification.
    var hasCompletedTutorial: Bool {
        didSet { persist() }
    }

    /// Identifiers of badges the player has unlocked so far.
    /// Automatically persists to UserDefaults upon modification.
    var earnedBadges: Set<String> {
        didSet { persist() }
    }

    /// Whether the player has ever completed a level without making a mistake.
    /// Automatically persists to UserDefaults upon modification.
    var hasPerfectRun: Bool {
        didSet { persist() }
    }

    /// Badges unlocked during the most recent level completion, used to surface "new badge" highlights.
    var newlyEarnedBadges: [Badge] = []

    /// Computed property returning the ID of the highest unlocked level.
    var currentLevel: Int {
        let ids = Level.allLevels.map(\.id)
        return ids.first { !completedLevels.contains($0) } ?? ids.last ?? 1
    }

    // MARK: - Initialization

    /// Initializes the GameState by loading previous progress from UserDefaults.
    init() {
        let saved = UserDefaults.standard.array(forKey: StorageKey.completedLevels) as? [Int] ?? []
        completedLevels = Set(saved)
        hasCompletedTutorial = UserDefaults.standard.bool(forKey: StorageKey.hasCompletedTutorial)
        let savedBadges = UserDefaults.standard.array(forKey: StorageKey.earnedBadges) as? [String] ?? []
        earnedBadges = Set(savedBadges)
        hasPerfectRun = UserDefaults.standard.bool(forKey: StorageKey.hasPerfectRun)
    }

    // MARK: - State Management

    /// Checks if a given level ID is unlocked based on current progress.
    func isLevelUnlocked(_ levelId: Int) -> Bool {
        levelId <= currentLevel
    }

    /// Marks a specific level as completed and evaluates any newly unlocked badges.
    /// - Parameter perfect: Whether the level was completed without any failed command attempts.
    func completeLevel(_ levelId: Int, perfect: Bool = false) {
        completedLevels.insert(levelId)
        if perfect {
            hasPerfectRun = true
        }
        evaluateBadges()
    }

    /// Marks the tutorial as finished.
    func completeTutorial() {
        hasCompletedTutorial = true
    }

    /// Wipes all game progress and resets the storage.
    func resetAllProgress() {
        completedLevels.removeAll()
        hasCompletedTutorial = false
        earnedBadges.removeAll()
        hasPerfectRun = false
        newlyEarnedBadges = []
        // Clear specific legacy tutorial flag as well
        UserDefaults.standard.removeObject(forKey: "hasSeenGameTutorial")
    }

    // MARK: - Badges

    /// Checks all badge criteria and unlocks any newly earned badges.
    private func evaluateBadges() {
        var newlyEarned: [Badge] = []
        for badge in Badge.allBadges where !earnedBadges.contains(badge.id) {
            if badge.criteria(self) {
                earnedBadges.insert(badge.id)
                newlyEarned.append(badge)
            }
        }
        newlyEarnedBadges = newlyEarned
    }

    // MARK: - Persistence Helper

    /// Saves the current progress tracking properties to UserDefaults.
    private func persist() {
        UserDefaults.standard.set(Array(completedLevels), forKey: StorageKey.completedLevels)
        UserDefaults.standard.set(hasCompletedTutorial, forKey: StorageKey.hasCompletedTutorial)
        UserDefaults.standard.set(Array(earnedBadges), forKey: StorageKey.earnedBadges)
        UserDefaults.standard.set(hasPerfectRun, forKey: StorageKey.hasPerfectRun)
    }
}
