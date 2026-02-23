import SwiftUI

/// A button style that scales down slightly when pressed for a tactile feel.
struct TapScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.94 : 1.0)
            .animation(.spring(response: 0.35, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

#Preview("Tap Scale Button Style") {
    ZStack {
        Theme.Colors.background.ignoresSafeArea()
        VStack(spacing: 20) {
            Button("Primary Action") {}
                .buttonStyle(TapScaleButtonStyle())
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 200, height: 50)
                .background(RoundedRectangle(cornerRadius: 14).fill(Theme.Colors.primary))

            Button("Secondary Action") {}
                .buttonStyle(TapScaleButtonStyle())
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 200, height: 50)
                .background(RoundedRectangle(cornerRadius: 14).fill(Theme.Colors.secondary))
        }
    }
    .preferredColorScheme(.dark)
}
