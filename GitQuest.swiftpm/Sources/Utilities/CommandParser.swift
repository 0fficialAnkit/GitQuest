import Foundation

struct CommandParser {
    static func concept(for command: String) -> CommandConcept {
        let cmd = command.trimmingCharacters(in: .whitespacesAndNewlines)
        
        switch cmd {
        case _ where cmd.contains("git init"):
            return CommandConcept(
                fullCommand: "git init",
                parts: [
                    CommandPart(text: "git", meaning: "Git version control tool", effect: "Invokes the Git program", type: .keyword),
                    CommandPart(text: "init", meaning: "Initialize", effect: "Creates a new hidden .git repository folder", type: .subcommand)
                ],
                explanation: "Running this command turns the current directory into a Git repository, allowing you to track changes."
            )
            
        case _ where cmd.contains("git add ."):
            return CommandConcept(
                fullCommand: "git add .",
                parts: [
                    CommandPart(text: "git", meaning: "Git version control tool", effect: "Invokes the Git program", type: .keyword),
                    CommandPart(text: "add", meaning: "Add files to staging", effect: "Prepares changes to be saved in the next commit", type: .subcommand),
                    CommandPart(text: ".", meaning: "Current directory", effect: "Includes all new and modified files in this folder", type: .argument)
                ],
                explanation: "This command stages all your current changes, telling Git which files you want to include in your next snapshot."
            )
            
        case _ where cmd.contains("git add") && !cmd.contains("."):
            let fileName = cmd.components(separatedBy: " ").last ?? "file"
            return CommandConcept(
                fullCommand: cmd,
                parts: [
                    CommandPart(text: "git", meaning: "Git version control tool", effect: "Invokes the Git program", type: .keyword),
                    CommandPart(text: "add", meaning: "Add to staging", effect: "Selects specific changes for the next commit", type: .subcommand),
                    CommandPart(text: fileName, meaning: "Specific file", effect: "Stages only \(fileName) for the next snapshot", type: .argument)
                ],
                explanation: "This stages only the specified file, allowing for more granular and focused commits."
            )
            
        case _ where cmd.contains("git commit"):
            let message = extractCommitMessage(from: cmd)
            return CommandConcept(
                fullCommand: cmd,
                parts: [
                    CommandPart(text: "git", meaning: "Git version control tool", effect: "Invokes the Git program", type: .keyword),
                    CommandPart(text: "commit", meaning: "Record snapshot", effect: "Permanently saves the staged changes to history", type: .subcommand),
                    CommandPart(text: "-m", meaning: "Message flag", effect: "Indicates that a comment follows", type: .flag),
                    CommandPart(text: "\"\(message)\"", meaning: "Commit message", effect: "Describes what this change accomplished", type: .argument)
                ],
                explanation: "A commit is a permanent save point in your project's history, identified by a message."
            )
            
        case _ where cmd.contains("git checkout -b"):
            let branchName = cmd.components(separatedBy: " ").last ?? "new-branch"
            return CommandConcept(
                fullCommand: cmd,
                parts: [
                    CommandPart(text: "git", meaning: "Git version control tool", effect: "Invokes the Git program", type: .keyword),
                    CommandPart(text: "checkout", meaning: "Switch version", effect: "Moves the HEAD pointer to a different branch", type: .subcommand),
                    CommandPart(text: "-b", meaning: "New branch flag", effect: "Creates the branch before switching to it", type: .flag),
                    CommandPart(text: branchName, meaning: "Branch name", effect: "The name of your new parallel timeline", type: .argument)
                ],
                explanation: "This command creates a new branch and immediately switches your workspace to it."
            )
            
        case _ where cmd.contains("git checkout"):
            let branchName = cmd.components(separatedBy: " ").last ?? "main"
            return CommandConcept(
                fullCommand: cmd,
                parts: [
                    CommandPart(text: "git", meaning: "Git version control tool", effect: "Invokes the Git program", type: .keyword),
                    CommandPart(text: "checkout", meaning: "Switch version", effect: "Moves the HEAD pointer to a different branch", type: .subcommand),
                    CommandPart(text: branchName, meaning: "Target branch", effect: "The branch you want to move to", type: .argument)
                ],
                explanation: "This switches your workspace to an existing branch, updating your files to match its state."
            )
            
        case _ where cmd.contains("git push"):
            return CommandConcept(
                fullCommand: cmd,
                parts: [
                    CommandPart(text: "git", meaning: "Git version control tool", effect: "Invokes the Git program", type: .keyword),
                    CommandPart(text: "push", meaning: "Upload changes", effect: "Sends local commits to a remote server", type: .subcommand),
                    CommandPart(text: "origin", meaning: "Remote alias", effect: "The default name for your GitHub/server repo", type: .argument),
                    CommandPart(text: "main", meaning: "Remote branch", effect: "The destination branch on the server", type: .argument)
                ],
                explanation: "Pushing uploads your local history to a remote repository so others can see and use your work."
            )
            
        case _ where cmd.contains("git pull"):
            return CommandConcept(
                fullCommand: "git pull",
                parts: [
                    CommandPart(text: "git", meaning: "Git version control tool", effect: "Invokes the Git program", type: .keyword),
                    CommandPart(text: "pull", meaning: "Download & Sync", effect: "Fetches and merges remote changes into your files", type: .subcommand)
                ],
                explanation: "Pulling downloads the latest changes from the server and integrates them into your current work."
            )
            
        case _ where cmd.contains("git merge"):
            let branchName = cmd.components(separatedBy: " ").last ?? "branch"
            return CommandConcept(
                fullCommand: cmd,
                parts: [
                    CommandPart(text: "git", meaning: "Git version control tool", effect: "Invokes the Git program", type: .keyword),
                    CommandPart(text: "merge", meaning: "Join branches", effect: "Combines history from another branch into yours", type: .subcommand),
                    CommandPart(text: branchName, meaning: "Source branch", effect: "The branch whose work you want to integrate", type: .argument)
                ],
                explanation: "Merging combines the code from another branch into your current branch, integrating features."
            )
            
        case _ where cmd.contains("git status"):
            return CommandConcept(
                fullCommand: "git status",
                parts: [
                    CommandPart(text: "git", meaning: "Git version control tool", effect: "Invokes the Git program", type: .keyword),
                    CommandPart(text: "status", meaning: "Check state", effect: "Shows the current condition of your repository", type: .subcommand)
                ],
                explanation: "This shows you which files are modified, staged, or untracked, helping you plan your next move."
            )
            
        default:
            return CommandConcept(
                fullCommand: cmd,
                parts: [
                    CommandPart(text: "git", meaning: "Git version control tool", effect: "Runs Git command", type: .keyword)
                ],
                explanation: "A Git command to manage your repository's version history."
            )
        }
    }
    
    private static func extractCommitMessage(from command: String) -> String {
        if let range = command.range(of: "\".*\"", options: .regularExpression) {
            return String(command[range]).replacingOccurrences(of: "\"", with: "")
        }
        return "message"
    }
}
