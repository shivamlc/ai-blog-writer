# Medium Blog Writer

[![MIT License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![macOS](https://img.shields.io/badge/platform-macOS-lightgrey.svg)](https://www.apple.com/macos/)
[![Node.js](https://img.shields.io/badge/node-%3E%3D14.0.0-green.svg)](https://nodejs.org/)
[![Claude Code](https://img.shields.io/badge/Claude_Code-Skill-blue.svg)](https://claude.ai/code)

An automation tool for drafting and publishing blog posts to Medium using Claude Code.

## Features

- **Automated Draft Creation**: Convert markdown files to Medium drafts automatically
- **Direct Publishing**: Publish drafts live to Medium with one command
- **Formatting Support**: Optional automatic heading and code block formatting
- **Persistent Browser Session**: Maintains login state across sessions (one-time 2FA setup)
- **Copy-Paste Integration**: Uses macOS clipboard for seamless content transfer

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

### Draft a Story
```bash
medium-story-drafter --file your-article.md
```

### Publish a Story
```bash
medium-story-drafter --file your-article.md --publish
```

### With Style Fixes
```bash
medium-story-drafter --file your-article.md --fix-styles
```

### Publish with Formatting
```bash
medium-story-drafter --file your-article.md --publish --fix-styles
```

## Markdown Format

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

You can use this skill directly in Claude Code:

1. In Claude Code, use the skill command:
   ```
   /medium-story-drafter --file your-article.md
   ```

2. Claude Code will handle browser automation, clipboard management, and Medium integration

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
