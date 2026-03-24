---
name: Remotion video style preference
description: User's preferred motion graphics style when editing tutorial videos with Remotion
type: feedback
---

Default motion graphics style: **Glassmorphism + YouTube Tutorial**

- Frosted glass panels (`backdrop-filter: blur`, semi-transparent backgrounds, gradient borders)
- Bright accent cards with rounded corners
- Friendly emoji icons in callout boxes
- Warm, approachable color accents (not cold/corporate)
- Spring animations for entry/exit

**Why:** User reviewed style options and selected this combination after seeing the first render.

**How to apply:** Whenever building Remotion components (LowerThird, Callout, ChapterCard, ProgressBar, Intro, Outro), default to glassmorphism surfaces + YouTube-tutorial-friendly typography and colors. Do not use the plain dark-navy minimal style unless asked.

Also: **No timestamp in the progress bar** — show the progress scrubber and chapter title only, remove the `mm:ss / mm:ss` time display.
