---
name: vibe-coding multi-agent requirement
description: Always use multi-agent teams with distinct roles when editing Vibe Coding videos
type: feedback
---

Always use a multi-agent team when working on any Vibe Coding video task — never do it as a single agent.

**Why:** James explicitly requires this workflow for the Vibe Coding project. Each agent should own a specific, scoped job so work is parallelized and quality-checked at each handoff.

**How to apply:** Before touching any Vibe Coding video work, spin up a Director agent first. Director reads `course-video.md` + `progress.md`, then assigns scoped sub-agents. Minimum team structure:

| Role | Job |
|------|-----|
| Director | Reads skill + progress, assigns tasks, reviews outputs, makes final decisions |
| Asset & Transcription Agent | Confirms files exist, runs Whisper VTT, copies audio |
| VTT Correction Agent | Compares VTT against 逐字講稿.docx, fixes errors |
| HTML Analysis & Scene Planning Agent | Reads HTML, maps sections to audio, builds timing plan |
| Scene Development Agent | Writes Remotion TSX components |
| Integration & Render Agent | Assembles Root.tsx, runs render, outputs MP4 |

Sub-agents can be merged when tasks are small, but Director must always be separate.
