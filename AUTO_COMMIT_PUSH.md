# Auto Commit & Push Skill

A Claude Code skill that automates the entire git workflow: analyzing changes, generating meaningful commit messages, committing, and pushing to remote.

## Features

✅ **Automatic Change Analysis**
- Parses `git status` and `git diff` to understand what changed
- Categorizes files as added, modified, or deleted
- Detects special files (README, CLAUDE.md, etc.)

✅ **Intelligent Commit Messages**
- Generates meaningful commit messages based on change types
- Supports custom commit messages via `--message` flag
- Includes file count information

✅ **Bash Script Integration**
- Uses pure bash scripts (`scripts/auto-commit-push.sh`) for all git operations
- Git commits are executed via bash, not direct git API calls
- Reliable and reproducible across different environments

✅ **Smart Pushing**
- Automatically detects current branch
- Pushes with `-u` flag to set upstream tracking
- Provides clear feedback at each step

## Usage

### Basic Usage (Auto-Detect Message)
```bash
/auto-commit-push
```

### With Custom Commit Message
```bash
/auto-commit-push --message "Fix bug in authentication flow"
```

### Force Push (if needed)
```bash
/auto-commit-push --force
```

## How It Works

### Step 1: Analyze Changes
```bash
git status --porcelain
git diff HEAD
```
- Gets all modified, added, and deleted files
- Reads the actual changes to understand impact

### Step 2: Generate Commit Message
The skill analyzes changes and generates appropriate messages:

| Changes | Generated Message |
|---------|-------------------|
| Added README.md | "Add README documentation" |
| Added CLAUDE.md | "Add CLAUDE.md project documentation" |
| Multiple additions | "Add new files (N files)" |
| Only modifications | "Update project files" |
| Only deletions | "Remove files" |
| Mixed changes | "Refactor and update project files" |

### Step 3: Stage & Commit (via Bash)
The skill uses a bash script to:
```bash
git add .
git commit -m "Generated message"
```

### Step 4: Push to Remote
```bash
BRANCH=$(git rev-parse --abbrev-ref HEAD)
git push -u origin "$BRANCH"
```

## Implementation Details

### Main Files

Located in `.claude/skills/auto-commit-push/`:

- **SKILL.md** - Skill definition and documentation
  - Defines skill interface and flags
  - Usage examples and workflow
  - Trigger documentation for Claude Code

- **.claude/skills/auto-commit-push/scripts/auto-commit-push.sh** - Pure bash implementation
  - Can be run standalone: `bash .claude/skills/auto-commit-push/scripts/auto-commit-push.sh`
  - Handles all git operations
  - Provides colored output for clarity
  - Self-contained and portable

- **.claude/skills/auto-commit-push/references/git-bash-implementation.md** - Technical details
  - Git operation sequence
  - Bash implementation details
  - Character escaping and safety

### Bash Script Execution

The skill creates temporary bash scripts that are executed:

```javascript
// From auto-commit-push.skill
const commitScript = `#!/bin/bash
set -e
git commit -m "${commitMessage.replace(/"/g, '\\"')}"
echo "Commit created successfully"
`;

fs.writeFileSync(scriptPath, commitScript, { mode: 0o755 });
runCommand(`bash ${scriptPath}`, { stdio: 'inherit' });
```

This ensures:
- Git operations are executed in a real shell
- Standard output/error are displayed to the user
- All git configurations and hooks are respected
- Errors are properly caught and reported

## Options

### `--message`
Provide a custom commit message instead of auto-generating.

```bash
/auto-commit-push --message "Deploy version 1.0.0"
```

### `--force`
Force push to remote (use with caution).

```bash
/auto-commit-push --force
```

## Requirements

- ✅ Git installed and configured
- ✅ Current directory is a git repository
- ✅ GitHub account with push access
- ✅ Proper git credentials set up

## Example Output

```
🔍 Analyzing git changes...

Changed files:
A  README.md
A  CLAUDE.md
M  auto-commit-push.skill

📊 Analysis: 2 added, 1 modified, 0 deleted

📝 Generated commit message:
   "Add documentation files and update skill"

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
Commit: "Add documentation files and update skill"
Branch: main
==================================================
```

## Running Standalone

You can also run the bash script directly without Claude Code:

```bash
# From the project root
bash .claude/skills/auto-commit-push/scripts/auto-commit-push.sh
bash .claude/skills/auto-commit-push/scripts/auto-commit-push.sh --message "Custom message"
bash .claude/skills/auto-commit-push/scripts/auto-commit-push.sh --force

# Or make it directly callable
chmod +x .claude/skills/auto-commit-push/scripts/auto-commit-push.sh
./.claude/skills/auto-commit-push/scripts/auto-commit-push.sh
```

## Troubleshooting

| Issue | Solution |
|-------|----------|
| "Not a git repository" | Make sure you're in a git repo directory |
| Commit fails | Check git is configured: `git config user.name` |
| Push fails | Verify remote is set: `git remote -v` |
| No changes detected | Run `git add .` first or create changes |
| Permission denied on script | Run `chmod +x scripts/auto-commit-push.sh` |

## Security Considerations

- ✅ Commit messages are properly escaped to prevent injection
- ✅ Bash scripts use `set -e` to exit on errors
- ✅ No credentials are stored or displayed
- ✅ Git operations respect your local git configuration

## Future Enhancements

- [ ] Support for conventional commits (feat:, fix:, etc.)
- [ ] Integration with GitHub commit checks
- [ ] Automatic changelog generation
- [ ] Support for co-authored commits
- [ ] Dry-run mode to preview changes

## License

MIT

## See Also

- [README.md](README.md) - Project overview
- [CLAUDE.md](CLAUDE.md) - Development documentation
- [medium-story-drafter.skill](medium-story-drafter.skill) - Example skill
