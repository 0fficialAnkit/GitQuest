import SwiftUI

struct WelcomeView: View {
    @Environment(GameState.self) var gameState
    let onStart: () -> Void

    @State private var showResetAlert = false
    @State private var isStartPressed = false

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Theme.Colors.primary.opacity(0.25),
                    Color(uiColor: .systemBackground)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: Theme.Spacing.xl) {
                Spacer()

                ZStack {
                    Image("icon")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 150, height: 150)
                }

                VStack(spacing: Theme.Spacing.sm) {
                    Text("Git Quest")

                        .font(Theme.Typography.hero)
                        .foregroundStyle(.primary)

                    Text("Learn Git step by step through interactive challenges that actually make sense.")
                        .font(Theme.Typography.body)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, Theme.Spacing.xl)
                }

                Spacer()

                VStack(spacing: Theme.Spacing.md) {

                    Button {
                        onStart()
                    } label: {
                        Text("Start Your Journey")
                            .font(Theme.Typography.h3)
                            .foregroundStyle(.primary)
                            .frame(maxWidth: .infinity)
                            .frame(height: Theme.Layout.buttonHeight)
                            .background(
                                RoundedRectangle(cornerRadius: 20, style: .continuous)
                                    .fill(.ultraThinMaterial)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 20, style: .continuous)
                                    .stroke(Color.white.opacity(0.15), lineWidth: 1)
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                            .shadow(color: Color.black.opacity(0.15), radius: 10, y: 5)
                    }
                    .scaleEffect(isStartPressed ? 0.96 : 1)
                    .animation(.easeInOut(duration: 0.15), value: isStartPressed)
                    .simultaneousGesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { _ in isStartPressed = true }
                            .onEnded { _ in isStartPressed = false }
                    )

                    if !gameState.completedLevels.isEmpty {
                        Button {
                            showResetAlert = true
                        } label: {
                            Label("Reset Progress", systemImage: "arrow.counterclockwise")
                                .font(Theme.Typography.body)
                                .foregroundStyle(.secondary)
                                .padding(.vertical, Theme.Spacing.sm)
                        }
                    }
                }
                .padding(.horizontal, Theme.Spacing.xl)

                Spacer()
                    .frame(height: 40)
            }
        }
        .alert("Reset All Progress?", isPresented: $showResetAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Reset", role: .destructive) {
                gameState.resetAllProgress()
            }
        } message: {
            Text("This will remove all completed levels. This action cannot be undone.")
        }
    }
}

#Preview("Welcome Screen") {
    WelcomeView {
        
    }
    .environment(GameState())
    .preferredColorScheme(.dark)
}
