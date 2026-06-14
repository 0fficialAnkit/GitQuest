import SwiftUI

// MARK: - Achievements / Badges Screen

/// Displays every badge in the game, highlighting the ones the player has unlocked.
struct BadgesView: View {
    @Environment(GameState.self) var gameState

    private let columns = [
        GridItem(.adaptive(minimum: 160), spacing: Theme.Spacing.md)
    ]

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
                VStack(spacing: Theme.Spacing.xl) {
                    header

                    LazyVGrid(columns: columns, spacing: Theme.Spacing.md) {
                        ForEach(Badge.allBadges) { badge in
                            BadgeCard(badge: badge, isEarned: gameState.earnedBadges.contains(badge.id))
                        }
                    }
                    .padding(.horizontal, Theme.Spacing.lg)
                    .padding(.bottom, Theme.Spacing.xl)
                }
                .padding(.top, Theme.Spacing.xl)
            }
            .scrollIndicators(.hidden)
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .preferredColorScheme(.dark)
    }

    private var header: some View {
        VStack(spacing: Theme.Spacing.xs) {
            Text("Achievements")
                .font(Theme.Typography.title)
                .foregroundStyle(
                    LinearGradient(
                        colors: [Theme.Colors.primary, Theme.Colors.secondary],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )

            Text("\(gameState.earnedBadges.count) of \(Badge.allBadges.count) unlocked")
                .font(Theme.Typography.h3)
                .foregroundStyle(Theme.Colors.textTertiary)
        }
        .padding(.horizontal, Theme.Spacing.lg)
    }
}

// MARK: - Badge Card

private struct BadgeCard: View {
    let badge: Badge
    let isEarned: Bool

    var body: some View {
        VStack(spacing: Theme.Spacing.sm) {
            ZStack {
                Circle()
                    .fill(isEarned ? badge.color.opacity(0.2) : Color.white.opacity(0.05))
                    .frame(width: 64, height: 64)
                    .overlay(
                        Circle().stroke(isEarned ? badge.color.opacity(0.4) : Color.white.opacity(0.08), lineWidth: 1)
                    )

                Image(systemName: isEarned ? badge.icon : "lock.fill")
                    .font(.system(size: isEarned ? 26 : 20, weight: .semibold))
                    .foregroundStyle(isEarned ? badge.color : Theme.Colors.textTertiary)
            }

            Text(badge.title)
                .font(Theme.Typography.bodyBold)
                .foregroundStyle(isEarned ? Theme.Colors.textPrimary : Theme.Colors.textTertiary)
                .multilineTextAlignment(.center)

            Text(badge.description)
                .font(Theme.Typography.small)
                .foregroundStyle(Theme.Colors.textTertiary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(Theme.Spacing.md)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(.regularMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(Color.white.opacity(isEarned ? 0.15 : 0.06), lineWidth: 1)
                )
        )
        .opacity(isEarned ? 1.0 : 0.6)
    }
}

#Preview("Badges") {
    NavigationStack {
        BadgesView()
            .environment(GameState())
    }
    .preferredColorScheme(.dark)
}
