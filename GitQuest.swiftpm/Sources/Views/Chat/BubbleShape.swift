import SwiftUI


// MARK: - Custom Bubble Shape

/// A customizable shape used for chat bubbles, adapting corner radii to create a visual "tail".
struct BubbleShape: Shape {
    let isCurrentUser: Bool
    let isLastInGroup: Bool

    func path(in rect: CGRect) -> Path {
        let radius: CGFloat = 20
        let tailRadius: CGFloat = isLastInGroup ? 6 : radius
        var path = Path()
        if isCurrentUser {
            path.addRoundedRect(
                in: rect,
                cornerRadii: RectangleCornerRadii(
                    topLeading: radius,
                    bottomLeading: radius,
                    bottomTrailing: tailRadius,
                    topTrailing: radius
                )
            )
        } else {
            path.addRoundedRect(
                in: rect,
                cornerRadii: RectangleCornerRadii(
                    topLeading: radius,
                    bottomLeading: tailRadius,
                    bottomTrailing: radius,
                    topTrailing: radius
                )
            )
        }
        return path
    }
}

#Preview {
    VStack(spacing: 20) {
        Text("Hello!")
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(BubbleShape(isCurrentUser: true, isLastInGroup: true).fill(Theme.Colors.secondary))
            .foregroundColor(.white)
        Text("Hi there!")
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(BubbleShape(isCurrentUser: false, isLastInGroup: true).fill(Color(.systemGray6)))
    }
    .padding()
    .preferredColorScheme(.dark)
}
