# Medium Blog Writer

An automation tool for drafting and publishing blog posts to Medium using Claude Code.

## Features

- **Automated Draft Creation**: Convert markdown files to Medium drafts automatically
- **Direct Publishing**: Publish drafts live to Medium with one command
- **Formatting Support**: Optional automatic heading and code block formatting
- **Persistent Browser Session**: Maintains login state across sessions (one-time 2FA setup)
- **Copy-Paste Integration**: Uses macOS clipboard for seamless content transfer

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

## Requirements

- macOS (for clipboard functionality)
- Playwright CLI
- Medium account
- Node.js/npm

## License

MIT

## Author

Shivam Gaur
