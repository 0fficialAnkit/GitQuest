//
//  MyApp.swift
//  GitQuest
//
//  App entry point and orientation lock
//

import SwiftUI

// MARK: - Portrait Lock via AppDelegate

/// Custom `UIApplicationDelegate` that enforces portrait-only orientation.
class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        supportedInterfaceOrientationsFor window: UIWindow?
    ) -> UIInterfaceOrientationMask {
        return .portrait
    }
}

// MARK: - App Entry Point

/// GitQuest application root. Injects shared `GameState` and
/// `GitRepositoryState` environment objects and enforces dark mode.
@main
struct MyApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @State private var gameState = GameState()
    @State private var repoState = GitRepositoryState()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(gameState)
                .environment(repoState)
                .preferredColorScheme(.dark)
        }
    }
}
