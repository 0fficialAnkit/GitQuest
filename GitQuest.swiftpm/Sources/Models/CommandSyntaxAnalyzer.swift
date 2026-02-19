import Foundation
//Ankit
// MARK: - Model used by ConceptCardView
struct CommandPartExplanation: Identifiable {
    let id = UUID()
    let part: String
    let meaning: String
    let purposeInCommand: String
}

// MARK: - Analyzer
struct CommandSyntaxAnalyzer {

    static func explain(command: String) -> [CommandPartExplanation] {

        // ORIGINAL tokens (shown in UI exactly same as hint)
        let originalTokens = tokenize(command)

        // normalized tokens (used only for logic comparisons)
        let normalizedTokens = originalTokens.map { $0.lowercased() }

        return originalTokens.enumerated().map { index, token in
            CommandPartExplanation(
                part: token, // <- keeps exact hint text
                meaning: meaning(of: token, index: index, tokens: normalizedTokens),
                purposeInCommand: role(of: token, index: index, tokens: normalizedTokens)
            )
        }
    }
}

// MARK: - TOKENIZER (preserves quotes)
private extension CommandSyntaxAnalyzer {

    static func tokenize(_ command: String) -> [String] {
        var tokens: [String] = []
        var current = ""
        var inQuotes = false

        for char in command {
            if char == "\"" {
                inQuotes.toggle()
                current.append(char) // keep quotes visible
                continue
            }

            if char == " " && !inQuotes {
                if !current.isEmpty {
                    tokens.append(current)
                    current = ""
                }
            } else {
                current.append(char)
            }
        }

        if !current.isEmpty { tokens.append(current) }
        return tokens
    }
}

// MARK: - MEANING (context aware)
private extension CommandSyntaxAnalyzer {

    static func meaning(of part: String, index: Int, tokens: [String]) -> String {

        guard tokens.count >= 2 else { return "Part of the command" }

        let action = tokens[1]
        let token = part.lowercased()

        // git
        if token == "git" {
            return "The Git program — every Git command starts with this"
        }

        // MAIN ACTION
        if index == 1 {
            switch token {
            case "init":     return "Creates a new Git repository in this folder"
            case "add":      return "Selects changes that will go into the next commit"
            case "commit":   return "Saves a permanent snapshot of staged changes"
            case "status":   return "Shows which files changed, staged, or untracked"
            case "log":      return "Displays the full commit history of the repo"
            case "branch":   return "Creates or lists development branches"
            case "checkout": return "Switches to another branch or creates one with -b"
            case "merge":    return "Combines another branch's commits into the current branch"
            case "push":     return "Uploads your local commits to a remote repository"
            case "pull":     return "Downloads remote commits and merges them locally"
            case "clone":    return "Downloads a full repository from a remote URL"
            case "remote":   return "Manages connections to remote repositories (like GitHub)"
            case "reset":    return "Moves HEAD back to a previous commit, optionally unstaging changes"
            case "fetch":    return "Downloads remote changes without merging them"
            case "rebase":   return "Moves or replays commits on top of another branch"
            default:         return "A Git sub-command"
            }
        }

        // FLAGS
        if token == "-m" {
            return "Flag: the next argument is the commit message"
        }
        if token == "-b" {
            return "Flag: create a new branch and switch to it immediately"
        }
        if token == "-a" {
            return "Flag: automatically stage all tracked modified files"
        }
        if token == "-u" || token == "--set-upstream" {
            return "Flag: links this local branch to the remote branch for future push/pull"
        }
        if token == "--hard" {
            return "Flag: discard staged AND working-directory changes (destructive)"
        }
        if token == "--soft" {
            return "Flag: undo the commit but keep all changes staged"
        }
        if token == "--mixed" {
            return "Flag: undo the commit and unstage changes (default reset mode)"
        }

        // HEAD~N  (e.g. HEAD~1)
        if token.hasPrefix("head~") {
            let n = token.dropFirst(5)
            return "Refers to \(n) commit\(n == "1" ? "" : "s") before the current HEAD"
        }
        if token == "head" {
            return "Pointer to the latest commit on the current branch"
        }

        // DOT
        if token == "." && action == "add" {
            return "Shorthand for all files in the current directory and sub-folders"
        }

        // PARENT DIRECTORY
        if token == ".." {
            return "Refers to the parent directory"
        }

        // COMMIT MESSAGE (token after -m)
        if isCommitMessage(index: index, tokens: tokens) {
            return "The message stored in history — describes what changed and why"
        }

        // URL
        if token.hasPrefix("https://") || token.hasPrefix("git@") {
            return "The remote repository URL on GitHub (or another Git host)"
        }

        // 'origin' remote alias
        if token == "origin" {
            return "The conventional alias for the primary remote repository"
        }

        // 'add' sub-command of git remote
        if action == "remote" && index == 2 && token == "add" {
            return "Sub-command: register a new remote under a given name"
        }

        // Remote name after 'remote add'
        if action == "remote" && index == 3 {
            return "The alias (short name) you assign to the remote repository"
        }

        // FILE
        if token.contains(".") && action == "add" {
            return "The specific file being staged for the next commit"
        }

        // BRANCH NAME
        if isBranchName(index: index, tokens: tokens) {
            return "The branch name — identifies this line of development"
        }

        // REMOTE + BRANCH (push / pull)
        if action == "push" || action == "pull" {
            if index == 2 { return "The remote alias to sync with (usually 'origin')" }
            if index == 3 { return "The branch being uploaded to / downloaded from the remote" }
        }

        return "An argument that customises or targets the command"
    }
}

// MARK: - ROLE (sentence teaching)
private extension CommandSyntaxAnalyzer {

    static func role(of token: String, index: Int, tokens: [String]) -> String {

        let lower = token.lowercased()

        if lower == "git" {
            return "Invokes the Git program — every Git command begins here"
        }

        if index == 1 {
            return "The main action Git will perform"
        }

        // Flags
        if lower == "-m"                           { return "Tells Git the next argument is the commit description" }
        if lower == "-b"                           { return "Makes Git create the branch before switching to it" }
        if lower == "-u" || lower == "--set-upstream" { return "Sets up tracking so future 'git push' needs no arguments" }
        if lower == "--hard"                       { return "Deletes changes permanently — use with caution" }
        if lower == "--soft"                       { return "Keeps your changes staged after undoing the commit" }
        if lower == "--mixed"                      { return "Unstages changes after undoing the commit (Git default)" }
        if lower.hasPrefix("-")                    { return "Modifies how the command behaves" }

        // HEAD~N
        if lower.hasPrefix("head~")                { return "Tells Git how far back in history to move" }
        if lower == "head"                         { return "References the latest commit on the current branch" }

        // Commit message
        if isCommitMessage(index: index, tokens: tokens) {
            return "Saved permanently in the commit log — describes the change"
        }

        // Dot
        if lower == "."                            { return "Applies the command to every file in this folder" }

        // URL
        if lower.hasPrefix("https://") || lower.hasPrefix("git@") {
            return "The address Git uses to communicate with the remote server"
        }

        // 'origin'
        if lower == "origin"                       { return "The default remote alias — points to your GitHub repo" }

        // 'add' sub-command of git remote
        let action = tokens.count > 1 ? tokens[1].lowercased() : ""
        if action == "remote" && index == 2 && lower == "add" {
            return "Sub-command that registers a new remote entry"
        }
        if action == "remote" && index == 3        { return "The short name used to refer to this remote from now on" }

        // File
        if lower.contains(".")                     { return "The specific file targeted by this command" }

        // Branch name
        if isBranchName(index: index, tokens: tokens) { return "The branch this operation is applied to" }

        // Push / Pull remote + branch positional args
        if action == "push" || action == "pull" {
            if index == 2 { return "The remote server to sync with" }
            if index == 3 { return "The branch being pushed or pulled" }
        }

        return "A required parameter that completes the command"
    }
}

// MARK: - Helpers
private extension CommandSyntaxAnalyzer {

    static func isCommitMessage(index: Int, tokens: [String]) -> Bool {
        guard let mIndex = tokens.firstIndex(of: "-m") else { return false }
        return index == mIndex + 1
    }

    static func isBranchName(index: Int, tokens: [String]) -> Bool {

        // checkout branch
        if tokens.count >= 3 && tokens[1] == "checkout" && index == 2 {
            return true
        }

        // branch branchName
        if tokens.count >= 3 && tokens[1] == "branch" && index == 2 {
            return true
        }

        // checkout -b branchName
        if let bIndex = tokens.firstIndex(of: "-b"),
           tokens.indices.contains(bIndex + 1),
           index == bIndex + 1 {
            return true
        }

        return false
    }
}
