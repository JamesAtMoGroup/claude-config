---
name: Post-render deliverables — 3 files required, chapter not done until all exist
description: A chapter is only complete when mp4 + subtitles.vtt + .html all exist in out/CH{N}-{title}/
type: feedback
---

A chapter is NOT complete after rendering the mp4. Three files are required:
1. `CH{N}-{title}.mp4`
2. `CH{N}-{title}-subtitles.vtt` — merged from per-segment VTTs using SEG_STARTS offsets
3. `CH{N}-{title}.html` — static course page mirroring slide content, NO logo bar

All three go in: `out/CH{N}-{title}/`

**Why:** CH0-3 was rendered to the wrong path (~/Downloads) and the VTT + HTML were never generated. James was very upset — "where is the .vtt file? where is the HTML?" The pipeline felt "done" after the mp4.

**How to apply:** After every render, immediately run the VTT merge script and generate the HTML. Do not report completion until all 3 files exist and are in the correct folder. The render script in package.json must always point to `out/CH{N}-{title}/` — never to Downloads or any other path.

## HTML rules
- Mirror every slide's content exactly — students reading the HTML see the same thing as the video
- Reference style from: `out/CH0-2-.../CH0-2-....html`
- **NO logo bar** — never add any logo, header image, or fixed top bar
- **NO inter-lecture navigation** — only `← 返回主頁`
- Use same design tokens: bg #000000, primary #7cffb2, secondary #ffd166, Noto Sans TC + Space Mono
