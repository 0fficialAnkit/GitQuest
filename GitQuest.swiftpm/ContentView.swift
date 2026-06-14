import SwiftUI

/// Navigation destinations: tutorial, level list, or a specific level game screen.
enum AppScreen: Hashable {
    case tutorial
    case levels
    case game(Level)
    case cheatSheet
    case badges
    case challenge
}

/// Root view: welcome ->  tutorial or level list -> level game. Uses NavigationStack and AppScreen for deep linking.
struct ContentView: View {
    @Environment(GameState.self) var gameState
    @State private var navigationPath = NavigationPath()
    @State private var showingWelcome = true

    // MARK: - Body

    var body: some View {
        if showingWelcome {
            WelcomeView {
                showingWelcome = false
            }
        } else {
            NavigationStack(path: $navigationPath) {
                Group {
                    if !gameState.hasCompletedTutorial {
                        TutorialView {
                            gameState.completeTutorial()
                            navigationPath.append(AppScreen.levels)
                        }
                    } else {
                        LevelSelectionView(navigationPath: $navigationPath)
                    }
                }
                .navigationDestination(for: AppScreen.self) { screen in
                    switch screen {
                    case .tutorial:
                        TutorialView {
                            gameState.completeTutorial()
                            navigationPath.append(AppScreen.levels)
                        }
                    case .levels:
                        LevelSelectionView(navigationPath: $navigationPath)
                    case .game(let level):
                        LevelGameView(level: level)
                    case .cheatSheet:
                        CheatSheetView()
                    case .badges:
                        BadgesView()
                    case .challenge:
                        ChallengeView()
                    }
                }
            }
        }
    }
}

#Preview("Welcome Screen") {
    WelcomeView { }
        .environment(GameState())
}
