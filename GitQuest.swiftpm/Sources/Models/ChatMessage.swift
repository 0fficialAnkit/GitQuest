import Foundation
import SwiftUI

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

    func withCurrentTimestamp() -> ChatMessage {
        ChatMessage(sender: sender, text: text, timestamp: Date())
    }
}

enum Sender: String, Hashable, CaseIterable {
    case siddharth
    case amrit
    case sumit
    case you

    var displayName: String {
        switch self {
        case .siddharth: return "Siddharth"
        case .amrit: return "Amrit"
        case .sumit: return "Sumit"
        case .you: return "You"
        }
    }

    var avatarInitial: String {
        String(displayName.prefix(1))
    }

    var isCurrentUser: Bool {
        self == .you
    }

    var bubbleColor: Color {
        switch self {
        case .siddharth, .amrit, .sumit: return Theme.Colors.headerBackground
        case .you: return Theme.Colors.secondary
        }
    }

    var textColor: Color {
        switch self {
        case .siddharth, .amrit, .sumit: return .white.opacity(0.9)
        case .you: return .white
        }
    }

    var alignment: HorizontalAlignment {
        switch self {
        case .siddharth, .amrit, .sumit: return .leading
        case .you: return .trailing
        }
    }

    var avatarColor: Color {
        switch self {
        case .siddharth: return Theme.Colors.primary
        case .amrit: return Theme.Colors.secondary
        case .sumit: return Theme.Colors.success
        case .you: return Theme.Colors.secondary
        }
    }
}
