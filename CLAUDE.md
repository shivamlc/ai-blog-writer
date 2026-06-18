# CLAUDE.md - Project Documentation

## Project Overview

**Medium Blog Writer** is a collection of Claude Code skills that automate content and git workflows:

1. **Medium Story Drafter** - Automate drafting and publishing blog posts to Medium
2. **Auto Commit & Push** - Automate git workflow with intelligent commit messages

## Project Goals

- Automate repetitive blog publishing and git management tasks
- Provide seamless workflows for markdown → Medium publication
- Enable intelligent git commit message generation based on changes
- Reduce manual copy-paste, formatting, and git operations
- Enable one-command workflows for both publishing and version control

## Architecture

### Skill Components

#### 1. Medium Story Drafter
- **File**: `medium-story-drafter.skill`
- **Purpose**: Automate Medium blog drafting and publishing
- **Features**:
  - Browser automation with Playwright
  - Persistent login session management
  - macOS clipboard integration
  - Draft creation and optional publishing
  - Optional formatting (headings, code blocks)

#### 2. Auto Commit & Push
- **Files**:
  - `auto-commit-push.skill` - Node.js orchestration layer
  - `scripts/auto-commit-push.sh` - Bash implementation
- **Purpose**: Automate git workflow with intelligent commit messages
- **Features**:
  - Git change analysis (status, diff)
  - Intelligent commit message generation
  - File categorization (added, modified, deleted)
  - Pure bash script execution for git operations
  - Automatic branch detection and push

### Key Files

- `medium-story-drafter.skill` - Medium automation
- `auto-commit-push.skill` - Git workflow orchestration
- `scripts/auto-commit-push.sh` - Bash git automation (executable)
- `Blog.md` - Example blog content
- `AUTO_COMMIT_PUSH.md` - Detailed git skill documentation
- `README.md` - User-facing documentation
- `CLAUDE.md` - This file

## Development Workflow

### Medium Story Drafter

#### Adding Features
1. **New publish options**: Modify the skill to accept new command-line flags
2. **Format improvements**: Extend the `--fix-styles` implementation to support more markdown elements
3. **Error handling**: Add retry logic or better error messages in browser automation

#### Testing
1. Run with a test markdown file
2. Verify draft is created (or published if flag set)
3. Check formatting is applied correctly
4. Confirm the Medium draft link is returned

#### Browser Profile Management
- **Location**: Playwright maintains a persistent browser profile
- **Login**: One-time manual login with 2FA required on first use
- **Reuse**: Subsequent runs automatically use saved credentials
- **Reset**: Delete the profile directory to force re-login

### Auto Commit & Push

#### How It Works
1. **Change Analysis**: Reads git status and diff
   - Identifies added, modified, deleted files
   - Analyzes diff content for context
   
2. **Message Generation**: Creates intelligent commit messages
   - Detects special files (README, CLAUDE.md)
   - Generates type-specific messages (add, update, remove, refactor)
   - Includes file count automatically
   
3. **Bash Execution**: Runs git operations via bash scripts
   - Creates temporary bash scripts with proper escaping
   - Executes: `git add .`, `git commit -m "..."`, `git push -u origin BRANCH`
   - Cleans up temporary files
   
4. **Error Handling**: Validates each step
   - Ensures git repository exists
   - Checks for changes before committing
   - Reports push status

#### Adding Features
- **Conventional commits**: Support `feat:`, `fix:`, `docs:` prefixes
- **Changelog generation**: Auto-generate CHANGELOG from commits
- **GitHub integration**: Link to commit on GitHub
- **Co-authored commits**: Support multiple authors

#### Testing
```bash
# Test message generation
bash scripts/auto-commit-push.sh --message "Test message"

# Test with actual changes
echo "test" > test.txt
bash scripts/auto-commit-push.sh

# Verify git operations
git log -1  # Check commit
git remote -v  # Check push destination
```

#### Extending the Script
- Modify `scripts/auto-commit-push.sh` for bash-specific changes
- Update `auto-commit-push.skill` for Node.js logic or option parsing
- Both files must stay in sync for consistent behavior

## Key Constraints & Conventions

### Medium Story Drafter
- **macOS only**: Uses native macOS clipboard for content transfer
- **Real browser**: Always uses a real browser session (not headless) for reliability
- **Medium-specific**: Tailored to Medium's story editor at https://medium.com/new-story
- **Blocking operations**: Browser automation blocks until draft/publish completes

### Auto Commit & Push
- **Bash-first**: All git operations use bash scripts, not direct git API calls
- **Atomic operations**: Each git command is separate but coordinated
- **Message escaping**: Commit messages properly escape special characters
- **Error handling**: Uses `set -e` in bash to exit on any error
- **Cross-platform**: Works on macOS, Linux, and Windows (with bash)
- **Non-destructive**: Uses `git add .` which stages all changes without force
- **Upstream tracking**: Always uses `-u origin BRANCH` for upstream tracking

## Common Tasks

### Medium Story Drafter

#### Debugging Browser Issues
- Check that browser is fully loaded
- Verify Playwright is up to date: `npm install -g playwright@latest`
- Clear browser profile and re-login if stuck

#### Modifying Markdown Parsing
- Markdown content is passed as-is to Medium's editor
- The `--fix-styles` flag applies formatting AFTER paste (via toolbar)
- To change formatting, modify the toolbar action sequence

#### Adding New Flags
- Add flags to the skill command documentation
- Handle flags in the main execution logic
- Update README with new usage examples

### Auto Commit & Push

#### Debugging Git Issues
```bash
# Check git is configured
git config user.name
git config user.email

# See what would be committed
git status
git diff

# Check remote is set
git remote -v
```

#### Modifying Commit Message Logic
Edit `.claude/skills/auto-commit-push/scripts/auto-commit-push.sh`:
- Change case statements in the message generation section
- Modify the file count logic
- Update special file detection

#### Testing Message Generation
```bash
# Make some changes
echo "test" > newfile.txt
git add newfile.txt

# See what message would be generated (dry run)
bash .claude/skills/auto-commit-push/scripts/auto-commit-push.sh --message "Test"

# Actually commit and push
bash .claude/skills/auto-commit-push/scripts/auto-commit-push.sh
```

#### Adding Custom Commit Types
1. Add new case in `scripts/auto-commit-push.sh`:
```bash
case $COMMIT_TYPE in
    # ... existing cases ...
    docs)
        COMMIT_MESSAGE="Update documentation"
        ;;
esac
```

2. Add detection logic for the new type
3. Test with appropriate file changes

## Dependencies

### Medium Story Drafter
- **playwright**: Browser automation
- **macOS**: Clipboard integration
- **Medium account**: For login and publishing

### Auto Commit & Push
- **bash**: Shell scripting (v4.0+)
- **git**: Version control (2.0+)
- **Node.js**: For the skill orchestration (optional if running bash only)
- **Standard Unix tools**: grep, echo (for bash script)

## Project Structure & Git Management

This project uses git for version control. Key considerations:

- **Commit messages**: Generated automatically by auto-commit-push skill
- **Branches**: Use feature branches, merge to main via PRs
- **Hooks**: No pre-commit hooks required, but respect local git config
- **Bash scripts**: Always executable (`chmod +x scripts/*.sh`)
- **Temporary files**: Auto-generated bash scripts cleanup after themselves

### Typical Workflow

```bash
# Make changes to project
vim file.md

# Use auto-commit-push to handle all git operations
/auto-commit-push

# Or manually
bash scripts/auto-commit-push.sh --message "Your message"
```

## Contact & Questions

For issues or questions about this project, check:

### Medium Story Drafter
1. Medium's story editor behavior (may have changed)
2. Playwright documentation: https://playwright.dev/
3. Project issues/discussions on GitHub

### Auto Commit & Push
1. Git documentation: https://git-scm.com/doc
2. Bash scripting guides for bash-specific issues
3. Check AUTO_COMMIT_PUSH.md for detailed documentation
