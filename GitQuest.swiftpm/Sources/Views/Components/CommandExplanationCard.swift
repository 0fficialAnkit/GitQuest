//
//  CommandExplanationCard.swift
//  GitQuest
//
//  Created by Ankit Kumar on 06/02/26.
//

import SwiftUI

// MARK: - Command Explanation Card

/// Full-screen educational card shown after a level is completed.
///
/// Displays the commands used, a pro tip, risk warnings,
/// real-world usage examples, and "Continue" / "Explore" buttons.
struct CommandExplanationCard: View {
    let level: Level
    var isLastLevel: Bool = false
    let onNextLevel: () -> Void
    let onStayAndExplore: () -> Void
    let onDismiss: () -> Void
    
    @State private var show = false
    @State private var contentOffset: CGFloat = 500
    
    var body: some View {
        ZStack {
            // Semi-transparent background
            Color.black.opacity(0.3)
                .ignoresSafeArea()
                .onTapGesture {
                    dismissCard()
                }
            
            VStack(spacing: 0) {
                Spacer()
                
                // Main card content
                VStack(alignment: .leading, spacing: 24) {
                    // Header
                    HStack {
                        Image(systemName: "lightbulb.fill")
                            .font(.title2)
                            .foregroundStyle(.yellow)
                        
                        Text("What You Used")
                            .font(.title2.bold())
                            .foregroundStyle(.primary)
                        
                        Spacer()
                        
                        Button(action: dismissCard) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.title3)
                                .foregroundStyle(.secondary)
                                .padding(4)
                                .background(
                                    Circle()
                                        .fill(.ultraThinMaterial)
                                        .overlay(
                                            Circle()
                                                .stroke(Color.white.opacity(0.18), lineWidth: 1)
                                        )
                                )
                        }
                    }
                    
                    ScrollView {
                        VStack(alignment: .leading, spacing: 20) {
                            // Command details
                            commandDetailsView
                            
                            Divider()
                            
                            // Pro tip
                            InsightBlock(
                                icon: "bolt.fill",
                                color: .yellow,
                                title: "Pro Tip",
                                content: level.commandExplanation.proTip
                            )
                            
                            // Risk warning
                            InsightBlock(
                                icon: "exclamationmark.triangle.fill",
                                color: .orange,
                                title: "Risk",
                                content: level.commandExplanation.risk
                            )
                            
                            // Real world usage
                            InsightBlock(
                                icon: "briefcase.fill",
                                color: .blue,
                                title: "Real World Usage",
                                content: level.commandExplanation.realWorldUsage
                            )
                            
                            // Reset instructions for final level
                            if isLastLevel {
                                Divider()
                                
                                InsightBlock(
                                    icon: "arrow.counterclockwise",
                                    color: .green,
                                    title: "Replay Journey",
                                    content: "To reset your progress and replay from Level 1, completely close the app and reopen it, then tap 'Reset Progress'."
                                )
                            }
                        }
                    }
                    .scrollIndicators(.hidden)
                    .frame(maxHeight: 400)
                    
                    // Action buttons
                    HStack(spacing: 16) {
                        Button(action: onStayAndExplore) {
                            HStack {
                                Image(systemName: "terminal")
                                Text("Stay & Explore")
                            }
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .fill(.ultraThinMaterial)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                                            .stroke(Color.white.opacity(0.18), lineWidth: 1)
                                    )
                            )
                            .foregroundStyle(.primary)
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                            .shadow(color: Color.black.opacity(0.12), radius: 8, y: 4)
                        }
                        
                        if !isLastLevel {
                            Button(action: onNextLevel) {
                                HStack {
                                    Text("Next Level")
                                    Image(systemName: "arrow.right")
                                }
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                                        .fill(.ultraThinMaterial)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                                .stroke(Color.white.opacity(0.18), lineWidth: 1)
                                        )
                                        .overlay(
                                            LinearGradient(
                                                colors: [.blue.opacity(0.5), .purple.opacity(0.5)],
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                                            .blendMode(.overlay)
                                        )
                                )
                                .foregroundStyle(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                                .shadow(color: Color.blue.opacity(0.25), radius: 12, y: 6)
                            }
                        }
                    }
                }
                .padding(24)
                .background(
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .fill(.regularMaterial)
                        .overlay(
                            RoundedRectangle(cornerRadius: 28, style: .continuous)
                                .stroke(Color.white.opacity(0.14), lineWidth: 1)
                        )
                        .shadow(color: .black.opacity(0.25), radius: 30, y: 18)
                )
                .overlay(alignment: .top) {
                    LinearGradient(
                        colors: [Color.white.opacity(0.25), .clear],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
                    .blendMode(.overlay)
                    .allowsHitTesting(false)
                }
                .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
                .offset(y: contentOffset)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                contentOffset = 0
                show = true
            }
        }
    }
    
    @ViewBuilder
    private var commandDetailsView: some View {
        VStack(alignment: .leading, spacing: 16) {
            ForEach(level.commandExplanation.commands, id: \.command) { cmd in
                CommandBlock(
                    command: cmd.command,
                    description: cmd.description
                )
            }
        }
    }
    
    private func dismissCard() {
        withAnimation(.easeOut(duration: 0.3)) {
            contentOffset = 500
            show = false
        }
        
        Task { @MainActor in
            try? await Task.sleep(for: .seconds(0.3))
            onDismiss()
        }
    }
}

// MARK: - Command Block

/// A single command entry rendered with a monospaced label and description.
struct CommandBlock: View {
    let command: String
    let description: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(command)
                .font(.system(.body, design: .default).weight(.semibold))
                .foregroundStyle(.blue)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    Capsule()
                        .fill(.ultraThinMaterial)
                        .overlay(
                            Capsule()
                                .stroke(Color.white.opacity(0.18), lineWidth: 1)
                        )
                )
            
            Text(description)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Insight Block

/// A collapsible insight section (Pro Tip, Risk, Real-World Usage)
/// with a header icon, title, and expandable body text.
struct InsightBlock: View {
    let icon: String
    let color: Color
    let title: String
    let content: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(color)
                .frame(width: 28)
            
            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.subheadline.bold())
                    .foregroundStyle(.primary)
                
                Text(content)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(Color.white.opacity(0.12), lineWidth: 1)
                )
        )
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}

#Preview {
    CommandExplanationCard(
        level: Level.allLevels[0],
        onNextLevel: {},
        onStayAndExplore: {},
        onDismiss: {}
    )
}
