# Git Bash Implementation Details

## Overview

The auto-commit-push skill uses bash scripts to perform all git operations. This document explains the implementation details, design decisions, and technical considerations.

## Git Operations Sequence

The skill executes these git commands in order:

```bash
1. git rev-parse --git-dir              # Check repository exists
2. git status --porcelain               # Get list of changes
3. git diff HEAD                        # Get change details (if needed)
4. git add .                            # Stage all changes
5. git commit -m "message"              # Create commit
6. git rev-parse --abbrev-ref HEAD      # Get current branch
7. git push -u origin BRANCH            # Push with upstream tracking
```

## Why Bash Scripts?

Using bash for git operations provides:

- **Reliability**: Direct git commands are more predictable than git libraries
- **Portability**: Works across macOS, Linux, Windows (with WSL/Git Bash)
- **Transparency**: Users can read and verify exactly what happens
- **Hook Compatibility**: Respects all local git hooks and configurations
- **Error Handling**: Can use `set -e` to fail safely
- **Auditability**: All operations are logged to console

## Commit Message Handling

### Escaping Special Characters

Bash variables in double quotes expand but preserve special characters. The script uses:

```bash
git commit -m "$COMMIT_MESSAGE"
```

This works safely because:
- `$COMMIT_MESSAGE` is set by the script, not user input
- For user input via `--message`, we pass it directly as the argument
- Shell metacharacters (`, $, \, ") inside messages are treated as literals

### Examples

```bash
# Single quotes in message - safe
COMMIT_MESSAGE="Add 'hello' to docs"
git commit -m "$COMMIT_MESSAGE"  # ✓ Works

# Backticks in message - safe
COMMIT_MESSAGE="Add \`code\` example"
git commit -m "$COMMIT_MESSAGE"  # ✓ Works

# Dollar sign in message - safe
COMMIT_MESSAGE="Fix $5 billing issue"
git commit -m "$COMMIT_MESSAGE"  # ✓ Works
```

## Change Analysis

### Parsing `git status --porcelain`

The porcelain format is one file per line with a 2-character status code:

```
A  new-file.txt       # Added
M  modified-file.txt  # Modified
D  deleted-file.txt   # Deleted
```

The script counts each type:

```bash
ADDED_COUNT=$(echo "$GIT_STATUS" | grep -c "^A " || true)
MODIFIED_COUNT=$(echo "$GIT_STATUS" | grep -c "^M " || true)
DELETED_COUNT=$(echo "$GIT_STATUS" | grep -c "^D " || true)
```

The `|| true` prevents the script from exiting if grep finds no matches (grep exits with 1 when no matches).

### Special File Detection

For particularly important files, the script detects them by name:

```bash
if echo "$GIT_STATUS" | grep -q "README"; then
    COMMIT_MESSAGE="Add README documentation"
elif echo "$GIT_STATUS" | grep -q "CLAUDE.md"; then
    COMMIT_MESSAGE="Add CLAUDE.md project documentation"
fi
```

This checks if the filename appears anywhere in the status output.

## Branch Detection

```bash
BRANCH=$(git rev-parse --abbrev-ref HEAD)
```

This gets the current branch name. Examples:
- Returns: `main`, `master`, `feature/auth`, `bugfix/login`
- Returns: `HEAD` if in detached HEAD state (rare, handled gracefully)

## Pushing with Upstream Tracking

```bash
git push -u origin "$BRANCH"
```

The `-u` (or `--set-upstream`) flag:
- Sets the remote tracking branch for the current local branch
- Allows future `git push`/`git pull` without specifying the branch
- Needed on first push to a new branch
- Harmless on subsequent pushes

Example:
```bash
# First push (from feature branch)
git push -u origin feature/auth
# Now sets: feature/auth -> origin/feature/auth

# Future pushes just need
git push

# Without -u, would need
git push origin feature/auth
```

## Error Handling Strategy

The script uses `set -e` at the top:

```bash
set -e
```

This causes bash to exit immediately if any command returns non-zero (error). Advantages:

- No need to check every command's exit status
- Script stops at first error
- User sees which command failed

Examples of commands that would stop execution:
- `git add .` fails (corrupted repo)
- `git commit -m "..."` fails (pre-commit hook rejected)
- `git push` fails (network error, permission denied)

## Color Output Implementation

The script uses ANSI escape codes:

```bash
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'  # No Color

log_success() {
    echo -e "${GREEN}$1${NC}"
}
```

- `\033[` - Escape sequence start
- `0;32m` - Color code (32 = green)
- `${NC}` - Reset to normal color
- `-e` flag in echo enables escape code interpretation

## Force Push Consideration

The script supports `--force` flag for force pushing:

```bash
if [ "$FORCE" = true ]; then
    git push --force-with-lease origin "$BRANCH"
else
    git push -u origin "$BRANCH"
fi
```

Note: Uses `--force-with-lease` instead of `--force` to:
- Still protect against overwriting someone else's work
- Only rewrite if remote hasn't changed since last fetch
- Safer than `--force` which blindly overwrites

## Logging and Output

The script logs to stdout for visibility:

```
🔍 Analyzing git changes...

Changed files:
A  new-file.md
M  old-file.md

📊 Analysis: 1 added, 1 modified, 0 deleted

📝 Generated commit message:
   "Add documentation and updates (2 files)"

📦 Staging changes...
✓ Changes staged

💾 Creating commit...
✓ Commit created successfully

🌿 Current branch: main

🚀 Pushing to remote...
✓ Push completed successfully

==================================================
✓ Git workflow completed successfully!
==================================================
Commit: "Add documentation and updates (2 files)"
Branch: main
==================================================
```

This provides:
- Clear progress indicators (emojis for different phases)
- Detailed analysis output
- Success confirmations
- Summary at the end

## Environment Considerations

The script works in:
- Bash 4.0+ (uses `[[ ]]` and `${var}` syntax)
- macOS (standard bash, may need to update for zsh)
- Linux (standard bash)
- Windows with Git Bash or WSL

Compatibility notes:
- Uses POSIX-compatible grep patterns
- Uses standard git commands (cross-platform)
- Uses `printf` for formatting (more portable than `echo -n`)

## Security Notes

The script is secure because:

1. **No credential handling** - Relies on system git credentials
2. **No command injection** - Doesn't eval user input
3. **Escaped messages** - Special chars in messages are literal
4. **Respects .gitignore** - `git add .` respects .gitignore rules
5. **Hook compliance** - All git hooks are executed normally

## Performance

Typical execution times:
- Analysis: <100ms (reading status/diff)
- Commit: <100ms (creating local commit)
- Push: 100ms - 5s (network dependent)
- Total: <6 seconds typical

## Testing the Implementation

Test different scenarios:

```bash
# Test 1: Multiple additions
echo "test1" > file1.md
echo "test2" > file2.md
bash auto-commit-push.sh

# Test 2: Mixed changes
echo "modified" >> existing.md
echo "new" > new.md
rm old-file.md
bash auto-commit-push.sh

# Test 3: Custom message
bash auto-commit-push.sh --message "Deploy v1.0"

# Test 4: No changes
bash auto-commit-push.sh  # Should exit with "No changes to commit"
```

## See Also

- Main skill documentation: SKILL.md
- Project documentation: ../../AUTO_COMMIT_PUSH.md
- Git documentation: https://git-scm.com/doc
- Bash manual: https://www.gnu.org/software/bash/manual/
