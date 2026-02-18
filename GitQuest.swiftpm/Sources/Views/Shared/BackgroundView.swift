//
//  BackgroundView.swift
//  GitQuest
//
//  Created by Ankit Kumar on 04/02/26.
//

import SwiftUI

/// Reusable gradient background with optional animation.
///
/// When `animation` is `true`, the gradient endpoints smoothly
/// oscillate, creating a slow "breathing" effect behind content.
struct BackgroundView: View {
    
    /// Gradient stop colours, rendered top-to-bottom.
    let colors: [Color]
    
    /// When `true`, the gradient continuously animates its start / end points.
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

// MARK: - Previews

#Preview("Static Background") {
    BackgroundView(
        colors: [.purple, .blue],
        animation: false
    )
}
