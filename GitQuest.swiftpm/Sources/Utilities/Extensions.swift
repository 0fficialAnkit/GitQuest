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
    
    /// Fires a `UIImpactFeedbackGenerator` haptic on tap.
    ///
    /// - Parameter style: The intensity of the haptic. Defaults to `.medium`.
//    func hapticFeedback(_ style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) -> some View {
//        self.onTapGesture {
//            let generator = UIImpactFeedbackGenerator(style: style)
//            generator.impactOccurred()
//        }
//    }
}

// MARK: - Color Extensions

//extension Color {
//    
//    /// Initialises a `Color` from a hex string.
//    ///
//    /// Supports 3-digit (RGB), 6-digit (RRGGBB), and 8-digit (AARRGGBB) formats.
//    /// Non-alphanumeric characters (e.g. `#`) are automatically stripped.
//    ///
//    /// ```swift
//    /// Color(hex: "#FF5733")
//    /// Color(hex: "3B82F6")
//    /// ```
//    init(hex: String) {
//        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
//        var int: UInt64 = 0
//        Scanner(string: hex).scanHexInt64(&int)
//        let a, r, g, b: UInt64
//        switch hex.count {
//        case 3: // RGB (12-bit)
//            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
//        case 6: // RGB (24-bit)
//            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
//        case 8: // ARGB (32-bit)
//            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
//        default:
//            (a, r, g, b) = (255, 0, 0, 0)
//        }
//        self.init(
//            .sRGB,
//            red: Double(r) / 255,
//            green: Double(g) / 255,
//            blue: Double(b) / 255,
//            opacity: Double(a) / 255
//        )
//    }
//}

// MARK: - String Extensions

//extension String {
//    
//    /// Returns the first double-quoted substring, or `nil` if none is found.
//    ///
//    /// ```swift
//    /// "git commit -m \"Init\"".extractQuoted()  // "Init"
//    /// ```
//    func extractQuoted() -> String? {
//        if let range = self.range(of: "\"([^\"]*)\"", options: .regularExpression) {
//            return String(self[range]).trimmingCharacters(in: CharacterSet(charactersIn: "\""))
//        }
//        return nil
//    }
//}
