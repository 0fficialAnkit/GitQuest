//
//  GameTips.swift
//  GitQuest
//
//  TipKit-based onboarding tips for the game screen.
//  Uses Apple's native TipKit framework for contextual help.
//

import SwiftUI
import TipKit

// MARK: - Tip Definitions

struct ChatTip: Tip {
    @Parameter
    static var isActive: Bool = false
    
    var title: Text {
        Text("Your Mission Briefing")
            .foregroundStyle(.white)
    }
    
    var message: Text? {
        Text("Welcome to Pixel Labs! Your teammates Maya, Jordan, and Alex are waiting. Read this chat — it's your mission briefing for what the team needs right now.")
            .foregroundStyle(.white.opacity(0.85))
    }
    
    var image: Image? {
        Image(systemName: "bubble.left.and.bubble.right.fill")
    }
    
    var actions: [Action] {
        [
            Action(id: "next", title: "Next →")
        ]
    }
    
    var rules: [Rule] {
        [
            #Rule(Self.$isActive) {
                $0 == true
            }
        ]
    }
    
    var options: [TipOption] {
        [
            Tips.MaxDisplayCount(1)
        ]
    }
}

struct ChatStoryTip: Tip {
    @Parameter
    static var isActive: Bool = false
    
    var title: Text {
        Text("Story Unfolds With You")
            .foregroundStyle(.white)
    }
    
    var message: Text? {
        Text("After every command you complete, your teammates react in real time. New messages appear here — you're solving a real team problem, not just running commands.")
            .foregroundStyle(.white.opacity(0.85))
    }
    
    var image: Image? {
        Image(systemName: "text.bubble.fill")
    }
    
    var actions: [Action] {
        [
            Action(id: "back", title: "← Back"),
            Action(id: "next", title: "Next →")
        ]
    }
    
    var rules: [Rule] {
        [
            #Rule(Self.$isActive) {
                $0 == true
            }
        ]
    }
    
    var options: [TipOption] {
        [
            Tips.MaxDisplayCount(1)
        ]
    }
}

struct ConceptTip: Tip {
    @Parameter
    static var isActive: Bool = false
    
    var title: Text {
        Text("Decode Every Word")
            .foregroundStyle(.white)
    }
    
    var message: Text? {
        Text("Before typing anything, study this card. It explains every single word — what 'git', 'commit', '-m', and the message each mean. Understanding beats memorizing.")
            .foregroundStyle(.white.opacity(0.85))
    }
    
    var image: Image? {
        Image(systemName: "book.closed.fill")
    }
    
    var actions: [Action] {
        [
            Action(id: "back", title: "← Back"),
            Action(id: "next", title: "Next →")
        ]
    }
    
    var rules: [Rule] {
        [
            #Rule(Self.$isActive) {
                $0 == true
            }
        ]
    }
    
    var options: [TipOption] {
        [
            Tips.MaxDisplayCount(1)
        ]
    }
}

struct ConsoleTip: Tip {
    @Parameter
    static var isActive: Bool = false
    
    var title: Text {
        Text("Your Real Terminal")
            .foregroundStyle(.white)
    }
    
    var message: Text? {
        Text("Type Git commands here just like a real developer. Tap any hint chip to auto-fill the command, then hit ↵ to run it. The output mirrors a real terminal exactly.")
            .foregroundStyle(.white.opacity(0.85))
    }
    
    var image: Image? {
        Image(systemName: "terminal.fill")
    }
    
    var actions: [Action] {
        [
            Action(id: "back", title: "← Back"),
            Action(id: "next", title: "Next →")
        ]
    }
    
    var rules: [Rule] {
        [
            #Rule(Self.$isActive) {
                $0 == true
            }
        ]
    }
    
    var options: [TipOption] {
        [
            Tips.MaxDisplayCount(1)
        ]
    }
}

struct VisualizerTip: Tip {
    @Parameter
    static var isActive: Bool = false
    
    var title: Text {
        Text("Live Git Graph")
            .foregroundStyle(.white)
    }
    
    var message: Text? {
        Text("Every commit appears as a coloured circle. Branches are separate rows. The green HEAD badge marks where you are in history. Tap any node to inspect it.")
            .foregroundStyle(.white.opacity(0.85))
    }
    
    var image: Image? {
        Image(systemName: "point.3.connected.trianglepath.dotted")
    }
    
    var actions: [Action] {
        [
            Action(id: "back", title: "← Back"),
            Action(id: "next", title: "Next →")
        ]
    }
    
    var rules: [Rule] {
        [
            #Rule(Self.$isActive) {
                $0 == true
            }
        ]
    }
    
    var options: [TipOption] {
        [
            Tips.MaxDisplayCount(1)
        ]
    }
}

struct RepoStateTip: Tip {
    @Parameter
    static var isActive: Bool = false
    
    var title: Text {
        Text("Repository Status")
            .foregroundStyle(.white)
    }
    
    var message: Text? {
        Text("Your repo's live dashboard — current branch, total commits, staged files, and remote connection. Each row flashes when it changes so you always know what just happened.")
            .foregroundStyle(.white.opacity(0.85))
    }
    
    var image: Image? {
        Image(systemName: "chart.bar.doc.horizontal.fill")
    }
    
    var actions: [Action] {
        [
            Action(id: "back", title: "← Back"),
            Action(id: "done", title: "Let's Go! 🚀")
        ]
    }
    
    var rules: [Rule] {
        [
            #Rule(Self.$isActive) {
                $0 == true
            }
        ]
    }
    
    var options: [TipOption] {
        [
            Tips.MaxDisplayCount(1)
        ]
    }
}

// MARK: - Tip Orchestrator
// MARK: - Tip Orchestrator

@Observable
@MainActor
class GameTipsOrchestrator {
    static let shared = GameTipsOrchestrator()
    
    var currentTipIndex = 0
    var showingTips = false
    
    let chatTip = ChatTip()
    let chatStoryTip = ChatStoryTip()
    let conceptTip = ConceptTip()
    let consoleTip = ConsoleTip()
    let visualizerTip = VisualizerTip()
    let repoStateTip = RepoStateTip()
    
    private var allTips: [any Tip] {
        [chatTip, chatStoryTip, conceptTip, consoleTip, visualizerTip, repoStateTip]
    }
    
    private static let hasShownTipsKey = "hasShownGameTips"
    
    func shouldShowTips() -> Bool {
        !UserDefaults.standard.bool(forKey: Self.hasShownTipsKey)
    }
    
    func startTipSequence() {
        guard shouldShowTips() else { return }
        
        // Reset and activate first tip
        Task {
            try? await Tips.resetDatastore()
            await MainActor.run {
                currentTipIndex = 0
                showingTips = true
                activateTip(at: 0)
            }
        }
        
        UserDefaults.standard.set(true, forKey: Self.hasShownTipsKey)
    }
    
    func handleAction(_ action: Tip.Action, for tipIndex: Int) {
        switch action.id {
        case "next":
            if tipIndex < allTips.count - 1 {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    deactivateTip(at: tipIndex)
                    currentTipIndex = tipIndex + 1
                    Task { @MainActor in
                        try? await Task.sleep(for: .seconds(0.1))
                        self.activateTip(at: tipIndex + 1)
                    }
                }
            }
        case "back":
            if tipIndex > 0 {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    deactivateTip(at: tipIndex)
                    currentTipIndex = tipIndex - 1
                    Task { @MainActor in
                        try? await Task.sleep(for: .seconds(0.1))
                        self.activateTip(at: tipIndex - 1)
                    }
                }
            }
        case "done":
            completeTipSequence()
        default:
            break
        }
    }
    
    func completeTipSequence() {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
            showingTips = false
        }
        deactivateAllTips()
    }
    
    private func activateTip(at index: Int) {
        switch index {
        case 0: ChatTip.isActive = true
        case 1: ChatStoryTip.isActive = true
        case 2: ConceptTip.isActive = true
        case 3: ConsoleTip.isActive = true
        case 4: VisualizerTip.isActive = true
        case 5: RepoStateTip.isActive = true
        default: break
        }
    }
    
    private func deactivateTip(at index: Int) {
        switch index {
        case 0: ChatTip.isActive = false
        case 1: ChatStoryTip.isActive = false
        case 2: ConceptTip.isActive = false
        case 3: ConsoleTip.isActive = false
        case 4: VisualizerTip.isActive = false
        case 5: RepoStateTip.isActive = false
        default: break
        }
        allTips[index].invalidate(reason: .actionPerformed)
    }
    
    private func deactivateAllTips() {
        ChatTip.isActive = false
        ChatStoryTip.isActive = false
        ConceptTip.isActive = false
        ConsoleTip.isActive = false
        VisualizerTip.isActive = false
        RepoStateTip.isActive = false
        
        for tip in allTips {
            tip.invalidate(reason: .actionPerformed)
        }
    }
    
    func resetTips() {
        UserDefaults.standard.removeObject(forKey: Self.hasShownTipsKey)
        Task {
            try? Tips.resetDatastore()
        }
    }
}

// MARK: - Tip Styling

struct GameTipStyle: TipViewStyle {
    func makeBody(configuration: Configuration) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            headerView(configuration: configuration)
            
            if !configuration.actions.isEmpty {
                actionsView(configuration: configuration)
            }
        }
        .padding(16)
        .background(backgroundView)
        .padding(.horizontal, 16)
    }
    
    @ViewBuilder
    private func headerView(configuration: Configuration) -> some View {
        HStack(alignment: .top, spacing: 12) {
            if let image = configuration.image {
                iconView(image: image)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                configuration.title
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                
                if let message = configuration.message {
                    message
                        .font(.system(size: 13, weight: .regular, design: .rounded))
                        .lineSpacing(3)
                }
            }
        }
    }
    
    private func iconView(image: Image) -> some View {
        image
            .font(.system(size: 24))
            .foregroundStyle(Color.white.opacity(0.8))
            .frame(width: 40, height: 40)
            .background(Circle().fill(Color.white.opacity(0.08)))
    }
    
    @ViewBuilder
    private func actionsView(configuration: Configuration) -> some View {
        HStack(spacing: 10) {
            ForEach(configuration.actions) { action in
                Button {
                    action.handler()
                } label: {
                    actionButtonLabel(action: action)
                }
            }
        }
    }
    
    private func actionButtonLabel(action: Tip.Action) -> some View {
        let isPrimary = action.id == "next" || action.id == "done"
        
        return action.label()
            .font(.system(size: 13, weight: .semibold, design: .rounded))
            .foregroundStyle(isPrimary ? Color.black : Color.white.opacity(0.6))
            .frame(maxWidth: .infinity)
            .frame(height: 42)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(isPrimary ? Color.white : Color.white.opacity(0.08))
            )
    }
    
    private var backgroundView: some View {
        RoundedRectangle(cornerRadius: 16, style: .continuous)
            .fill(
                LinearGradient(
                    colors: [
                        Color(red: 0.14, green: 0.14, blue: 0.18),
                        Color(red: 0.10, green: 0.10, blue: 0.13)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.3), radius: 20, y: 5)
    }
}
