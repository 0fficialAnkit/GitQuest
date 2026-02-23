import Foundation

/// Data model holding all educational content shown after completing a level.
/// Used by both CompletedInfoCard and LearningDetailSheet.
struct LearningContent {
    let concept: String
    let whyItExists: String
    let whenUsed: String
    let realWorldUsage: [String]
    let tips: [String]
    let risks: [String]
    let scenario: String

    static func content(for levelId: Int) -> LearningContent {
        switch levelId {
        case 1:
            return LearningContent(
                concept: "A Git repository is a hidden .git folder that tracks every change you make to your project files. Think of it as a time machine for your code.",
                whyItExists: "Without version control, you'd rely on copying folders like 'project_final_v2_REAL'. Git gives you a structured history of every change, who made it, and why.",
                whenUsed: "Every software project starts with git init. It's the very first command you run when creating something new, whether it's a personal script or a startup's codebase.",
                realWorldUsage: [
                    "Every new project at companies like Google, Apple, and Meta starts with initializing a repository",
                    "Open-source projects on GitHub all begin with git init before any code is written",
                    "CI/CD pipelines depend on a valid Git repo to build, test, and deploy automatically",
                    "Even solo developers use repos to safely experiment without losing working code"
                ],
                tips: [
                    "Run git init only once per project - it creates the .git folder that tracks everything",
                    "Use git status constantly - it's your GPS in the Git world",
                    "Add a .gitignore file early to exclude build artifacts, secrets, and OS files",
                    "Commit early and often - small commits are easier to understand and revert",
                    "Write meaningful commit messages from day one - future you will be grateful"
                ],
                risks: [
                    "Deleting the .git folder wipes your entire project history - there's no undo",
                    "Running git init inside an existing repo creates a nested repo, causing confusion",
                    "Forgetting .gitignore can accidentally commit passwords, API keys, or large binary files",
                    "Avoid these by always checking git status before committing"
                ],
                scenario: "It's your first day at a startup. Your tech lead says: 'Set up the new microservice repo.' You run git init, add a .gitignore, make your first commit, and push to GitHub. The CI pipeline picks it up and your service is ready for development. You just laid the foundation for the entire team's workflow."
            )
        case 2:
            return LearningContent(
                concept: "Staging is Git's prep zone. Before committing, you choose exactly which changes to include. It's like reviewing what goes into a package before sealing it.",
                whyItExists: "Not every change belongs in the same commit. Staging lets you group related changes together, keeping your history clean and meaningful.",
                whenUsed: "Every single commit starts with staging. You use git add to select files, then git commit to save them. It's the two-step rhythm of every Git workflow.",
                realWorldUsage: [
                    "Developers stage only bug-fix files separately from feature work for clean pull requests",
                    "Code reviews are much easier when commits are focused - staging makes this possible",
                    "Teams use staging to separate database migrations from application code changes",
                    "git add -p lets you stage individual lines, not just whole files - surgical precision"
                ],
                tips: [
                    "Use git add . carefully - it stages everything, including files you might not want",
                    "Prefer git add <specific-file> to keep commits focused and reviewable",
                    "Use git diff --staged to review exactly what you're about to commit",
                    "Unstage mistakes with git reset HEAD <file> - no changes are lost",
                    "Think of each commit as telling a story - staging helps you write clean chapters"
                ],
                risks: [
                    "git add . can accidentally stage secrets, debug files, or unfinished work",
                    "Forgetting to stage new files means they won't appear in your commit",
                    "Staging and committing mixed changes makes git blame and git bisect harder to use",
                    "Always run git status and git diff --staged before committing to catch mistakes"
                ],
                scenario: "You fixed a login bug AND started a new feature in the same session. Instead of committing everything together, you use git add auth.swift and commit the fix first. Then you stage the feature files separately. Your colleague reviews two clean, focused pull requests instead of one messy blob."
            )
        case 3:
            return LearningContent(
                concept: "Branches are parallel timelines for your code. The main branch stays stable while you experiment freely on a separate branch. When your work is ready, you merge it back.",
                whyItExists: "Without branches, every developer would edit the same files simultaneously, causing constant conflicts. Branches let teams work independently and merge when ready.",
                whenUsed: "Every feature, bug fix, and experiment gets its own branch. It's the foundation of collaborative development - you'll create hundreds of branches in your career.",
                realWorldUsage: [
                    "Feature branches like feature/user-auth keep new work isolated until it's reviewed and tested",
                    "Hotfix branches let teams patch production bugs without disrupting ongoing feature work",
                    "Release branches stabilize code before deployment while new features continue on main",
                    "GitHub Flow and GitFlow are entire workflows built around branching strategies"
                ],
                tips: [
                    "Name branches descriptively: feature/add-login, fix/crash-on-launch, refactor/database-layer",
                    "Keep branches short-lived - merge within days, not weeks, to avoid drift",
                    "Always branch from an up-to-date main to minimize future merge conflicts",
                    "Delete merged branches to keep the repo clean: git branch -d branch-name",
                    "Use git branch -a to see all branches including remote ones"
                ],
                risks: [
                    "Long-lived branches diverge from main, making merges painful or even impossible",
                    "Working directly on main risks breaking the production codebase for everyone",
                    "Forgetting which branch you're on can lead to committing to the wrong place",
                    "Check your branch with git branch before making changes - make it a habit"
                ],
                scenario: "The product manager needs a dark mode feature for the app. You create feature/dark-mode, spend three days building it, and open a pull request. Meanwhile, two other developers ship a bug fix and a performance improvement on their own branches - nobody's work interferes with anyone else's."
            )
        case 4:
            return LearningContent(
                concept: "Merging combines work from different branches into one. It's how isolated features, fixes, and experiments become part of the main codebase.",
                whyItExists: "After branching, you need a way to bring everything back together. Merging integrates completed work while preserving the history of how it was developed.",
                whenUsed: "After a feature is complete and code-reviewed, you merge it into main. This happens multiple times per day on active teams - it's the heartbeat of collaboration.",
                realWorldUsage: [
                    "Pull requests on GitHub are essentially merge proposals - review, approve, then merge",
                    "CI pipelines run tests on the merge result before allowing it into main",
                    "Teams use squash merges to condense messy feature history into one clean commit",
                    "Release managers merge release branches into main and tag them for deployment"
                ],
                tips: [
                    "Always pull the latest main before merging to minimize conflicts",
                    "Use git merge --no-ff to preserve the branch history in the commit graph",
                    "Resolve merge conflicts carefully - don't just accept one side blindly",
                    "Run tests after merging to ensure nothing broke in the integration",
                    "Consider rebasing for a linear history in smaller teams or solo projects"
                ],
                risks: [
                    "Merge conflicts happen when two branches edit the same lines - don't panic, read carefully",
                    "Force-resolving conflicts by always choosing 'ours' or 'theirs' can silently drop code",
                    "Merging untested code into main can break the build for the entire team",
                    "Use git merge --abort if a merge goes wrong - you can always start over cleanly"
                ],
                scenario: "Friday afternoon. Two feature branches need to ship before the weekend release. You merge feature/payments first - clean, no conflicts. Then feature/notifications has a conflict in the shared config file. You carefully resolve it, run the test suite, and merge. Both features ship on time."
            )
        case 5:
            return LearningContent(
                concept: "Remote repositories are copies of your project hosted on servers like GitHub. They let multiple developers share work, back up code, and collaborate across the world.",
                whyItExists: "Local repos live only on your machine. Remotes let you push your work to a shared location, pull others' changes, and ensure code survives laptop failures.",
                whenUsed: "Every collaborative project uses remotes. You push to share your work, pull to get updates, and clone to start working on existing projects.",
                realWorldUsage: [
                    "GitHub, GitLab, and Bitbucket host millions of remote repositories for teams worldwide",
                    "git push deploys code to production servers in many CI/CD pipelines",
                    "Forking creates your own remote copy of an open-source project to contribute to",
                    "Remote backups mean a stolen laptop doesn't mean lost code"
                ],
                tips: [
                    "Set up SSH keys for passwordless push/pull - saves time and is more secure",
                    "Use git remote -v to verify your remote URLs are correct",
                    "Always pull before pushing to avoid rejection errors",
                    "Use git fetch to see what's changed on the remote without modifying your local files",
                    "Name your primary remote 'origin' - it's the universal convention"
                ],
                risks: [
                    "git push --force can overwrite your teammates' commits on the remote - extremely dangerous",
                    "Pushing secrets (API keys, passwords) to a public remote exposes them permanently",
                    "Forgetting to push means your work exists only locally - one disk failure and it's gone",
                    "Use git push --force-with-lease instead of --force - it checks if anyone pushed first"
                ],
                scenario: "You're contributing to an open-source project. You fork the repo, clone it locally, create a branch, make your fix, push to your fork, and open a pull request. The maintainer reviews it, suggests a change, you push an update, and your code gets merged into a project used by thousands of developers."
            )
        case 6:
            return LearningContent(
                concept: "Collaboration in Git means multiple developers working on the same codebase simultaneously. Pull requests, code reviews, and branch protection rules keep everything organized.",
                whyItExists: "Software is built by teams. Git's collaboration features ensure that everyone's work integrates smoothly, code quality stays high, and nothing ships without review.",
                whenUsed: "Every day on a development team. You pull changes, push your work, review others' code, and resolve conflicts. It's the daily rhythm of professional development.",
                realWorldUsage: [
                    "Pull requests are the standard for code review at virtually every tech company",
                    "Branch protection rules prevent direct pushes to main - all changes go through review",
                    "CODEOWNERS files automatically assign reviewers based on which files were changed",
                    "Teams use git stash to save work-in-progress before switching to review a colleague's PR"
                ],
                tips: [
                    "Pull frequently - small, regular syncs prevent massive conflict nightmares",
                    "Write descriptive PR descriptions explaining what changed and why",
                    "Review others' code generously - it improves the whole team's quality",
                    "Use git stash when you need to context-switch quickly without committing",
                    "Establish branch naming conventions with your team early on"
                ],
                risks: [
                    "Not pulling before starting work creates divergent histories and painful merges",
                    "Pushing directly to main bypasses review and can ship bugs to production",
                    "Ignoring merge conflicts or resolving them carelessly loses other people's work",
                    "Communicate with your team when working on shared files to avoid duplicate effort"
                ],
                scenario: "Monday morning standup. Three developers are working on the same service. Developer A pushes a database change, Developer B pulls it before starting their API work, and Developer C reviews both PRs before merging. By Wednesday, all three features are integrated, tested, and deployed. No conflicts, no lost work - just clean collaboration."
            )
        case 7:
            return LearningContent(
                concept: "Merge conflicts happen when Git can't automatically combine changes because two branches modified the same lines. You must manually decide which changes to keep.",
                whyItExists: "When multiple developers edit the same code, Git can merge most changes automatically. But when two people change the exact same lines, only a human can decide the right outcome.",
                whenUsed: "Conflicts arise during merges, rebases, and pulls. They're a normal part of teamwork - experienced developers resolve them quickly because they understand the pattern.",
                realWorldUsage: [
                    "Large teams encounter conflicts daily - especially in shared config files and APIs",
                    "IDE tools like VS Code, Xcode, and IntelliJ have built-in conflict resolution UIs",
                    "git mergetool launches a visual three-way diff for complex conflicts",
                    "Trunk-based development with short-lived branches minimizes conflict frequency"
                ],
                tips: [
                    "Read both sides of the conflict carefully before choosing - understand the intent",
                    "Look for the <<<<<<< ======= >>>>>>> markers - they show exactly where conflicts are",
                    "After resolving, always run tests to ensure the merged code actually works",
                    "Use git log --merge to see which commits caused the conflict",
                    "Communicate with the other developer when resolving non-trivial conflicts"
                ],
                risks: [
                    "Accepting one side blindly can silently delete important code from a teammate",
                    "Leaving conflict markers (<<<<<<) in the code will cause build failures",
                    "Resolving conflicts without understanding context introduces subtle bugs",
                    "Use git merge --abort to start over if you get lost during resolution"
                ],
                scenario: "You and a colleague both updated the app's theme configuration. Git marks the conflict and shows both versions. You see that your colleague changed the primary color while you updated the font. You keep both changes, remove the markers, run the tests - all green. What felt scary the first time is now a 60-second routine."
            )
        default:
            return LearningContent(
                concept: "This concept builds on your growing Git expertise.",
                whyItExists: "Every Git concept exists to solve a real problem in collaborative software development.",
                whenUsed: "You'll use this concept regularly throughout your development career.",
                realWorldUsage: ["Used daily by professional developers worldwide"],
                tips: ["Practice makes perfect - try these commands in a test repository"],
                risks: ["Always use git status to understand your current state before running commands"],
                scenario: "As you grow as a developer, these Git skills become second nature - like reading or writing code."
            )
        }
    }
}
