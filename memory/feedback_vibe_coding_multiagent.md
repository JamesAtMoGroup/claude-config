---
name: multi-agent requirement for all video work
description: Always use multi-agent teams for ANY video work (Vibe Coding AND article-video) — never single-agent
type: feedback
---

Always use a multi-agent team when working on any video task — never do it as a single agent. Applies to both Vibe Coding and article-video projects.

**Why:** James explicitly requires parallelized multi-agent workflow for all video work. Jobs like audio processing, VTT correction, and rendering should run in parallel agents, not sequentially in one agent.

**How to apply:** Spin up independent agents for independent jobs. Examples of tasks that can run in parallel:
- Audio processing (ffmpeg chain) ↔ Reading/analyzing source files
- VTT transcription ↔ Scene planning
- Multiple scene components written simultaneously by separate agents
- Render can start while another agent does QA on the source files

Minimum team structure for article-video:

| Role | Job |
|------|-----|
| Director | Assigns tasks, reviews outputs, makes final calls |
| Audio Agent | ffmpeg processing, denoise, EQ, mix with BG music |
| Transcription Agent | Whisper VTT, cross-reference with article MD, corrections |
| Scene Dev Agent | Writes/edits Remotion TSX components, timing sync |
| Render Agent | Runs render, monitors output, copies to out/ folder |

For Vibe Coding add:
| Asset Agent | Confirms files, copies audio, checks folder structure |
| HTML Analysis Agent | Maps HTML sections to audio timestamps |

Sub-agents can be merged when tasks are small, but never collapse everything into one agent.
