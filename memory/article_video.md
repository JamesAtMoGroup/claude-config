---
name: article-video project
description: Remotion project for daily AI knowledge explainer videos; local at ~/article-video, GitHub at JamesAtMoGroup/article-video
type: project
---

Daily AI knowledge video pipeline using Remotion + TTS.

**Why:** Turns daily AI articles into short ~33s explainer videos for newsletter/content.
**How to apply:** When working on article-video, read `~/article-video/progress.md` first. Use glassmorphism style (BG `#0d0d1a`, ORANGE/TEAL/YELLOW). Skill for daily scraping is in `~/article-video/SKILL.md`.

## Key Details
- Repo: https://github.com/JamesAtMoGroup/article-video
- Local: `~/article-video/`
- Stack: Remotion, TypeScript, TTS audio, Lottie characters
- Design: Glassmorphism (`#0d0d1a` bg, `#FF6B35`/`#20D9BA`/`#FFD60A`)
- Output: `out/video.mp4` (~33s, 1280×720, 30fps)
- Daily articles: `ai-knowledge-YYYY-MM-DD.md` in project root
- Skill: `SKILL.md` = `daily-knowledge-scrape` (auto-search + write AI article)

## Current Status (2026-03-27)
- Source code complete and buildable
- 3 daily articles generated (Mar 24–26)
- Next: automate article → TTS → video pipeline
