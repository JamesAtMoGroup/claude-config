---
name: vibe-coding-video project
description: Remotion course video project for AI 寫程式入門課程 — current state, pipeline, and standards
type: project
---

Remotion video project at `~/Projects/vibe-coding-video/` for the "Vibe Coding" course series.

**Why:** James produces course videos combining lecturer audio + HTML slide visuals + motion graphics using Remotion.

**How to apply:** Read `~/.claude/skills/course-video.md` before starting any video work. Progress is tracked in `~/Projects/vibe-coding-video/progress.md`.

## Current state (as of 2026-03-27)

- CH 0-1 full video rendered: `out/CH0-1-complete.mp4` — 65MB, 14m 27s
- All 14 scenes complete with VTT-synced progressive animation
- Audio pipeline fully applied: denoise → trim → normalize (−16 LUFS)
- HeyGen avatar script running for 14 segments (6,000 credits available)
- Avatar currently showing as placeholder black circle; final re-render pending HeyGen completion

## Key standards established

- **CONTAINER_W = 1500**, **SUBTITLE_H = 160** (bottom reserved for subtitles — no content)
- Font minimum: any content shown to learners ≥ 24px; main body ≥ 36px; UI chrome ≥ 16px
- Compare table: th 28px, td label 26px fontWeight 700, td content 26px, borderRadius 22
- Learning path steps: 48×48 circle, step# 18px, title 28px, desc 24px
- Quiz box: label 18px Space Mono, body 26px, bullets 24px
- Nav bar text: 16px Space Mono
- iMessage callout: `maxWidth: NOTIF_W`, no `minHeight`, no `\n` in text (use `，`)
- iMessage font: "訊息" 18px, "剛剛" 15px, sender 22px, body 34px fontWeight 800
- Stacking: `calcStackOffset()` is a plain function (not hook) — all hooks before `return null`
- Focus highlight: `useFocusHighlight(startFrame)` adds green glow when element first appears
- Avatar: Lottie (`speaking-animation.json`) — NOT HeyGen video
- Output: `out/CH{chapter}/CH{chapter}-complete.mp4` + `CH{chapter}-subtitles.vtt`

## 素材與講稿工作原則

### 音檔位置（新規則）
- 音檔在 `chapters/{chapter}/{chapter} 音檔/`，**不再放 `public/audio/`**

### 逐字講稿（.pages）
- 位置：`chapters/{chapter}/章節{chapter}_逐字講稿.pages`
- 雙用途：① Whisper VTT 校正對照稿 ② 素材插入時機依據
- `**備注**：使用相關素材 {檔名}.mp4 (片長 XX 秒)` = Scene Dev 必須在此插入 MP4

### 影片製作素材
- 位置：`chapters/{chapter}/{chapter} 影片製作相關素材/`
- 內容對應講稿的 `**備注**` 素材標記

### CH 0-1 未完成項目
- v5 缺少 4.3 段兩個螢幕錄影：`旅遊偏好的表單頁面.mp4`（56s）、`旅遊偏好的表單頁面_改顏色.mp4`（27s）

## Repo
- GitHub: `JamesAtMoGroup/vibe-coding-video`
- Progress doc: `~/Projects/vibe-coding-video/progress.md`
