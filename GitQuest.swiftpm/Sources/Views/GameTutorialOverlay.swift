//
//  GameTutorialOverlay.swift
//  GitQuest
//
//  Custom tutorial overlay with spotlight, borders, and positioned tip boxes.
//

import SwiftUI

// MARK: - Tutorial Step

struct TutorialStep {
    let id: Int
    let cardKey: TutorialCardKey
    let title: String
    let message: String
    let tipPosition: TipPosition
    
    enum TipPosition {
        case left, right, top
    }
}

enum TutorialCardKey: String {
    case chat, concept, console, visualizer, repoState
}

// MARK: - All Tutorial Steps

extension TutorialStep {
    static let allSteps: [TutorialStep] = [
        TutorialStep(
            id: 0,
            cardKey: .chat,
            title: "Read Your Mission",
            message: "Your teammates are briefing you on what needs to be done. Read each message carefully to understand your task.",
            tipPosition: .right
        ),
        TutorialStep(
            id: 1,
            cardKey: .concept,
            title: "Understand the Command",
            message: "This card breaks down every word of the Git command you'll use. Study it before typing anything.",
            tipPosition: .left
        ),
        TutorialStep(
            id: 2,
            cardKey: .console,
            title: "Type Commands Here",
            message: "This is your terminal. Type the Git command here or tap a hint chip to auto-fill it. Hit ↵ to execute.",
            tipPosition: .top
        ),
        TutorialStep(
            id: 3,
            cardKey: .visualizer,
            title: "Watch Your Repository",
            message: "Every commit you make appears as a circle here. Branches are rows. The green HEAD shows your current position.",
            tipPosition: .right
        ),
        TutorialStep(
            id: 4,
            cardKey: .repoState,
            title: "Repository Status",
            message: "Live status of your repo: which branch you're on, commits made, files staged, and remote connection.",
            tipPosition: .left
        )
    ]
}

// MARK: - Anchor Preference

struct TutorialCardFrameKey: PreferenceKey {
    typealias Value = [TutorialCardKey: Anchor<CGRect>]
    nonisolated(unsafe) static var defaultValue: Value = [:]
    static func reduce(value: inout Value, nextValue: () -> Value) {
        value.merge(nextValue()) { _, new in new }
    }
}

extension View {
    func tutorialAnchor(_ key: TutorialCardKey) -> some View {
        anchorPreference(key: TutorialCardFrameKey.self, value: .bounds) {
            [key: $0]
        }
    }
}

// MARK: - Tutorial Overlay

struct GameTutorialOverlay: ViewModifier {
    @Binding var isShowing: Bool
    
    @State private var currentStep = 0
    @State private var overlayOpacity: Double = 0
    @State private var tipOpacity: Double = 0
    @State private var tipOffset: CGFloat = 20
    @State private var nextHapticTrigger = false
    @State private var doneHapticTrigger = false
    
    private let steps = TutorialStep.allSteps
    
    func body(content: Content) -> some View {
        content
            .overlayPreferenceValue(TutorialCardFrameKey.self) { anchors in
                if isShowing {
                    GeometryReader { geo in
                        ZStack {
                            // ── DIM OVERLAY with cut-out for active card ──
                            dimOverlay(anchors: anchors, geo: geo)
                                .opacity(overlayOpacity)
                                .allowsHitTesting(false)
                            
                            // ── HIGHLIGHTED BORDER around active card ──
                            if let anchor = anchors[steps[currentStep].cardKey] {
                                highlightBorder(frame: geo[anchor])
                                    .opacity(overlayOpacity)
                                    .allowsHitTesting(false)
                            }
                            
                            // ── TIP BOX ──
                            if let anchor = anchors[steps[currentStep].cardKey] {
                                tipBox(
                                    step: steps[currentStep],
                                    cardFrame: geo[anchor],
                                    geo: geo
                                )
                                .opacity(tipOpacity)
                                .offset(y: tipOffset)
                            }
                        }
                    }
                    .ignoresSafeArea()
                    .sensoryFeedback(.impact(flexibility: .soft), trigger: nextHapticTrigger)
                    .sensoryFeedback(.impact(weight: .medium), trigger: doneHapticTrigger)
                    
                    .onAppear {
                        withAnimation(.easeOut(duration: 0.4)) {
                            overlayOpacity = 1
                        }
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.25)) {
                            tipOpacity = 1
                            tipOffset = 0
                        }
                    }
                }
            }
    }
    
    // MARK: - Dim Overlay
    
    private func dimOverlay(anchors: [TutorialCardKey: Anchor<CGRect>], geo: GeometryProxy) -> some View {
        let activeFrame = anchors[steps[currentStep].cardKey].map { geo[$0] } ?? .zero
        let expandedFrame = activeFrame.insetBy(dx: -8, dy: -8)
        
        return Canvas { ctx, size in
            // Fill entire screen
            ctx.fill(
                Path(CGRect(origin: .zero, size: size)),
                with: .color(.black.opacity(0.75))
            )
            
            // Cut out the active card area
            ctx.blendMode = .destinationOut
            ctx.fill(
                Path(roundedRect: expandedFrame, cornerRadius: 24),
                with: .color(.white)
            )
        }
        .compositingGroup()
        .animation(.spring(response: 0.5, dampingFraction: 0.82), value: currentStep)
    }
    
    // MARK: - Highlight Border
    
    private func highlightBorder(frame: CGRect) -> some View {
        RoundedRectangle(cornerRadius: 24)
            .stroke(
                LinearGradient(
                    colors: [
                        Color.white.opacity(0.8),
                        Color.white.opacity(0.3)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                lineWidth: 2.5
            )
            .frame(width: frame.width + 16, height: frame.height + 16)
            .shadow(color: .white.opacity(0.4), radius: 12)
            .position(x: frame.midX, y: frame.midY)
            .animation(.spring(response: 0.5, dampingFraction: 0.82), value: currentStep)
    }
    
    // MARK: - Tip Box
    
    private func tipBox(step: TutorialStep, cardFrame: CGRect, geo: GeometryProxy) -> some View {
        let boxWidth: CGFloat = 280
        let padding: CGFloat = 16
        
        // Calculate position based on tip position preference
        let position = calculatePosition(
            step: step,
            cardFrame: cardFrame,
            boxWidth: boxWidth,
            geo: geo,
            padding: padding
        )
        
        return VStack(alignment: .leading, spacing: 12) {
            // Title
            Text(step.title)
                .font(.system(size: 17, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
            
            // Message
            Text(step.message)
                .font(.system(size: 14, weight: .regular, design: .rounded))
                .foregroundStyle(.white.opacity(0.85))
                .lineSpacing(4)
                .fixedSize(horizontal: false, vertical: true)
            
            // Progress dots + Next button
            HStack {
                // Dots
                HStack(spacing: 6) {
                    ForEach(0..<steps.count, id: \.self) { i in
                        Circle()
                            .fill(i == currentStep ? Color.white : Color.white.opacity(0.25))
                            .frame(
                                width: i == currentStep ? 8 : 6,
                                height: i == currentStep ? 8 : 6
                            )
                            .animation(.spring(response: 0.3), value: currentStep)
                    }
                }
                
                Spacer()
                
                // Next / Got it button
                Button {
                    handleNext()
                } label: {
                    HStack(spacing: 6) {
                        Text(currentStep == steps.count - 1 ? "Got it! 🚀" : "Next")
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                        if currentStep < steps.count - 1 {
                            Image(systemName: "arrow.right")
                                .font(.system(size: 12, weight: .bold))
                        }
                    }
                    .foregroundStyle(.black)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(
                        Capsule()
                            .fill(.white)
                    )
                }
            }
        }
        .padding(18)
        .frame(width: boxWidth)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
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
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(Color.white.opacity(0.12), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.5), radius: 25, y: 8)
        )
        .position(x: position.x, y: position.y)
        .animation(.spring(response: 0.5, dampingFraction: 0.82), value: currentStep)
    }
    
    // MARK: - Position Calculator
    
    private func calculatePosition(
        step: TutorialStep,
        cardFrame: CGRect,
        boxWidth: CGFloat,
        geo: GeometryProxy,
        padding: CGFloat
    ) -> CGPoint {
        
        let boxHeight: CGFloat = 200 // estimated
        
        switch step.tipPosition {
        case .right:
            // Position to the right of the card
            let x = min(
                cardFrame.maxX + padding + boxWidth / 2,
                geo.size.width - boxWidth / 2 - padding
            )
            let y = cardFrame.midY
            return CGPoint(x: x, y: y)
            
        case .left:
            // Position to the left of the card
            let x = max(
                cardFrame.minX - padding - boxWidth / 2,
                boxWidth / 2 + padding
            )
            let y = cardFrame.midY
            return CGPoint(x: x, y: y)
            
        case .top:
            // Position above the card, centered
            let x = cardFrame.midX
            let y = max(
                cardFrame.minY - padding - boxHeight / 2,
                boxHeight / 2 + padding + 40 // account for safe area
            )
            return CGPoint(x: x, y: y)
        }
    }
    
    // MARK: - Navigation
    
//    private func handleNext() {
////        let haptic = UIImpactFeedbackGenerator(style: .light)
////        haptic.impactOccurred()
//        
//        if currentStep < steps.count - 1 {
//            // Fade out tip
//            withAnimation(.easeIn(duration: 0.15)) {
//                tipOpacity = 0
//                tipOffset = -12
//            }
//            
//            // Move to next step
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.18) {
//                currentStep += 1
//                tipOffset = 20
//                
//                // Fade in new tip
//                withAnimation(.spring(response: 0.45, dampingFraction: 0.8)) {
//                    tipOpacity = 1
//                    tipOffset = 0
//                }
//            }
//        } else {
//            // Dismiss tutorial
////            let haptic2 = UIImpactFeedbackGenerator(style: .medium)
////            haptic2.impactOccurred()
//            
//            withAnimation(.easeOut(duration: 0.3)) {
//                tipOpacity = 0
//                overlayOpacity = 0
//            }
//            
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
//                isShowing = false
//            }
//        }
//    }
    private func handleNext() {

        nextHapticTrigger.toggle()

        if currentStep < steps.count - 1 {

            withAnimation(.easeIn(duration: 0.15)) {
                tipOpacity = 0
                tipOffset = -12
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.18) {
                currentStep += 1
                tipOffset = 20

                withAnimation(.spring(response: 0.45, dampingFraction: 0.8)) {
                    tipOpacity = 1
                    tipOffset = 0
                }
            }

        } else {

            doneHapticTrigger.toggle()

            withAnimation(.easeOut(duration: 0.3)) {
                tipOpacity = 0
                overlayOpacity = 0
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                isShowing = false
            }
        }
    }

}

extension View {
    func gameTutorial(isShowing: Binding<Bool>) -> some View {
        modifier(GameTutorialOverlay(isShowing: isShowing))
    }
}




// // //
// MARK: - Preview Playground

private struct TutorialPreviewScreen: View {

    @State private var showTutorial = true

    var body: some View {
        ZStack {
            // Fake background
            Color(red: 0.08, green: 0.09, blue: 0.12)
                .ignoresSafeArea()

            VStack(spacing: 18) {

                // Chat card
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.blue.opacity(0.25))
                    .frame(height: 120)
                    .overlay(Text("Chat Card").foregroundStyle(.white))
                    .tutorialAnchor(.chat)

                HStack(spacing: 16) {

                    // Concept card
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.purple.opacity(0.25))
                        .frame(height: 120)
                        .overlay(Text("Concept").foregroundStyle(.white))
                        .tutorialAnchor(.concept)

                    // Repo state
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.orange.opacity(0.25))
                        .frame(height: 120)
                        .overlay(Text("Repo State").foregroundStyle(.white))
                        .tutorialAnchor(.repoState)
                }

                // Console
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.green.opacity(0.25))
                    .frame(height: 90)
                    .overlay(Text("Console").foregroundStyle(.white))
                    .tutorialAnchor(.console)

                // Visualizer
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.cyan.opacity(0.25))
                    .frame(height: 160)
                    .overlay(Text("Visualizer").foregroundStyle(.white))
                    .tutorialAnchor(.visualizer)

                Spacer()
            }
            .padding()
        }
        .gameTutorial(isShowing: $showTutorial)
    }
}

#Preview("Tutorial Overlay") {
    TutorialPreviewScreen()
}


