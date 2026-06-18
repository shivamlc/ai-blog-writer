# CLAUDE.md - Project Documentation

## Project Overview

**Medium Blog Writer** is a Claude Code skill that automates the process of drafting and publishing blog posts to Medium. It uses Playwright to drive a browser session against Medium's story editor.

## Project Goals

- Automate repetitive blog publishing tasks
- Provide a seamless workflow from markdown → Medium draft/publication
- Reduce manual copy-paste and formatting effort
- Enable one-command publishing directly from the CLI

## Architecture

### Components

- **medium-story-drafter.skill**: Main skill file that defines the automation workflow
  - Handles browser automation with Playwright
  - Manages Medium login (persistent browser profile)
  - Pastes content via macOS clipboard
  - Creates drafts and optionally publishes
  - Applies optional formatting (headings, code blocks)

### Key Files

- `medium-story-drafter.skill` - Main automation logic
- `Blog.md` - Example blog content
- `README.md` - User-facing documentation
- `CLAUDE.md` - This file

## Development Workflow

### Adding Features

1. **New publish options**: Modify the skill to accept new command-line flags
2. **Format improvements**: Extend the `--fix-styles` implementation to support more markdown elements
3. **Error handling**: Add retry logic or better error messages in browser automation

### Testing

The skill is tested by:
1. Running it with a test markdown file
2. Verifying draft is created (or published if flag set)
3. Checking that formatting is applied correctly
4. Confirming the Medium draft link is returned

### Browser Profile Management

- **Location**: Playwright maintains a persistent browser profile
- **Login**: One-time manual login with 2FA required on first use
- **Reuse**: Subsequent runs automatically use saved credentials
- **Reset**: Delete the profile directory to force re-login

## Key Constraints & Conventions

- **macOS only**: Uses native macOS clipboard for content transfer
- **Real browser**: Always uses a real browser session (not headless) for reliability
- **Medium-specific**: Tailored to Medium's story editor at https://medium.com/new-story
- **Blocking operations**: Browser automation blocks until draft/publish completes

## Common Tasks

### Debugging Browser Issues
- Check that browser is fully loaded
- Verify Playwright is up to date: `npm install -g playwright@latest`
- Clear browser profile and re-login if stuck

### Modifying Markdown Parsing
- Markdown content is passed as-is to Medium's editor
- The `--fix-styles` flag applies formatting AFTER paste (via toolbar)
- To change formatting, modify the toolbar action sequence

### Adding New Flags
- Add flags to the skill command documentation
- Handle flags in the main execution logic
- Update README with new usage examples

## Dependencies

- **playwright**: Browser automation
- **macOS**: Clipboard integration
- **Medium account**: For login and publishing

## Contact & Questions

For issues or questions about this project, check:
1. Medium's story editor behavior (may have changed)
2. Playwright documentation: https://playwright.dev/
3. Project issues/discussions on GitHub
