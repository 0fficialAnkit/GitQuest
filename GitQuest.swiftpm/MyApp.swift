import SwiftUI

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        supportedInterfaceOrientationsFor window: UIWindow?
    ) -> UIInterfaceOrientationMask {
        .portrait
    }
}

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
