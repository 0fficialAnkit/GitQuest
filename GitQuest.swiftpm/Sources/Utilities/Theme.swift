//
//  Theme.swift
//  GitQuest
//
//  Created by Ankit Kumar on 04/02/26.
//

import SwiftUI

/// Centralised design-system tokens for GitQuest.
///
/// Every view should reference `Theme.Colors`, `Theme.Typography`, etc.
/// instead of hard-coding values, keeping the visual language consistent.
enum Theme {
    
    // MARK: - Colors
    
    /// Semantic colour palette that adapts automatically to light / dark mode.
    enum Colors {
        
        // MARK: Surfaces & Backgrounds
        
        /// Primary screen background.
        static let background = Color(uiColor: .systemBackground)
        
        /// Secondary-level background (cards, grouped sections).
        static let secondaryBackground = Color(uiColor: .secondarySystemBackground)
        
        /// Grouped-content background (e.g. settings-style lists).
        static let groupedBackground = Color(uiColor: .systemGroupedBackground)
        
        /// Card / elevated surface fill.
        static let surface = Color(uiColor: .secondarySystemBackground)
        
        /// Highest-elevation surface (modals, popovers).
        static let elevatedSurface = Color(uiColor: .tertiarySystemBackground)
        
        /// Thin separators and borders.
        static let border = Color(uiColor: .separator)
        
        // MARK: Brand
        
        /// Primary brand colour used for CTAs and key accents.
        static let primary = Color.purple
        
        /// Secondary brand colour for gradients and supporting accents.
        static let secondary = Color.blue
        
        /// Strong accent colour for high-contrast elements.
        static let accent = Color.black
        
        // MARK: Semantic
        
        /// Positive / success state.
        static let success = Color.green
        
        /// Error / destructive state.
        static let error = Color.red
        
        /// Warning / caution state.
        static let warning = Color.yellow
        
        /// Informational accent.
        static let info = Color.blue
        
        // MARK: Text
        
        /// Highest-contrast body text.
        static let textPrimary = Color.primary
        
        /// Muted secondary text (subtitles, descriptions).
        static let textSecondary = Color.secondary
        
        /// Lowest-contrast tertiary text (timestamps, labels).
        static let textTertiary = Color(uiColor: .tertiaryLabel)
        
        // MARK: Concept Colors
        
        /// Returns the accent colour associated with a given `GitConcept`.
        static func conceptColor(_ concept: GitConcept) -> Color {
            switch concept {
            case .repository:    return .purple
            case .staging:       return .blue
            case .branching:     return .green
            case .merging:       return .orange
            case .remote:        return .cyan
            case .collaboration: return .pink
            case .conflicts:     return .red
            case .history:       return .red
            case .advanced:      return .yellow
            @unknown default:    return .gray
            }
        }
    }
    
    // MARK: - Typography
    
    /// Pre-configured `Font` tokens for consistent type hierarchy.
    enum Typography {
        
        // MARK: Display
        
        /// Extra-large display font (welcome screen title).
        static let hero = Font.system(size: 100, weight: .bold, design: .rounded)
        
        /// Section title (level selection header).
        static let title = Font.system(size: 50, weight: .bold, design: .rounded)
        
        // MARK: Headings
        
        /// Heading level 1.
        static let h1 = Font.system(size: 32, weight: .bold, design: .rounded)
        
        /// Heading level 2.
        static let h2 = Font.system(size: 24, weight: .semibold, design: .rounded)
        
        /// Heading level 3.
        static let h3 = Font.system(size: 20, weight: .semibold, design: .rounded)
        
        // MARK: Body
        
        /// Default body text.
        static let body = Font.system(size: 16, weight: .regular)
        
        /// Emphasised body text.
        static let bodyBold = Font.system(size: 16, weight: .semibold)
        
        /// Small caption / metadata text.
        static let caption = Font.system(size: 14, weight: .regular)
        
        /// Smallest informational text.
        static let small = Font.system(size: 12, weight: .regular)
        
        // MARK: Code
        
        /// Inline code snippets.
        static let code = Font.system(size: 14, design: .monospaced)
        
        /// Terminal / console output.
        static let terminal = Font.system(size: 13, design: .monospaced)
    }
    
    // MARK: - Spacing
    
    /// 4-pt grid spacing tokens used throughout the UI.
    enum Spacing {
        static let xs:  CGFloat = 4
        static let sm:  CGFloat = 8
        static let md:  CGFloat = 16
        static let lg:  CGFloat = 24
        static let xl:  CGFloat = 32
        static let xxl: CGFloat = 48
    }
    
    // MARK: - Shadow
    
    /// Pre-defined shadow colours (use with `.shadow(color:radius:x:y:)`).
    enum Shadow {
        /// Subtle shadow for flat cards.
        static let light = Color.black.opacity(0.1)
        
        /// Medium shadow for raised surfaces.
        static let medium = Color.black.opacity(0.2)
        
        /// Heavy shadow for modals / popovers.
        static let heavy = Color.black.opacity(0.3)
        
        /// Tinted shadow derived from an arbitrary colour.
        static func colored(_ color: Color, opacity: Double = 0.5) -> Color {
            color.opacity(opacity)
        }
    }
}
