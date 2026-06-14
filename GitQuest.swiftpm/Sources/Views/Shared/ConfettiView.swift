import SwiftUI

// MARK: - Confetti Celebration Effect

/// A lightweight celebratory particle effect used to decorate completion screens.
struct ConfettiView: View {
    /// Controls how many pieces of confetti are spawned.
    var pieceCount: Int = 60

    @State private var pieces: [ConfettiPiece] = []

    private let colors: [Color] = [
        GitTheme.purple, GitTheme.blue, GitTheme.green,
        GitTheme.orange, GitTheme.cyan, GitTheme.yellow, GitTheme.pink
    ]

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                ForEach(pieces) { piece in
                    RoundedRectangle(cornerRadius: 2, style: .continuous)
                        .fill(piece.color)
                        .frame(width: piece.size, height: piece.size * 0.4)
                        .rotationEffect(piece.rotation)
                        .position(x: piece.x * proxy.size.width, y: piece.fallen ? proxy.size.height + 40 : -40)
                        .opacity(piece.fallen ? 0 : 1)
                        .animation(
                            .easeIn(duration: piece.duration).delay(piece.delay),
                            value: piece.fallen
                        )
                }
            }
            .onAppear {
                pieces = (0..<pieceCount).map { _ in
                    ConfettiPiece(
                        x: Double.random(in: 0...1),
                        size: CGFloat.random(in: 6...12),
                        color: colors.randomElement() ?? GitTheme.purple,
                        rotation: .degrees(Double.random(in: 0...360)),
                        duration: Double.random(in: 1.4...2.4),
                        delay: Double.random(in: 0...0.4)
                    )
                }
                for index in pieces.indices {
                    pieces[index].fallen = true
                }
            }
        }
        .allowsHitTesting(false)
    }
}

private struct ConfettiPiece: Identifiable {
    let id = UUID()
    let x: Double
    let size: CGFloat
    let color: Color
    let rotation: Angle
    let duration: Double
    let delay: Double
    var fallen: Bool = false
}

#Preview("Confetti") {
    ZStack {
        Theme.Colors.background.ignoresSafeArea()
        ConfettiView()
    }
}
