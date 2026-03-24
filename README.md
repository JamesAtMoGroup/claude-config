# Claude Code Config

Personal Claude Code configuration — global instructions, custom skills, slash commands, and persistent memory.

---

## Structure

```
.
├── CLAUDE.md              ← Global rules Claude reads every session
├── settings.json          ← MCP servers, plugins, voice (redact PAT before use)
├── settings.local.json    ← Per-machine shell permissions
├── commands/              ← Custom slash commands
├── skills/                ← Skill knowledge bases (injected by Skill tool)
└── memory/                ← Persistent memory across conversations
```

---

## CLAUDE.md

The most important file. Claude reads this at the start of every session. It defines:

- **Autonomy rule** — Claude does things itself, never asks you to do what it can do
- **UI rule** — always ask for UI/UX style preference before writing any webpage code
- **n8n API credentials** (instance URL + key)
- **Skills Reference table** — which skill to use for which task, with a decision tree

---

## settings.json

| Key | Value |
|-----|-------|
| `voiceEnabled` | `true` |
| `mcpServers.github` | GitHub MCP via `@modelcontextprotocol/server-github` |
| `enabledPlugins` | `frontend-design@claude-plugins-official` |

> Replace `YOUR_GITHUB_PAT_HERE` with a GitHub Personal Access Token (classic, `repo` scope).

---

## commands/

Custom slash commands invoked with `/command-name` in Claude Code.

| File | Command | Purpose |
|------|---------|---------|
| `remotion-video.md` | `/remotion-video` | Remotion framework reference + style preferences (Glassmorphism + YouTube Tutorial) |

---

## skills/

Knowledge bases loaded by the `Skill` tool. Each folder is one skill.

| Folder | Skill Name | When to Use |
|--------|------------|-------------|
| `ui-ux-pro-max/` | `ui-ux-pro-max` | Any webpage or app UI — 50+ styles, 161 palettes, 10 stacks. **Required before writing UI code.** |
| `design/` | `design` | Logos, CIP, banners, slides, icons, social media images |
| `banner-design/` | `banner-design` | Social covers, ad banners, website heroes, print banners |
| `brand/` | `brand` | Brand voice, style guides, visual identity, consistency audits |
| `design-system/` | `design-system` | Design token architecture (primitive → semantic → component), CSS vars, Tailwind |
| `ui-styling/` | `ui-styling` | React UIs with shadcn/ui + Tailwind; accessible components, dark mode |
| `slides/` | `slides` | Strategic HTML presentations with Chart.js (data-driven) |
| `frontend-slides/` | `frontend-slides` | Animated, visually stunning zero-dependency HTML presentations |

Each skill folder contains:
- `SKILL.md` — main skill prompt
- `references/` — reference documents injected as context
- `scripts/` — helper scripts the skill can run
- `data/` — structured data (CSV, JSON) used by the skill

---

## memory/

Persistent memory files loaded across all Claude Code conversations. The `MEMORY.md` file is the index — Claude loads it on every session startup.

| File | Type | Summary |
|------|------|---------|
| `MEMORY.md` | Index | Links to all memory files |
| `n8ncourse.md` | Project | n8ncourse GitHub Pages site — repo layout, design tokens, lecture conventions, forbidden language |
| `online-class-booking.md` | Project | Class-booking platform — stack (Next.js 16 + Supabase + Zeabur), architecture, pre-build blockers |
| `feedback_no_timeframes.md` | Feedback | Never use fixed timeframes (三週) or instructor bio sections in n8ncourse lecture pages |
| `remotion_style_preference.md` | Feedback | Default Remotion style: Glassmorphism + YouTube Tutorial; no timestamp in progress bar |

---

## Setup (restoring on a new machine)

1. Clone this repo to `~/.claude/`
   ```bash
   git clone https://github.com/JamesAtMoGroup/claude-config.git ~/.claude
   ```
2. Add your GitHub PAT to `settings.json`:
   ```json
   "GITHUB_PERSONAL_ACCESS_TOKEN": "your_actual_pat_here"
   ```
3. Copy `memory/` contents to `~/.claude/projects/-Users-yourname/memory/`
4. Start Claude Code — it will pick up `CLAUDE.md` automatically

---

## What's NOT included

These are machine-specific or auto-generated and are excluded from the repo:

| Folder | Reason excluded |
|--------|----------------|
| `backups/` | Auto-generated `.claude.json` backups |
| `cache/` | Bundler/changelog cache |
| `debug/` | Session debug logs |
| `file-history/` | Per-file edit history |
| `history.jsonl` | Full conversation history (sensitive) |
| `paste-cache/` | Clipboard cache |
| `session-env/` | Shell environment snapshots |
| `sessions/` | Session metadata |
| `shell-snapshots/` | Shell state snapshots |
| `telemetry/` | Usage telemetry |
| `projects/*/` | Conversation logs (large, sensitive) |
