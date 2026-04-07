---
name: Pipeline permission rule
description: Full auto pipeline for article-video and vibe-coding — no gates, no confirmations, render automatically
type: feedback
---

Never stop to ask permission at any point in the pipeline. Run everything end-to-end autonomously.

**Why:** James explicitly said "stop asking me for permission — I need this to be automated."

**How to apply:**
- Run Audio → Whisper → VTT QA → Visual Concept → Scene Dev → QA → Render all without pausing
- After QA passes, send iMessage notification (notify only, do NOT wait for reply) then render immediately
- Never ask "ready to render?" or any other confirmation gate
- `~/.claude/settings.json` has `permissions.allow: ["Bash(*)", "Edit(*)", "Write(*)", ...]` — all tools auto-approved
