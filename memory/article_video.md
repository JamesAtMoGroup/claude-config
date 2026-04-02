---
name: article-video project
description: Remotion project for daily AI knowledge explainer videos; local at ~/Projects/article-video, GitHub at JamesAtMoGroup/article-video
type: project
---

Daily AI knowledge video pipeline using Remotion + narrator's own recorded audio.

**Why:** Turns daily AI articles into ~6.5 min explainer videos with 3D animations and iMessage callouts.
**How to apply:** Read `~/Projects/article-video/progress.md` first. Use Vibe Coding dark neon-green style (S=3, 4K). Always multi-agent for new videos. Every agent must produce a checklist file in `ai-knowledge-YYYY-MM-DD/`; Director verifies all checklists before render.

## Key Details
- Repo: https://github.com/JamesAtMoGroup/article-video
- Local: `~/Projects/article-video/`
- Stack: Remotion v4.0.438, TypeScript, @remotion/three, @react-three/fiber, ffmpeg
- Design: Vibe Coding style (`#000000` bg, `#7cffb2` neon-green, `#ffd166` yellow, S=3)
- Output: `out/YYYY-MM-DD/YYYY-MM-DD.mp4` + `out/YYYY-MM-DD/ai-knowledge-YYYY-MM-DD.vtt`
- Render flag: `--gl=angle` (required for ThreeCanvas WebGL)
- Audio target: -20 LUFS, Peak -2 dBFS, Crest ~11 (ref: `0-1_4.3.wav`)

## Current Status (2026-03-30)
- 03-30 video in progress: Token & Context Window episode, VTT-driven timing
- SOP revised: VTT-first pipeline (Audio+Script parallel → Whisper → QA VTT → Scene Dev → Animation QA → Render)
- Key lessons: QA before render; ContentColumn maxHeight=570*S; SUBTITLE_SAFE=80*S; rich animations required

## Critical Rules (all video Agents must know)
1. **Mandatory checklists**: Every agent must save a checklist file to `ai-knowledge-YYYY-MM-DD/checklist-[agent].md`. Director reads and verifies all `[x]` before next phase. Any `[ ]` = agent must redo.
2. **VTT-first**: Scene Dev AND Visual Concept Agent CANNOT start until corrected VTT exists
2. **QA before render**: No render until Animation QA passes
3. **Subtitle safe zone**: ContentColumn maxHeight = H - contentTop - SUBTITLE_SAFE where `SUBTITLE_SAFE = 120*S` (360px at 4K, 17% of canvas) — NOT 80*S
4. **Element Fade-Out**: Multi-element Scenes MUST fade out + remove early elements from DOM before later elements appear; total visible height must never exceed maxHeight=1590px at 4K
5. **AnalogyBox delay**: delay must be < scene duration; if delay ≥ duration it never renders
6. **Sentence-level animation**: Every VTT cue is a visual design decision. Ask: "What should the audience SEE at the exact moment this sentence is spoken?" Visual elements must appear at `vtt_seconds × 30`, not guessed
7. **No 30s gaps**: No scene may go 30+ seconds without a new visual element appearing
8. **SummaryScene required**: Last ~30s must have dedicated SummaryScene with 3 recap cards
9. **Whisper**: use `python3 -m whisper` (not `whisper`); sub-agents have no Bash access
10. **No anlmdn**: Skip denoise filter; breaks audio quality

## Standard Production Requirements (updated 2026-04-02)

**Concept Animations (Motion Graphics)** are now mandatory for all article-video productions:
- Every video must include 3–5 concept animations synced to VTT timestamps (ideally 1 per scene + title)
- triggerFrame = `Math.round(vttSeconds × 30)`; animations float as `position: absolute` overlays at `zIndex: 50`, `pointerEvents: none`
- Standard envelope: fade-in 0–10f, hold, fade-out last 12f; total duration 70–90f
- `useCurrentFrame()` called once at component top level only — never inside `.map()`
- Must not overlap subtitle safe zone (bottom `120*S` px)
- First implemented in 04-01 RAG video: `BrainForgetAnimation` (f415), `KnowledgeFreezeAnimation` (f4022), `DocumentSliceAnimation` (f6716)
- Full spec in `~/.claude/skills/article-video.md` → "Concept Animations (Motion Graphics)" section

## Completed Videos
| ID | Date | Notes |
|----|------|-------|
| ArticleVideo | 2026-03-24 | Legacy 720p |
| ArticleVideo-2026-03-26 | 2026-03-26 | 4K, no 3D |
| ArticleVideo-2026-03-27 | 2026-03-27 | 4K + 3D + own audio + looping BG |
| ArticleVideo-2026-03-30 | 2026-03-30 | Token & Context Window, VTT-driven timing, SummaryScene |
