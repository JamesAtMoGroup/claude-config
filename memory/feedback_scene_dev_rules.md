---
name: Scene Dev mandatory rules — VTT timing, asset size, safe zones
description: Three hard rules for all video Scene Dev agents; violations cause visible bugs
type: feedback
---

Three rules Scene Dev agents MUST follow — all three were violated in CH1-1 causing rework.

## Rule 0 — Read the script .txt and implement every 備注 exactly

Before writing any scene, read `chapters/{chapter}/章節{chapter}_逐字講稿.txt`.

Find every `**備注**` block. Each specifies:
- **使用相關素材**: exact filenames to embed
- **呈現方式**: exact layout — follow it literally, not approximately

Rules:
- Asset appears at the VTT frame when the speaker says the content just before the 備注
- "併排並拉箭頭" = horizontal row with arrow (NOT a 2×2 grid)
- "影片置中" = **full-screen AbsoluteFill overlay** (zIndex: 999, covers entire 3840×2160 including nav/subtitle). NOT inside SceneWrap. Mute speaker audio during the video via volume callback. Always convert `.mov` → `.mp4` first (ffmpeg libx264) for browser compatibility. Fade in/out 18f.
- **Video filenames must be ASCII** — Chinese/CJK characters in filenames cause URL encoding failures in the browser preview. Always rename to ASCII before using in code (e.g. `跨部門彙整.mp4` → `kuabumen-demo.mp4`).
- **Prefetch video assets** — add a `useEffect` at the composition root that creates a hidden `<video>` element to preload heavy assets before they appear.
- Asset goes in the scene matching the script section number — never moved elsewhere
- Callouts must NOT fire before the speaker says the related topic — `from` ≥ VTT cue start for that topic

**Why:** CH1-1 scene 3.2 had both 備注 markers: PNGs should be horizontal row + .mov centered in scene 3.2. Instead the agent used a 2×2 grid for PNGs and placed the .mov in scene 4.3 (wrong scene entirely). Callouts in Scene11Hero fired at 15f and 150f — before the speaker said anything related.

---

## Rule 1 — Motion graphics timing from VTT, never guessed

Every `startFrame`, callout `from/to`, and scroll trigger MUST come from reading the actual `.vtt` file.
Never approximate (e.g. "~21s = 630f"). Read the cue, multiply by 30.

```
VTT: "00:21.620 --> 00:24.100 但如果你能夠把這件事情自動化"
→ startFrame = Math.round(21.62 * 30) = 648
```

**Why:** All CH1-1 timings were guessed, causing motion graphics to appear seconds before or after the speaker mentioned the concept. James had to call it out and request a full fix pass.

**How to apply:** Before writing any scene, open the segment's `.vtt`, find each key concept cue, and annotate the exact frame. Then use those frames as `startFrame` values.

---

## Rule 2 — Assets must be large enough to read at 4K

- Minimum image width: `200 * S` (400px). Prefer `240–320 * S`.
- If 4+ images appear at once → use a 2×2 grid, not a vertical stack.
- Video embeds: `width: "100%"` or at least `600 * S`.

**Why:** CH1-1 scene 3.2 had 4 department PNG screenshots at 160×100*S — completely unreadable on a 3840px canvas. James said "根本看不到圖片".

**How to apply:** After sizing any image, ask: "Can someone read the text in this screenshot on a 3840px wide screen?" If not, increase size or change layout.

---

## Rule 3 — All content must stay within the safe zone

Safe zone boundaries:
- Top: `NAV_H = 144px` (never place content above)
- Bottom: `H - SUBTITLE_H = 1840px` (never exceed without scroll)

If content overflows bottom:
1. Calculate `maxScroll = totalContentHeight - (H - NAV_H - SUBTITLE_H - paddingTop)`
2. Add `scrollY = interpolate(frame, [triggerStart, triggerEnd], [0, maxScroll], clamp)`
3. Trigger = VTT frame when the overflowing content is being spoken
4. Pass `scrollY` to `SceneWrap`

**Why:** CH1-1 scene 3.2 "自動化後，每週少..." result block was completely hidden behind the subtitle reserved area. Scene 4.3 had the video embed at the very bottom, covered by subtitle zone.

**How to apply:** Before finalizing a scene, estimate total content height. If it exceeds 1696px, add scroll. Never let important content render below 1840px without bringing it into view via scroll.
