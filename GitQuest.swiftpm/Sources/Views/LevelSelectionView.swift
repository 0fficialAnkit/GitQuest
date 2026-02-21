//
//  LevelSelectionView.swift
//  GitQuest
//
//  Created by Ankit Kumar on 04/02/26.
//

import SwiftUI

/// Level selection screen with colorful animated design
struct LevelSelectionView: View {
    @Environment(GameState.self) var gameState
    @Binding var navigationPath: NavigationPath
    @State private var lockedTapId: Int? = nil
    
    var body: some View {
        ZStack {
            // Animated gradient background - fills entire screen
            BackgroundView(
                colors: [
                    Theme.Colors.primary.opacity(0.4),
                    Theme.Colors.secondary.opacity(0.4)
                ],
                animation: true
            )
            
            // ScrollView takes full available height
            ScrollViewReader { proxy in
                ScrollView(.vertical) {
                    VStack(spacing: Theme.Spacing.xl) {
                        // Header
                        headerSection
                            .padding(.top, Theme.Spacing.xl)
                        
                        // Level path with staggered layout
                        VStack(spacing: Theme.Spacing.xxl) {
                            ForEach(Array(Level.allLevels.enumerated()), id: \.element.id) { index, level in
                                LevelNode(
                                    level: level,
                                    isUnlocked: gameState.isLevelUnlocked(level.id),
                                    isCompleted: gameState.completedLevels.contains(level.id),
                                    isCurrent: level.id == gameState.currentLevel
                                )
                                .id(level.id)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    if gameState.isLevelUnlocked(level.id) {
                                        navigationPath.append(AppScreen.game(level))
                                    } else {
                                        // Locked tap → bounce + flash
                                        withAnimation(.easeInOut(duration: 0.06).repeatCount(4, autoreverses: true)) {
                                            lockedTapId = level.id
                                        }
                                        Task { @MainActor in
                                            try? await Task.sleep(for: .seconds(0.3))
                                            withAnimation(.easeOut(duration: 0.2)) {
                                                lockedTapId = nil
                                            }
                                        }
                                    }
                                }
                                // Locked level visual feedback
                                .offset(x: lockedTapId == level.id ? 6 : 0)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 60, style: .continuous)
                                        .fill(Color.gray.opacity(0.12))
                                        .opacity(lockedTapId == level.id ? 1 : 0)
                                        .allowsHitTesting(false)
                                )
                                .offset(x: offsetForLevel(index))
                            }
                        }
                        .padding(.vertical, Theme.Spacing.xl)
                        .padding(.bottom, 80) // Extra bottom padding for safe area
                    }
                    .frame(maxWidth: .infinity)
                }
                .scrollIndicators(.hidden)
                .scrollBounceBehavior(.basedOnSize)
                .onChange(of: gameState.currentLevel) { _, newLevel in
                    withAnimation(.easeInOut(duration: 0.8)) {
                        proxy.scrollTo(newLevel, anchor: .center)
                    }
                }
            }
        }
        .ignoresSafeArea(edges: .bottom)
        .toolbar(.hidden, for: .navigationBar)
    }
    
    private var headerSection: some View {
        VStack(spacing: Theme.Spacing.md) {
            HStack {
                Text("Git Quest Journey")
                    .font(Theme.Typography.title)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Theme.Colors.primary, Theme.Colors.secondary],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
            }
            
            Text("Master Git one level at a time")
                .font(Theme.Typography.h3)
                .foregroundStyle(Theme.Colors.textTertiary)
        }
    }
    
    private func offsetForLevel(_ index: Int) -> CGFloat {
        let positions: [CGFloat] = [0, 100, -100, 80, -80, 100, -100, 0]
        return positions[min(index, positions.count - 1)]
    }
}

/// Animated level node with colorful design
struct LevelNode: View {
    let level: Level
    let isUnlocked: Bool
    let isCompleted: Bool
    let isCurrent: Bool
    
    @State private var pulse = false
    @State private var appeared = false
    
    var body: some View {
        VStack(spacing: Theme.Spacing.md) {
            ZStack {
                // Pulsing glow for current level
                if isCurrent && !isCompleted {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [levelColor.opacity(0.5), Color.clear],
                                center: .center,
                                startRadius: 0,
                                endRadius: 90
                            )
                        )
                        .frame(width: 160, height: 160)
                        .scaleEffect(pulse ? 1.2 : 1.0)
                        .opacity(pulse ? 0 : 0.6)
                }
                
                // Main circle with gradient
                Circle()
                    .fill(isUnlocked ? AnyShapeStyle(.regularMaterial) : AnyShapeStyle(.ultraThinMaterial))
                    .frame(width: 120, height: 120)
                    .overlay(
                        Circle()
                            .fill(levelColor.opacity(isUnlocked ? 0.25 : 0.08))
                    )
                    .overlay(
                        Circle()
                            .stroke(Color.white.opacity(0.15), lineWidth: 1)
                    )
                    .shadow(color: Color.black.opacity(0.15), radius: 10, y: 5)
                
                // Icon or status
                if isCompleted {
                    VStack(spacing: Theme.Spacing.xs) {
                        Image(systemName: level.concept.icon)
                            .font(.system(size: 50))
                            .foregroundStyle(Color.white)
                        
                        Text("Done")
                            .font(Theme.Typography.small)
                            .fontWeight(.bold)
                            .foregroundStyle(Color.white)
                    }
                } else if isUnlocked {
                    Image(systemName: level.icon)
                        .font(.system(size: 50))
                        .foregroundStyle(Color.white)
                } else {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 45))
                        .foregroundStyle(Color.white.opacity(0.6))
                }
                
                // Level number badge
                VStack {
                    HStack {
                        Spacer()
                        Text("\(level.id)")
                            .font(Theme.Typography.caption)
                            .fontWeight(.bold)
                            .foregroundStyle(Color.white)
                            .frame(width: 32, height: 32)
                            .background(
                                Circle()
                                    .fill(isUnlocked ? levelColor.opacity(0.8) : Color.gray.opacity(0.7))
                            )
                            .offset(x: 20, y: -20)
                    }
                    Spacer()
                }
                .frame(width: 120, height: 120)
            }
            
            // Title and info
            VStack(spacing: Theme.Spacing.xs) {
                Text(level.title)
                    .font(Theme.Typography.h3)
                    .foregroundStyle(isUnlocked ? Theme.Colors.textPrimary : Theme.Colors.textTertiary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            .frame(width: 200)
        }
        .scaleEffect(isUnlocked ? 1.0 : 0.85)
        .scaleEffect(appeared ? 1.0 : 0.8)
        .opacity(appeared ? 1.0 : 0)
        .onAppear {
            // Staggered entrance animation
            withAnimation(
                .spring(response: 0.6, dampingFraction: 0.7)
                .delay(Double(level.id) * 0.1)
            ) {
                appeared = true
            }
            
            // Pulse animation for current level
            if isCurrent && !isCompleted {
                Task { @MainActor in
                    try? await Task.sleep(for: .seconds(Double(level.id) * 0.1))
                    withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: false)) {
                        pulse = true
                    }
                }
            }
        }
    }
    
    private var levelColor: Color {
        Theme.Colors.conceptColor(level.concept)
    }
}
// MARK: - Preview Container

struct LevelSelectionPreviewContainer: View {
    @State private var path = NavigationPath()
    @State private var gameState = GameState()
    
    var body: some View {
        NavigationStack(path: $path) {
            LevelSelectionView(navigationPath: $path)
                .environment(gameState)
        }
    }
}


#Preview("Level Selection") {
    LevelSelectionPreviewContainer()
}
