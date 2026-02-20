import SwiftUI

struct ConceptCardView: View {
    let command: String
    
    private var explanations: [CommandPartExplanation] {
        CommandSyntaxAnalyzer.explain(command: command)
    }
    
    // Dark palette
    private let cardBg = Color(red: 0.12, green: 0.12, blue: 0.14)
    private let headerBg = Color(red: 0.10, green: 0.10, blue: 0.12)
    private let boxBg = Color.black.opacity(0.3)
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // ── HEADER ──
            HStack(spacing: 8) {
                Image(systemName: "book.closed.fill")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Theme.Colors.primary)
                
                Text("Understanding the Command")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(.white)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(headerBg)
            
            ScrollViewReader { proxy in
                ScrollView(){
                    VStack(alignment: .leading, spacing: 16) {
                        // 1. COMMAND DISPLAY
                        VStack(alignment: .leading, spacing: 8) {
                            headerLabel("FULL COMMAND", color: .white.opacity(0.4))
                            Text(command)
                                .font(.system(size: 13, weight: .bold))
                                .foregroundStyle(Theme.Colors.success)
                                .padding(12)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(boxBg)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 8)
                                                .stroke(Theme.Colors.success.opacity(0.2), lineWidth: 1)
                                        )
                                )
                        }
                        .id("top")
                        
                        // 2. BREAKDOWN SECTION
                        VStack(alignment: .leading, spacing: 12) {
                            headerLabel("COMMAND PARTS & ROLES", color: .white.opacity(0.4))
                            
                            VStack(spacing: 12) {
                                ForEach(explanations) { explanation in
                                    partCard(for: explanation)
                                }
                            }
                        }
                    }
                    .padding(16)
                }
                .scrollIndicators(.hidden)
                .onChange(of: command) { _, _ in
                    withAnimation(.easeOut(duration: 0.3)) {
                        proxy.scrollTo("top", anchor: .top)
                    }
                }
            }
        }
        .background(cardBg)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
    
    // MARK: - Components
    
    private func headerLabel(_ text: String, icon: String? = nil, color: Color) -> some View {
        HStack(spacing: 4) {
            if let icon = icon {
                Image(systemName: icon)
                    .font(.system(size: 10))
                    .foregroundStyle(color)
            }
            Text(text)
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(color)
        }
    }
    
    @ViewBuilder
    private func partCard(for explanation: CommandPartExplanation) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            // Token
            Text(explanation.part)
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(Theme.Colors.secondary)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Theme.Colors.secondary.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 6))
            
            // Meaning
            Text(explanation.meaning)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(.white)
            
            // Purpose (Role)
            HStack(alignment: .top, spacing: 6) {
                Image(systemName: "arrow.turn.down.right")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(Theme.Colors.primary.opacity(0.7))
                    .padding(.top, 2)
                
                Text(explanation.purposeInCommand)
                    .font(.system(size: 12, weight: .regular))
                    .foregroundStyle(.white.opacity(0.7))
                    .lineSpacing(2)
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white.opacity(0.04))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.white.opacity(0.05), lineWidth: 1)
        )
    }
    
    private func color(for type: CommandPart.PartType) -> Color {
        switch type {
        case .keyword:    return Theme.Colors.secondary // Blue
        case .subcommand: return Theme.Colors.success   // Green
        case .flag:       return Theme.Colors.warning   // Orange/Yellow
        case .argument:   return Theme.Colors.primary   // Purple
        }
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        ConceptCardView(command: "git commit -m \"Initial commit\"")
            .frame(width: 300, height: 500)
    }
}
