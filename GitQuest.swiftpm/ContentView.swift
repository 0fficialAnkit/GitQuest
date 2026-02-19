//
//  ContentView.swift
//  GitQuest
//
//  Root navigation container
//

import SwiftUI

// MARK: - Navigation Destinations

/// Type-safe navigation destinations used with `NavigationStack`.
enum AppScreen: Hashable {
    case tutorial
    case levels
    case game(Level)
}

// MARK: - Content View

/// Root view that controls the top-level navigation flow:
/// Welcome → Tutorial (if needed) → Level Selection → Game.
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
                // Determine initial screen based on tutorial completion
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
