//
//  TutorialView.swift
//  GitQuest
//
//  Created by Ankit Kumar on 04/02/26.
//

import SwiftUI

// MARK: - Tutorial View

/// Page-based onboarding tutorial introducing GitQuest concepts.
///
/// Uses a `TabView` with page-style indicators. The player can
/// swipe or tap "Next" to advance, and "Skip" to jump ahead.
struct TutorialView: View {
    @EnvironmentObject var gameState: GameState
    let onComplete: () -> Void
    
    @State private var currentPage = 0
    
    private let tutorialPages: [(icon: String, title: String, description: String, color: Color)] = [
        ("folder.badge.gearshape", "What is Git?", 
         "Git is a version control system that tracks changes in your code. Think of it as a time machine for your projects!", 
         .purple),
        ("terminal", "How It Works", 
         "You'll learn Git by typing real commands. Each level teaches a new concept with a story that explains why developers use these commands.", 
         .blue),
        ("arrow.triangle.branch", "Key Concepts", 
         "You'll master repositories, commits, branches, merging, and collaboration. These are the building blocks every developer needs.", 
         .green)
    ]
    
    var body: some View {
        ZStack {
            // Animated gradient background
            BackgroundView(
                colors: [tutorialPages[currentPage].color.opacity(0.3), .purple.opacity(0.2)],
                animation: true
            )
            
            VStack(spacing: 0) {
                // Skip button
                HStack {
                    Spacer()
                    Button("Skip") {
                        onComplete()
                    }
                    .font(Theme.Typography.bodyBold)
                    .foregroundStyle(Theme.Colors.textPrimary)
                    .padding(.horizontal, Theme.Spacing.md)
                    .padding(.vertical, Theme.Spacing.sm)
                    .background(
                        Capsule()
                            .fill(.ultraThinMaterial)
                    )
                    .padding(Theme.Spacing.lg)
                }
                
                // Animated tutorial pages
                TabView(selection: $currentPage) {
                    ForEach(Array(tutorialPages.enumerated()), id: \.offset) { index, page in
                        TutorialPageView(
                            icon: page.icon,
                            title: page.title,
                            description: page.description,
                            accentColor: page.color
                        )
                        .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .always))
                .animation(.easeInOut(duration: 0.3), value: currentPage)
                
                // Navigation buttons
                HStack(spacing: Theme.Spacing.lg) {
                    if currentPage > 0 {
                        Button {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                                currentPage -= 1
                            }
                        } label: {
                            HStack {
                                Image(systemName: "chevron.left")
                                Text("Back")
                            }
                            .font(Theme.Typography.bodyBold)
                            .foregroundStyle(Theme.Colors.textPrimary)
                            .frame(maxWidth: .infinity)
                            .frame(height: Constants.Layout.buttonHeight)
                            .background(
                                RoundedRectangle(cornerRadius: Constants.Layout.cornerRadius)
                                    .fill(.ultraThinMaterial)
                            )
                        }
                    }
                    
                    Button {
                        if currentPage == tutorialPages.count - 1 {
                            onComplete()
                        } else {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                                currentPage += 1
                            }
                        }
                    } label: {
                        HStack {
                            Text(currentPage == tutorialPages.count - 1 ? "Start Learning" : "Next")
                            Image(systemName: "chevron.right")
                        }
                        .font(Theme.Typography.bodyBold)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: Constants.Layout.buttonHeight)
                        .background(
                            RoundedRectangle(cornerRadius: Constants.Layout.cornerRadius)
                                .fill(
                                    LinearGradient(
                                        colors: [Theme.Colors.primary, Theme.Colors.secondary],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                        )
                    }
                }
                .padding(.horizontal, Theme.Spacing.lg)
                .padding(.bottom, Theme.Spacing.xl)
            }
        }
        .toolbar(.hidden, for: .navigationBar)
    }
}

/// Individual tutorial page with animations
struct TutorialPageView: View {
    let icon: String
    let title: String
    let description: String
    let accentColor: Color
    
    @State private var appeared = false
    
    var body: some View {
        VStack(spacing: Theme.Spacing.xl) {
            Spacer()
            
            // Animated icon
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [accentColor.opacity(0.3), Color.clear],
                            center: .center,
                            startRadius: 0,
                            endRadius: 80
                        )
                    )
                    .frame(width: 160, height: 160)
                    .scaleEffect(appeared ? 1.1 : 0.9)
                
                Image(systemName: icon)
                    .font(.system(size: 70))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [accentColor, accentColor.opacity(0.7)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: accentColor.opacity(0.5), radius: 20)
            }
            .scaleEffect(appeared ? 1.0 : 0.5)
            .opacity(appeared ? 1.0 : 0)
            
            VStack(spacing: Theme.Spacing.md) {
                Text(title)
                    .font(Theme.Typography.title)
                    .foregroundStyle(Theme.Colors.textPrimary)
                    .offset(y: appeared ? 0 : 20)
                    .opacity(appeared ? 1 : 0)
                
                Text(description)
                    .font(Theme.Typography.h3)
                    .foregroundStyle(Theme.Colors.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(6)
                    .padding(.horizontal, Theme.Spacing.xl)
                    .offset(y: appeared ? 0 : 20)
                    .opacity(appeared ? 1 : 0)
            }
            
            Spacer()
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                appeared = true
            }
        }
        .onDisappear {
            appeared = false
        }
    }
}
#Preview("Tutorial Screen") {
    TutorialView {
        // Preview next action
    }
}
