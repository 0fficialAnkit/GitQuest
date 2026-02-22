import SwiftUI

/// Full-screen “Level complete” overlay with checkmark, level title, concept badge, and dismiss button.
struct SuccessOverlay: View {
    let level: Level
    let onDismiss: () -> Void

    @State private var isVisible = false
    @State private var dismissHapticTrigger = false

    var body: some View {
        ZStack {
            Color.black.opacity(0.5)
                .ignoresSafeArea()
                .onTapGesture { dismissOverlay() }

            VStack(spacing: 25) {
                ZStack {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 95, weight: .bold))
                        .foregroundStyle(
                            LinearGradient(colors: [.green], startPoint: .topLeading, endPoint: .bottomTrailing)
                        )
                        .shadow(color: .green.opacity(0.3), radius: 30)
                        .shadow(color: .green.opacity(0.3), radius: 15)
                }
                .scaleEffect(isVisible ? 1.0 : 0.3)
                .opacity(isVisible ? 1.0 : 0)

                VStack(spacing: 10) {
                    Text("Level Complete!")
                        .font(.system(size: 38, weight: .bold))
                        .foregroundStyle(Theme.Colors.textPrimary)
                    Text(level.title)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(Theme.Colors.textPrimary)
                }
                .offset(y: isVisible ? 0 : 25)
                .opacity(isVisible ? 1.0 : 0)

                HStack(spacing: 8) {
                    Image(systemName: level.concept.icon)
                        .font(.system(size: 18))
                    Text(level.concept.rawValue)
                        .font(.system(size: 16, weight: .medium))
                }
                .foregroundStyle(Theme.Colors.conceptColor(level.concept))
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(.ultraThinMaterial)
                        .overlay(Capsule().stroke(Color.white.opacity(0.18), lineWidth: 1))
                )
                .scaleEffect(isVisible ? 1.0 : 0.8)
                .opacity(isVisible ? 1.0 : 0)

                Text("Tap anywhere to continue")
                    .font(.system(size: 10))
                    .foregroundStyle(Theme.Colors.textSecondary)
                    .opacity(isVisible ? 1.0 : 0)
                    .offset(y: isVisible ? 0 : 10)
            }
            .padding(40)
            .background(
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .fill(.regularMaterial)
                    .overlay(RoundedRectangle(cornerRadius: 28, style: .continuous).stroke(Color.white.opacity(0.14), lineWidth: 1))
                    .shadow(color: .black.opacity(0.25), radius: 30, y: 18)
                    .shadow(color: .green.opacity(0.15), radius: 40)
            )
            .overlay(alignment: .top) {
                LinearGradient(colors: [Color.white.opacity(0.25), .clear], startPoint: .top, endPoint: .bottom)
                    .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
                    .blendMode(.overlay)
                    .allowsHitTesting(false)
            }
            .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
            .padding(.horizontal, 24)
        }
        .sensoryFeedback(.success, trigger: isVisible)
        .sensoryFeedback(.impact(flexibility: .soft), trigger: dismissHapticTrigger)
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                isVisible = true
            }
        }
    }

    private func dismissOverlay() {
        withAnimation(.easeOut(duration: 0.2)) {
            isVisible = false
        }
        dismissHapticTrigger.toggle()
        Task { @MainActor in
            try? await Task.sleep(for: .seconds(0.2))
            onDismiss()
        }
    }
}

#Preview("Success – Branching Level") {
    ZStack {
        Theme.Colors.background
            .ignoresSafeArea()
        SuccessOverlay(level: Level.allLevels[2]) { }
    }
    .preferredColorScheme(.dark)
}
