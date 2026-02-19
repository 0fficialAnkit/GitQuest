//
//  GameState.swift
//  GitQuest
//
//  Persistent player progress tracked via UserDefaults
//

import Foundation
import Observation

// MARK: - Game State

/// Observable store for the player's overall progress.
///
/// Persists completed levels and tutorial status to `UserDefaults`
/// so the player picks up where they left off between launches.
@Observable
@MainActor
class GameState {
    
    // MARK: - Persistence Keys
    
    /// `UserDefaults` keys used for serialisation.
    private enum StorageKey {
        static let completedLevels = "completedLevels"
        static let hasCompletedTutorial = "hasCompletedTutorial"
    }
    
    // MARK: - State
    
    /// Set of level IDs the player has finished.
    var completedLevels: Set<Int> {
        didSet { save() }
    }
    
    /// Whether the onboarding tutorial has been shown and dismissed.
    var hasCompletedTutorial: Bool {
        didSet { save() }
    }
    
    // MARK: - Computed Properties
    
    /// The next level the player should attempt (first incomplete level).
    var currentLevel: Int {
        let allLevelIDs = Level.allLevels.map(\.id)
        return allLevelIDs.first { !completedLevels.contains($0) } ?? allLevelIDs.last ?? 1
    }
    
    // MARK: - Initialisation
    
    init() {
        let saved = UserDefaults.standard.array(forKey: StorageKey.completedLevels) as? [Int] ?? []
        self.completedLevels = Set(saved)
        self.hasCompletedTutorial = UserDefaults.standard.bool(forKey: StorageKey.hasCompletedTutorial)
    }
    
    // MARK: - Actions
    
    /// Returns `true` when `levelId` is at or before the player's current frontier.
    func isLevelUnlocked(_ levelId: Int) -> Bool {
        levelId <= currentLevel
    }
    
    /// Marks a level as completed and persists the change.
    func completeLevel(_ levelId: Int) {
        completedLevels.insert(levelId)
    }
    
    /// Records that the player has finished the onboarding tutorial.
    func completeTutorial() {
        hasCompletedTutorial = true
    }
    
    /// Wipes all progress (completed levels and tutorial flag).
    func resetAllProgress() {
        completedLevels.removeAll()
        hasCompletedTutorial = false
        UserDefaults.standard.removeObject(forKey: "hasSeenGameTutorial")
    }
    
    // MARK: - Persistence
    
    /// Writes current state to `UserDefaults`.
    private func save() {
        UserDefaults.standard.set(Array(completedLevels), forKey: StorageKey.completedLevels)
        UserDefaults.standard.set(hasCompletedTutorial, forKey: StorageKey.hasCompletedTutorial)
    }
}
