//
//  BubbleShape.swift
//  GitQuest
//
//  Custom chat-bubble shape with an optional tail
//

import SwiftUI

// MARK: - Bubble Shape

/// A rounded-rectangle path with an optional triangular "tail"
/// that mimics the Apple Messages bubble aesthetic.
///
/// - `isCurrentUser` controls which side the tail appears on.
/// - `isLastInGroup` determines whether the tail is drawn at all.
struct BubbleShape: Shape {
    /// `true` when the message belongs to the player (tail on trailing edge).
    let isCurrentUser: Bool
    
    /// `true` for the final bubble in a consecutive sender group (shows the tail).
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
            .background(BubbleShape(isCurrentUser: true, isLastInGroup: true).fill(Color(red: 0.0, green: 0.48, blue: 1.0)))
            .foregroundColor(.white)
        
        Text("Hi there!")
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(BubbleShape(isCurrentUser: false, isLastInGroup: true).fill(Color(.systemGray6)))
    }
    .padding()
}
