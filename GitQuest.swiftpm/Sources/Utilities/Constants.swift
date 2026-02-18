//
//  Constants.swift
//  GitQuest
//
//  App-wide layout and animation constants
//

import Foundation

// MARK: - Constants

/// Central namespace for app-wide magic numbers and configuration values.
/// Keeps layout dimensions and animation timings in one discoverable location.
enum Constants {
    
    // MARK: - Layout
    
    /// Fixed dimensions used across multiple screens (buttons, corners, icons).
    enum Layout {
        /// Standard height for primary action buttons (e.g. "Start Your Journey").
        static let buttonHeight: CGFloat = 56
        
        /// Default corner radius for cards and buttons.
        static let cornerRadius: CGFloat = 16
        
        /// Standard size for level-node icons on the selection screen.
        static let iconSize: CGFloat = 60
    }
    
    // MARK: - Animation
    
    /// Shared timing curves used for page transitions and element entrances.
    enum Animation {
        /// Duration of a standard screen or element transition.
        static let defaultDuration: Double = 0.3
        
        /// Spring response for bouncy entrance animations.
        static let springResponse: Double = 0.6
        
        /// Damping fraction paired with `springResponse`.
        static let springDamping: Double = 0.7
    }
}
