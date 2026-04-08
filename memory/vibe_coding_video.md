---
name: vibe-coding-video project
description: Remotion course video project — automation pipeline, current chapter state, key standards
type: project
---

Remotion video project at `~/Projects/vibe-coding-video/` for the "Vibe Coding" course series.

**Why:** James produces course videos combining lecturer audio + HTML slide visuals + motion graphics using Remotion.

**How to apply:** Read `~/Projects/vibe-coding-video/.agents/rules/pipeline.md` as source of truth. `~/.claude/skills/course-video.md` for supplemental standards.

## Current State (2026-04-08)

| Chapter | Status |
|---------|--------|
| CH 0-1 | ✅ 完成，Drive 已上傳 |
| CH 0-2 | ✅ 完成，Drive 已上傳 |
| CH 0-3 | ✅ 完成，Drive 已上傳 |
| CH 1-1 | ✅ 完成，Drive 已上傳 |
| CH 1-2 | 🔄 Pipeline 執行中（Whisper Phase 1） |
| CH 1-3 | ⏳ 排隊中（1-2 完成後自動觸發） |
| CH 1-4 | ⏳ 排隊中（1-3 完成後自動觸發） |

## 自動化 Pipeline

**完全自動**，LaunchAgents 常駐運行：
- `com.jamesshih.vibe-intake` — Drive intake watcher（每 120 秒 poll）
- `com.jamesshih.vibe-watch` — 本機 chapters/ 資料夾 watcher

**一次只跑一個 chapter**（2026-04-08 修正）：有 lock 時 watcher 跳過，完成後自動觸發下一個。

**James 唯一需要做的事**：
1. 等 iMessage QA 通知
2. 開 `http://localhost:3000` 預覽
3. 回「通過」→ 自動 render + Drive 上傳

## 關鍵修正記錄（2026-04-08）

- **LaunchAgent PATH 修正**：`start-chapter.sh` / `post-render.sh` 開頭加 `export PATH="$HOME/.local/bin:/opt/homebrew/bin:/usr/local/bin:$HOME/Library/Python/3.9/bin:$PATH"`（claude、whisper、npx、ffmpeg、rclone 都在這些路徑）
- **Whisper 錯誤處理**：單一檔案失敗加 `|| true`，不中斷整體 pipeline
- **QA chapter 路徑修正**：`chapters/${CHAPTER}` 不是 `chapters/CH${CHAPTER}`
- **整段影片 segment 規格**：詳見 pipeline.md 及 course-video.md

## Scale & Output

- S=2, 4K 3840×2160, fps=30
- Output: `out/CH{N}-{章節標題}/CH{N}-{章節標題}.mp4 + .vtt + .html`
- Drive: `1jt_nkySWqs_iGBVUARVDW053DA6pOlJY`

## Repo
- GitHub: `JamesAtMoGroup/vibe-coding-video`
- Scripts: `~/Projects/vibe-coding-video/scripts/`
- Pipeline SOP: `.agents/rules/pipeline.md`
