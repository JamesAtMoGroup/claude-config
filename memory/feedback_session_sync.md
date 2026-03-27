---
name: session start/end sync rule
description: Read from laptop at session start; push to laptop AND GitHub at session end. Never pull from GitHub to start.
type: feedback
---

At the start of a session, read local files only — laptop is always the source of truth. Do not fetch from GitHub.

At the end of a session, push all new/changed files to both the local laptop AND GitHub (`claude-config` repo).

**Why:** Skills, memory, and project files are always kept in sync on the laptop. Pulling from GitHub at session start is redundant and slow. The sync direction is always: laptop → GitHub (push only), never GitHub → laptop (pull).

**How to apply:**
- Session start: read `~/.claude/rules.md`, `MEMORY.md`, `soul.md`, `personality.md` from local disk
- Session end: update any changed memory/skill files locally first, then push to GitHub
- Never `git pull` or fetch from claude-config to bootstrap a session
