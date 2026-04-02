---
name: Pipeline permission rule
description: During article-video (and vibe-coding) pipeline, never ask for permission mid-pipeline — only ask before render
type: feedback
---

Never stop to ask permission during the production pipeline. Just proceed through all phases autonomously.

**Why:** James explicitly said "stop asking me for permission."

**How to apply:** Run Audio → Whisper → VTT QA → Scene Dev → Animation QA all without pausing to confirm each step. The only gate is **before render** — always open the browser preview first, then ask "ready to render?" before running `npm run build:YYYY-MM-DD`.
