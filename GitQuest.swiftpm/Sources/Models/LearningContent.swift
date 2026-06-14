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
        case 8:
            return LearningContent(
                concept: "git stash temporarily shelves your uncommitted changes so your working directory looks clean, then lets you bring them back exactly as they were whenever you're ready.",
                whyItExists: "Real work rarely lines up perfectly with interruptions. Stash lets you context-switch - to fix an urgent bug, pull updates, or switch branches - without committing unfinished, broken, or messy code.",
                whenUsed: "Whenever you need a clean working directory but aren't ready to commit: urgent bug reports, switching branches mid-task, or testing something on a different branch.",
                realWorldUsage: [
                    "Pausing a half-finished feature to fix a production incident on main, then resuming afterwards",
                    "Stashing local experiments before pulling teammates' changes to avoid conflicts",
                    "Quickly checking out another branch to review a PR without losing your current edits",
                    "git stash --include-untracked covers new files too, not just modified ones"
                ],
                tips: [
                    "Run 'git stash list' to see everything you've stashed - it's easy to forget",
                    "Use 'git stash save \"message\"' to label stashes so future-you knows what's inside",
                    "git stash pop applies AND removes the stash; git stash apply keeps it for reuse",
                    "Stash is local only - it never gets pushed, so don't rely on it as backup"
                ],
                risks: [
                    "Stashes can silently pile up and be forgotten, hiding work you meant to finish",
                    "Popping a stash can create conflicts if the files changed since you stashed",
                    "Stash is not a substitute for committing - it's a short-term shelf, not permanent storage"
                ],
                scenario: "You're three files deep into a settings redesign when a critical Safari bug gets reported. You stash your half-finished work, switch to main, fix the bug, push the hotfix, switch back, and pop your stash. Everything is exactly where you left it - the interruption cost you two minutes instead of losing an hour of context."
            )
        case 9:
            return LearningContent(
                concept: "git cherry-pick copies the changes from one specific commit on another branch and applies them as a new commit on your current branch - without merging everything else from that branch.",
                whyItExists: "Sometimes you need just ONE fix from a branch, not the whole branch's history. Cherry-pick lets you grab exactly that commit, so urgent fixes can ship to other branches independently.",
                whenUsed: "Backporting a hotfix from a feature or release branch onto main (or another release branch) without waiting for a full merge.",
                realWorldUsage: [
                    "Applying a critical security fix to main, a release branch, AND an older supported version - all via cherry-pick",
                    "Pulling a single bugfix commit out of a large in-progress feature branch",
                    "Release managers cherry-pick approved fixes into a release-candidate branch",
                    "Recovering a useful commit that was accidentally made on the wrong branch"
                ],
                tips: [
                    "Cherry-pick creates a NEW commit with a new hash - it's a copy, not a move",
                    "Use 'git log' to find the exact commit hash you want to cherry-pick",
                    "For merge commits, you'll need the -m flag to specify which parent line to follow",
                    "After cherry-picking, the original branch can still merge normally later"
                ],
                risks: [
                    "Cherry-picking the same change onto multiple branches can cause duplicate-looking history",
                    "If the surrounding code differs between branches, cherry-pick can produce conflicts",
                    "Overusing cherry-pick instead of merging can make history hard to follow"
                ],
                scenario: "A teammate fixed a null-pointer crash on their hotfix branch, but main needs that exact fix right now - the rest of their branch isn't ready. You check out main and cherry-pick just that one commit. main is patched and deployed in minutes, while the rest of the hotfix branch continues through normal review."
            )
        case 10:
            return LearningContent(
                concept: "git tag creates a permanent, human-readable name (like v1.0) pointing at a specific commit. Unlike branches, tags don't move - they mark a fixed point in history forever.",
                whyItExists: "Commit hashes like a1b2c3d are impossible to remember. Tags give meaningful names to important milestones - especially releases - so anyone can find and check out that exact version instantly.",
                whenUsed: "Whenever you ship a release: v1.0, v2.3.1, etc. Also used to mark internal milestones like 'before-migration' or 'demo-ready'.",
                realWorldUsage: [
                    "Semantic versioning (v1.2.3) tags mark every published release of a library or app",
                    "CI/CD pipelines watch for new tags matching v*.*.* and automatically build/deploy them",
                    "App Store and Play Store releases are often tagged so the exact shipped code can be found later",
                    "git checkout v1.0 lets anyone inspect the project exactly as it was at that release"
                ],
                tips: [
                    "Use annotated tags (git tag -a v1.0 -m \"message\") for releases - they store author, date, and notes",
                    "Tags must be pushed explicitly: git push origin v1.0, or git push --tags for all of them",
                    "Follow semantic versioning: MAJOR.MINOR.PATCH (e.g. v2.1.0) so version bumps communicate impact",
                    "List existing tags with git tag, or see details with git show v1.0"
                ],
                risks: [
                    "Forgetting to push a tag means your CI/CD release pipeline never triggers",
                    "Reusing or moving an existing tag confuses anyone who already checked it out",
                    "Tagging the wrong commit ships the wrong code as a 'release' - double-check HEAD first"
                ],
                scenario: "QA signs off on the build. You tag the current commit v1.0 and push the tag to GitHub. Within minutes, the CI/CD pipeline detects the new tag, builds the release artifact, and the release notes go live. Six months later, a support ticket references 'v1.0' - and you can check out that exact tag to reproduce the issue precisely."
            )
        case 11:
            return LearningContent(
                concept: "git rm --cached removes files from Git's tracking without deleting them from disk, and .gitignore prevents specific files and folders from ever being tracked again.",
                whyItExists: "Build artifacts, dependencies (node_modules), and secrets (.env) don't belong in version control - they're huge, machine-specific, or sensitive. Untracking them plus .gitignore keeps repos small, fast, and safe.",
                whenUsed: "Right after noticing a mistake like a committed node_modules folder, build directory, or credentials file - and ideally, .gitignore is set up before the very first commit.",
                realWorldUsage: [
                    "Every framework's starter template ships with a tailored .gitignore (Node, Swift, Python, etc.)",
                    "github.com/github/gitignore provides ready-made templates for almost any language or tool",
                    "Teams add .env, *.log, build/, and DerivedData/ to .gitignore to keep repos lean",
                    "git rm --cached is the standard fix when something slips through before .gitignore existed"
                ],
                tips: [
                    "Set up .gitignore BEFORE your first commit using a template for your stack",
                    "git rm -r --cached <folder> untracks a whole folder while keeping it on disk",
                    "Run git status after editing .gitignore to confirm the files disappear from 'untracked'",
                    "Commit .gitignore changes together with the untracking for a clean, reviewable cleanup"
                ],
                risks: [
                    "git rm --cached doesn't remove the file from OLD commits - history still contains it",
                    "If secrets were committed, untracking isn't enough - you may need to rewrite history and rotate credentials",
                    "Forgetting --cached (just 'git rm') deletes the file from disk too - be careful"
                ],
                scenario: "Your repo ballooned to 200MB because node_modules got committed on day one. You run git rm -r --cached node_modules to untrack it, add node_modules/ to .gitignore, and commit the cleanup. The next clone is 4MB instead of 200MB - and node_modules can never accidentally sneak back in."
            )
        case 12:
            return LearningContent(
                concept: "git revert creates a brand-new commit that undoes the changes from a previous commit - without deleting or rewriting any existing history.",
                whyItExists: "Once a commit is pushed and others have pulled it, rewriting history (like reset) would cause major problems for everyone else. Revert undoes the effect of a bad commit while keeping history intact and shareable.",
                whenUsed: "Whenever a problematic commit has already been pushed to a shared branch - a broken build, a bad config change, or a feature that needs to be pulled back.",
                realWorldUsage: [
                    "Rolling back a bad production deploy by reverting the offending commit, then redeploying",
                    "Undoing a merged pull request that introduced a regression, without disrupting other branches",
                    "git revert -m 1 <hash> reverts a merge commit by specifying which parent to follow",
                    "Reverting is often automated by 'rollback' buttons in CI/CD dashboards"
                ],
                tips: [
                    "git revert HEAD undoes the most recent commit on your current branch",
                    "Revert opens an editor for a commit message - Git auto-fills 'Revert \"original message\"'",
                    "You can revert a revert later if you decide the original change was actually fine",
                    "Combine with git log to find the exact commit hash if it's not the most recent one"
                ],
                risks: [
                    "Reverting a merge commit without -m can fail or produce unexpected results",
                    "If later commits depend on the reverted change, reverting can introduce new conflicts",
                    "Revert doesn't 'erase' the mistake from history - it adds a new commit on top, which is the point"
                ],
                scenario: "An hour after pushing, you realize your last commit broke the build - and two teammates already pulled it. Resetting would rewrite history they now share. Instead, you run git revert HEAD. A new commit undoes your change, the build goes green, and everyone's next 'git pull' just works - no special instructions needed."
            )
        case 13:
            return LearningContent(
                concept: "git log shows the project's commit history, and git blame shows who last changed each line of a specific file and in which commit - together they're your debugging compass.",
                whyItExists: "When something breaks, you need to know WHAT changed and WHEN. Log and blame turn 'something is broken' into 'this exact commit, by this person, on this date, changed this exact line.'",
                whenUsed: "Investigating regressions, understanding unfamiliar code, preparing code review context, or figuring out who to ask about a confusing piece of logic.",
                realWorldUsage: [
                    "git log --oneline -- <file> shows only the commits that touched a specific file",
                    "git blame is built into Xcode, VS Code, and GitHub's web UI as inline annotations",
                    "git bisect uses log history to binary-search for the exact commit that introduced a bug",
                    "Engineers often message a teammate directly after blame points to their commit"
                ],
                tips: [
                    "git log --oneline keeps output compact - one line per commit",
                    "git log -p shows the actual code changes (diffs) for each commit",
                    "git blame -L 40,45 file.js limits blame output to a specific line range",
                    "Pair log and blame: find the suspicious commit in log, then confirm with blame on the exact line"
                ],
                risks: [
                    "git blame shows who LAST touched a line - the real root cause might be several commits earlier",
                    "Long-running, unfocused commits make blame less useful since one commit touches everything",
                    "Don't treat blame as finger-pointing - it's a debugging tool, not a performance review"
                ],
                scenario: "Checkout is broken on Safari and nobody knows why. You run git log --oneline and spot 'Refactor checkout validation' from yesterday - right when reports started. git blame checkout.js confirms line 42 was changed in that exact commit. Two minutes after the bug report, you already know exactly what to revert or fix."
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
