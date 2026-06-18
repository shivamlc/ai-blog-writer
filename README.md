# Medium Blog Writer

[![MIT License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![macOS](https://img.shields.io/badge/platform-macOS-lightgrey.svg)](https://www.apple.com/macos/)
[![Node.js](https://img.shields.io/badge/node-%3E%3D14.0.0-green.svg)](https://nodejs.org/)
[![Claude Code](https://img.shields.io/badge/Claude_Code-Skill-blue.svg)](https://claude.ai/code)

A collection of Claude Code skills for automating blog workflows: drafting & publishing to Medium, and managing git commits.

## 📚 Included Skills

### 1. Medium Story Drafter
Automate drafting and publishing blog posts to Medium.

- **Automated Draft Creation**: Convert markdown files to Medium drafts automatically
- **Direct Publishing**: Publish drafts live to Medium with one command
- **Formatting Support**: Optional automatic heading and code block formatting
- **Persistent Browser Session**: Maintains login state across sessions (one-time 2FA setup)
- **Copy-Paste Integration**: Uses macOS clipboard for seamless content transfer

### 2. Auto Commit & Push
Automate the entire git workflow with intelligent commit message generation.

- **Change Analysis**: Automatically understands what files changed
- **Smart Commit Messages**: Generates meaningful commits based on changes
- **Bash Integration**: Uses pure bash scripts for all git operations
- **One-Command Workflow**: Stage, commit, and push in one action
- **Custom Messages**: Override auto-generated messages when needed

## About This Project

This project is a **Claude Code Skill** - an automation workflow built with Claude Code that integrates with the Claude Code CLI and IDE extensions. It leverages Claude's capabilities to automate repetitive publishing tasks.

### What is Claude Code?

[Claude Code](https://claude.ai/code) is an AI-powered development tool that helps with software engineering tasks. This project uses Claude Code's Playwright integration for browser automation.

## Installation

1. Clone this repository:
```bash
git clone https://github.com/YOUR_USERNAME/medium-blog-writer.git
cd medium-blog-writer
```

2. Ensure you have Playwright installed:
```bash
npm install -g playwright
```

3. Make sure you have Claude Code installed:
```bash
npm install -g @anthropic-ai/claude-code
```

## Usage

### Medium Story Drafter

#### Draft a Story
```bash
/medium-story-drafter --file your-article.md
```

#### Publish a Story
```bash
/medium-story-drafter --file your-article.md --publish
```

#### With Style Fixes
```bash
/medium-story-drafter --file your-article.md --fix-styles
```

#### Publish with Formatting
```bash
/medium-story-drafter --file your-article.md --publish --fix-styles
```

### Auto Commit & Push

Automate your entire git workflow in one command:

#### Auto-Generate Commit Message
```bash
/auto-commit-push
```

#### With Custom Message
```bash
/auto-commit-push --message "Fix authentication bug"
```

#### Or Run Bash Script Directly
```bash
bash .claude/skills/auto-commit-push/scripts/auto-commit-push.sh
bash .claude/skills/auto-commit-push/scripts/auto-commit-push.sh --message "Your message"
```

**How it works:**
1. Analyzes git changes (added, modified, deleted files)
2. Generates intelligent commit message
3. Stages all changes with `git add .`
4. Commits using bash script
5. Pushes to remote branch with tracking

## Project Structure

```
medium-blog-writer/
├── .claude/
│   └── skills/
│       ├── medium-story-drafter/
│       │   ├── SKILL.md
│       │   ├── scripts/
│       │   └── references/
│       └── auto-commit-push/
│           ├── SKILL.md            # Auto-commit-push skill definition
│           ├── scripts/
│           │   └── auto-commit-push.sh    # Bash implementation
│           └── references/
│               └── git-bash-implementation.md
├── README.md                       # This file
├── CLAUDE.md                       # Development documentation
├── AUTO_COMMIT_PUSH.md             # Detailed auto-commit-push guide
└── Blog.md                         # Example blog post
```

## Markdown Format (for Medium)

Create a markdown file with the following structure:

```markdown
# Your Article Title

Your article content goes here with standard markdown formatting.

## Section 1

Content for section 1...

## Section 2

Content for section 2...
```

## First-Time Setup

1. Run the tool for the first time
2. Complete Manual login with 2FA (one-time only)
3. Browser profile is saved for future sessions
4. Subsequent runs will use saved credentials

## Running with Claude Code

These are Claude Code skills that integrate directly into your workflow:

### Medium Story Drafter
```bash
/medium-story-drafter --file your-article.md
/medium-story-drafter --file your-article.md --publish
```

Claude Code will handle:
- Browser automation with Playwright
- Clipboard management
- Medium integration
- Login session persistence

### Auto Commit & Push
```bash
/auto-commit-push
/auto-commit-push --message "Your custom message"
```

Claude Code will:
- Analyze git changes
- Generate smart commit messages
- Execute bash scripts for git operations
- Push to your remote repository

### Standalone Usage

Both skills can also be run directly without Claude Code:

```bash
# Run auto-commit-push script standalone
bash scripts/auto-commit-push.sh
bash scripts/auto-commit-push.sh --message "Custom message"

# Make it executable
chmod +x scripts/auto-commit-push.sh
./scripts/auto-commit-push.sh
```

## Requirements

- macOS (for clipboard functionality)
- Playwright CLI
- Medium account
- Node.js/npm
- Claude Code (for skill integration)

## Troubleshooting

| Issue | Solution |
|-------|----------|
| Browser won't open | Update Playwright: `npm install -g playwright@latest` |
| Login not persisting | Clear browser profile and re-authenticate |
| Clipboard issues | Ensure clipboard access is granted in macOS settings |
| Medium layout changed | Update Playwright and browser selectors in the skill |

## License

MIT

## Author

Shivam Gaur

## Contributing

Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.
