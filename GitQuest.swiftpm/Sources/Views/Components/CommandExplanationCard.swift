import SwiftUI


// MARK: - Command Explanation Overlay

/// A modal card displaying detailed educational summaries of commands learned in a level.
struct CommandExplanationCard: View {
    let level: Level
    var isLastLevel: Bool = false
    let onNextLevel: () -> Void
    let onStayAndExplore: () -> Void
    let onDismiss: () -> Void

    @State private var show = false
    @State private var contentOffset: CGFloat = 800
    @State private var orbRotation: Double = 0

    private var levelColor: Color {
        Theme.Colors.conceptColor(level.concept)
    }

    var body: some View {
        ZStack {
            Rectangle()
                .fill(.black.opacity(0.35))
                .background(.ultraThinMaterial)
                .ignoresSafeArea()
                .opacity(show ? 1 : 0)
                .onTapGesture { dismissCard() }

            Circle()
                .fill(
                    LinearGradient(
                        colors: [levelColor.opacity(0.7), levelColor.opacity(0.3)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 320, height: 320)
                .blur(radius: 90)
                .offset(x: cos(orbRotation) * 40, y: (show ? 100 : 300) + sin(orbRotation) * 40)
                .opacity(show ? 0.8 : 0)
                .allowsHitTesting(false)

            VStack(spacing: 0) {
                Spacer()
                
                VStack(alignment: .leading, spacing: 28) {
                    HStack {
                        ZStack {
                            Circle()
                                .fill(levelColor.opacity(0.15))
                                .frame(width: 44, height: 44)
                            Image(systemName: "sparkles")
                                .font(.title3.weight(.bold))
                                .foregroundStyle(levelColor)
                        }
                        
                        Text("What You Used")
                            .font(.system(.title2, design: .rounded).weight(.bold))
                            .foregroundStyle(.white)
                        
                        Spacer()
                        
                        Button(action: dismissCard) {
                            Image(systemName: "xmark")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundStyle(.white.opacity(0.8))
                                .frame(width: 32, height: 32)
                                .background(
                                    Circle()
                                        .fill(Color.white.opacity(0.1))
                                )
                                .overlay(
                                    Circle().stroke(Color.white.opacity(0.2), lineWidth: 0.5)
                                )
                        }
                    }

                    ScrollView {
                        VStack(alignment: .leading, spacing: 24) {
                            commandDetailsView
                            
                            Rectangle()
                                .fill(LinearGradient(colors: [.clear, .white.opacity(0.1), .clear], startPoint: .leading, endPoint: .trailing))
                                .frame(height: 1)
                                .padding(.horizontal, 20)
                            
                            InsightBlock(icon: "bolt.fill", color: .yellow, title: "Pro Tip", content: level.commandExplanation.proTip)
                            InsightBlock(icon: "exclamationmark.triangle.fill", color: .orange, title: "Risk", content: level.commandExplanation.risk)
                            InsightBlock(icon: "case.fill", color: .cyan, title: "Real World Usage", content: level.commandExplanation.realWorldUsage)
                            
                            if isLastLevel {
                                Rectangle()
                                    .fill(LinearGradient(colors: [.clear, .white.opacity(0.1), .clear], startPoint: .leading, endPoint: .trailing))
                                    .frame(height: 1)
                                    .padding(.horizontal, 20)
                                    
                                InsightBlock(
                                    icon: "arrow.counterclockwise",
                                    color: .green,
                                    title: "Replay Journey",
                                    content: "To reset your progress and replay from Level 1, completely close the app and reopen it, then tap 'Reset Progress'."
                                )
                            }
                        }
                        .padding(.bottom, 20)
                    }
                    .scrollIndicators(.hidden)
                    .frame(maxHeight: 380)

                    HStack(spacing: 16) {
                        Button(action: onStayAndExplore) {
                            HStack {
                                Image(systemName: "terminal")
                                Text("Explore")
                            }
                            .font(.system(.headline, design: .rounded))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 22, style: .continuous)
                                    .fill(Color.white.opacity(0.05))
                                    .background(.ultraThinMaterial)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 22, style: .continuous)
                                    .stroke(LinearGradient(colors: [.white.opacity(0.2), .clear], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 0.5)
                            )
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                        }

                        if !isLastLevel {
                            Button(action: onNextLevel) {
                                HStack {
                                    Text("Next Level")
                                    Image(systemName: "arrow.right")
                                }
                                .font(.system(.headline, design: .rounded))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(
                                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                                        .fill(levelColor.opacity(0.8))
                                        .background(.regularMaterial)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                                        .stroke(LinearGradient(colors: [.white.opacity(0.5), .white.opacity(0.1)], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 0.5)
                                )
                                .overlay(
                                    LinearGradient(
                                        colors: [.white.opacity(0.2), .clear],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                    .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                                    .blendMode(.overlay)
                                )
                                .foregroundStyle(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                                .shadow(color: levelColor.opacity(0.4), radius: 15, y: 8)
                            }
                        }
                    }
                }
                .padding(28)
                .background(
                    RoundedRectangle(cornerRadius: 40, style: .continuous)
                        .fill(Color(white: 0.05, opacity: 0.6))
                        .background(.ultraThinMaterial)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 40, style: .continuous)
                        .stroke(
                            LinearGradient(
                                colors: [.white.opacity(0.3), .white.opacity(0.0), .white.opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 0.5
                        )
                )
                .overlay(alignment: .top) {
                    LinearGradient(colors: [Color.white.opacity(0.15), .clear], startPoint: .top, endPoint: .bottom)
                        .frame(height: 80)
                        .clipShape(RoundedRectangle(cornerRadius: 40, style: .continuous))
                        .blendMode(.overlay)
                        .allowsHitTesting(false)
                }
                .clipShape(RoundedRectangle(cornerRadius: 40, style: .continuous))
                .shadow(color: .black.opacity(0.4), radius: 40, y: 20)
                .padding(.horizontal, 16)
                .padding(.bottom, 32)
                .offset(y: contentOffset)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.65, dampingFraction: 0.75)) {
                contentOffset = 0
                show = true
            }
            withAnimation(.linear(duration: 8).repeatForever(autoreverses: false)) {
                orbRotation = .pi * 2
            }
        }
    }

    // MARK: - Subcomponents

    @ViewBuilder
    private var commandDetailsView: some View {
        VStack(alignment: .leading, spacing: 16) {
            ForEach(level.commandExplanation.commands, id: \.command) { cmd in
                CommandBlock(command: cmd.command, description: cmd.description)
            }
        }
    }

    private func dismissCard() {
        withAnimation(.easeIn(duration: 0.3)) {
            contentOffset = 800
            show = false
        }
        Task { @MainActor in
            try? await Task.sleep(for: .seconds(0.35))
            onDismiss()
        }
    }
}

// MARK: - Helper Views

/// Renders a single Git command and its description.
struct CommandBlock: View {
    let command: String
    let description: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(command)
                .font(.system(.body, design: .monospaced).weight(.semibold))
                .foregroundStyle(.cyan)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Color.black.opacity(0.4))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .stroke(Color.white.opacity(0.1), lineWidth: 0.5)
                        )
                )
            Text(description)
                .font(.system(.subheadline, design: .rounded))
                .foregroundStyle(.white.opacity(0.7))
                .lineSpacing(4)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.leading, 4)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

/// Renders a highlighted insight block (e.g., Pro Tip, Risk) with an icon and custom color.
struct InsightBlock: View {
    let icon: String
    let color: Color
    let title: String
    let content: String

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 36, height: 36)
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(color)
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.system(.subheadline, design: .rounded).weight(.semibold))
                    .foregroundStyle(.white)
                Text(content)
                    .font(.system(.caption, design: .rounded))
                    .foregroundStyle(.white.opacity(0.6))
                    .lineSpacing(4)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.white.opacity(0.03))
                .background(.ultraThinMaterial)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(
                    LinearGradient(
                        colors: [.white.opacity(0.15), .clear, .white.opacity(0.05)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 0.5
                )
        )
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
}

#Preview {
    CommandExplanationCard(
        level: Level.allLevels[0],
        onNextLevel: {},
        onStayAndExplore: {},
        onDismiss: {}
    )
    .preferredColorScheme(.dark)
}
