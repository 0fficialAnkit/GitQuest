import Foundation
import Observation

@Observable
@MainActor
class GameState {
    private enum StorageKey {
        static let completedLevels = "completedLevels"
        static let hasCompletedTutorial = "hasCompletedTutorial"
    }

    var completedLevels: Set<Int> {
        didSet { persist() }
    }

    var hasCompletedTutorial: Bool {
        didSet { persist() }
    }

    var currentLevel: Int {
        let ids = Level.allLevels.map(\.id)
        return ids.first { !completedLevels.contains($0) } ?? ids.last ?? 1
    }

    init() {
        let saved = UserDefaults.standard.array(forKey: StorageKey.completedLevels) as? [Int] ?? []
        completedLevels = Set(saved)
        hasCompletedTutorial = UserDefaults.standard.bool(forKey: StorageKey.hasCompletedTutorial)
    }

    func isLevelUnlocked(_ levelId: Int) -> Bool {
        levelId <= currentLevel
    }

    func completeLevel(_ levelId: Int) {
        completedLevels.insert(levelId)
    }

    func completeTutorial() {
        hasCompletedTutorial = true
    }

    func resetAllProgress() {
        completedLevels.removeAll()
        hasCompletedTutorial = false
        UserDefaults.standard.removeObject(forKey: "hasSeenGameTutorial")
    }

    private func persist() {
        UserDefaults.standard.set(Array(completedLevels), forKey: StorageKey.completedLevels)
        UserDefaults.standard.set(hasCompletedTutorial, forKey: StorageKey.hasCompletedTutorial)
    }
}
