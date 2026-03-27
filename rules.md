# Claude Working Rules

## Always Read Before Working

Before starting any task, read all files relevant to that domain:

### Remotion / Video Work
- `~/.claude/commands/remotion-video.md` — full skill: TTS, animation hooks, subtitle system, scene architecture
- `~/.claude/projects/-Users-jamesshih/memory/remotion_style_preference.md` — James's style: Glassmorphism + YouTube Tutorial
- `~/.claude/projects/-Users-jamesshih/memory/feedback_remotion_style.md` — style rules summary

### n8n Course
- `~/.claude/projects/-Users-jamesshih/memory/n8ncourse.md` — repo structure, design tokens, URL conventions

### LINE Booking App
- `~/Projects/line-liff-booking/README.md` — system design, architecture, deployment notes

### Design / UI Work
- `~/.claude/skills/design-system/SKILL.md`
- `~/.claude/skills/ui-ux-pro-max/SKILL.md`
- `~/.claude/skills/brand/SKILL.md`

### Slides / Presentations
- `~/.claude/skills/frontend-slides/SKILL.md`
- `~/.claude/skills/frontend-slides/STYLE_PRESETS.md`
- `~/.claude/skills/frontend-slides/animation-patterns.md`

---

## General Rules

1. **Always check `~/.claude/skills/` first** — if a relevant skill exists, follow it exactly before writing any code.
2. **Always check `~/.claude/commands/`** — slash commands there define the canonical workflow for that task type.
3. **Memory is ground truth for preferences** — read `~/.claude/projects/-Users-jamesshih/memory/MEMORY.md` to find relevant past decisions before suggesting approaches.
4. **James's GitHub is the source of skills**: https://github.com/JamesAtMoGroup/claude-config — if a skill seems outdated, re-fetch from GitHub.
5. **Never skip the style guide** — for any visual/video work, apply the Glassmorphism + YouTube Tutorial style from `remotion_style_preference.md`.
6. **No timeframes or instructor bios** — never add fixed course durations (三週 etc.) or instructor profile sections to course pages.
7. **Progress bars**: chapter title + scrubber only — no mm:ss timestamps.
