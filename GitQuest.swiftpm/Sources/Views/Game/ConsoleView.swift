import SwiftUI

/// In-game terminal: scrollable output, hint buttons, and command input with execute. Used in LevelGameView.
struct ConsoleView: View {
    @Binding var commandInput: String
    let terminalOutput: [TerminalLine]
    let suggestedCommands: [String]
    let onExecute: () -> Void
    let onCommandTap: (String) -> Void

    private let terminalBg = Theme.Colors.terminalBackground
    private let terminalHeaderBg = Theme.Colors.headerBackground
    private let terminalGreen = Theme.Colors.success
    private let terminalGray = GitTheme.gray

    var body: some View {
        VStack(spacing: 0) {
            terminalHeader
            Divider().background(Color.white.opacity(0.06))
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(alignment: .leading, spacing: 4) {
                        ForEach(terminalOutput) { line in
                            GitTerminalLine(line: line)
                                .id(line.id)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(12)
                }
                .scrollIndicators(.hidden)
                .frame(minHeight: 80, idealHeight: 120, maxHeight: 160)
                .background(terminalBg)
                .onChange(of: terminalOutput.count) { _, _ in
                    if let last = terminalOutput.last {
                        withAnimation(.easeOut(duration: 0.2)) {
                            proxy.scrollTo(last.id, anchor: .bottom)
                        }
                    }
                }
            }
            if !suggestedCommands.isEmpty {
                suggestedCommandsRow
            }
            commandInputArea
        }
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(terminalBg)
        )
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }

    // MARK: - Subviews

    private var terminalHeader: some View {
        HStack(spacing: 8) {
            HStack(spacing: 6) {
                Circle().fill(GitTheme.red.opacity(0.8)).frame(width: 12, height: 12)
                Circle().fill(Theme.Colors.warning.opacity(0.8)).frame(width: 12, height: 12)
                Circle().fill(Theme.Colors.success.opacity(0.8)).frame(width: 12, height: 12)
            }
            Spacer()
            Text("gitquest - console")
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(.white.opacity(0.5))
            Spacer()
            HStack(spacing: 6) {
                Circle().fill(Color.clear).frame(width: 12, height: 12)
                Circle().fill(Color.clear).frame(width: 12, height: 12)
                Circle().fill(Color.clear).frame(width: 12, height: 12)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(terminalHeaderBg)
    }

    private var suggestedCommandsRow: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 8) {
                Text("Hints:")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(terminalGray)
                ForEach(suggestedCommands, id: \.self) { command in
                    Button {
                        onCommandTap(command)
                    } label: {
                        Text(command)
                            .font(.system(size: 12, weight: .medium, design: .monospaced))
                            .foregroundStyle(terminalGreen)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(RoundedRectangle(cornerRadius: 6).fill(terminalGreen.opacity(0.12)))
                    }
                }
            }
            .padding(.horizontal, 12)
        }
        .scrollIndicators(.hidden)
        .padding(.vertical, 8)
        .background(Theme.Colors.headerBackground)
    }

    private var commandInputArea: some View {
        HStack(spacing: 8) {
            Text("$")
                .font(.system(size: 16, weight: .bold, design: .monospaced))
                .foregroundStyle(terminalGreen)
            Text(commandInput.isEmpty ? "Tap a hint command below..." : commandInput)
                .font(.system(size: 14, weight: .regular, design: .monospaced))
                .foregroundStyle(commandInput.isEmpty ? terminalGray : .white)
                .frame(maxWidth: .infinity, alignment: .leading)
            Button {
                if !commandInput.isEmpty { onExecute() }
            } label: {
                Image(systemName: "return")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(commandInput.isEmpty ? terminalGray : terminalGreen)
                    .frame(width: 32, height: 32)
                    .background(
                        RoundedRectangle(cornerRadius: 6)
                            .fill(commandInput.isEmpty ? Color.clear : terminalGreen.opacity(0.15))
                    )
            }
            .disabled(commandInput.isEmpty)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(terminalBg)
    }
}

/// Renders one terminal line with optional “$” prefix for commands and color by type (success, error, info, etc.).
struct GitTerminalLine: View {
    let line: TerminalLine

    private let terminalGreen = Theme.Colors.success
    private let terminalYellow = Theme.Colors.warning
    private let terminalRed = GitTheme.red
    private let terminalCyan = GitTheme.cyan
    private let terminalGray = GitTheme.gray

    var body: some View {
        HStack(alignment: .top, spacing: 6) {
            if line.type == .command {
                Text("$")
                    .font(.system(size: 13, weight: .bold, design: .monospaced))
                    .foregroundStyle(terminalGreen)
            }
            Text(line.text)
                .font(.system(size: 13, weight: line.type == .command ? .medium : .regular, design: .monospaced))
                .foregroundStyle(colorForType(line.type))
        }
    }

    private func colorForType(_ type: TerminalLineType) -> Color {
        switch type {
        case .command: return .white
        case .success: return terminalGreen
        case .error: return terminalRed
        case .info: return terminalCyan
        case .instruction: return terminalYellow
        case .system: return terminalGray
        }
    }
}

#Preview("Console View") {
    ConsoleView(
        commandInput: .constant("git status"),
        terminalOutput: [],
        suggestedCommands: ["git init", "git status"],
        onExecute: {},
        onCommandTap: { _ in }
    )
    .preferredColorScheme(.dark)
}
