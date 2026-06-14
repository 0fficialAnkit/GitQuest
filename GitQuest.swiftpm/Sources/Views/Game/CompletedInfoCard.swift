import SwiftUI

/// Overlay card shown when a user revisits a completed level.
/// Shows concept summary, real-world usage, tips, risks, and scenario,
/// with a Practice Again button at the bottom.
struct CompletedInfoCard: View {
    let level: Level
    let content: LearningContent
    let onPracticeAgain: () -> Void

    @State private var appeared = false

    private let accentBlue   = GitTheme.blue
    private let accentOrange = GitTheme.orange
    private let accentCyan   = GitTheme.cyan
    private let accentPurple = GitTheme.purple

    var body: some View {
        VStack(spacing: 0) {

            // MARK: Header
            VStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Theme.Colors.conceptColor(level.concept),
                                    Theme.Colors.conceptColor(level.concept).opacity(0.6)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 56, height: 56)
                        .overlay(Circle().stroke(Color.white.opacity(0.18), lineWidth: 1))
                        .shadow(color: Theme.Colors.conceptColor(level.concept).opacity(0.4), radius: 10)

                    Image(systemName: level.icon)
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(.white)
                        .scaleEffect(appeared ? 1.0 : 0.9)
                }

                VStack(spacing: 4) {
                    Text("What You Just Learned")
                        .font(.title3.bold())
                        .foregroundStyle(.white)

                    Text(level.title)
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.white.opacity(0.5))
                }
            }
            .frame(maxWidth: .infinity)
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 6)
            .padding(.top, 28)
            .padding(.bottom, 20)
            .padding(.horizontal, 20)

            Divider()
                .overlay(Color.white.opacity(0.12))

            // MARK: Scrollable content
            ScrollView(.vertical) {
                VStack(alignment: .leading, spacing: 24) {

                    sectionCard(title: "Understanding the Concept", icon: "lightbulb.fill", color: .yellow, tint: Color.yellow.opacity(0.08)) {
                        Text(content.concept)
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.85))
                            .lineSpacing(3)
                            .fixedSize(horizontal: false, vertical: true)

                        Text(content.whyItExists)
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.6))
                            .lineSpacing(2)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(.top, 4)

                        Text(content.whenUsed)
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.6))
                            .lineSpacing(2)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(.top, 2)
                    }

                    if !content.realWorldUsage.isEmpty {
                        sectionCard(title: "Real-World Usage", icon: "briefcase.fill", color: accentCyan, tint: accentCyan.opacity(0.08)) {
                            ForEach(content.realWorldUsage, id: \.self) { item in
                                bulletRow(item, color: accentCyan)
                            }
                        }
                    }

                    if !content.tips.isEmpty {
                        sectionCard(title: "Pro Tips", icon: "bolt.fill", color: accentBlue, tint: accentBlue.opacity(0.08)) {
                            ForEach(content.tips, id: \.self) { tip in
                                bulletRow(tip, color: accentBlue)
                            }
                        }
                    }

                    if !content.risks.isEmpty {
                        sectionCard(title: "Common Risks", icon: "exclamationmark.triangle.fill", color: accentOrange, tint: accentOrange.opacity(0.08)) {
                            ForEach(content.risks, id: \.self) { risk in
                                bulletRow(risk, color: accentOrange)
                            }
                        }
                    }

                    sectionCard(title: "Real Scenario", icon: "person.2.fill", color: accentPurple, tint: accentPurple.opacity(0.08)) {
                        Text(content.scenario)
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.75))
                            .lineSpacing(3)
                            .italic()
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    sectionCard(title: "Learn More", icon: "book.fill", color: GitTheme.green, tint: GitTheme.green.opacity(0.08)) {
                        Link(destination: level.referenceURL) {
                            HStack {
                                Text("Read the official docs on git-scm.com")
                                    .font(.caption.weight(.semibold))
                                    .foregroundStyle(GitTheme.green)
                                    .multilineTextAlignment(.leading)

                                Spacer()

                                Image(systemName: "arrow.up.right")
                                    .font(.caption.weight(.semibold))
                                    .foregroundStyle(GitTheme.green)
                            }
                        }
                    }
                }
                .padding(20)
                .padding(.bottom, 8)
            }
            .scrollIndicators(.hidden)

            Divider()
                .overlay(Color.white.opacity(0.12))

            // MARK: Practice Again button
            Button(action: onPracticeAgain) {
                HStack(spacing: 8) {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 14, weight: .bold))
                    Text("Practice Again")
                        .font(.system(size: 15, weight: .semibold))
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 15)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color.white.opacity(0.12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .stroke(Color.white.opacity(0.25), lineWidth: 1)
                        )
                )
            }
            .buttonStyle(TapScaleButtonStyle())
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 20)
        }
        .background(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(Theme.Colors.headerBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .stroke(Color.white.opacity(0.15), lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(0.6), radius: 40, y: 24)
        )
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .preferredColorScheme(.dark)
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                appeared = true
            }
        }
    }

    // MARK: - Helpers

    private func sectionCard<C: View>(
        title: String,
        icon: String,
        color: Color,
        tint: Color? = nil,
        @ViewBuilder content: () -> C
    ) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(color)

                Text(title)
                    .font(.callout.bold())
                    .foregroundStyle(.white)
            }

            VStack(alignment: .leading, spacing: 8) {
                content()
            }
            .padding(tint != nil ? 14 : 0)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                Group {
                    if tint != nil {
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(.ultraThinMaterial)
                            .overlay(
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .stroke(Color.white.opacity(0.12), lineWidth: 1)
                            )
                    }
                }
            )
        }
    }

    private func bulletRow(_ text: String, color: Color) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Circle()
                .fill(color.opacity(0.7))
                .frame(width: 5, height: 5)
                .padding(.top, 6)

            Text(text)
                .font(.caption)
                .foregroundStyle(.white.opacity(0.75))
                .lineSpacing(2)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

#Preview("Completed Info Card") {
    ZStack {
        Theme.Colors.background.ignoresSafeArea()
        CompletedInfoCard(
            level: Level.allLevels[0],
            content: LearningContent.content(for: 1),
            onPracticeAgain: {}
        )
        .frame(maxWidth: 600)
        .padding(.horizontal, 24)
        .padding(.vertical, 32)
    }
    .preferredColorScheme(.dark)
}
