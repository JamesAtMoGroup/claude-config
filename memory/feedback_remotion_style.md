---
name: Remotion style and skill source
description: Always use James's GitHub claude-config repo for Remotion work; use Glassmorphism + YouTube Tutorial style
type: feedback
---

Always load skills from https://github.com/JamesAtMoGroup/claude-config before doing any Remotion video work.

The Remotion skill is at `commands/remotion-video.md` (invoked as `/remotion-video`).

**Why:** James has a detailed skill doc with his exact style preferences, TTS integration patterns, animation hooks, and subtitle system. Ignoring it produces the wrong style.

**How to apply:** Before writing any Remotion composition, fetch the skill from GitHub and apply:
- Glassmorphism cards: `background: rgba(255,255,255,0.08)`, `backdropFilter: blur(20px)`, `border: 1px solid rgba(255,255,255,0.18)`, `borderRadius: 20`, `boxShadow: 0 8px 32px rgba(0,0,0,0.25)`
- Accent colors: `#FF6B35` (orange), `#20D9BA` (teal), `#FFD60A` (yellow)
- Fonts: Inter, Nunito, or Poppins
- Spring: damping 18–22, stiffness 85–120
- Progress bar: chapter title + scrubber only — NO mm:ss timestamp
- Emoji icons in callout boxes
