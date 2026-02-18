//
//  ChatMessage.swift
//  GitQuest
//
//  Chat message model and sender definitions
//

import Foundation
import SwiftUI

// MARK: - Chat Message

/// A single message displayed in the in-game chat feed.
///
/// Each message has a `sender`, body `text`, and `timestamp`.
/// The struct conforms to `Identifiable` for use in `ForEach` lists
/// and to `Hashable` for potential use as a navigation value.
struct ChatMessage: Identifiable, Hashable {
    let id = UUID()
    let sender: Sender
    let text: String
    let timestamp: Date
    
    init(sender: Sender, text: String, timestamp: Date = Date()) {
        self.sender = sender
        self.text = text
        self.timestamp = timestamp
    }
}

// MARK: - Sender

/// The character who sent a chat message.
///
/// Each case carries styling metadata (bubble colour, text colour, alignment)
/// so that `ChatBubble` can render appropriately without switch-casing itself.
enum Sender: String, Hashable, CaseIterable {
    case maya
    case jordan
    case alex
    case you
    
    // MARK: - Display
    
    /// Human-readable name shown above message groups.
    var displayName: String {
        switch self {
        case .maya:   return "Maya"
        case .jordan: return "Jordan"
        case .alex:   return "Alex"
        case .you:    return "You"
        }
    }
    
    /// Single-character initial used inside the avatar circle.
    var avatarInitial: String {
        String(displayName.prefix(1))
    }
    
    /// Whether this sender represents the current player.
    var isCurrentUser: Bool {
        self == .you
    }
    
    // MARK: - Bubble Styling
    
    /// Background colour of the chat bubble.
    var bubbleColor: Color {
        switch self {
        case .maya, .jordan, .alex: return Color(red: 0.20, green: 0.20, blue: 0.22)
        case .you:                  return Color(red: 0.0, green: 0.48, blue: 1.0)
        }
    }
    
    /// Foreground text colour inside the bubble.
    var textColor: Color {
        switch self {
        case .maya, .jordan, .alex: return .white.opacity(0.9)
        case .you:                  return .white
        }
    }
    
    /// Horizontal alignment (leading for teammates, trailing for player).
    var alignment: HorizontalAlignment {
        switch self {
        case .maya, .jordan, .alex: return .leading
        case .you:                  return .trailing
        }
    }
    
    // MARK: - Avatar Styling
    
    /// Colour of the circular avatar badge.
    var avatarColor: Color {
        switch self {
        case .maya:   return .purple
        case .jordan: return .blue
        case .alex:   return .green
        case .you:    return Color(red: 0.0, green: 0.48, blue: 1.0)
        }
    }
}
