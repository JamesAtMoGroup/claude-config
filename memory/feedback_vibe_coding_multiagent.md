---
name: multi-agent requirement for all video work
description: Always use multi-agent teams for ANY video work (Vibe Coding AND article-video) — never single-agent
type: feedback
---

Always use a multi-agent team when working on any video task — never do it as a single agent. Applies to both Vibe Coding and article-video projects. Each project now has a SEPARATE Director.

**Why:** James explicitly requires parallelized multi-agent workflow for all video work. Jobs like audio processing, VTT correction, and rendering should run in parallel agents, not sequentially in one agent.

**How to apply:** Spin up independent agents for independent jobs. Examples of tasks that can run in parallel:
- Audio processing (ffmpeg chain) ↔ Reading/analyzing source files
- VTT transcription ↔ Scene planning
- Multiple scene components written simultaneously by separate agents

**Read before planning (MANDATORY for any video Director):**
- vibe-coding-video: `.agents/AGENTS.md` → `.agents/rules/project.md` → `.agents/rules/pipeline.md` → `progress.md`
- article-video: `.agents/AGENTS.md` → `.agents/rules/project.md` → `.agents/rules/pipeline.md` → `progress.md`

## Director 強制閘門（必須遵守）

Scene Dev 完成 → Director **立即、自動**啟動 QA Agent（不等 James 指示）
QA 全部 ✅ → 才可通知 James / 開放 preview
QA 有 ❌ → Director 立即派 Fix Agent → 修完再跑 QA → 全 ✅ 才通知
**禁止在 QA 未完成前通知 James「完成了」或讓他看到 preview**

這個閘門的存在是因為 CH 0-3 Scene Dev 完成後 QA 未跑，James 直接看到了品質問題（SVG 太小、時間點估算、設計不一致）。問題應該由 QA 自動攔截，而非由 James 反應式發現。

## Minimum team structure for Vibe Coding

| Role | Job |
|------|-----|
| Director | 分派任務、監督流程、強制 QA 閘門 |
| Audio Agent | ffmpeg normalize（不降噪），輸出 frames |
| Transcription Agent | Whisper VTT + 逐字稿校正 + 音檔分割 |
| Visual Concept Agent | 輸出 visual-spec.json，每場景至少 1 個動畫 |
| Scene Dev Agent | 實作 TSX，完成後回報 Director |
| QA Agent | 逐項 checklist，有 ❌ 直接回報 Director（非 James） |
| Fix Agent | QA 找到問題後由 Director 派出修正 |
| Render Agent | QA 全通過後才啟動 |

For article-video:
| Audio Agent | ffmpeg processing, EQ, mix with BG music |
| Transcription Agent | Whisper VTT, cross-reference with article MD |
| Scene Dev Agent | Writes/edits Remotion TSX components |
| QA Agent | Same gate as above |
| Render Agent | After QA passes |

Sub-agents can be merged when tasks are small, but never collapse everything into one agent.
