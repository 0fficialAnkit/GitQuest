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
    let onComplete: () -> Void
    
    @State private var currentPage = 0
    @State private var isSkipPressed = false
    @State private var isStartPressed = false
    
    private let tutorialPages: [(icon: String, title: String, description: String, color: Color)] = [
        ("folder.badge.gearshape", "What is Git?",
         "Git is a version control system that tracks changes in your code. Think of it as a time machine for your projects!",
         .purple),
        ("terminal", "How It Works",
         "You'll learn Git by running real commands. Tap the suggested commands in the console to execute them. Each level teaches a new concept with a story that explains why developers use these commands.",
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
                // Skip button — Glass Style (top-right)
                HStack {
                    Spacer()
                    Button("Skip") {
                        onComplete()
                    }
                    .font(Theme.Typography.bodyBold)
                    .foregroundStyle(.primary)
                    .padding(.horizontal, Theme.Spacing.md)
                    .padding(.vertical, Theme.Spacing.sm)
                    .background(
                        Capsule(style: .continuous)
                            .fill(.ultraThinMaterial)
                    )
                    .overlay(
                        Capsule(style: .continuous)
                            .stroke(Color.white.opacity(0.15), lineWidth: 1)
                    )
                    .clipShape(Capsule(style: .continuous))
                    .shadow(color: Color.black.opacity(0.15), radius: 8, y: 4)
                    .scaleEffect(isSkipPressed ? 0.96 : 1)
                    .animation(.easeInOut(duration: 0.15), value: isSkipPressed)
                    .simultaneousGesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { _ in isSkipPressed = true }
                            .onEnded { _ in isSkipPressed = false }
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
                
                // "Start Learning" button — only on last page
                if currentPage == tutorialPages.count - 1 {
                    Button {
                        onComplete()
                    } label: {
                        Text("Start Learning")
                            .font(Theme.Typography.h3)
                            .foregroundStyle(.primary)
                            .frame(maxWidth: .infinity)
                            .frame(height: Constants.Layout.buttonHeight)
                            .background(
                                RoundedRectangle(cornerRadius: 20, style: .continuous)
                                    .fill(.regularMaterial)
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
                    .padding(.horizontal, Theme.Spacing.lg)
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
                }
                
                Spacer()
                    .frame(height: Theme.Spacing.xl)
            }
            .animation(.easeInOut(duration: 0.3), value: currentPage)
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
