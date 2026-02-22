import SwiftUI

struct BackgroundView: View {
    let colors: [Color]
    let animation: Bool

    @State private var animateGradient = false

    init(colors: [Color], animation: Bool = false) {
        self.colors = colors
        self.animation = animation
    }

    var body: some View {
        LinearGradient(
            colors: colors,
            startPoint: animateGradient ? .topLeading : .bottomLeading,
            endPoint: animateGradient ? .bottomTrailing : .topTrailing
        )
        .ignoresSafeArea()
        .onAppear {
            if animation {
                withAnimation(.linear(duration: 3).repeatForever(autoreverses: true)) {
                    animateGradient = true
                }
            }
        }
    }
}

#Preview("Static Background") {
    BackgroundView(colors: [.purple, .blue], animation: false)
        .preferredColorScheme(.dark)
}
