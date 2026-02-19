//
//  Extensions.swift
//  GitQuest
//
//  Created by Ankit Kumar on 04/02/26.
//

import SwiftUI

// MARK: - View Extensions

extension View {
    
    /// Wraps the view in a rounded card with a thin-material background and
    /// a medium drop-shadow. Use this for dashboard-style content tiles.
    ///
    /// - Parameter padding: Inset applied inside the card. Defaults to `Theme.Spacing.md`.
    func cardStyle(padding: CGFloat = Theme.Spacing.md) -> some View {
        self
            .padding(padding)
            .background(
                RoundedRectangle(cornerRadius: Constants.Layout.cornerRadius)
                    .fill(.ultraThinMaterial)
            )
            .shadow(color: Theme.Shadow.medium, radius: 10, y: 5)
    }
    
    /// Applies a frosted-glass (glassmorphism) background with a subtle white
    /// border stroke, commonly seen on overlay cards and modals.
    func glassMorphism() -> some View {
        self
            .background(
                RoundedRectangle(cornerRadius: Constants.Layout.cornerRadius)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: Constants.Layout.cornerRadius)
                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    )
            )
    }
    
}
