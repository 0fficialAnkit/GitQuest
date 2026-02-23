import Foundation
import SwiftUI

// MARK: - Chat Message Model

/// Represents a single message within the story/chat interface in a level.
struct ChatMessage: Identifiable, Hashable {
    let id = UUID()
    let sender: Sender
    let text: String
    var timestamp: Date

    init(sender: Sender, text: String, timestamp: Date = Date()) {
        self.sender = sender
        self.text = text
        self.timestamp = timestamp
    }

    /// Returns a new instance of the message with the timestamp updated to the current time.
    /// Useful for staggering incoming message animations.
    func withCurrentTimestamp() -> ChatMessage {
        ChatMessage(sender: sender, text: text, timestamp: Date())
    }
}

// MARK: - Sender Model

/// Defines the possible senders in the game's chat interface and their associated styling.
enum Sender: String, Hashable {
    case siddharth
    case amrit
    case sumit
    case you

    // MARK: - Properties

    /// The human-readable name of the sender.
    var displayName: String {
        switch self {
        case .siddharth: return "Siddharth"
        case .amrit: return "Amrit"
        case .sumit: return "Sumit"
        case .you: return "You"
        }
    }

    /// A 1-character string used as the fallback initial for the avatar.
    var avatarInitial: String {
        String(displayName.prefix(1))
    }

    /// Convenience check for whether this sender represents the player.
    var isCurrentUser: Bool {
        self == .you
    }

    // MARK: - Styling Properties

    /// The background color for the chat bubble.
    var bubbleColor: Color {
        switch self {
        case .siddharth, .amrit, .sumit: return Theme.Colors.headerBackground
        case .you: return Theme.Colors.secondary
        }
    }

    /// The text color inside the chat bubble.
    var textColor: Color {
        switch self {
        case .siddharth, .amrit, .sumit: return .white.opacity(0.9)
        case .you: return .white
        }
    }

    /// The background color for the sender's avatar circle.
    var avatarColor: Color {
        switch self {
        case .siddharth: return Theme.Colors.primary
        case .amrit: return Theme.Colors.secondary
        case .sumit: return Theme.Colors.success
        case .you: return Theme.Colors.secondary
        }
    }
}
