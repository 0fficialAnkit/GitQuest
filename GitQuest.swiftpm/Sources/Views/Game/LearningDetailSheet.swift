import SwiftUI

/// Sheet presented when user taps the info button on a completed level.
/// Shows the same educational sections as CompletedInfoCard in a scrollable sheet.
struct LearningDetailSheet: View {
    let level: Level
    let content: LearningContent

    @State private var appeared = false

    private let accentBlue   = GitTheme.blue
    private let accentOrange = GitTheme.orange
    private let accentCyan   = GitTheme.cyan
    private let accentPurple = GitTheme.purple

    var body: some View {
        ScrollView(.vertical) {
            VStack(alignment: .leading, spacing: 24) {

                headerSection

                sectionCard(title: "Understanding the Concept", icon: "lightbulb.fill", color: .yellow, tint: Color.yellow.opacity(0.08)) {
                    Text(content.concept)
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.85))
                        .lineSpacing(3)

                    Text(content.whyItExists)
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.6))
                        .lineSpacing(2)
                        .padding(.top, 4)

                    Text(content.whenUsed)
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.6))
                        .lineSpacing(2)
                        .padding(.top, 2)
                }

                sectionCard(title: "Real-World Usage", icon: "briefcase.fill", color: accentCyan, tint: accentCyan.opacity(0.08)) {
                    ForEach(content.realWorldUsage, id: \.self) { item in
                        bulletRow(item, color: accentCyan)
                    }
                }

                sectionCard(title: "Pro Tips", icon: "bolt.fill", color: accentBlue, tint: accentBlue.opacity(0.08)) {
                    ForEach(content.tips, id: \.self) { tip in
                        bulletRow(tip, color: accentBlue)
                    }
                }

                sectionCard(title: "Common Risks", icon: "exclamationmark.triangle.fill", color: accentOrange, tint: accentOrange.opacity(0.08)) {
                    ForEach(content.risks, id: \.self) { risk in
                        bulletRow(risk, color: accentOrange)
                    }
                }

                sectionCard(title: "Real Scenario", icon: "person.2.fill", color: accentPurple, tint: accentPurple.opacity(0.08)) {
                    Text(content.scenario)
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.75))
                        .lineSpacing(3)
                        .italic()
                }
            }
            .padding(20)
            .padding(.bottom, 30)
        }
        .scrollIndicators(.hidden)
        .background(
            Rectangle()
                .fill(.regularMaterial)
                .ignoresSafeArea()
        )
        .preferredColorScheme(.dark)
        .onAppear {
            withAnimation(.easeOut(duration: 0.4)) {
                appeared = true
            }
        }
    }

    // MARK: - Header

    private var headerSection: some View {
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
                    .overlay(
                        Circle()
                            .stroke(Color.white.opacity(0.18), lineWidth: 1)
                    )
                    .shadow(color: Theme.Colors.conceptColor(level.concept).opacity(0.4), radius: 10)

                Image(systemName: level.icon)
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(.white)
                    .scaleEffect(appeared ? 1.0 : 0.95)
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
#Preview("Learning Detail Sheet") {
    LearningDetailSheet(
        level: Level.allLevels[0],
        content: LearningContent.content(for: 1)
    )
    .preferredColorScheme(.dark)
}
