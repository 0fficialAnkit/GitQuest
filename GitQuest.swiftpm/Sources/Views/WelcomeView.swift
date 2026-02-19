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

                    // Start Journey Button
                    Button {
                        onStart()
                    } label: {
                        Text("Start Your Journey")
                            .font(Theme.Typography.h3)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: Constants.Layout.buttonHeight)
                            .background(
                                RoundedRectangle(cornerRadius: Constants.Layout.cornerRadius)
                                    .fill(Theme.Colors.primary)
                            )
                            .shadow(
                                color: Theme.Colors.primary.opacity(0.3),
                                radius: 10,
                                y: 6
                            )
                    }

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
