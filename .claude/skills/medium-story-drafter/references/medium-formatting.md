# Medium editor formatting tips

Medium's story editor converts markdown-style shortcuts as you type. The
script in this skill only types plain paragraphs (one per line in the body
file), but you can write those lines using these shortcuts to get richer
formatting once Medium's editor renders them:

| Want                | Type at start of line / around text |
| ------------------- | ------------------------------------ |
| Heading 1 (Title)   | `# ` then text                        |
| Heading 2 (Subtitle)| `## ` then text                       |
| Bold                | `**text**`                             |
| Italic              | `*text*`                               |
| Blockquote          | `> ` then text                        |
| Bulleted list item  | `- ` then text                        |
| Numbered list item  | `1. ` then text                       |
| Horizontal rule     | `---` then Enter                      |
| Inline code         | `` `code` ``                          |
| Fenced code block   | ` ``` ` on its own line, code lines, then ` ``` ` on its own line |

These only apply to the **body**. The title field (first line) is plain text
only -- Medium does not apply markdown shortcuts there.

## Fenced code blocks

The script handles ` ``` ` fences specially, since a code block doesn't
exit on a normal Enter the way a paragraph does:

- A line that is exactly ` ``` ` (optionally with a language, e.g.
  ` ```bash `) **opens** a code block.
- Every line until the next ` ``` ` is typed as-is, including blank lines
  (blank lines inside the block become blank lines in the code, not
  skipped).
- The matching closing ` ``` ` line is **not typed** -- instead the script
  presses Enter twice on an empty line, which is how Medium's editor exits
  a code block, then continues with the next paragraph.

So this in your body file:

```
```bash
medium-draft --title "My Title" --body-file body.md
```
```

becomes a real Medium code block containing one line, followed by a normal
paragraph for whatever comes next.

Each line in the body file becomes its own paragraph/block (the script
presses Enter after every line). For a numbered/bulleted list, putting
consecutive `- ` or `1. ` lines one after another will produce a continuous
list, since Medium keeps list formatting active across Enter presses.

Images, embeds, and tables require Medium's `+` / `/` insert menu and are
not handled by this skill -- add those manually after the draft opens.
