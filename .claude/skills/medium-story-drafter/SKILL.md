---
name: medium-story-drafter
description: Use playwright-cli (https://playwright.dev/agent-cli) to drive a real, persistent browser session to Medium's story editor (https://medium.com/new-story), paste in a title and body from a local .md file via the macOS clipboard, save as an unpublished draft and print the draft link, then close the browser. By DEFAULT saves draft and prints link -- pass --publish to go live, --fix-styles to apply heading/code block formatting via Medium's toolbar after paste (opt-in, never breaks core flow), or both together. Trigger whenever the user wants to draft, write, post, or publish a story/article/post to Medium. Login including 2FA is a one-time manual step in a persistent browser profile.
---

# Medium Story Drafter

Pastes title + body into Medium's new story editor via the macOS clipboard,
saves as draft (default) or publishes (--publish), prints the URL, and closes
the browser.

## Flags

```
--title "..."         Story title (required)
--body-file path.md   Path to body content file (required)
--publish             Publish immediately instead of saving a draft
--fix-styles          After paste, apply ## headings and code block styling
                      via Medium's toolbar (opt-in -- errors here never abort
                      the draft/publish flow)
--session name        playwright-cli session name (default: medium)
```

## Usage examples

```bash
# Save as draft, print link
medium-draft --title "My Title" --body-file body.md

# Save draft + fix heading/code styles
medium-draft --title "My Title" --body-file body.md --fix-styles

# Publish immediately
medium-draft --title "My Title" --body-file body.md --publish

# Fix styles + publish
medium-draft --title "My Title" --body-file body.md --fix-styles --publish
```

# Medium Story Drafter

Drives Medium's "New story" editor with `playwright-cli` and types in the
title/body the user provides.

- **Default behavior**: save as an **unpublished draft** and print the
  draft's edit link (Medium autosaves once a title exists).
- **Opt-in publish**: only if the user explicitly asks to publish/post it
  live, run the script with `--publish`, which clicks Publish → Publish now
  and prints the live story URL instead.

If the user's request is ambiguous about draft vs. publish, default to a
draft and tell them they can ask to publish it (or re-run with `--publish`).

## Prerequisites (one-time setup)

```bash
npm install -g @playwright/cli@latest
playwright-cli install-browser   # installs chromium
```

## One-time login (handles 2FA)

`state-save`/`state-load` cookie replay does not reliably survive 2FA. Use a
named **persistent session** instead -- a real on-disk browser profile that
Medium treats as a real, remembered device:

```bash
playwright-cli -s=medium open https://medium.com/m/signin --headed --persistent
# log in fully, including 2FA, in the browser window that opens
```

Then verify it stuck:

```bash
playwright-cli -s=medium open https://medium.com/new-story --headed --persistent
```

If this lands in the story editor (not a sign-in page), the persistent
profile remembers the session. This is a one-time step -- future runs of
the script reuse the same `medium` profile and stay signed in.

## Running the skill

1. Get the story content from the user: a **title** and a **body**. If the
   user pastes text inline, write it to a temp file (e.g.
   `/tmp/medium-body.md`), one paragraph per line, blank lines between
   paragraphs are ignored. See `references/medium-formatting.md` for how to
   express headings, bold, bullet lists, etc. using Medium's markdown
   shortcuts.
2. Run the script (draft, default):

```bash
bash scripts/post_to_medium.sh \
  --title "My Story Title" \
  --body-file /tmp/medium-body.md
```

This prints something like:

```
Saved as draft (not published).
Draft link: https://medium.com/p/<id>/edit
Re-run with --publish to publish this story instead.
```

To publish immediately instead of saving a draft, add `--publish`:

```bash
bash scripts/post_to_medium.sh \
  --title "My Story Title" \
  --body-file /tmp/medium-body.md \
  --publish
```

which prints the live story URL instead of a draft link.

If the script exits saying it's not logged in (the persistent profile's
session expired), re-run the one-time login step above, then retry.

3. The script opens `https://medium.com/new-story` in a headed browser,
   types the title, then each body line as its own paragraph, waits for
   Medium's autosave to assign a `/p/<id>` URL, and takes a screenshot. With
   `--publish` it additionally confirms through Medium's publish flow.
4. Share the printed link with the user (draft edit link, or live story URL
   if `--publish` was used).

## Notes

- Uses a named persistent session (`-s=medium --persistent`), a real
  on-disk browser profile stored by `playwright-cli`. The browser stays
  open between commands within a run, so the user can keep interacting
  with the draft (or published story) after the script ends.
- If the session isn't logged in, the script exits with the one-time login
  instructions above instead of hanging or failing silently.
- Medium's editor is a contenteditable rich-text area, not plain
  `<input>`/`<textarea>` fields — `type` + `press Enter` (simulated
  keystrokes) is used instead of `fill`, because `fill` can bypass the
  editor's internal React state.
- The `--publish` path clicks the top-nav "Publish" button, then clicks the
  *last* button with the exact accessible name "Publish" (Medium's
  confirmation modal reuses the same label). If Medium changes this UI,
  run `playwright-cli -s=medium snapshot` after clicking the first
  "Publish" to find the new confirm button's name and adjust the locator in
  `scripts/post_to_medium.sh`.
- A draft link opens the editor for the logged-in author only — it isn't a
  public preview link. The published URL (with `--publish`) is public.
- Override the session name with `--session <name>` if you want a separate
  persistent profile (e.g. a second Medium account).
