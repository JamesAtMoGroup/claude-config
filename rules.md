# Claude Working Rules

## Conversation Start Protocol

At the **start of every new conversation**, before doing anything else:

1. **Fetch the latest skill index from GitHub:**
   ```
   gh api "repos/JamesAtMoGroup/claude-config/git/trees/HEAD?recursive=1" -q '.tree[].path'
   ```
2. **Read soul and personality:**
   - `~/.claude/projects/-Users-jamesshih/memory/soul.md`
   - `~/.claude/projects/-Users-jamesshih/memory/personality.md`
3. **Read MEMORY.md** to load past decisions and preferences.
4. If the task touches a specific domain, fetch that skill file from GitHub before writing any code.

## End of Section / Task Sync Protocol

After **completing any significant section of work** (finishing a feature, completing a task, finalizing a document):

1. Copy new/changed files to `/tmp/claude-config-sync/` (clone first if not already cloned)
2. Stage, commit, and push to `JamesAtMoGroup/claude-config`
3. Also update `MEMORY.md` with any new decisions or preferences discovered during the session

---

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
