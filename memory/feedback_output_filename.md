---
name: Output filename convention
description: article-video rendered output files must use {title}-{date}.{ext} format
type: feedback
---

Rendered output files must follow this naming format: `{title}-{date}.{ext}`

Example: `什麼是MCP-2026-04-13.mp4` and `什麼是MCP-2026-04-13.vtt`

**Why:** James specified this naming convention explicitly — the title comes first, then the date.

**How to apply:**
- Output directory: `out/{date}/`
- MP4 filename: `{episode-title}-{date}.mp4`
- VTT filename: `{episode-title}-{date}.vtt`
- Episode title = the topic/article title in Chinese (or English), NOT "ai-knowledge"
- Date format: `YYYY-MM-DD`
