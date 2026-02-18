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
                        
                        Text("What You Just Learned")
                            .font(.title2.bold())
                            .foregroundStyle(.primary)
                        
                        Spacer()
                        
                        Button(action: dismissCard) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.title3)
                                .foregroundStyle(.secondary)
                        }
                    }
                    
                    ScrollView (showsIndicators: false) {
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
                        }
                    }
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
                            .background(Color.secondary.opacity(0.2))
                            .foregroundStyle(.primary)
                            .cornerRadius(12)
                        }
                        
                        Button(action: onNextLevel) {
                            HStack {
                                Text("Next Level")
                                Image(systemName: "arrow.right")
                            }
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                LinearGradient(
                                    colors: [.blue, .purple],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .foregroundStyle(Color.white)
                            .cornerRadius(12)
                        }
                    }
                }
                .padding(24)
                .background(
                    RoundedRectangle(cornerRadius: 24)
                        .fill(.ultraThickMaterial)
                        .shadow(color: .black.opacity(0.3), radius: 30)
                )
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
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
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
                .font(.system(.body, design: .monospaced).weight(.semibold))
                .foregroundStyle(.blue)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.blue.opacity(0.1))
                .cornerRadius(6)
            
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
        .background(color.opacity(0.1))
        .cornerRadius(10)
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
