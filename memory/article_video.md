---
name: article-video project
description: Remotion project for daily AI knowledge explainer videos; local at ~/Projects/article-video, GitHub at JamesAtMoGroup/article-video
type: project
---

Daily AI knowledge video pipeline using Remotion + narrator's own recorded audio.

**Why:** Turns daily AI articles into ~6.5 min explainer videos with 3D animations and iMessage callouts.
**How to apply:** Read `~/Projects/article-video/progress.md` first. Use Vibe Coding dark neon-green style (S=3, 4K). Always multi-agent for new videos.

## Key Details
- Repo: https://github.com/JamesAtMoGroup/article-video
- Local: `~/Projects/article-video/`
- Stack: Remotion v4.0.438, TypeScript, @remotion/three, @react-three/fiber, ffmpeg
- Design: Vibe Coding style (`#000000` bg, `#7cffb2` neon-green, `#ffd166` yellow, S=3)
- Output: `out/YYYY-MM-DD/YYYY-MM-DD.mp4` + `out/YYYY-MM-DD/ai-knowledge-YYYY-MM-DD.vtt`
- Render flag: `--gl=angle` (required for ThreeCanvas WebGL)
- Audio target: -20 LUFS, Peak -2 dBFS, Crest ~11 (ref: `0-1_4.3.wav`)

## Current Status (2026-03-30)
- 03-27 video complete: 6:29 (11678f), 3D animations, podcast audio, looping BG music
- SOP established: multi-agent parallel (Audio / Transcription / Scene Dev)
- Next: 03-28+ videos following new SOP

## Completed Videos
| ID | Date | Notes |
|----|------|-------|
| ArticleVideo | 2026-03-24 | Legacy 720p |
| ArticleVideo-2026-03-26 | 2026-03-26 | 4K, no 3D |
| ArticleVideo-2026-03-27 | 2026-03-27 | 4K + 3D + own audio + looping BG |
