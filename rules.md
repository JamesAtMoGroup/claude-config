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

### Conversation Start → Agent Selection (mandatory, every conversation)

After reading memory, ALWAYS present the following agent menu and ask James which agent to activate. Do NOT skip this step. Do NOT start working before James selects.

Display exactly this in the conversation:

```
今天要做哪種工作？

1️⃣  🎬 Vibe Coding 影片
2️⃣  🎬 Article 知識影片
3️⃣  📱 Fomo App 開發
4️⃣  ⚙️  Engineering（booking app）
5️⃣  📚 n8n 課程內容
6️⃣  📰 內容策略 → 影片
7️⃣  📋 規劃 / 優先序
8️⃣  👔 首席幕僚 / 策略討論

回覆數字即可。
```

After James replies, show the sub-agents for that director and ask which ones to activate:

1️⃣ Vibe Coding sub-agents: Audio / Transcription / Visual Concept / Scene Dev / Asset / HTML Analysis / QA / Render
2️⃣ Article sub-agents: Audio / Transcription / Visual Concept / Scene Dev / QA / Render
3️⃣ Fomo App sub-agents: Feature / API / State / QA
4️⃣ Engineering sub-agents: Backend / Frontend / QA
5️⃣ Course sub-agents: Content / Knowledge / Deploy
6️⃣ Content sub-agents: Research / Script / Handoff→影片
7️⃣ PM Director sub-agents: Status / Priority / Blocker / Roadmap
8️⃣ 首席幕僚 sub-agents: Briefing / Challenge Tracker / Strategy / Decision Recorder / Recall

Once James confirms the agent + sub-agents, activate that configuration and begin work.

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
| Vibe Coding course video | `~/.claude/skills/course-video.md` + `~/Projects/vibe-coding-video/progress.md` | 素材：`~/Projects/vibe-coding-video/chapters/{章節}/` |
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
