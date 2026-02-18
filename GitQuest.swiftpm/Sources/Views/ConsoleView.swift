//
//  ConsoleView.swift
//  GitQuest
//
//  Dark-themed terminal console with hint bar
//

import SwiftUI

// MARK: - Console View

/// Bottom-anchored terminal console that displays command output
/// and provides a tap-driven hint bar for suggested Git commands.
struct ConsoleView: View {
    @Binding var commandInput: String
    let terminalOutput: [TerminalLine]
    let suggestedCommands: [String]
    let onExecute: () -> Void
    let onCommandTap: (String) -> Void
    
    private let terminalBg = Color(red: 0.08, green: 0.08, blue: 0.10)
    private let terminalHeaderBg = Color(red: 0.12, green: 0.12, blue: 0.14)
    private let terminalGreen = Color(red: 0.2, green: 0.8, blue: 0.4)
    private let terminalGray = Color(red: 0.5, green: 0.5, blue: 0.55)
    
    var body: some View {
        VStack(spacing: 0) {
            // Terminal header bar
            terminalHeader
            
            // Terminal output area
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
            
            // Suggested commands
            if !suggestedCommands.isEmpty {
                suggestedCommandsRow
            }
            
            // Command input area
            commandInputArea
        }
//        .background(terminalBg)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(terminalBg)
        )
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
    
    // MARK: - Terminal Header
    
    private var terminalHeader: some View {
        HStack(spacing: 8) {
            HStack(spacing: 6) {
                Circle().fill(Color(red: 0.9, green: 0.3, blue: 0.3).opacity(0.8)).frame(width: 12, height: 12)
                Circle().fill(Color(red: 0.9, green: 0.8, blue: 0.3).opacity(0.8)).frame(width: 12, height: 12)
                Circle().fill(Color(red: 0.2, green: 0.8, blue: 0.4).opacity(0.8)).frame(width: 12, height: 12)
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
    
    // MARK: - Suggested Commands
    
    private var suggestedCommandsRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
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
                            .background(
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(terminalGreen.opacity(0.12))
                            )
                    }
                }
            }
            .padding(.horizontal, 12)
        }
        .padding(.vertical, 8)
        .background(Color(red: 0.10, green: 0.10, blue: 0.12))
    }
    
    // MARK: - Command Input
    
    private var commandInputArea: some View {
        HStack(spacing: 8) {
            Text("$")
                .font(.system(size: 16, weight: .bold, design: .monospaced))
                .foregroundStyle(terminalGreen)
            
            Text(commandInput.isEmpty ? "Type git command..." : commandInput)
                .font(.system(size: 14, weight: .regular, design: .monospaced))
                .foregroundStyle(commandInput.isEmpty ? terminalGray : .white)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Button(action: {
                if !commandInput.isEmpty {
                    onExecute()
                }
            }) {
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

/// Individual terminal line
struct GitTerminalLine: View {
    let line: TerminalLine
    
    private let terminalGreen = Color(red: 0.2, green: 0.8, blue: 0.4)
    private let terminalYellow = Color(red: 0.9, green: 0.8, blue: 0.3)
    private let terminalRed = Color(red: 0.9, green: 0.3, blue: 0.3)
    private let terminalCyan = Color(red: 0.3, green: 0.8, blue: 0.9)
    private let terminalGray = Color(red: 0.6, green: 0.6, blue: 0.65)
    
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
