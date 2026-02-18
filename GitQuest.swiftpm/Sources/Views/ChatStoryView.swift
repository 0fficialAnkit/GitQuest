//  ChatStoryView.swift
//  GitQuest
//
//  Scrolling chat feed with typing indicator and auto-scroll
//

import SwiftUI

// MARK: - Chat Story View

/// Dark-themed, auto-scrolling chat panel that displays team messages
/// using `ChatBubble` views. Includes sender grouping, entrance
/// animations, and a typing indicator.
struct ChatStoryView: View {
    
    let messages: [ChatMessage]
    /// Bump this UUID whenever a new level starts to reset scroll position to top.
    var resetId: UUID = UUID()
    var isTyping: Bool = false
    var typingSender: String = "Maya"
    
    @State private var animatedMessageIDs: Set<UUID> = []
    @State private var suppressBottomScroll = false
    
    private let chatBg = Color(red: 0.12, green: 0.12, blue: 0.14)
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // ── HEADER ──
            statusHeader
            
            ScrollViewReader { proxy in
                ScrollView(showsIndicators: false) {
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
                        
                        // Typing indicator
                        if isTyping {
                            TypingDotsView(senderName: typingSender)
                                .padding(.top, 4)
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 14)
                }
                .onAppear {
                    suppressBottomScroll = true
                    scrollToTop(proxy: proxy)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                        suppressBottomScroll = false
                    }
                }
                // Level changed → clear animation state and scroll to top
                .onChange(of: resetId) { _, _ in
                    suppressBottomScroll = true
                    animatedMessageIDs.removeAll()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                        scrollToTop(proxy: proxy)
                    }
                    // Re-enable bottom-scroll after the initial messages settle
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                        suppressBottomScroll = false
                    }
                }
                // New messages appended after a step completes → scroll to bottom
                .onChange(of: messages.count) { oldCount, newCount in
                    guard newCount > oldCount, !suppressBottomScroll else { return }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                        scrollToBottom(proxy: proxy)
                    }
                }
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(chatBg)
        )
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
    
    // MARK: - Header
    
    private var statusHeader: some View {
        HStack(spacing: 8) {
            Image(systemName: "bubble.left.and.bubble.right.fill")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(Color(red: 0.56, green: 0.27, blue: 0.68)) // purple
            
            Text("Team Chat")
                .font(.system(size: 15, weight: .bold, design: .monospaced))
                .foregroundStyle(.white)
            
            Spacer()
            
            HStack(spacing: 5) {
                Circle()
                    .fill(Color(red: 0.24, green: 0.72, blue: 0.39)) // green
                    .frame(width: 7, height: 7)
                
                Text("Active")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(Color(red: 0.24, green: 0.72, blue: 0.39))
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color(red: 0.10, green: 0.10, blue: 0.12))
    }
    
    // MARK: - Helpers
    
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

// MARK: - Typing Indicator

private struct TypingDotsView: View {
    let senderName: String
    
    @State private var activeDot: Int = 0
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 6) {
            Circle()
                .fill(Color.white.opacity(0.15))
                .frame(width: 28, height: 28)
                .overlay(
                    Text(String(senderName.prefix(1)))
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.white.opacity(0.7))
                )
            
            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 5) {
                    dotCircle(index: 0)
                    dotCircle(index: 1)
                    dotCircle(index: 2)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(
                    BubbleShape(isCurrentUser: false, isLastInGroup: true)
                        .fill(Color.white.opacity(0.08))
                )
                
                Text("\(senderName) is typing…")
                    .font(.system(size: 11))
                    .foregroundColor(.white.opacity(0.3))
                    .padding(.leading, 4)
            }
            
            Spacer(minLength: 60)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.bottom, 4)
        .onAppear { animateDots() }
    }
    
    private func dotCircle(index: Int) -> some View {
        Circle()
            .fill(Color.white.opacity(0.3))
            .frame(width: 8, height: 8)
            .scaleEffect(activeDot == index ? 1.15 : 0.85)
            .opacity(activeDot == index ? 1.0 : 0.4)
    }
    
    private func animateDots() {
        withAnimation(.easeInOut(duration: 0.35).repeatForever(autoreverses: false)) {
            activeDot = 1
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            withAnimation(.easeInOut(duration: 0.35).repeatForever(autoreverses: false)) {
                activeDot = 2
            }
        }
    }
}

// MARK: - Preview

#Preview {
    ChatStoryView(
        messages: [
            ChatMessage(sender: .maya, text: "Hey! Welcome to Pixel Labs 🎉"),
            ChatMessage(sender: .maya, text: "Can you set up the new repo?"),
            ChatMessage(sender: .you, text: "Sure, on it!"),
            ChatMessage(sender: .jordan, text: "Let me know if you need help 👍")
        ],
        isTyping: true
    )
    .frame(height: 400)
    .padding()
    .background(Color.black)
    .preferredColorScheme(.dark)
}
