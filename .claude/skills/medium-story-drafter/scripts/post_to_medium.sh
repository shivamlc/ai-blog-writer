#!/usr/bin/env bash
# Paste title + body into Medium via macOS clipboard, save draft or publish.
set -euo pipefail

TITLE=""
BODY_FILE=""
PUBLISH=false
SESSION="medium"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --title)      TITLE="$2"; shift 2 ;;
    --body-file)  BODY_FILE="$2"; shift 2 ;;
    --session)    SESSION="$2"; shift 2 ;;
    --publish)    PUBLISH=true; shift ;;
    *)            echo "Unknown argument: $1" >&2; exit 1 ;;
  esac
done

[[ -z "$TITLE" ]]                    && { echo "Error: --title required" >&2; exit 1; }
[[ -z "$BODY_FILE" || ! -f "$BODY_FILE" ]] && { echo "Error: --body-file not found" >&2; exit 1; }

PW=(playwright-cli "-s=$SESSION")

echo "Opening Medium ..."
"${PW[@]}" open https://medium.com/new-story --headed --persistent

# Check logged in
URL="$("${PW[@]}" eval "() => window.location.href" 2>/dev/null | grep -o 'https://[^"[:space:]]*' | head -1)"
[[ "$URL" == *"signin"* ]] && { echo "Not logged in. Log in manually then re-run." >&2; exit 1; }

# Click title field
"${PW[@]}" run-code 'async (page) => {
  await page.waitForSelector("[contenteditable=true]", { timeout: 15000 });
  const els = await page.$$("[contenteditable=true]");
  if (els[0]) await els[0].click();
}'

# Paste title
echo "Pasting title ..."
printf '%s' "$TITLE" | pbcopy
"${PW[@]}" press Meta+v
"${PW[@]}" press Enter
sleep 0.5

# Click body field
"${PW[@]}" run-code 'async (page) => {
  await page.waitForTimeout(500);
  const els = await page.$$("[contenteditable=true]");
  const body = els[1] ?? els[0];
  if (body) {
    await body.evaluate(el => el.scrollIntoView({ block: "center" }));
    await page.waitForTimeout(200);
    await body.click({ force: true });
  }
}'

# Paste body
echo "Pasting body ..."
pbcopy < "$BODY_FILE"
"${PW[@]}" press Meta+v

# Wait for autosave
echo "Waiting for autosave ..."
"${PW[@]}" run-code 'async (page) => {
  await page.waitForTimeout(2000);
  await page.waitForFunction(
    () => location.href.includes("medium.com/p/"),
    { timeout: 30000 }
  ).catch(() => {});
  await page.waitForTimeout(1000);
}'

DRAFT_URL="$("${PW[@]}" eval "() => window.location.href" 2>/dev/null \
  | grep -o 'https://medium\.com/p/[^"[:space:]]*' | head -1)"
[[ -z "$DRAFT_URL" ]] && DRAFT_URL="https://medium.com/me/stories/drafts"

"${PW[@]}" screenshot

if [[ "$PUBLISH" == "true" ]]; then
  echo "Publishing ..."
  # Click the green Publish button in the nav to open the Story preview modal
  "${PW[@]}" click "getByRole('button', { name: 'Publish' })"
  sleep 2

  # Click the black Publish button inside the Story preview modal.
  # This button is visually distinct from the green nav button --
  # it's the one next to "Schedule for later" at the bottom of the modal.
  "${PW[@]}" run-code 'async (page) => {
    await page.waitForSelector("text=Story preview", { timeout: 10000 });
    await page.waitForTimeout(500);
    // Find the black Publish button -- it sits next to "Schedule for later"
    // Look for a button containing exactly "Publish" that is visible in the modal
    const btns = await page.$$("button");
    for (const btn of btns) {
      const txt = (await btn.innerText().catch(() => "")).trim();
      const visible = await btn.isVisible().catch(() => false);
      if (txt === "Publish" && visible) {
        const box = await btn.boundingBox().catch(() => null);
        // Modal Publish button is below y=400, nav button is at top ~y=32
        if (box && box.y > 400) {
          await btn.click();
          console.log("Clicked modal Publish at y=" + box.y);
          return;
        }
      }
    }
    console.log("Modal Publish button not found");
  }'
  "${PW[@]}" run-code 'async (page) => {
    await page.waitForFunction(
      () => !location.href.includes("/new-story") && !location.href.includes("/edit"),
      { timeout: 15000 }
    ).catch(() => {});
    await page.waitForTimeout(1000);
  }'
  PUB_URL="$("${PW[@]}" eval "() => window.location.href" 2>/dev/null \
    | grep -o 'https://medium\.com/p/[a-z0-9]*' | head -1)"
  "${PW[@]}" screenshot
  "${PW[@]}" run-code 'async (page) => { await page.close(); }'
  echo ""
  echo "Published: ${PUB_URL:-https://medium.com/me/stories/public}"
else
  "${PW[@]}" run-code 'async (page) => { await page.close(); }'
  echo ""
  echo "Saved as draft."
  echo "Draft link: $DRAFT_URL"
  echo ""
  echo "To publish: medium-draft --title \"...\" --body-file $BODY_FILE --publish"
fi
