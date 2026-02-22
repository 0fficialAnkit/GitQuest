import SwiftUI

enum AppScreen: Hashable {
    case tutorial
    case levels
    case game(Level)
}

struct ContentView: View {
    @Environment(GameState.self) var gameState
    @State private var navigationPath = NavigationPath()
    @State private var showingWelcome = true

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
