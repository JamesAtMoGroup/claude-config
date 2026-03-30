# Claude Working Rules

## Sync Protocol — Bidirectional

The sync script lives at `~/.claude/scripts/sync.sh`. It handles both directions.

### Conversation Start → Pull (GitHub → local)
Run at the start of every new conversation:
```bash
~/.claude/scripts/sync.sh pull
```
This pulls the latest from `JamesAtMoGroup/claude-config` and overwrites local skills, commands, memory, settings, rules, and CLAUDE.md with whatever is newest on GitHub.

Then read:
- `~/.claude/projects/-Users-jamesshih/memory/soul.md`
- `~/.claude/projects/-Users-jamesshih/memory/personality.md`
- `~/.claude/projects/-Users-jamesshih/memory/MEMORY.md`

### End of Section → Push (local → GitHub)
Run after completing any significant section of work:
```bash
~/.claude/scripts/sync.sh push
```
This copies all local `~/.claude/` files (skills, commands, memory, settings, rules, CLAUDE.md) into the clone and pushes to GitHub. Also update `MEMORY.md` with any new decisions before pushing.

### Full Sync (both directions)
```bash
~/.claude/scripts/sync.sh both
```

---

## Skill Loading — Lazy Only

**Never pre-load skill files.** Load exactly one skill file, only when the task requires it.

| Task type | Read this — nothing else |
|-----------|--------------------------|
| Remotion / video | `~/.claude/commands/remotion-video.md` |
| Vibe Coding course video | `~/Downloads/Vibe Coding 剪輯/course-video.md` + `~/Projects/vibe-coding-video/progress.md` | 素材：`~/Projects/vibe-coding-video/chapters/{章節}/` |
| n8n course | `memory/n8ncourse.md` |
| LINE booking app | `~/Projects/line-liff-booking/README.md` |
| Design / UI | `~/.claude/skills/ui-ux-pro-max/SKILL.md` |
| Slides | `~/.claude/skills/frontend-slides/SKILL.md` |
| Three.js / ECS / game dev | `~/.claude/skills/threejs-ecs-ts/claude-code-plugin.json` (lists all skill paths) |
| MCP large response | `~/.claude/skills/mcp-response-analyzer/SKILL.md` |

---

## General Rules

1. **One skill, on demand.** If a relevant skill exists, load only that one file before writing code.
2. **Memory is ground truth.** Read `memory/MEMORY.md` to find past decisions — don't re-derive what's already decided.
3. **Never skip the style guide** — for any visual/video work, apply Glassmorphism + YouTube Tutorial style.
4. **No timeframes or instructor bios** in course content.
5. **Progress bars**: chapter title + scrubber only — no mm:ss timestamps.
