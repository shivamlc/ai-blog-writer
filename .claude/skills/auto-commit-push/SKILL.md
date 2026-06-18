---
name: auto-commit-push
description: Analyze git changes, generate an intelligent commit message based on added/modified/deleted files, stage all changes with `git add .`, create a commit using a bash script, and push to the remote branch with upstream tracking. By DEFAULT auto-generates commit message -- pass --message "..." to use a custom message instead. Trigger whenever the user wants to commit and push their git changes with automatic commit message generation. Works as a Claude Code skill or standalone bash script.
---

# Auto Commit & Push

Analyzes git changes, generates an intelligent commit message, stages changes,
commits via bash script, and pushes to remote with upstream tracking.

## Flags

```
--message "..."       Custom commit message (optional, auto-generates by default)
--force              Force push to remote (use with caution)
```

## Usage examples

```bash
# Auto-generate commit message, stage, commit, and push
/auto-commit-push

# Use custom commit message
/auto-commit-push --message "Fix authentication bug in login flow"

# Force push (overwrite remote history - use carefully)
/auto-commit-push --force

# Standalone bash script
bash scripts/auto-commit-push.sh
bash scripts/auto-commit-push.sh --message "Deploy v1.0.0"
```

## How it works

The skill performs these steps:

1. **Analyze Changes**: Reads `git status --porcelain` and `git diff` to understand:
   - Added files (new content)
   - Modified files (existing changes)
   - Deleted files (removed content)

2. **Generate Commit Message** (if not provided):
   - Detects special files (README.md, CLAUDE.md, etc.)
   - Categorizes changes: add, update, remove, refactor
   - Includes file count
   - Examples:
     - "Add README documentation" (for README.md additions)
     - "Update project files (3 files)" (for mixed modifications)
     - "Refactor and update project files" (for mixed changes)

3. **Stage Changes**: Runs `git add .` via bash script to stage all changes

4. **Create Commit**: Uses bash script to execute:
   ```bash
   git commit -m "Generated or custom message"
   ```

5. **Push to Remote**: Detects current branch and runs:
   ```bash
   git push -u origin BRANCH
   ```
   The `-u` flag sets upstream tracking for future pushes.

## Prerequisites

- Git installed and configured with user.name and user.email
- Current directory is a git repository (`git rev-parse --git-dir` succeeds)
- Remote named `origin` exists and is accessible
- Proper git credentials configured (SSH keys or HTTPS tokens)

## Workflow example

```bash
# Make changes to files
echo "new content" > newfile.md
vim existing-file.md

# Check what changed (optional)
git status
git diff

# Use auto-commit-push to handle everything
/auto-commit-push

# Output:
# 🔍 Analyzing git changes...
# Changed files: 2 added, 1 modified, 0 deleted
# 📝 Generated commit message: "Add new documentation (2 files)"
# 📦 Staging changes...
# 💾 Creating commit...
# 🚀 Pushing to remote...
# ✓ Git workflow completed successfully!
```

## Commit message generation logic

The skill analyzes file changes to generate appropriate messages:

| Scenario | Generated Message |
|----------|-------------------|
| Add README.md | "Add README documentation" |
| Add CLAUDE.md | "Add CLAUDE.md project documentation" |
| Add other files | "Add new files (N files)" |
| Only modifications | "Update project files (N files)" |
| Only deletions | "Remove files (N files)" |
| Mixed additions/updates | "Refactor and update project files (N files)" |

## Running as standalone bash script

The skill can also be run directly without Claude Code:

```bash
# Make it executable
chmod +x scripts/auto-commit-push.sh

# Run with auto-generated message
bash scripts/auto-commit-push.sh

# Run with custom message
bash scripts/auto-commit-push.sh --message "Your custom message"

# Run with force push
bash scripts/auto-commit-push.sh --force
```

## Error handling

The skill validates:
- ✓ Current directory is a git repository
- ✓ There are changes to commit (exits if none found)
- ✓ Git is configured (user.name and user.email)
- ✓ Remote `origin` exists
- ✓ Branch is trackable

If any check fails, an error message is displayed and the operation stops.

## Bash script implementation

The bash script (`scripts/auto-commit-push.sh`):
- Uses `set -e` to exit on any error
- Properly escapes commit message special characters
- Provides colored output for readability
- Cleans up after itself
- Respects all local git configuration and hooks

## Security considerations

- ✓ Commit messages are properly escaped to prevent injection
- ✓ No credentials are stored or displayed
- ✓ Git operations respect local `.git/config`
- ✓ All git hooks are respected
- ✓ Uses `-u` flag only (no force push by default)

## Troubleshooting

| Issue | Solution |
|-------|----------|
| "Not a git repository" | Run in a git repo: `git init` if needed |
| "No changes to commit" | Make changes to files first |
| "user.name not configured" | Run `git config user.name "Your Name"` |
| Commit message looks wrong | Use `--message "Your message"` to override |
| Push fails | Check: `git remote -v` and verify credentials |
| "Permission denied" on script | Run: `chmod +x scripts/auto-commit-push.sh` |

## Implementation details

See `references/git-bash-implementation.md` for:
- How bash handles special characters in commit messages
- The exact git operations performed
- How branch detection works
- Error exit codes and handling

## See also

- Main documentation: `AUTO_COMMIT_PUSH.md` in project root
- Project development: `CLAUDE.md`
- Project overview: `README.md`
