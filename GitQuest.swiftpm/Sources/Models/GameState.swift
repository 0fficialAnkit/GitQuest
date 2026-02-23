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
    }

    // MARK: - State Management

    /// Checks if a given level ID is unlocked based on current progress.
    func isLevelUnlocked(_ levelId: Int) -> Bool {
        levelId <= currentLevel
    }

    /// Marks a specific level as completed.
    func completeLevel(_ levelId: Int) {
        completedLevels.insert(levelId)
    }

    /// Marks the tutorial as finished.
    func completeTutorial() {
        hasCompletedTutorial = true
    }

    /// Wipes all game progress and resets the storage.
    func resetAllProgress() {
        completedLevels.removeAll()
        hasCompletedTutorial = false
        // Clear specific legacy tutorial flag as well
        UserDefaults.standard.removeObject(forKey: "hasSeenGameTutorial")
    }

    // MARK: - Persistence Helper

    /// Saves the current progress tracking properties to UserDefaults.
    private func persist() {
        UserDefaults.standard.set(Array(completedLevels), forKey: StorageKey.completedLevels)
        UserDefaults.standard.set(hasCompletedTutorial, forKey: StorageKey.hasCompletedTutorial)
    }
}
