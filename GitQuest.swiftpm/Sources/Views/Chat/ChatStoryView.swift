import SwiftUI


// MARK: - Chat Story View

/// A scrolling chat interface that displays story messages to set the context for each level.
struct ChatStoryView: View {
    let messages: [ChatMessage]
    var resetId: UUID = UUID()

    @State private var animatedMessageIDs: Set<UUID> = []
    @State private var suppressBottomScroll = false

    private let chatBg = Theme.Colors.cardBackground

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            statusHeader
            Divider().background(Color.white.opacity(0.06))
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(messages) { message in
                            let index = messageIndex(for: message)
                            ChatBubble(
                                message: message,
                                showSenderName: shouldShowSenderName(at: index),
                                isLastInGroup: isLastMessageInGroup(at: index)
                            )
                            .id(message.id)
                            .opacity(animatedMessageIDs.contains(message.id) ? 1.0 : 0.0)
                            .offset(y: animatedMessageIDs.contains(message.id) ? 0 : 8)
                            .onAppear {
                                withAnimation(.easeOut(duration: 0.35)) {
                                    _ = animatedMessageIDs.insert(message.id)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 14)
                }
                .scrollIndicators(.hidden)
                .onAppear {
                    suppressBottomScroll = true
                    scrollToTop(proxy: proxy)
                    Task { @MainActor in
                        try? await Task.sleep(for: .seconds(0.4))
                        suppressBottomScroll = false
                    }
                }
                .onChange(of: resetId) { _, _ in
                    suppressBottomScroll = true
                    animatedMessageIDs = Set(messages.map(\.id))
                    Task { @MainActor in
                        try? await Task.sleep(for: .seconds(0.05))
                        scrollToTop(proxy: proxy)
                    }
                    Task { @MainActor in
                        try? await Task.sleep(for: .seconds(0.4))
                        suppressBottomScroll = false
                    }
                }
                .onChange(of: messages.count) { oldCount, newCount in
                    if oldCount > 0 && (newCount < oldCount || abs(newCount - oldCount) > 2) {
                        animatedMessageIDs = Set(messages.map(\.id))
                        suppressBottomScroll = true
                        Task { @MainActor in
                            try? await Task.sleep(for: .seconds(0.1))
                            if let first = messages.first {
                                withAnimation(.easeOut(duration: 0.3)) {
                                    proxy.scrollTo(first.id, anchor: .top)
                                }
                            }
                            try? await Task.sleep(for: .seconds(0.3))
                            suppressBottomScroll = false
                        }
                    } else if newCount > oldCount && !suppressBottomScroll {
                        Task { @MainActor in
                            try? await Task.sleep(for: .seconds(0.15))
                            scrollToBottom(proxy: proxy)
                        }
                    }
                }
            }
        }
        .background(RoundedRectangle(cornerRadius: 20).fill(chatBg))
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }

    // MARK: - Subcomponents

    /// The top header indicating the "Team Chat" status.
    private var statusHeader: some View {
        HStack(spacing: 8) {
            Image(systemName: "bubble.left.and.bubble.right.fill")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(Theme.Colors.primary)
            Text("Team Chat")
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(.white)
            Spacer()
            HStack(spacing: 5) {
                Circle()
                    .fill(Theme.Colors.success)
                    .frame(width: 7, height: 7)
                Text("Active")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(Theme.Colors.success)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Theme.Colors.headerBackground)
    }

    // MARK: - Message Helpers

    private func messageIndex(for message: ChatMessage) -> Int {
        messages.firstIndex(where: { $0.id == message.id }) ?? 0
    }

    private func shouldShowSenderName(at index: Int) -> Bool {
        guard index > 0 else { return true }
        return messages[index].sender != messages[index - 1].sender
    }

    private func isLastMessageInGroup(at index: Int) -> Bool {
        guard index < messages.count - 1 else { return true }
        return messages[index].sender != messages[index + 1].sender
    }

    private func scrollToBottom(proxy: ScrollViewProxy) {
        if let last = messages.last {
            withAnimation(.easeOut(duration: 0.3)) {
                proxy.scrollTo(last.id, anchor: .bottom)
            }
        }
    }

    private func scrollToTop(proxy: ScrollViewProxy) {
        if let first = messages.first {
            withAnimation(.easeOut(duration: 0.3)) {
                proxy.scrollTo(first.id, anchor: .top)
            }
        }
    }
}


#Preview {
    ChatStoryView(
        messages: [
            ChatMessage(sender: .siddharth, text: "Hey! Welcome to GitQuest Labs 🎉"),
            ChatMessage(sender: .siddharth, text: "Can you set up the new repo?"),
            ChatMessage(sender: .you, text: "Sure, on it!"),
            ChatMessage(sender: .amrit, text: "Let me know if you need help 👍")
        ]
    )
    .frame(height: 400)
    .padding()
    .background(Theme.Colors.background)
    .preferredColorScheme(.dark)
}
