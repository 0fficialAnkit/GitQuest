import SwiftUI


// MARK: - Chat Bubble View

/// Renders a single message bubble for the simulated team chat.
struct ChatBubble: View {
    let message: ChatMessage
    let showSenderName: Bool
    let isLastInGroup: Bool

    private var isCurrentUser: Bool {
        message.sender.isCurrentUser
    }

    var body: some View {
        VStack(alignment: isCurrentUser ? .trailing : .leading, spacing: 2) {
            if showSenderName && !isCurrentUser {
                senderHeader
            }
            bubbleRow
        }
        .frame(maxWidth: .infinity, alignment: isCurrentUser ? .trailing : .leading)
        .padding(.bottom, isLastInGroup ? 10 : 2)
    }

    // MARK: - Subcomponents

    private var senderHeader: some View {
        Text(message.sender.displayName)
            .font(.system(size: 12, weight: .semibold))
            .foregroundStyle(.white.opacity(0.45))
            .padding(.leading, isLastInGroup ? 40 : 12)
            .padding(.bottom, 2)
    }

    private var bubbleRow: some View {
        HStack(alignment: .bottom, spacing: 6) {
            if isCurrentUser {
                Spacer(minLength: 60)
                bubbleContent
            } else {
                avatarOrSpacer
                bubbleContent
                Spacer(minLength: 60)
            }
        }
    }

    private var avatarOrSpacer: some View {
        Group {
            if isLastInGroup {
                Circle()
                    .fill(message.sender.avatarColor.opacity(0.7))
                    .frame(width: 28, height: 28)
                    .overlay(
                        Text(message.sender.avatarInitial)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(.white)
                    )
            } else {
                Color.clear
                    .frame(width: 28, height: 28)
            }
        }
    }

    private var bubbleContent: some View {
        VStack(alignment: isCurrentUser ? .trailing : .leading, spacing: 3) {
            Text(message.text)
                .font(.system(size: 16))
                .foregroundStyle(message.sender.textColor)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(
                    BubbleShape(isCurrentUser: isCurrentUser, isLastInGroup: isLastInGroup)
                        .fill(message.sender.bubbleColor)
                )
            if isLastInGroup {
                Text(formatTime(message.timestamp))
                    .font(.system(size: 11))
                    .foregroundStyle(.white.opacity(0.3))
                    .padding(.horizontal, 4)
            }
        }
    }

    // MARK: - Helpers

    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: date)
    }
}

#Preview {
    VStack(spacing: 0) {
        ChatBubble(
            message: ChatMessage(sender: .siddharth, text: "Hey! Welcome to the team 🎉"),
            showSenderName: true,
            isLastInGroup: false
        )
        ChatBubble(
            message: ChatMessage(sender: .siddharth, text: "Ready to set up the repo?"),
            showSenderName: false,
            isLastInGroup: true
        )
        ChatBubble(
            message: ChatMessage(sender: .you, text: "Sure, on it!"),
            showSenderName: false,
            isLastInGroup: true
        )
    }
    .padding()
    .background(Theme.Colors.background)
    .preferredColorScheme(.dark)
}
