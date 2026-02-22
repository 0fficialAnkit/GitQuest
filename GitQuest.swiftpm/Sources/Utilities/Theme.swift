import SwiftUI

// MARK: - Theme

/// App-wide colors, typography, spacing, and layout constants. Use for consistent UI across all screens.
enum Theme {
    enum Colors {
        static let background = Color(red: 0.07, green: 0.07, blue: 0.09)
        static let cardBackground = Color(red: 0.12, green: 0.12, blue: 0.14)
        static let headerBackground = Color(red: 0.10, green: 0.10, blue: 0.12)
        static let terminalBackground = Color(red: 0.08, green: 0.08, blue: 0.10)
        
        static let primary = Color.purple
        static let secondary = Color.blue
        static let success = Color.green
        static let warning = Color.yellow
        static let textPrimary = Color.white
        static let textSecondary = Color.white.opacity(0.6)
        static let textTertiary = Color.white.opacity(0.3)

        static func conceptColor(_ concept: GitConcept) -> Color {
            switch concept {
            case .repository: return GitTheme.purple
            case .staging: return GitTheme.blue
            case .branching: return GitTheme.green
            case .merging: return GitTheme.orange
            case .remote: return GitTheme.cyan
            case .collaboration: return GitTheme.pink
            case .conflicts: return GitTheme.red
            case .history: return GitTheme.red
            case .advanced: return GitTheme.yellow
            @unknown default: return GitTheme.gray
            }
        }
    }

    enum Typography {
        static let hero = Font.system(size: 100, weight: .bold)
        static let title = Font.system(size: 50, weight: .bold)
        static let h3 = Font.system(size: 20, weight: .semibold)
        static let body = Font.system(size: 16, weight: .regular)
        static let bodyBold = Font.system(size: 16, weight: .semibold)
        static let caption = Font.system(size: 14, weight: .regular)
        static let small = Font.system(size: 12, weight: .regular)
    }

    enum Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 16
        static let lg: CGFloat = 24
        static let xl: CGFloat = 32
        static let xxl: CGFloat = 48
    }

    enum Layout {
        static let buttonHeight: CGFloat = 56
    }
}

/// Git-specific colors for the graph visualizer and repo card (commits, branches, remote, etc.).
enum GitTheme {
    static let orange = Color(red: 0.96, green: 0.58, blue: 0.12)
    static let green = Color(red: 0.24, green: 0.72, blue: 0.39)
    static let blue = Color(red: 0.18, green: 0.50, blue: 0.93)
    static let purple = Color(red: 0.56, green: 0.27, blue: 0.68)
    static let cyan = Color(red: 0.20, green: 0.67, blue: 0.86)
    static let yellow = Color(red: 0.90, green: 0.72, blue: 0.15)
    static let gray = Color(red: 0.55, green: 0.55, blue: 0.57)
    static let red = Color(red: 0.86, green: 0.24, blue: 0.24)
    static let pink = Color(red: 0.90, green: 0.30, blue: 0.60)
    static let darkBackground = Color(red: 0.11, green: 0.12, blue: 0.14)
}
