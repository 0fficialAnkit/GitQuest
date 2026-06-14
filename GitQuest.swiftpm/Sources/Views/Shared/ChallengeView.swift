import SwiftUI

// MARK: - Daily Challenge Mode

/// A quick-fire recall mode: randomly presents a scenario from a level and asks
/// the player to type the correct Git command from memory, without hints.
struct ChallengeView: View {
    @State private var currentQuestion: ChallengeQuestion
    @State private var answer: String = ""
    @State private var feedback: ChallengeFeedback?
    @State private var streak: Int = 0
    @State private var bestStreak: Int

    private static let bestStreakKey = "challengeBestStreak"

    init() {
        _currentQuestion = State(initialValue: ChallengeQuestion.random())
        _bestStreak = State(initialValue: UserDefaults.standard.integer(forKey: Self.bestStreakKey))
    }

    var body: some View {
        ZStack {
            BackgroundView(
                colors: [
                    Theme.Colors.primary.opacity(0.3),
                    Theme.Colors.secondary.opacity(0.3)
                ],
                animation: true
            )

            ScrollView(.vertical) {
                VStack(spacing: Theme.Spacing.lg) {
                    header

                    questionCard

                    answerField

                    if let feedback {
                        feedbackCard(feedback)
                    }

                    actionButton
                }
                .padding(.horizontal, Theme.Spacing.lg)
                .padding(.top, Theme.Spacing.xl)
                .padding(.bottom, Theme.Spacing.xl)
            }
            .scrollIndicators(.hidden)
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .preferredColorScheme(.dark)
    }

    // MARK: - Sections

    private var header: some View {
        VStack(spacing: Theme.Spacing.xs) {
            Text("Daily Challenge")
                .font(Theme.Typography.title)
                .foregroundStyle(
                    LinearGradient(
                        colors: [Theme.Colors.primary, Theme.Colors.secondary],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )

            Text("Recall the command — no hints this time")
                .font(Theme.Typography.h3)
                .foregroundStyle(Theme.Colors.textTertiary)

            HStack(spacing: Theme.Spacing.lg) {
                statPill(title: "Streak", value: "\(streak)", color: GitTheme.green)
                statPill(title: "Best", value: "\(bestStreak)", color: GitTheme.yellow)
            }
            .padding(.top, Theme.Spacing.sm)
        }
    }

    private var questionCard: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            HStack(spacing: Theme.Spacing.sm) {
                Image(systemName: currentQuestion.level.icon)
                    .foregroundStyle(Theme.Colors.conceptColor(currentQuestion.level.concept))
                Text(currentQuestion.level.title)
                    .font(Theme.Typography.small)
                    .foregroundStyle(Theme.Colors.textTertiary)
            }

            Text(currentQuestion.step.contextMessage)
                .font(Theme.Typography.body)
                .foregroundStyle(Theme.Colors.textPrimary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(Theme.Spacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(.regularMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
    }

    private var answerField: some View {
        HStack(spacing: Theme.Spacing.sm) {
            Text("$")
                .font(.system(.body, design: .monospaced).weight(.bold))
                .foregroundStyle(GitTheme.green)

            TextField("Type the git command...", text: $answer)
                .font(.system(.body, design: .monospaced))
                .foregroundStyle(Theme.Colors.textPrimary)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
                .disabled(feedback != nil)
                .onSubmit(checkAnswer)
        }
        .padding(Theme.Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Theme.Colors.terminalBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(Color.white.opacity(0.12), lineWidth: 1)
                )
        )
    }

    private func feedbackCard(_ feedback: ChallengeFeedback) -> some View {
        HStack(alignment: .top, spacing: Theme.Spacing.sm) {
            Image(systemName: feedback.isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                .foregroundStyle(feedback.isCorrect ? GitTheme.green : GitTheme.red)

            VStack(alignment: .leading, spacing: 4) {
                Text(feedback.isCorrect ? "Correct!" : "Not quite")
                    .font(Theme.Typography.bodyBold)
                    .foregroundStyle(Theme.Colors.textPrimary)

                Text("Answer: \(currentQuestion.step.exampleCommand)")
                    .font(.system(.caption, design: .monospaced))
                    .foregroundStyle(Theme.Colors.textSecondary)
            }
        }
        .padding(Theme.Spacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill((feedback.isCorrect ? GitTheme.green : GitTheme.red).opacity(0.12))
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke((feedback.isCorrect ? GitTheme.green : GitTheme.red).opacity(0.3), lineWidth: 1)
                )
        )
    }

    private var actionButton: some View {
        Button(action: {
            if feedback == nil {
                checkAnswer()
            } else {
                nextQuestion()
            }
        }) {
            Text(feedback == nil ? "Check Answer" : "Next Challenge")
                .font(Theme.Typography.h3)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: Theme.Layout.buttonHeight)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Theme.Colors.primary.opacity(0.8))
                )
        }
        .buttonStyle(TapScaleButtonStyle())
        .disabled(isCheckDisabled)
        .opacity(isCheckDisabled ? 0.5 : 1.0)
    }

    private var isCheckDisabled: Bool {
        feedback == nil && answer.trimmingCharacters(in: .whitespaces).isEmpty
    }

    private func statPill(title: String, value: String, color: Color) -> some View {
        VStack(spacing: 2) {
            Text(value)
                .font(Theme.Typography.h3)
                .foregroundStyle(color)
            Text(title)
                .font(Theme.Typography.small)
                .foregroundStyle(Theme.Colors.textTertiary)
        }
        .padding(.horizontal, Theme.Spacing.md)
        .padding(.vertical, Theme.Spacing.sm)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(.ultraThinMaterial)
        )
    }

    // MARK: - Logic

    private func checkAnswer() {
        let trimmed = answer.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let expected = currentQuestion.step.expectedCommand.lowercased()
        let isCorrect = !trimmed.isEmpty && trimmed.contains(expected)

        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            feedback = ChallengeFeedback(isCorrect: isCorrect)
        }

        if isCorrect {
            streak += 1
            if streak > bestStreak {
                bestStreak = streak
                UserDefaults.standard.set(bestStreak, forKey: Self.bestStreakKey)
            }
        } else {
            streak = 0
        }
    }

    private func nextQuestion() {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            currentQuestion = ChallengeQuestion.random()
            answer = ""
            feedback = nil
        }
    }
}

// MARK: - Supporting Types

private struct ChallengeQuestion {
    let level: Level
    let step: LevelStep

    static func random() -> ChallengeQuestion {
        let candidates = Level.allLevels.flatMap { level in
            level.requiredSteps.map { (level: level, step: $0) }
        }
        let pick = candidates.randomElement()!
        return ChallengeQuestion(level: pick.level, step: pick.step)
    }
}

private struct ChallengeFeedback {
    let isCorrect: Bool
}

#Preview("Daily Challenge") {
    NavigationStack {
        ChallengeView()
    }
    .preferredColorScheme(.dark)
}
