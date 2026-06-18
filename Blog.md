I write a lot more than I publish. Most of my drafts die in a notes app because opening Medium, clicking New Story, pasting content, and formatting it is just enough friction to kill momentum. So I decided to eliminate that last step entirely.

This post is about building a terminal command that takes a title and a markdown file and either saves a Medium draft or publishes it, from any project on my laptop, in one line. It covers what I built, every approach that failed, and what the final working setup looks like.

## What I built

A bash script called post_to_medium.sh wrapped in a Claude Skill called medium-story-drafter. The skill lives in ~/.claude/skills/ so Claude Code picks it up automatically in every project. There is also a shell alias so I can call it without Claude at all.

The command looks like this from any directory.

medium-draft --title "My Post Title" --body-file post.md

Add --publish to go live instead of saving a draft. The script prints the draft link or the published URL and closes the browser window when it is done.

## How it works

Two tools make this possible.

Playwright CLI is a command-line interface for browser automation built for coding agents. It runs a persistent daemon browser and exposes shell commands like open, type, click, press, and eval. Unlike writing Playwright scripts, you drive the browser directly from the terminal or from a bash script one command at a time.

A Claude Skill is a SKILL.md file that tells Claude when and how to use a tool. Claude Code scans ~/.claude/skills/ on every session, so once the skill is installed it is available from any project without any extra configuration.

The script itself opens medium.com/new-story in a persistent browser session, clicks the title field, copies the title to the macOS clipboard using pbcopy and pastes it with Cmd+V, then does the same for the full body file. It waits for Medium's autosave to assign a /p/<id> URL, reads that URL back, prints it, and closes the browser. With --publish it additionally clicks through Medium's publish modal and prints the live story URL.

## The 2FA problem

The first obstacle was authentication. The obvious approach was playwright-cli state-save to capture cookies after logging in and state-load to restore them on every run.

This broke immediately because my account has two-factor authentication. With 2FA enabled, the saved-cookie replay bounced back to the sign-in page on every run even right after a successful login. Medium's session validation wanted more than a cookie snapshot.

The fix was named persistent sessions. Running playwright-cli with -s=medium and --persistent uses a real on-disk browser profile that survives between runs, the same way a regular browser remembers you. After logging in once inside that profile and completing 2FA, Medium treated it as a remembered device. Every subsequent run reuses the same profile and skips login entirely. This is a one-time setup step.

## What failed along the way

Getting content into Medium's editor cleanly took far more iterations than expected.

Line-by-line keystroke simulation was the first attempt. Medium's editor is a contenteditable rich-text area, not a plain input field, so the plan was to type each line and press Enter. This broke immediately on code blocks. When the script typed three backticks, Medium converted them into a code block element and every subsequent Enter just added another line inside it. The cursor was trapped. Escape, double Enter, triple Enter, and clicking below the block all failed in different ways.

Synthetic JavaScript clipboard events were the second attempt. Dispatching a ClipboardEvent from inside page.evaluate got content into the editor but produced inconsistent results depending on whether Medium's internal React event handlers picked up the event, which varied with timing and page state.

Typing headings live while pasting the rest was the third approach. Since Medium only converts markdown shortcuts on live keystrokes and not on paste, the plan was to type heading lines character by character and paste paragraphs in bulk. This mostly worked for content but playwright-cli type sends text as a clipboard paste internally rather than firing individual key events, so headings still did not convert.

A post-paste fixup pass for headings was the fourth attempt. After pasting the full body, the script walked the DOM to find paragraphs starting with ## or #, selected them, and tried to click the heading button in Medium's floating formatting toolbar. The toolbar appears when text is selected and contains buttons for bold, italic, link, large heading T, small heading T, blockquote, and lock. None of these buttons have aria-labels. After confirming the correct button via playwright-cli snapshot, the selector .buttonSet > button:nth-child(5) was verified to work manually. The problem was that playwright-cli's individual press and click commands each involve a round-trip to the browser daemon, and the text selection was lost between calls before the toolbar click could fire. Combining everything into a single run-code call helped but the prefix-stripping logic, which deleted marker characters from heading lines before reselecting and applying style, was unreliable in Medium's editor because Delete key presses did not behave consistently in a contenteditable context.

## What actually works

The final script is about seventy lines with no DOM manipulation, no styling logic, and no markdown conversion. It uses pbcopy to write content to the macOS system clipboard and playwright-cli press Meta+V to fire a real Cmd+V through the browser. This is exactly what a human would do, and it is the most reliable approach for exactly that reason.

Headings, code blocks, bold, and italic all land as plain text in the draft. Applying heading style to a section takes about thirty seconds manually in Medium's editor after the draft is created. That tradeoff is acceptable. The draft has all the content in the right order and the right paragraphs, and the publish flow works reliably every time.

## Setting it up

Install the skill package by unzipping medium-story-drafter.skill into ~/.claude/skills/. Do the one-time persistent session login with playwright-cli -s=medium open https://medium.com/m/signin --headed --persistent and complete 2FA in the browser window that opens. Add the alias to ~/.zshrc pointing at the script. After that, the command works from any project directory.

## What ~/.claude looks like after setup

After running unzip -o medium-story-drafter.skill -d ~/.claude/skills/ and completing the one-time login, the ~/.claude directory looks like this.

```
~/.claude/
└── skills/
    └── medium-story-drafter/
        ├── SKILL.md
        ├── scripts/
        │   └── post_to_medium.sh
        └── references/
            └── medium-formatting.md
```

SKILL.md is what Claude Code reads to understand when and how to use this tool. Its description field tells Claude to trigger the skill whenever someone asks to draft or publish a Medium post. The scripts folder contains the actual bash script. The references folder has notes on Medium's formatting shortcuts for when you want to manually apply headings or code blocks after the draft is created.

The alias in ~/.zshrc points directly at the script so it can be called without Claude in the loop.

alias medium-draft='bash ~/.claude/skills/medium-story-drafter/scripts/post_to_medium.sh'

Claude Code scans the skills folder on every session, so the skill is automatically available in any project you open without any project-level configuration needed.

## Future work

The one remaining piece is automatic heading formatting. The approach that came closest was finding each heading paragraph via run-code, deleting the ## prefix with individual Delete key presses, selecting the clean text, and clicking the toolbar button, all within a single run-code call to keep the selection alive. The selector and the button click work when triggered manually. The challenge is that Delete key behaviour in Medium's contenteditable editor is inconsistent, and each round-trip between script steps risks losing editor focus.

The plan is to ship this as an optional --fix-styles flag so it is always opt-in and can never break the core paste and draft flow. The core flow, which reliably creates a draft and returns a link, is the part that actually eliminates the friction. Heading formatting is a thirty second manual step. Automating it is a nice to have, not a blocker.

## What I learned

Browser automation against a modern React editor is harder than it looks. Medium's contenteditable area behaves differently from a standard form input in ways that break the obvious approaches one by one. The thing that finally worked was treating the browser exactly like a human would use it, using the operating system clipboard rather than trying to inject content through JavaScript or simulate individual keystrokes.

The Claude Skill format made the tool immediately reusable across every project without any additional setup. That part worked exactly as expected from the start.