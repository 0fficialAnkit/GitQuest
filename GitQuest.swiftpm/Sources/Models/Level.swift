//
//  Level.swift
//  GitQuest
//
//  Created by Ankit Kumar on 04/02/26.
//

import Foundation
import SwiftUI

// MARK: - Level

/// A playable level combining narrative context, required Git commands,
/// and post-completion explanations.
///
/// Each level is self-contained: it defines its own chat script,
/// step sequence, difficulty rating, and educational summary.
struct Level: Identifiable, Hashable {
    let id: Int
    let title: String
    let subtitle: String
    let initialChat: [ChatMessage]
    let stepChats: [Int: [ChatMessage]]
    let icon: String
    let concept: GitConcept
    let commands: [String]
    let requiredSteps: [LevelStep]
    let difficulty: Difficulty
    let estimatedTime: Int
    let commandExplanation: CommandExplanation
    
    // MARK: - Hashable (by ID only, since stepChats isn't Hashable)
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Level, rhs: Level) -> Bool {
        lhs.id == rhs.id
    }
    
    /// Skill tier displayed on the level node badge.
    enum Difficulty: String {
        case beginner = "Beginner"
        case intermediate = "Intermediate"
        case advanced = "Advanced"
        
        /// Badge colour mapped to difficulty.
        var color: Color {
            switch self {
            case .beginner:     return .green
            case .intermediate: return .orange
            case .advanced:     return .red
            }
        }
    }
}

// MARK: - Git Concept

/// The educational topic a level teaches. Used for colour-coding,
/// icon selection, and the concept badge on the success overlay.
enum GitConcept: String, Hashable {
    case repository = "Repository Basics"
    case staging = "Staging & Committing"
    case branching = "Branch Management"
    case merging = "Merging Branches"
    case remote = "Remote Repositories"
    case collaboration = "Pull & Sync"
    case conflicts = "Merge Conflicts"
    case history = "History & Undo"
    case advanced = "Advanced Workflows"
    
    /// Gradient pair used for the concept's background treatment.
    var themeColors: [Color] {
        switch self {
        case .repository: return [.purple, .blue]
        case .staging: return [.blue, .cyan]
        case .branching: return [.green, .mint]
        case .merging: return [.orange, .yellow]
        case .remote: return [.cyan, .blue]
        case .collaboration: return [.pink, .purple]
        case .conflicts: return [.red, .orange]
        case .history: return [.red, .orange]
        case .advanced: return [.yellow, .orange]
        }
    }
    
    /// SF Symbol name representing this concept.
    var icon: String {
        switch self {
        case .repository: return "folder.fill.badge.plus"
        case .staging: return "tray.and.arrow.down.fill"
        case .branching: return "arrow.triangle.branch"
        case .merging: return "arrow.triangle.merge"
        case .remote: return "cloud.fill"
        case .collaboration: return "arrow.left.arrow.right"
        case .conflicts: return "exclamationmark.triangle.fill"
        case .history: return "clock.arrow.circlepath"
        case .advanced: return "star.fill"
        }
    }
}

// MARK: - Level Step

/// A single step within a level that the player must complete.
struct LevelStep: Identifiable, Hashable {
    let id: Int
    
    /// Narrative context explaining *why* this command matters right now.
    let contextMessage: String
    
    /// The Git command the player is expected to type.
    let expectedCommand: String
    
    /// Helpful hint shown when the player enters a wrong command.
    let hint: String
    
    /// Congratulatory message displayed after completing this step.
    let successMessage: String
    
    /// Optional reaction from a teammate (shown as a chat bubble).
    let teamReaction: String?
}

// MARK: - Command Explanation

/// Educational content shown after level completion.
struct CommandExplanation: Hashable {
    /// Breakdown of each command used in the level.
    let commands: [CommandDetail]
    
    /// A practical "pro tip" for real-world usage.
    let proTip: String
    
    /// Warning about common mistakes or dangers.
    let risk: String
    
    /// A mini-walkthrough of how this skill applies professionally.
    let realWorldUsage: String
}

/// A single command plus its plain-English description.
struct CommandDetail: Hashable {
    let command: String
    let description: String
}

// MARK: - Level Database (Story-Driven)
extension Level {
    static let allLevels: [Level] = [
        // LEVEL 1: YOUR FIRST COMMIT
        Level(
            id: 1,
            title: "Your First Commit",
            subtitle: "Day 1 at Pixel Labs",
            initialChat: [
                ChatMessage(sender: .maya, text: "Morning team! Customer dashboard project kicks off today 🚀"),
                ChatMessage(sender: .jordan, text: "I've got the React boilerplate ready - just need a repo to push it to"),
                ChatMessage(sender: .alex, text: "Same here - UI mockups are done but I can't version them without Git"),
                ChatMessage(sender: .maya, text: "Can you initialize the repo? That'll unblock everyone before standup at 10"),
                ChatMessage(sender: .jordan, text: "Once the repo exists I'll push the starter template 👍")
            ],
            stepChats: [
                0: [
                    ChatMessage(sender: .you, text: "Repository initialized."),
                    ChatMessage(sender: .jordan, text: "Nice - repo's live. Now we need a README before I push the template"),
                    ChatMessage(sender: .maya, text: "Stage the README so Git knows to track it")
                ],
                1: [
                    ChatMessage(sender: .you, text: "Files staged."),
                    ChatMessage(sender: .jordan, text: "Good call staging specific files - keeps the commit clean"),
                    ChatMessage(sender: .maya, text: "Now commit it with a descriptive message. This'll be our first entry in the project history")
                ],
                2: [
                    ChatMessage(sender: .you, text: "First commit done! ✅"),
                    ChatMessage(sender: .maya, text: "Clean commit message - that makes the history way easier to review 👍"),
                    ChatMessage(sender: .jordan, text: "Pushing the starter template now. We're officially in business 🚀"),
                    ChatMessage(sender: .alex, text: "Finally! Uploading the Figma exports. This sprint is going to be great")
                ]
            ],
            icon: "folder.fill.badge.plus",
            concept: .repository,
            commands: ["git-init", "git-add", "git-commit"],
            requiredSteps: [
                LevelStep(
                    id: 1,
                    contextMessage: """
                    📍 YOUR FIRST TASK
                    
                    Maya needs this repo initialized.
                    
                    In real dev work, 'git init' creates a hidden .git folder 
                    that tracks every change you make. It's how your project 
                    remembers its history.
                    
                    Think of it like: Starting a journal.
                    """,
                    expectedCommand: "git init",
                    hint: "Type exactly: git init",
                    successMessage: "✓ Repository Created",
                    teamReaction: nil
                ),
                LevelStep(
                    id: 2,
                    contextMessage: """
                    📍 STAGE YOUR CHANGES
                    
                    Before committing, you need to tell Git which files to save.
                    
                    'git add' stages files — like putting items in a shopping cart 
                    before checkout.
                    
                    Stage the README file.
                    """,
                    expectedCommand: "git add",
                    hint: "Use: git add README.md",
                    successMessage: "Files staged and ready to commit",
                    teamReaction: "Jordan: Good call staging specific files — keeps the commit clean 👍"
                ),
                LevelStep(
                    id: 3,
                    contextMessage: """
                    📍 MAKE IT OFFICIAL
                    
                    Now commit the README. This tells Git: "Save this 
                    moment — I want to remember this state."
                    
                    Real developers commit constantly. It's like saving 
                    your game. Commit early, commit often.
                    
                    Why teams love this: Everyone can see what changed.
                    """,
                    expectedCommand: "git commit",
                    hint: "Use: git commit -m \"Initial commit: Add README\"",
                    successMessage: "🎉 You Just Shipped Your First Commit!",
                    teamReaction: "Maya: Clean commit message — that makes the history way easier to review 👍"
                )
            ],
            difficulty: .beginner,
            estimatedTime: 3,
            commandExplanation: CommandExplanation(
                commands: [
                    CommandDetail(
                        command: "git init",
                        description: "Creates a repository. One-time setup."
                    ),
                    CommandDetail(
                        command: "git add <file>",
                        description: "Stages changes for commit. Like adding items to a shopping cart."
                    ),
                    CommandDetail(
                        command: "git commit -m \"message\"",
                        description: "Saves staged changes with a description. This is permanent history."
                    )
                ],
                proTip: "Write commit messages that explain WHY, not WHAT. \"Fix login bug\" is better than \"Update auth.js\"",
                risk: "Committing too much at once makes bugs hard to track. Commit small, atomic changes.",
                realWorldUsage: "Pro developers commit 20+ times per day. Every logical checkpoint gets a commit."
            )
        ),
        
        // LEVEL 2: FEATURE BRANCHES
        Level(
            id: 2,
            title: "Feature Branches",
            subtitle: "Your First Real Feature",
            initialChat: [
                ChatMessage(sender: .maya, text: "Update from the design team — dark mode just got bumped to priority 1"),
                ChatMessage(sender: .alex, text: "YES! Users have been requesting this for weeks 🌙"),
                ChatMessage(sender: .maya, text: "We deploy from main every Friday at 4pm. Can't have work-in-progress code there"),
                ChatMessage(sender: .jordan, text: "Create a feature branch — keeps main stable while you build"),
                ChatMessage(sender: .maya, text: "Call it feature/dark-mode and commit your changes there")
            ],
            stepChats: [
                0: [
                    ChatMessage(sender: .you, text: "Branch created!"),
                    ChatMessage(sender: .jordan, text: "Perfect — now anything you commit stays off main until it's ready"),
                    ChatMessage(sender: .maya, text: "Exactly. Friday deploy is safe. Build away 👍")
                ],
                1: [
                    ChatMessage(sender: .you, text: "Dark mode feature committed."),
                    ChatMessage(sender: .alex, text: "Ooh can't wait to see this in the demo! 🌙"),
                    ChatMessage(sender: .maya, text: "Feature is safely isolated on its own branch. Nice workflow"),
                    ChatMessage(sender: .jordan, text: "Solid first feature branch. That's exactly how we do it here")
                ]
            ],
            icon: "arrow.triangle.branch",
            concept: .branching,
            commands: ["git-branch", "git-checkout"],
            requiredSteps: [
                LevelStep(
                    id: 1,
                    contextMessage: """
                    📍 WHY BRANCHES MATTER
                    
                    Imagine editing a Google Doc with 5 people at once. 
                    Chaos, right?
                    
                    Branches let you work in isolation. Your changes 
                    stay separate until you're ready to merge.
                    
                    In real teams:
                    • main = production code (always working)
                    • feature branches = experiments (safe to break)
                    
                    Create a branch called 'feature/dark-mode'
                    """,
                    expectedCommand: "git checkout",
                    hint: "Use: git checkout -b feature/dark-mode",
                    successMessage: "🌿 Feature Branch Created",
                    teamReaction: "Jordan: Perfect — now anything you commit stays off main until it's ready"
                ),
                LevelStep(
                    id: 2,
                    contextMessage: """
                    📍 BUILD THE FEATURE
                    
                    Make a commit to simulate adding dark mode.
                    
                    Real developers commit at logical checkpoints:
                    • After adding a function
                    • After fixing a bug
                    • Before lunch (seriously)
                    """,
                    expectedCommand: "git commit",
                    hint: "Use: git commit -m \"Add dark mode toggle to settings\"",
                    successMessage: "Feature committed to your branch!",
                    teamReaction: "Alex: Ooh can't wait to see this in the demo! 🌙"
                )
            ],
            difficulty: .beginner,
            estimatedTime: 4,
            commandExplanation: CommandExplanation(
                commands: [
                    CommandDetail(
                        command: "git checkout -b <branch-name>",
                        description: "Creates AND switches to a new branch. Shortcut for branch + checkout."
                    ),
                    CommandDetail(
                        command: "git branch",
                        description: "Lists all branches. Current branch is marked with *"
                    )
                ],
                proTip: "Use descriptive names. Your teammates should understand what you're building just from the branch name.",
                risk: "Leaving old branches around clutters the repo. Delete merged branches with 'git branch -d <name>'",
                realWorldUsage: "Common patterns: feature/new-ui, bugfix/login-error, experiment/ai-suggestions"
            )
        ),
        
        // LEVEL 3: PUSH TO GITHUB
        Level(
            id: 3,
            title: "Push to GitHub",
            subtitle: "Share Your Work",
            initialChat: [
                ChatMessage(sender: .jordan, text: "Hey — I need to pull your auth components for my API integration work"),
                ChatMessage(sender: .jordan, text: "But I don't see your code on GitHub yet?"),
                ChatMessage(sender: .maya, text: "Ah right, we haven't connected the remote yet"),
                ChatMessage(sender: .maya, text: "Add the GitHub remote and push your commits — that'll unblock Jordan"),
                ChatMessage(sender: .jordan, text: "My code review is at 2pm so I need your stuff before then 😅")
            ],
            stepChats: [
                0: [
                    ChatMessage(sender: .you, text: "Remote added."),
                    ChatMessage(sender: .jordan, text: "Nice — local repo now knows where GitHub lives"),
                    ChatMessage(sender: .maya, text: "Now push your commits up so the team can access them")
                ],
                1: [
                    ChatMessage(sender: .you, text: "Code pushed! ☁️"),
                    ChatMessage(sender: .jordan, text: "Got it! Pulling now... auth components look solid 👀"),
                    ChatMessage(sender: .alex, text: "I can see the commits on GitHub — looks great from here! 🎨"),
                    ChatMessage(sender: .maya, text: "Code is now backed up and shareable. Good work unblocking the team")
                ]
            ],
            icon: "cloud.fill",
            concept: .remote,
            commands: ["git-remote", "git-push"],
            requiredSteps: [
                LevelStep(
                    id: 1,
                    contextMessage: """
                    📍 GOING REMOTE
                    
                    So far, Git has been local — only on your machine.
                    
                    To collaborate, you need a "remote" — a shared version 
                    of the repo on GitHub.
                    
                    Think of it like:
                    • Your laptop = your private notes
                    • GitHub = the team's shared whiteboard
                    
                    Add the remote repository.
                    """,
                    expectedCommand: "git remote",
                    hint: "Use: git remote add origin https://github.com/pixel-labs/user-profiles.git",
                    successMessage: "Remote added! Your local repo knows about GitHub now.",
                    teamReaction: nil
                ),
                LevelStep(
                    id: 2,
                    contextMessage: """
                    📍 SEND IT TO THE CLOUD
                    
                    Now push your branch to GitHub so Alex can access it.
                    
                    This uploads your commits to the remote repository.
                    """,
                    expectedCommand: "git push",
                    hint: "Use: git push -u origin feature/dark-mode",
                    successMessage: "☁️ Code Pushed to GitHub",
                    teamReaction: "Jordan: Got it! Pulling now... auth components look solid 👀"
                )
            ],
            difficulty: .intermediate,
            estimatedTime: 5,
            commandExplanation: CommandExplanation(
                commands: [
                    CommandDetail(
                        command: "git remote add origin <url>",
                        description: "Tells Git where the shared repo lives. You only do this once per repo."
                    ),
                    CommandDetail(
                        command: "git push -u origin <branch>",
                        description: "Sends your commits to GitHub. -u sets up tracking for future pushes."
                    )
                ],
                proTip: "After the first push, you can just use 'git push' — tracking remembers the branch.",
                risk: "Force pushing (--force) can delete others' work. Only use if you know why.",
                realWorldUsage: "Every feature branch gets pushed so teammates can review PRs, CI/CD can run tests, and code is backed up."
            )
        ),
        
        // LEVEL 4: THE MERGE CONFLICT CRISIS
        Level(
            id: 4,
            title: "The 3 PM Crisis",
            subtitle: "Resolve Merge Conflict",
            initialChat: [
                ChatMessage(sender: .maya, text: "🚨 Heads up @channel — we have a merge conflict in dashboard.js"),
                ChatMessage(sender: .jordan, text: "That was me, sorry. I edited the same section Alex was working on"),
                ChatMessage(sender: .alex, text: "The stakeholder demo is at 3:30 and the build is broken 😰"),
                ChatMessage(sender: .maya, text: "We need to resolve this before the demo. Can you take a look?"),
                ChatMessage(sender: .jordan, text: "Check git status first — it'll show you exactly which files are conflicted")
            ],
            stepChats: [
                0: [
                    ChatMessage(sender: .you, text: "Checking status..."),
                    ChatMessage(sender: .jordan, text: "There it is — dashboard.js has the conflict"),
                    ChatMessage(sender: .maya, text: "Open it up, pick the right version, and stage the fix")
                ],
                1: [
                    ChatMessage(sender: .you, text: "Conflict resolved in dashboard.js"),
                    ChatMessage(sender: .jordan, text: "Nice — you kept Alex's purple theme. Design team approved that one"),
                    ChatMessage(sender: .maya, text: "Good. Now commit the resolution so the build goes green")
                ],
                2: [
                    ChatMessage(sender: .you, text: "Merge commit done! 🎯"),
                    ChatMessage(sender: .alex, text: "Build is green again! Demo is saved 🙏"),
                    ChatMessage(sender: .jordan, text: "Good call on the purple. That's the version design signed off on"),
                    ChatMessage(sender: .maya, text: "Nice work under pressure. That's real production debugging right there")
                ]
            ],
            icon: "exclamationmark.triangle.fill",
            concept: .conflicts,
            commands: ["git-status", "git-merge"],
            requiredSteps: [
                LevelStep(
                    id: 1,
                    contextMessage: """
                    📍 WHAT JUST HAPPENED
                    
                    When two people change the same lines of code, 
                    Git can't decide which version to keep.
                    
                    This is called a MERGE CONFLICT.
                    
                    It's not a bug. It's not an error. It's Git asking:
                    "I see two versions. Which one is right?"
                    
                    First, check which files are conflicted.
                    """,
                    expectedCommand: "git status",
                    hint: "Type: git status",
                    successMessage: "Conflicts identified: dashboard.js",
                    teamReaction: "Jordan: There it is — dashboard.js has the conflict"
                ),
                LevelStep(
                    id: 2,
                    contextMessage: """
                    📍 RESOLVE THE CONFLICT
                    
                    You've seen the conflict markers in dashboard.js:
                    
                    <<<<<<< HEAD
                    (Jordan's version - blue color)
                    =======
                    (Alex's version - purple color)
                    >>>>>>> feature/alex-colors
                    
                    Decision: Keep Alex's purple (design team approved it).
                    
                    After fixing the file, stage it to mark as resolved.
                    """,
                    expectedCommand: "git add",
                    hint: "Use: git add dashboard.js",
                    successMessage: "Conflict marked as resolved",
                    teamReaction: nil
                ),
                LevelStep(
                    id: 3,
                    contextMessage: """
                    📍 COMMIT THE RESOLUTION
                    
                    Now commit the fix. This creates a "merge commit" 
                    that brings both branches together.
                    """,
                    expectedCommand: "git commit",
                    hint: "Use: git commit -m \"Resolve dashboard color conflict — use purple\"",
                    successMessage: "🎯 Conflict Resolved!",
                    teamReaction: """
                    Maya: Build is green. Nice work under pressure.
                    Jordan: Good call on the purple — that's the signed-off version.
                    Alex: Demo is saved! Thank you 🙏
                    """
                )
            ],
            difficulty: .advanced,
            estimatedTime: 8,
            commandExplanation: CommandExplanation(
                commands: [
                    CommandDetail(
                        command: "git status",
                        description: "Shows which files have conflicts. Always run this first when you see 'CONFLICT'."
                    ),
                    CommandDetail(
                        command: "git add <file>",
                        description: "Marks a conflicted file as resolved after you fix it."
                    ),
                    CommandDetail(
                        command: "git commit",
                        description: "Creates a merge commit after resolving conflicts."
                    )
                ],
                proTip: "Never blindly accept one side — read the code. Test after resolving. Ask the other dev if unsure.",
                risk: "Resolving wrong breaks production. Not testing can introduce bugs. Forgetting 'git add' means Git thinks conflict isn't resolved.",
                realWorldUsage: """
                Reading Conflict Markers:
                <<<<<<< HEAD        → Your current branch
                =======             → Divider
                >>>>>>> branch-name → Incoming changes
                
                Resolution Strategies:
                • Keep yours: Delete incoming, keep HEAD
                • Keep theirs: Delete HEAD, keep incoming
                • Combine both: Merge logic from both versions
                • Rewrite: Neither version is right, start fresh
                
                Real Team Communication:
                "Hey, I'm resolving a conflict in auth.js. I'm keeping your validation 
                logic and my error handling. Let me know if that breaks anything."
                """
            )
        ),
        
        // LEVEL 5: PULL FROM REMOTE
        Level(
            id: 5,
            title: "Stay in Sync",
            subtitle: "Pull Teammate's Changes",
            initialChat: [
                ChatMessage(sender: .maya, text: "Morning! Pushed the auth service updates at 6am - couldn't sleep 😴"),
                ChatMessage(sender: .jordan, text: "Legend! Pulling now..."),
                ChatMessage(sender: .alex, text: "Wait should I pull before I start my CSS work today?"),
                ChatMessage(sender: .maya, text: "YES - I changed the user model. You'll get conflicts otherwise"),
                ChatMessage(sender: .jordan, text: "Always pull first thing in the morning. Learned that one the hard way last sprint 😅")
            ],
            stepChats: [
                0: [
                    ChatMessage(sender: .you, text: "Pulled latest changes! 🔄"),
                    ChatMessage(sender: .jordan, text: "Nice - now you've got Maya's auth refactor. Way cleaner API 👍"),
                    ChatMessage(sender: .maya, text: "Good habit. You're in sync for standup"),
                    ChatMessage(sender: .alex, text: "Same here, just pulled. No conflicts on my end 🎉")
                ]
            ],
            icon: "arrow.left.arrow.right",
            concept: .collaboration,
            commands: ["git-pull"],
            requiredSteps: [
                LevelStep(
                    id: 1,
                    contextMessage: """
                    📍 GET THE LATEST
                    
                    'git pull' fetches changes from GitHub and merges 
                    them into your local branch.
                    
                    It's like syncing your Dropbox — you get everyone 
                    else's updates.
                    
                    Pull the latest changes from main.
                    """,
                    expectedCommand: "git pull",
                    hint: "Use: git pull origin main",
                    successMessage: "🔄 Up to date! You have the latest team changes.",
                    teamReaction: "Jordan: Nice — now you've got Maya's auth refactor. Way cleaner API 👍"
                )
            ],
            difficulty: .intermediate,
            estimatedTime: 3,
            commandExplanation: CommandExplanation(
                commands: [
                    CommandDetail(
                        command: "git pull origin <branch>",
                        description: "Fetches and merges changes from the remote branch into your current branch."
                    ),
                    CommandDetail(
                        command: "git fetch",
                        description: "Downloads changes but doesn't merge them. Safer for reviewing first."
                    )
                ],
                proTip: "Pull at the start of every work session. Some teams pull every 30 minutes on active projects.",
                risk: "Pulling can cause merge conflicts if you and a teammate edited the same files. That's normal — just resolve them.",
                realWorldUsage: "Pro workflow: git pull → review changes → git checkout -b feature/new-work → start coding"
            )
        ),
        
        // LEVEL 6: UNDO WITH RESET
        Level(
            id: 6,
            title: "Time Travel",
            subtitle: "Undo Your Mistakes",
            initialChat: [
                ChatMessage(sender: .you, text: "Oh no. I just committed the .env file with all our API keys 😱"),
                ChatMessage(sender: .jordan, text: "STOP — don't push yet! 🚨"),
                ChatMessage(sender: .maya, text: "OK this is recoverable. Did you already push to GitHub?"),
                ChatMessage(sender: .you, text: "No, just committed locally"),
                ChatMessage(sender: .jordan, text: "Good. Use git reset HEAD~1 — it'll undo the commit but keep your files"),
                ChatMessage(sender: .maya, text: "The keys will still be in the file, just not committed. Then we'll add .env to .gitignore"),
                ChatMessage(sender: .alex, text: "This happened to me my first week too, don't stress 😅")
            ],
            stepChats: [
                0: [
                    ChatMessage(sender: .you, text: "Commit undone! ⏮️"),
                    ChatMessage(sender: .jordan, text: "Crisis averted 👍 Now remove the keys and add .env to .gitignore before re-committing"),
                    ChatMessage(sender: .maya, text: "Good catch. If those keys had reached GitHub we'd be rotating every credential tonight"),
                    ChatMessage(sender: .alex, text: "Git literally just saved us. Adding .env to .gitignore now so this can't happen again")
                ]
            ],
            icon: "clock.arrow.circlepath",
            concept: .history,
            commands: ["git-reset"],
            requiredSteps: [
                LevelStep(
                    id: 1,
                    contextMessage: """
                    📍 UNDO THE COMMIT
                    
                    'git reset HEAD~1' removes the last commit from history 
                    BUT keeps your changes in the files.
                    
                    This lets you fix the mistake and re-commit correctly.
                    
                    Your API keys will still be in the file — just not 
                    committed anymore.
                    """,
                    expectedCommand: "git reset",
                    hint: "Use: git reset HEAD~1",
                    successMessage: "⏮️ Commit undone! Changes are still in your files.",
                    teamReaction: "Jordan: Crisis averted 👍 Now remove the keys and add .env to .gitignore"
                )
            ],
            difficulty: .intermediate,
            estimatedTime: 4,
            commandExplanation: CommandExplanation(
                commands: [
                    CommandDetail(
                        command: "git reset HEAD~1",
                        description: "Removes the last commit but keeps changes in your working directory."
                    ),
                    CommandDetail(
                        command: "git reset --hard HEAD~1",
                        description: "⚠️ DANGER: Removes the commit AND deletes the changes. Unrecoverable."
                    ),
                    CommandDetail(
                        command: "git reset --soft HEAD~1",
                        description: "Removes the commit but keeps changes staged (ready to re-commit)."
                    )
                ],
                proTip: "Default reset (--mixed) is usually what you want. It unstages changes so you can review them before re-committing.",
                risk: "NEVER use --hard unless you're 100% sure you want to delete the changes. There's no undo for --hard.",
                realWorldUsage: """
                Common scenarios:
                • Committed to wrong branch → reset, switch branches, re-commit
                • Committed incomplete work → reset, finish work, commit properly
                • Committed secrets → reset, remove secrets, commit safely
                
                Pro tip: Before using reset, create a backup branch:
                git branch backup-before-reset
                """
            )
        ),
        
        // LEVEL 7: MERGE BRANCHES
        Level(
            id: 7,
            title: "Ship Your Feature",
            subtitle: "Merge Into Main",
            initialChat: [
                ChatMessage(sender: .alex, text: "QA just signed off on dark mode — zero bugs found! 🎉"),
                ChatMessage(sender: .maya, text: "Perfect timing. We can make the 4pm deploy"),
                ChatMessage(sender: .jordan, text: "Merge window closes at 3pm — gives ops time to build and stage"),
                ChatMessage(sender: .maya, text: "Switch to main and merge feature/dark-mode. Let's ship this"),
                ChatMessage(sender: .alex, text: "10,000 users are about to get dark mode! 🌙")
            ],
            stepChats: [
                0: [
                    ChatMessage(sender: .you, text: "Switched to main."),
                    ChatMessage(sender: .jordan, text: "On main now — ready to merge"),
                    ChatMessage(sender: .maya, text: "Go for it 🚀")
                ],
                1: [
                    ChatMessage(sender: .you, text: "Branches merged! 🔀"),
                    ChatMessage(sender: .maya, text: "Clean merge — no conflicts 🎉"),
                    ChatMessage(sender: .jordan, text: "Deploying to production..."),
                    ChatMessage(sender: .jordan, text: "Build passed. Staging verified. Going live..."),
                    ChatMessage(sender: .alex, text: "IT'S LIVE! First user just tweeted about dark mode! 📱"),
                    ChatMessage(sender: .maya, text: "Ship of the week goes to you. Welcome to the team 😊"),
                    ChatMessage(sender: .jordan, text: "From git init to production in one sprint. Seriously great work 🚀")
                ]
            ],
            icon: "arrow.triangle.merge",
            concept: .merging,
            commands: ["git-checkout", "git-merge"],
            requiredSteps: [
                LevelStep(
                    id: 1,
                    contextMessage: """
                    📍 SWITCH TO MAIN
                    
                    Before merging, switch to the branch you want to 
                    merge INTO (main).
                    
                    Think of it like: You can't pour coffee into a mug 
                    if you're not holding the mug.
                    """,
                    expectedCommand: "git checkout",
                    hint: "Use: git checkout main",
                    successMessage: "Switched to branch 'main'",
                    teamReaction: nil
                ),
                LevelStep(
                    id: 2,
                    contextMessage: """
                    📍 MERGE THE FEATURE
                    
                    Now merge your feature branch into main.
                    
                    This brings all your dark mode commits into the 
                    main branch.
                    """,
                    expectedCommand: "git merge",
                    hint: "Use: git merge feature/dark-mode",
                    successMessage: "🔀 Branches merged! Dark mode is now in main.",
                    teamReaction: """
                    Maya: Clean merge — no conflicts 🎉
                    Jordan: Deploying to production...
                    Alex: IT'S LIVE! First user just tweeted about dark mode! 📱
                    Maya: Ship of the week goes to you. Welcome to the team 😊
                    """
                )
            ],
            difficulty: .intermediate,
            estimatedTime: 5,
            commandExplanation: CommandExplanation(
                commands: [
                    CommandDetail(
                        command: "git checkout <branch>",
                        description: "Switches to the specified branch. Switch to the target branch before merging."
                    ),
                    CommandDetail(
                        command: "git merge <branch>",
                        description: "Merges the specified branch into your current branch."
                    )
                ],
                proTip: "Always switch to the branch you want to merge INTO, then merge FROM the feature branch. 'On main, merge feature'.",
                risk: "Merging the wrong direction can mess up your branch structure. Always verify with 'git status' before merging.",
                realWorldUsage: """
                Real merge workflow:
                1. git checkout main
                2. git pull origin main (get latest)
                3. git merge feature/dark-mode
                4. Resolve any conflicts
                5. git push origin main
                6. Delete the feature branch
                
                After successful merge:
                git branch -d feature/dark-mode (local)
                git push origin --delete feature/dark-mode (remote)
                """
            )
        )
    ]
    
    // MARK: - Navigation Helpers
    
    /// Looks up a level by its numeric ID.
    static func level(withId id: Int) -> Level? {
        allLevels.first { $0.id == id }
    }
    
    /// Returns the level immediately after this one, or `nil` if this is the last.
    func nextLevel() -> Level? {
        Level.allLevels.first { $0.id == self.id + 1 }
    }
    
    /// Returns the level immediately before this one, or `nil` if this is the first.
    func previousLevel() -> Level? {
        guard id > 1 else { return nil }
        return Level.allLevels.first { $0.id == self.id - 1 }
    }
}
