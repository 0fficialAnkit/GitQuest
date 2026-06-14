import Foundation
import SwiftUI

// MARK: - Core Level Model

/// Represents a single educational level or scenario in the Git game.
struct Level: Identifiable, Hashable {
    let id: Int
    let title: String

    /// Story messages displayed at the beginning of the level.
    let initialChat: [ChatMessage]

    /// Messages mapping to specific steps in the level when they are completed.
    let stepChats: [Int: [ChatMessage]]

    /// The SF Symbol icon representing the level.
    let icon: String

    /// The educational concept covered by this level.
    let concept: GitConcept

    /// The sequence of actions the user must perform to pass the level.
    let requiredSteps: [LevelStep]

    /// Provides additional educational breakdown of the commands used.
    let commandExplanation: CommandExplanation

    /// Link to the official Git documentation page most relevant to this level's concept.
    let referenceURL: URL

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: Level, rhs: Level) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Educational Concepts

/// Categorizes the primary Git skill being taught.
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

    /// Provides an associated SF Symbol for UI representation.
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

// MARK: - Step and Explanation Models

/// A single step requirement within a level.
struct LevelStep: Identifiable, Hashable {
    let id: Int
    let contextMessage: String
    let expectedCommand: String
    let hint: String
    let successMessage: String
}

/// A comprehensive explanation of commands taught in a level.
struct CommandExplanation: Hashable {
    let commands: [CommandDetail]
    let proTip: String
    let risk: String
    let realWorldUsage: String
}

/// A breakdown of a specific command string.
struct CommandDetail: Hashable {
    let command: String
    let description: String
}

// MARK: - Challenge Mode Helpers

extension LevelStep {
    /// A full, realistic example of the command expected for this step, used to
    /// show a meaningful answer in Challenge mode (where `expectedCommand` alone,
    /// e.g. "git add", would be too vague to display as "the answer").
    var exampleCommand: String {
        let prefix = "Tap: "
        guard hint.hasPrefix(prefix) else { return expectedCommand }
        return String(hint.dropFirst(prefix.count))
    }
}

// MARK: - Hardcoded Level Data

extension Level {

    /// The complete list of available levels in the game.
    static let allLevels: [Level] = [
        Level(
            id: 1,
            title: "Your First Commit",
            initialChat: [
                ChatMessage(sender: .siddharth, text: "Morning team! Customer dashboard project kicks off today 🚀"),
                ChatMessage(sender: .amrit, text: "I've got the React boilerplate ready - just need a repo to push it to"),
                ChatMessage(sender: .sumit, text: "Same here - UI mockups are done but I can't version them without Git"),
                ChatMessage(sender: .siddharth, text: "Can you initialize the repo? That'll unblock everyone before standup at 10"),
                ChatMessage(sender: .amrit, text: "Once the repo exists I'll push the starter template 👍")
            ],
            stepChats: [
                0: [
                    ChatMessage(sender: .you, text: "Repository initialized."),
                    ChatMessage(sender: .amrit, text: "Nice - repo's live. Now we need a README before I push the template"),
                    ChatMessage(sender: .siddharth, text: "Stage the README so Git knows to track it")
                ],
                1: [
                    ChatMessage(sender: .you, text: "Files staged."),
                    ChatMessage(sender: .amrit, text: "Good call staging specific files - keeps the commit clean"),
                    ChatMessage(sender: .siddharth, text: "Now commit it with a descriptive message. This'll be our first entry in the project history")
                ],
                2: [
                    ChatMessage(sender: .you, text: "First commit done! ✅"),
                    ChatMessage(sender: .siddharth, text: "Clean commit message - that makes the history way easier to review 👍"),
                    ChatMessage(sender: .amrit, text: "Pushing the starter template now. We're officially in business 🚀"),
                    ChatMessage(sender: .sumit, text: "Finally! Uploading the Figma exports. This sprint is going to be great")
                ]
            ],
            icon: "folder.fill.badge.plus",
            concept: .repository,
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
                    hint: "Tap: git init",
                    successMessage: "✓ Repository Created"
                ),
                LevelStep(
                    id: 2,
                    contextMessage: """
                    📍 STAGE YOUR CHANGES

                    Before committing, you need to tell Git which files to save.

                    'git add' stages files - like putting items in a shopping cart
                    before checkout.

                    Stage the README file.
                    """,
                    expectedCommand: "git add",
                    hint: "Tap: git add README.md",
                    successMessage: "Files staged and ready to commit"
                ),
                LevelStep(
                    id: 3,
                    contextMessage: """
                    📍 MAKE IT OFFICIAL

                    Now commit the README. This tells Git: "Save this
                    moment - I want to remember this state."

                    Real developers commit constantly. It's like saving
                    your game. Commit early, commit often.

                    Why teams love this: Everyone can see what changed.
                    """,
                    expectedCommand: "git commit",
                    hint: "Tap: git commit -m \"Initial commit: Add README\"",
                    successMessage: "🎉 You Just Shipped Your First Commit!"
                )
            ],
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
            ),
            referenceURL: URL(string: "https://git-scm.com/docs/git-init")!
        ),

        Level(
            id: 2,
            title: "Feature Branches",
            initialChat: [
                ChatMessage(sender: .siddharth, text: "Update from the design team - dark mode just got bumped to priority 1"),
                ChatMessage(sender: .sumit, text: "YES! Users have been requesting this for weeks 🌙"),
                ChatMessage(sender: .siddharth, text: "We deploy from main every Friday at 4pm. Can't have work-in-progress code there"),
                ChatMessage(sender: .amrit, text: "Create a feature branch - keeps main stable while you build"),
                ChatMessage(sender: .siddharth, text: "Call it feature/dark-mode and commit your changes there")
            ],
            stepChats: [
                0: [
                    ChatMessage(sender: .you, text: "Branch created!"),
                    ChatMessage(sender: .amrit, text: "Perfect - now anything you commit stays off main until it's ready"),
                    ChatMessage(sender: .siddharth, text: "Exactly. Friday deploy is safe. Build away 👍")
                ],
                1: [
                    ChatMessage(sender: .you, text: "Dark mode feature committed."),
                    ChatMessage(sender: .sumit, text: "Ooh can't wait to see this in the demo! 🌙"),
                    ChatMessage(sender: .siddharth, text: "Feature is safely isolated on its own branch. Nice workflow"),
                    ChatMessage(sender: .amrit, text: "Solid first feature branch. That's exactly how we do it here")
                ]
            ],
            icon: "arrow.triangle.branch",
            concept: .branching,
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
                    hint: "Tap: git checkout -b feature/dark-mode",
                    successMessage: "🌿 Feature Branch Created"
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
                    hint: "Tap: git commit -m \"Add dark mode toggle to settings\"",
                    successMessage: "Feature committed to your branch!"
                )
            ],
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
                risk: "Leaving old branches around clutters the repo. Delete merged branches with 'git branch -d <n>'",
                realWorldUsage: "Common patterns: feature/new-ui, bugfix/login-error, experiment/ai-suggestions"
            ),
            referenceURL: URL(string: "https://git-scm.com/docs/git-branch")!
        ),

        Level(
            id: 3,
            title: "Push to GitHub",
            initialChat: [
                ChatMessage(sender: .amrit, text: "Hey - I need to pull your auth components for my API integration work"),
                ChatMessage(sender: .amrit, text: "But I don't see your code on GitHub yet?"),
                ChatMessage(sender: .siddharth, text: "Ah right, we haven't connected the remote yet"),
                ChatMessage(sender: .siddharth, text: "Add the GitHub remote and push your commits - that'll unblock Jordan"),
                ChatMessage(sender: .amrit, text: "My code review is at 2pm so I need your stuff before then 😅")
            ],
            stepChats: [
                0: [
                    ChatMessage(sender: .you, text: "Remote added."),
                    ChatMessage(sender: .amrit, text: "Nice - local repo now knows where GitHub lives"),
                    ChatMessage(sender: .siddharth, text: "Now push your commits up so the team can access them")
                ],
                1: [
                    ChatMessage(sender: .you, text: "Code pushed! ☁️"),
                    ChatMessage(sender: .amrit, text: "Got it! Pulling now... auth components look solid 👀"),
                    ChatMessage(sender: .sumit, text: "I can see the commits on GitHub - looks great from here! 🎨"),
                    ChatMessage(sender: .siddharth, text: "Code is now backed up and shareable. Good work unblocking the team")
                ]
            ],
            icon: "cloud.fill",
            concept: .remote,
            requiredSteps: [
                LevelStep(
                    id: 1,
                    contextMessage: """
                    📍 GOING REMOTE

                    So far, Git has been local - only on your machine.

                    To collaborate, you need a "remote" - a shared version
                    of the repo on GitHub.

                    Think of it like:
                    • Your laptop = your private notes
                    • GitHub = the team's shared whiteboard

                    Add the remote repository.
                    """,
                    expectedCommand: "git remote",
                    hint: "Tap: git remote add origin https://github.com/gitquest-labs/user-profiles.git",
                    successMessage: "Remote added! Your local repo knows about GitHub now."
                ),
                LevelStep(
                    id: 2,
                    contextMessage: """
                    📍 SEND IT TO THE CLOUD

                    Now push your branch to GitHub so Alex can access it.

                    This uploads your commits to the remote repository.
                    """,
                    expectedCommand: "git push",
                    hint: "Tap: git push -u origin feature/dark-mode",
                    successMessage: "☁️ Code Pushed to GitHub"
                )
            ],
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
                proTip: "After the first push, you can just use 'git push' - tracking remembers the branch.",
                risk: "Force pushing (--force) can delete others' work. Only use if you know why.",
                realWorldUsage: "Every feature branch gets pushed so teammates can review PRs, CI/CD can run tests, and code is backed up."
            ),
            referenceURL: URL(string: "https://git-scm.com/docs/git-push")!
        ),

        Level(
            id: 4,
            title: "The 3 PM Crisis",
            initialChat: [
                ChatMessage(sender: .siddharth, text: "🚨 Heads up @channel - we have a merge conflict in dashboard.js"),
                ChatMessage(sender: .amrit, text: "That was me, sorry. I edited the same section Alex was working on"),
                ChatMessage(sender: .sumit, text: "The stakeholder demo is at 3:30 and the build is broken 😰"),
                ChatMessage(sender: .siddharth, text: "We need to resolve this before the demo. Can you take a look?"),
                ChatMessage(sender: .amrit, text: "Check git status first - it'll show you exactly which files are conflicted")
            ],
            stepChats: [
                0: [
                    ChatMessage(sender: .you, text: "Checking status..."),
                    ChatMessage(sender: .amrit, text: "There it is - dashboard.js has the conflict"),
                    ChatMessage(sender: .siddharth, text: "Open it up, pick the right version, and stage the fix")
                ],
                1: [
                    ChatMessage(sender: .you, text: "Conflict resolved in dashboard.js"),
                    ChatMessage(sender: .amrit, text: "Nice - you kept Alex's purple theme. Design team approved that one"),
                    ChatMessage(sender: .siddharth, text: "Good. Now commit the resolution so the build goes green")
                ],
                2: [
                    ChatMessage(sender: .you, text: "Merge commit done! 🎯"),
                    ChatMessage(sender: .sumit, text: "Build is green again! Demo is saved 🙏"),
                    ChatMessage(sender: .amrit, text: "Good call on the purple. That's the version design signed off on"),
                    ChatMessage(sender: .siddharth, text: "Nice work under pressure. That's real production debugging right there")
                ]
            ],
            icon: "exclamationmark.triangle.fill",
            concept: .conflicts,
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
                    hint: "Tap: git status",
                    successMessage: "Conflicts identified: dashboard.js"
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
                    hint: "Tap: git add dashboard.js",
                    successMessage: "Conflict marked as resolved"
                ),
                LevelStep(
                    id: 3,
                    contextMessage: """
                    📍 COMMIT THE RESOLUTION

                    Now commit the fix. This creates a "merge commit"
                    that brings both branches together.
                    """,
                    expectedCommand: "git commit",
                    hint: "Tap: git commit -m \"Resolve dashboard color conflict - use purple\"",
                    successMessage: "🎯 Conflict Resolved!"
                )
            ],
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
                proTip: "Never blindly accept one side - read the code. Test after resolving. Ask the other dev if unsure.",
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
            ),
            referenceURL: URL(string: "https://git-scm.com/docs/git-merge")!
        ),

        Level(
            id: 5,
            title: "Stay in Sync",
            initialChat: [
                ChatMessage(sender: .siddharth, text: "Morning! Pushed the auth service updates at 6am - couldn't sleep 😴"),
                ChatMessage(sender: .amrit, text: "Legend! Pulling now..."),
                ChatMessage(sender: .sumit, text: "Wait should I pull before I start my CSS work today?"),
                ChatMessage(sender: .siddharth, text: "YES - I changed the user model. You'll get conflicts otherwise"),
                ChatMessage(sender: .amrit, text: "Always pull first thing in the morning. Learned that one the hard way last sprint 😅")
            ],
            stepChats: [
                0: [
                    ChatMessage(sender: .you, text: "Pulled latest changes! 🔄"),
                    ChatMessage(sender: .amrit, text: "Nice - now you've got Maya's auth refactor. Way cleaner API 👍"),
                    ChatMessage(sender: .siddharth, text: "Good habit. You're in sync for standup"),
                    ChatMessage(sender: .sumit, text: "Same here, just pulled. No conflicts on my end 🎉")
                ]
            ],
            icon: "arrow.left.arrow.right",
            concept: .collaboration,
            requiredSteps: [
                LevelStep(
                    id: 1,
                    contextMessage: """
                    📍 GET THE LATEST

                    'git pull' fetches changes from GitHub and merges
                    them into your local branch.

                    It's like syncing your Dropbox - you get everyone
                    else's updates.

                    Pull the latest changes from main.
                    """,
                    expectedCommand: "git pull",
                    hint: "Tap: git pull origin main",
                    successMessage: "🔄 Up to date! You have the latest team changes."
                )
            ],
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
                risk: "Pulling can cause merge conflicts if you and a teammate edited the same files. That's normal - just resolve them.",
                realWorldUsage: "Pro workflow: git pull → review changes → git checkout -b feature/new-work → start coding"
            ),
            referenceURL: URL(string: "https://git-scm.com/docs/git-pull")!
        ),

        Level(
            id: 6,
            title: "Time Travel",
            initialChat: [
                ChatMessage(sender: .you, text: "Oh no. I just committed the .env file with all our API keys 😱"),
                ChatMessage(sender: .amrit, text: "STOP - don't push yet! 🚨"),
                ChatMessage(sender: .siddharth, text: "OK this is recoverable. Did you already push to GitHub?"),
                ChatMessage(sender: .you, text: "No, just committed locally"),
                ChatMessage(sender: .amrit, text: "Good. Use git reset HEAD~1 - it'll undo the commit but keep your files"),
                ChatMessage(sender: .siddharth, text: "The keys will still be in the file, just not committed. Then we'll add .env to .gitignore"),
                ChatMessage(sender: .sumit, text: "This happened to me my first week too, don't stress 😅")
            ],
            stepChats: [
                0: [
                    ChatMessage(sender: .you, text: "Commit undone! ⏮️"),
                    ChatMessage(sender: .amrit, text: "Crisis averted 👍 Now remove the keys and add .env to .gitignore before re-committing"),
                    ChatMessage(sender: .siddharth, text: "Good catch. If those keys had reached GitHub we'd be rotating every credential tonight"),
                    ChatMessage(sender: .sumit, text: "Git literally just saved us. Adding .env to .gitignore now so this can't happen again")
                ]
            ],
            icon: "clock.arrow.circlepath",
            concept: .history,
            requiredSteps: [
                LevelStep(
                    id: 1,
                    contextMessage: """
                    📍 UNDO THE COMMIT

                    'git reset HEAD~1' removes the last commit from history
                    BUT keeps your changes in the files.

                    This lets you fix the mistake and re-commit correctly.

                    Your API keys will still be in the file - just not
                    committed anymore.
                    """,
                    expectedCommand: "git reset",
                    hint: "Tap: git reset HEAD~1",
                    successMessage: "⏮️ Commit undone! Changes are still in your files."
                )
            ],
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
            ),
            referenceURL: URL(string: "https://git-scm.com/docs/git-reset")!
        ),

        Level(
            id: 7,
            title: "Ship Your Feature",
            initialChat: [
                ChatMessage(sender: .sumit, text: "QA just signed off on dark mode - zero bugs found! 🎉"),
                ChatMessage(sender: .siddharth, text: "Perfect timing. We can make the 4pm deploy"),
                ChatMessage(sender: .amrit, text: "Merge window closes at 3pm - gives ops time to build and stage"),
                ChatMessage(sender: .siddharth, text: "Switch to main and merge feature/dark-mode. Let's ship this"),
                ChatMessage(sender: .sumit, text: "10,000 users are about to get dark mode! 🌙")
            ],
            stepChats: [
                0: [
                    ChatMessage(sender: .you, text: "Switched to main."),
                    ChatMessage(sender: .amrit, text: "On main now - ready to merge"),
                    ChatMessage(sender: .siddharth, text: "Go for it 🚀")
                ],
                1: [
                    ChatMessage(sender: .you, text: "Branches merged! 🔀"),
                    ChatMessage(sender: .siddharth, text: "Clean merge - no conflicts 🎉"),
                    ChatMessage(sender: .amrit, text: "Deploying to production..."),
                    ChatMessage(sender: .amrit, text: "Build passed. Staging verified. Going live..."),
                    ChatMessage(sender: .sumit, text: "IT'S LIVE! First user just tweeted about dark mode! 📱"),
                    ChatMessage(sender: .siddharth, text: "Ship of the week goes to you. Welcome to the team 😊"),
                    ChatMessage(sender: .amrit, text: "From git init to production in one sprint. Seriously great work 🚀")
                ]
            ],
            icon: "arrow.triangle.merge",
            concept: .merging,
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
                    hint: "Tap: git checkout main",
                    successMessage: "Switched to branch 'main'"
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
                    hint: "Tap: git merge feature/dark-mode",
                    successMessage: "🔀 Branches merged! Dark mode is now in main."
                )
            ],
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
            ),
            referenceURL: URL(string: "https://git-scm.com/docs/git-merge")!
        ),

        Level(
            id: 8,
            title: "Don't Lose That Work",
            initialChat: [
                ChatMessage(sender: .siddharth, text: "🚨 Production bug just got reported - login button is broken on Safari"),
                ChatMessage(sender: .amrit, text: "That's bad, we need a hotfix on main ASAP"),
                ChatMessage(sender: .sumit, text: "I'm mid-way through the settings redesign - half my files are a mess right now"),
                ChatMessage(sender: .siddharth, text: "No worries - stash your changes, fix the bug on main, then come right back to it"),
                ChatMessage(sender: .amrit, text: "git stash is perfect for this. It saves your work-in-progress without committing half-finished code")
            ],
            stepChats: [
                0: [
                    ChatMessage(sender: .you, text: "Changes stashed! 📦"),
                    ChatMessage(sender: .amrit, text: "Nice - your working directory is clean now. Go fix that login bug"),
                    ChatMessage(sender: .siddharth, text: "Thanks for the quick turnaround 🙏 Bug's patched, you're all clear")
                ],
                1: [
                    ChatMessage(sender: .you, text: "Stash restored! 📦"),
                    ChatMessage(sender: .sumit, text: "Phew, exactly where I left off. Continuing the settings redesign now"),
                    ChatMessage(sender: .amrit, text: "That's the power of stash - context-switch without losing anything"),
                    ChatMessage(sender: .siddharth, text: "Clean workflow. This is exactly how pros handle interruptions")
                ]
            ],
            icon: "archivebox.fill",
            concept: .advanced,
            requiredSteps: [
                LevelStep(
                    id: 1,
                    contextMessage: """
                    📍 SAVE YOUR WORK-IN-PROGRESS

                    You're mid-way through the settings redesign, but
                    a production bug needs fixing on main RIGHT NOW.

                    Your changes aren't ready to commit - they're not
                    even finished. But you can't just lose them either.

                    'git stash' temporarily shelves your uncommitted
                    changes and gives you back a clean working directory.

                    Think of it like: Putting your half-finished sketch
                    in a drawer so you can borrow the desk.
                    """,
                    expectedCommand: "git stash",
                    hint: "Tap: git stash",
                    successMessage: "📦 Changes Stashed - Working Directory Clean"
                ),
                LevelStep(
                    id: 2,
                    contextMessage: """
                    📍 GET YOUR WORK BACK

                    The hotfix is shipped and main is stable again.

                    Now bring back your settings redesign exactly as
                    you left it.

                    'git stash pop' re-applies your most recent stash
                    and removes it from the stash list.
                    """,
                    expectedCommand: "git stash pop",
                    hint: "Tap: git stash pop",
                    successMessage: "📦 Stash Restored - Back to Work"
                )
            ],
            commandExplanation: CommandExplanation(
                commands: [
                    CommandDetail(
                        command: "git stash",
                        description: "Temporarily saves your uncommitted changes and restores a clean working directory."
                    ),
                    CommandDetail(
                        command: "git stash pop",
                        description: "Re-applies your most recently stashed changes and removes them from the stash list."
                    )
                ],
                proTip: "Use 'git stash list' to see all your stashes, and 'git stash save \"message\"' to label them so you remember what's in each one.",
                risk: "Stashes can pile up and get forgotten. Run 'git stash list' occasionally - an old stash is easy to lose track of.",
                realWorldUsage: "Developers stash dozens of times a week when interrupted by urgent bugs, code reviews, or 'can you jump on a call?' messages."
            ),
            referenceURL: URL(string: "https://git-scm.com/docs/git-stash")!
        ),

        Level(
            id: 9,
            title: "The Hotfix Cherry-Pick",
            initialChat: [
                ChatMessage(sender: .amrit, text: "Fixed that critical null-pointer bug on hotfix/null-check - tests all pass ✅"),
                ChatMessage(sender: .siddharth, text: "Great, but main needs that fix immediately too - we can't wait for the full branch to merge"),
                ChatMessage(sender: .sumit, text: "Can we just grab that one commit without merging everything else from that branch?"),
                ChatMessage(sender: .amrit, text: "Yep - cherry-pick! It copies a single commit's changes onto another branch"),
                ChatMessage(sender: .siddharth, text: "Switch to main and cherry-pick that fix commit")
            ],
            stepChats: [
                0: [
                    ChatMessage(sender: .you, text: "Switched to main."),
                    ChatMessage(sender: .amrit, text: "Good - now grab that commit and bring it over")
                ],
                1: [
                    ChatMessage(sender: .you, text: "Fix cherry-picked! 🍒"),
                    ChatMessage(sender: .siddharth, text: "main is patched. Deploying the hotfix now"),
                    ChatMessage(sender: .sumit, text: "hotfix/null-check can still go through normal review later"),
                    ChatMessage(sender: .amrit, text: "Exactly - cherry-pick gets urgent fixes out without skipping process")
                ]
            ],
            icon: "doc.on.doc.fill",
            concept: .advanced,
            requiredSteps: [
                LevelStep(
                    id: 1,
                    contextMessage: """
                    📍 GET TO THE RIGHT BRANCH

                    Before you can bring the fix to main, you need
                    to be standing on main.

                    Switch to the main branch first.
                    """,
                    expectedCommand: "git checkout",
                    hint: "Tap: git checkout main",
                    successMessage: "Switched to branch 'main'"
                ),
                LevelStep(
                    id: 2,
                    contextMessage: """
                    📍 COPY JUST THAT ONE COMMIT

                    The fix lives in a single commit on hotfix/null-check.

                    'git cherry-pick <commit-hash>' applies the changes
                    from that ONE commit onto your current branch as a
                    brand-new commit - without bringing along anything
                    else from that branch.

                    Cherry-pick the fix commit onto main.
                    """,
                    expectedCommand: "git cherry-pick",
                    hint: "Tap: git cherry-pick a1b2c3d",
                    successMessage: "🍒 Commit Cherry-Picked onto main"
                )
            ],
            commandExplanation: CommandExplanation(
                commands: [
                    CommandDetail(
                        command: "git checkout <branch>",
                        description: "Switches your working directory to the target branch."
                    ),
                    CommandDetail(
                        command: "git cherry-pick <commit-hash>",
                        description: "Applies the changes from a specific commit onto your current branch as a new commit."
                    )
                ],
                proTip: "Cherry-pick is great for backporting urgent fixes. For whole features, prefer a full merge so you don't end up with duplicate-looking commits.",
                risk: "Cherry-picking the same commit onto multiple branches can create confusing, duplicate-looking history. Use it sparingly and intentionally.",
                realWorldUsage: "Classic hotfix flow: fix on a feature/hotfix branch, then cherry-pick that single commit onto main AND any active release branches."
            ),
            referenceURL: URL(string: "https://git-scm.com/docs/git-cherry-pick")!
        ),

        Level(
            id: 10,
            title: "Tag the Release",
            initialChat: [
                ChatMessage(sender: .sumit, text: "QA just finished testing - dark mode and the hotfix are both stable 🎉"),
                ChatMessage(sender: .siddharth, text: "Perfect timing for our v1.0 release"),
                ChatMessage(sender: .amrit, text: "We should tag this commit so we can always find this exact version later"),
                ChatMessage(sender: .siddharth, text: "Tag it v1.0 and push the tag to GitHub so the release pipeline picks it up"),
                ChatMessage(sender: .sumit, text: "Release notes are ready to go the second that tag lands")
            ],
            stepChats: [
                0: [
                    ChatMessage(sender: .you, text: "Tag v1.0 created! 🏷️"),
                    ChatMessage(sender: .amrit, text: "Now push it up so CI can build the release artifact")
                ],
                1: [
                    ChatMessage(sender: .you, text: "Tag pushed to GitHub! ☁️"),
                    ChatMessage(sender: .siddharth, text: "Release pipeline triggered - v1.0 is building now"),
                    ChatMessage(sender: .sumit, text: "Publishing release notes for v1.0 🎉"),
                    ChatMessage(sender: .amrit, text: "And just like that, anyone can check out v1.0 forever. Nice work")
                ]
            ],
            icon: "tag.fill",
            concept: .advanced,
            requiredSteps: [
                LevelStep(
                    id: 1,
                    contextMessage: """
                    📍 MARK THIS MOMENT

                    Right now this commit represents your v1.0 release -
                    but commits only have cryptic hashes.

                    'git tag' creates a permanent, human-friendly name
                    pointing at this exact commit.

                    Think of it like: Bookmarking the exact page in a
                    book you might need to find again.

                    Create a tag called v1.0.
                    """,
                    expectedCommand: "git tag",
                    hint: "Tap: git tag v1.0",
                    successMessage: "🏷️ Tag v1.0 Created"
                ),
                LevelStep(
                    id: 2,
                    contextMessage: """
                    📍 SHARE THE RELEASE MARKER

                    Tags live only on your machine until you push them -
                    they're NOT included in a normal 'git push'.

                    Push the v1.0 tag to origin so the team and your
                    CI/CD pipeline can see it.
                    """,
                    expectedCommand: "git push",
                    hint: "Tap: git push origin v1.0",
                    successMessage: "☁️ Tag Pushed - Release Triggered"
                )
            ],
            commandExplanation: CommandExplanation(
                commands: [
                    CommandDetail(
                        command: "git tag v1.0",
                        description: "Creates a lightweight tag pointing at the current commit - a permanent named marker."
                    ),
                    CommandDetail(
                        command: "git push origin v1.0",
                        description: "Uploads the tag to the remote so it's visible to the whole team and CI/CD."
                    )
                ],
                proTip: "For real releases, prefer annotated tags: 'git tag -a v1.0 -m \"First stable release\"' - they store the author, date, and a message.",
                risk: "Tags aren't pushed automatically with 'git push'. You must push them explicitly by name, or use 'git push --tags' for all of them.",
                realWorldUsage: "Every versioned release (v1.0, v2.3.1) is a Git tag. CI/CD pipelines often trigger production builds the moment a tag matching v*.*.* is pushed."
            ),
            referenceURL: URL(string: "https://git-scm.com/docs/git-tag")!
        ),

        Level(
            id: 11,
            title: "Clean Up the Mess",
            initialChat: [
                ChatMessage(sender: .sumit, text: "Hey, why is our repo 200MB now?? Cloning takes forever 😩"),
                ChatMessage(sender: .amrit, text: "Let me check... oh no, someone committed the entire node_modules folder"),
                ChatMessage(sender: .siddharth, text: "Happens to literally everyone once. Let's fix it - untrack it and add it to .gitignore"),
                ChatMessage(sender: .amrit, text: "'git rm --cached' keeps the files on your disk but stops Git from tracking them"),
                ChatMessage(sender: .siddharth, text: "Then add node_modules/ to .gitignore so this can never happen again")
            ],
            stepChats: [
                0: [
                    ChatMessage(sender: .you, text: "node_modules untracked! 🧹"),
                    ChatMessage(sender: .amrit, text: "Good - Git will ignore it going forward. But we still need the .gitignore rule so it isn't re-added by accident")
                ],
                1: [
                    ChatMessage(sender: .you, text: ".gitignore staged."),
                    ChatMessage(sender: .siddharth, text: "Now commit this cleanup - future clones will be tiny again")
                ],
                2: [
                    ChatMessage(sender: .you, text: "Cleanup committed! ✨"),
                    ChatMessage(sender: .sumit, text: "Re-cloning now... whoa, 4MB instead of 200MB. Huge difference"),
                    ChatMessage(sender: .amrit, text: "Lesson learned: always set up .gitignore before your very first commit"),
                    ChatMessage(sender: .siddharth, text: "Exactly why we're adding this to the onboarding checklist")
                ]
            ],
            icon: "folder.badge.minus",
            concept: .repository,
            requiredSteps: [
                LevelStep(
                    id: 1,
                    contextMessage: """
                    📍 STOP TRACKING THE FOLDER

                    node_modules got committed by accident and it's
                    bloating the whole repo for everyone.

                    'git rm -r --cached <folder>' removes a folder from
                    Git's tracking (the index) WITHOUT deleting it from
                    your disk - your files are safe.

                    Untrack node_modules.
                    """,
                    expectedCommand: "git rm",
                    hint: "Tap: git rm -r --cached node_modules",
                    successMessage: "🧹 node_modules Untracked"
                ),
                LevelStep(
                    id: 2,
                    contextMessage: """
                    📍 PREVENT IT FROM HAPPENING AGAIN

                    A .gitignore file lists patterns of files and
                    folders Git should never track - things like
                    node_modules/, .env, and build/.

                    Stage the new .gitignore file.
                    """,
                    expectedCommand: "git add",
                    hint: "Tap: git add .gitignore",
                    successMessage: ".gitignore Staged"
                ),
                LevelStep(
                    id: 3,
                    contextMessage: """
                    📍 SAVE THE CLEANUP

                    Commit the untracking and the new .gitignore
                    together as one tidy cleanup commit.
                    """,
                    expectedCommand: "git commit",
                    hint: "Tap: git commit -m \"Remove node_modules from tracking\"",
                    successMessage: "✨ Repo Cleaned Up"
                )
            ],
            commandExplanation: CommandExplanation(
                commands: [
                    CommandDetail(
                        command: "git rm -r --cached <folder>",
                        description: "Removes files from Git's tracking (the index) while leaving them safely on your disk."
                    ),
                    CommandDetail(
                        command: ".gitignore",
                        description: "A text file listing patterns of files/folders Git should never track - like node_modules/, .env, build/."
                    ),
                    CommandDetail(
                        command: "git commit -m \"message\"",
                        description: "Saves the cleanup as a permanent step in history."
                    )
                ],
                proTip: "Set up .gitignore BEFORE your first commit, using a template for your language or framework (github.com/github/gitignore).",
                risk: "'git rm --cached' only stops FUTURE tracking - the file is still in OLD commits. For secrets, you may need to rewrite history entirely.",
                realWorldUsage: "Nearly every repo has a .gitignore from day one. Forgetting it is the #1 cause of bloated repos and accidentally committed secrets."
            ),
            referenceURL: URL(string: "https://git-scm.com/docs/gitignore")!
        ),

        Level(
            id: 12,
            title: "Safe Undo in Public",
            initialChat: [
                ChatMessage(sender: .siddharth, text: "🚨 The commit I pushed an hour ago broke the build - sorry team"),
                ChatMessage(sender: .amrit, text: "It's already on main and two people have pulled it. We can't reset - that would rewrite shared history"),
                ChatMessage(sender: .sumit, text: "Isn't there a way to undo it without messing up everyone else's branches?"),
                ChatMessage(sender: .amrit, text: "git revert! It creates a NEW commit that undoes the changes - history stays intact"),
                ChatMessage(sender: .siddharth, text: "Do it - revert my last commit so the build goes green again")
            ],
            stepChats: [
                0: [
                    ChatMessage(sender: .you, text: "Commit reverted! ↩️"),
                    ChatMessage(sender: .amrit, text: "Build's green again 🎉 And nobody needs to do anything special - just pull like normal"),
                    ChatMessage(sender: .siddharth, text: "Reverting is so much safer than reset once something's pushed. Lesson learned"),
                    ChatMessage(sender: .sumit, text: "Pulling now... no conflicts, smooth as ever")
                ]
            ],
            icon: "arrow.uturn.backward.circle.fill",
            concept: .history,
            requiredSteps: [
                LevelStep(
                    id: 1,
                    contextMessage: """
                    📍 UNDO SOMETHING THAT'S ALREADY SHARED

                    Back in Level 6, 'git reset' undid a LOCAL,
                    unpushed commit. That worked because nobody else
                    had seen it yet.

                    This commit is different - it's already on main
                    and teammates have pulled it. Resetting now would
                    rewrite history they already have, causing chaos.

                    'git revert HEAD' creates a brand-new commit that
                    applies the EXACT OPPOSITE of the last commit -
                    undoing its changes without deleting it from history.

                    Revert the last commit.
                    """,
                    expectedCommand: "git revert",
                    hint: "Tap: git revert HEAD",
                    successMessage: "↩️ Commit Safely Reverted"
                )
            ],
            commandExplanation: CommandExplanation(
                commands: [
                    CommandDetail(
                        command: "git revert HEAD",
                        description: "Creates a brand-new commit that applies the exact opposite of the targeted commit, undoing its changes without removing it from history."
                    )
                ],
                proTip: "Revert is the safe choice for anything already pushed and shared. Reset (Level 6) is only for local, unpushed mistakes.",
                risk: "Reverting a merge commit needs the -m flag to specify which parent to revert to - get it wrong and you can undo the wrong side of history.",
                realWorldUsage: """
                Reset vs Revert - the golden rule:
                • Not pushed yet? → git reset is fine, nobody else has seen it
                • Already pushed / shared? → git revert, never reset shared history

                Reverting is how teams safely undo bad deploys without
                rewriting history that others have already pulled.
                """
            ),
            referenceURL: URL(string: "https://git-scm.com/docs/git-revert")!
        ),

        Level(
            id: 13,
            title: "Investigate the Bug",
            initialChat: [
                ChatMessage(sender: .sumit, text: "Users are reporting the checkout button doesn't work on Safari 😬"),
                ChatMessage(sender: .siddharth, text: "Let's figure out when this broke and who last touched checkout.js"),
                ChatMessage(sender: .amrit, text: "git log will give us the recent commit history for context"),
                ChatMessage(sender: .siddharth, text: "And git blame will show exactly which commit changed each line of checkout.js"),
                ChatMessage(sender: .amrit, text: "Once we know the commit, we can revert it or ping whoever wrote it")
            ],
            stepChats: [
                0: [
                    ChatMessage(sender: .you, text: "History displayed 📜"),
                    ChatMessage(sender: .siddharth, text: "There it is - 'Refactor checkout validation' from yesterday, right when reports started")
                ],
                1: [
                    ChatMessage(sender: .you, text: "Blame results shown 🔍"),
                    ChatMessage(sender: .amrit, text: "Line 42 - that's the validation check. That commit touched it yesterday"),
                    ChatMessage(sender: .siddharth, text: "Got it. Pinging the author now - this is exactly the kind of thing git blame is built for"),
                    ChatMessage(sender: .sumit, text: "Mystery solved in under 2 minutes. Love it")
                ]
            ],
            icon: "magnifyingglass",
            concept: .history,
            requiredSteps: [
                LevelStep(
                    id: 1,
                    contextMessage: """
                    📍 SEE WHAT CHANGED RECENTLY

                    Before you can fix a regression, you need to know
                    what changed and when.

                    'git log --oneline' shows a condensed history -
                    one line per commit, with its hash and message.

                    Show the recent commit history.
                    """,
                    expectedCommand: "git log",
                    hint: "Tap: git log --oneline",
                    successMessage: "📜 Commit History Displayed"
                ),
                LevelStep(
                    id: 2,
                    contextMessage: """
                    📍 FIND WHO TOUCHED THIS LINE

                    'git log' tells you WHAT changed across the
                    project. 'git blame <file>' tells you WHO last
                    changed each individual LINE of a specific file,
                    and in which commit.

                    Run blame on checkout.js to find the culprit commit.
                    """,
                    expectedCommand: "git blame",
                    hint: "Tap: git blame checkout.js",
                    successMessage: "🔍 Blame Results Shown"
                )
            ],
            commandExplanation: CommandExplanation(
                commands: [
                    CommandDetail(
                        command: "git log --oneline",
                        description: "Shows a condensed, one-line-per-commit view of project history - hash plus message."
                    ),
                    CommandDetail(
                        command: "git blame <file>",
                        description: "Shows who last modified each line of a file, and in which commit - perfect for tracking down regressions."
                    )
                ],
                proTip: "Combine them: 'git log --oneline -- checkout.js' shows only the commits that touched that specific file.",
                risk: "git blame shows who LAST touched a line - not necessarily who introduced the bug. The real cause might be several commits earlier.",
                realWorldUsage: "Every developer reaches for log and blame multiple times a week. Xcode and VS Code even show inline blame annotations right next to your code."
            ),
            referenceURL: URL(string: "https://git-scm.com/docs/git-log")!
        )
    ]

    // MARK: - Helper Methods

    /// Looks up a level by its ID.
    static func level(withId id: Int) -> Level? {
        allLevels.first { $0.id == id }
    }

    /// Looks up the immediate next level in sequence after the current one.
    func nextLevel() -> Level? {
        Level.allLevels.first { $0.id == self.id + 1 }
    }
}
