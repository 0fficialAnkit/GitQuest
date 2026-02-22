import SwiftUI

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
            message: "This card breaks down every word of the Git command you'll use. Study it before running any command.",
            tipPosition: .left
        ),
        TutorialStep(
            id: 2,
            cardKey: .console,
            title: "Run Commands Here",
            message: "This is your terminal. Tap a hint command to auto-fill it, then hit ↵ to execute.",
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

struct GameTutorialOverlay: ViewModifier {
    @Binding var isShowing: Bool

    @State private var currentStep = 0
    @State private var overlayOpacity: Double = 0
    @State private var tipOpacity: Double = 0
    @State private var tipOffset: CGFloat = 20
    @State private var stepHapticTrigger = false
    @State private var doneHapticTrigger = false
    @State private var floatAnimate = false
    @State private var buttonPressed = false

    private let steps = TutorialStep.allSteps

    func body(content: Content) -> some View {
        content
            .sensoryFeedback(.impact(flexibility: .soft), trigger: stepHapticTrigger)
            .sensoryFeedback(.impact(weight: .medium), trigger: doneHapticTrigger)
            .overlayPreferenceValue(TutorialCardFrameKey.self) { anchors in
                if isShowing {
                    GeometryReader { geo in
                        ZStack {

                            dimOverlay(anchors: anchors, geo: geo)
                                .opacity(overlayOpacity)
                                .allowsHitTesting(false)

                            if let anchor = anchors[steps[currentStep].cardKey] {
                                highlightBorder(frame: geo[anchor])
                                    .opacity(overlayOpacity)
                                    .allowsHitTesting(false)
                            }

                            if let anchor = anchors[steps[currentStep].cardKey] {
                                tipBox(
                                    step: steps[currentStep],
                                    cardFrame: geo[anchor],
                                    geo: geo
                                )
                                .opacity(tipOpacity)
                                .offset(y: tipOffset)
                                .offset(y: floatAnimate ? -4 : 4)
                                .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: floatAnimate)
                                .transition(.asymmetric(
                                    insertion: .scale(scale: 0.92).combined(with: .opacity).combined(with: .move(edge: .bottom)),
                                    removal: .opacity
                                ))
                            }
                        }
                    }
                    .ignoresSafeArea()
                    .onAppear {
                        withAnimation(.easeOut(duration: 0.4)) {
                            overlayOpacity = 1
                        }
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.25)) {
                            tipOpacity = 1
                            tipOffset = 0
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                            floatAnimate = true
                        }
                    }
                    .onChange(of: currentStep) { _, _ in

                        tipOpacity = 0
                        tipOffset = 20

                        withAnimation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.1)) {
                            tipOpacity = 1
                            tipOffset = 0
                        }
                    }
                }
            }
    }

    private func dimOverlay(anchors: [TutorialCardKey: Anchor<CGRect>], geo: GeometryProxy) -> some View {
        let activeFrame = anchors[steps[currentStep].cardKey].map { geo[$0] } ?? .zero
        let expandedFrame = activeFrame.insetBy(dx: -8, dy: -8)

        return Canvas { ctx, size in

            ctx.fill(
                Path(CGRect(origin: .zero, size: size)),
                with: .color(.black.opacity(0.75))
            )

            ctx.blendMode = .destinationOut
            ctx.fill(
                Path(roundedRect: expandedFrame, cornerRadius: 24),
                with: .color(.white)
            )
        }
        .compositingGroup()
        .animation(.spring(response: 0.5, dampingFraction: 0.82), value: currentStep)
    }

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

    private func tipBox(step: TutorialStep, cardFrame: CGRect, geo: GeometryProxy) -> some View {
        let boxWidth: CGFloat = 280
        let padding: CGFloat = 16

        let position = calculatePosition(
            step: step,
            cardFrame: cardFrame,
            boxWidth: boxWidth,
            geo: geo,
            padding: padding
        )

        return VStack(alignment: .leading, spacing: 14) {

            Text(step.title)
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(.primary)

            Text(step.message)
                .font(.system(size: 15, weight: .regular))
                .foregroundStyle(.secondary)
                .lineSpacing(5)
                .fixedSize(horizontal: false, vertical: true)

            HStack {

                HStack(spacing: 6) {
                    ForEach(0..<steps.count, id: \.self) { i in
                        Circle()
                            .fill(i == currentStep ? Color.primary : Color.secondary.opacity(0.35))
                            .frame(
                                width: i == currentStep ? 8 : 6,
                                height: i == currentStep ? 8 : 6
                            )
                            .animation(.spring(response: 0.3), value: currentStep)
                    }
                }

                Spacer()

                Button {
                    handleNext()
                } label: {
                    HStack(spacing: 6) {
                        Text(currentStep == steps.count - 1 ? "Got it! 🚀" : "Next")
                            .font(.system(size: 14, weight: .bold))
                        if currentStep < steps.count - 1 {
                            Image(systemName: "arrow.right")
                                .font(.system(size: 12, weight: .bold))
                        }
                    }
                    .foregroundStyle(.primary)
                    .padding(.horizontal, 18)
                    .padding(.vertical, 11)
                    .background(
                        Capsule()
                            .fill(.ultraThinMaterial)
                            .overlay(Capsule().stroke(Color.white.opacity(0.18), lineWidth: 1))
                    )
                }
                .scaleEffect(buttonPressed ? 0.96 : 1)
                .animation(.spring(response: 0.25, dampingFraction: 0.7), value: buttonPressed)
                .onLongPressGesture(minimumDuration: .infinity, pressing: { pressing in
                    buttonPressed = pressing
                }, perform: {})
            }
        }
        .padding(22)
        .frame(width: boxWidth)
        .background(
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .fill(.regularMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 30, style: .continuous)
                        .stroke(Color.white.opacity(0.15), lineWidth: 1)
                )
                .overlay(alignment: .top) {
                    LinearGradient(
                        colors: [Color.white.opacity(0.25), .clear],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(height: 80)
                    .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
                    .blendMode(.overlay)
                }
                .shadow(color: Color.black.opacity(0.3), radius: 35, y: 20)
        )
        .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
        .position(x: position.x, y: position.y)
        .animation(.spring(response: 0.5, dampingFraction: 0.82), value: currentStep)
    }

    private func calculatePosition(
        step: TutorialStep,
        cardFrame: CGRect,
        boxWidth: CGFloat,
        geo: GeometryProxy,
        padding: CGFloat
    ) -> CGPoint {

        let boxHeight: CGFloat = 200

        switch step.tipPosition {
        case .right:

            let x = min(
                cardFrame.maxX + padding + boxWidth / 2,
                geo.size.width - boxWidth / 2 - padding
            )
            let y = cardFrame.midY
            return CGPoint(x: x, y: y)

        case .left:

            let x = max(
                cardFrame.minX - padding - boxWidth / 2,
                boxWidth / 2 + padding
            )
            let y = cardFrame.midY
            return CGPoint(x: x, y: y)

        case .top:

            let x = cardFrame.midX
            let y = max(
                cardFrame.minY - padding - boxHeight / 2,
                boxHeight / 2 + padding + 40
            )
            return CGPoint(x: x, y: y)
        }
    }

    private func handleNext() {
        if currentStep < steps.count - 1 {
            stepHapticTrigger.toggle()

            withAnimation(.easeIn(duration: 0.15)) {
                tipOpacity = 0
                tipOffset = -12
            }

            Task { @MainActor in
                try? await Task.sleep(for: .seconds(0.18))
                currentStep += 1
                tipOffset = 20

                withAnimation(.spring(response: 0.45, dampingFraction: 0.8)) {
                    tipOpacity = 1
                    tipOffset = 0
                }
            }
        } else {

            doneHapticTrigger.toggle()

            UserDefaults.standard.set(true, forKey: "hasSeenGameTutorial")

            withAnimation(.easeOut(duration: 0.3)) {
                tipOpacity = 0
                overlayOpacity = 0
            }

            Task { @MainActor in
                try? await Task.sleep(for: .seconds(0.35))
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
