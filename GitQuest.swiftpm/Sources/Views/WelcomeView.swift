//
//  WelcomeView.swift
//  GitQuest
//
//  Created by Ankit Kumar on 04/02/26.
//

import SwiftUI

// MARK: - Welcome View

/// Launch screen presenting the app identity, a "Start" button,
/// and an optional progress-reset action.
struct WelcomeView: View {
    @Environment(GameState.self) var gameState
    let onStart: () -> Void

    @State private var showResetAlert = false
    @State private var isStartPressed = false

    var body: some View {
        ZStack {
            // MARK: - Color graded background (adaptive for light/dark)
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

                // MARK: - App Icon (static, premium look)
                ZStack {
                    Image("icon")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 150, height: 150)
                }


                // MARK: - Title & Subtitle
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

                // MARK: - Primary & Secondary Actions
                VStack(spacing: Theme.Spacing.md) {

                    // Start Journey Button — Glass Style
                    Button {
                        onStart()
                    } label: {
                        Text("Start Your Journey")
                            .font(Theme.Typography.h3)
                            .foregroundStyle(.primary)
                            .frame(maxWidth: .infinity)
                            .frame(height: Constants.Layout.buttonHeight)
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

                    // Reset Progress (only if progress exists)
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
        // Preview action
    }
    .environment(GameState())
}
