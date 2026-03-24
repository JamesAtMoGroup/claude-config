# Global Rules

## Autonomy
If there is something I can do or fix myself (run SQL, edit code, push to GitHub, apply configs, etc.), I must do it myself. Never ask the user to manually do something I am capable of doing.

## Webpage / UI Development
Whenever I am creating or designing a webpage, ALWAYS ask me first:
"What UI/UX style do you prefer for this page?" before writing any code.
Wait for my answer before proceeding.

## n8n API
Instance URL: https://xuecu-n8n-server.zeabur.app
API Key: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI4MmExN2JlNy1jNDFiLTRjZGMtOTUxNy05NWNiNDMyODdiMTkiLCJpc3MiOiJuOG4iLCJhdWQiOiJwdWJsaWMtYXBpIiwianRpIjoiOWRlNGJkZmYtNGFmOS00N2UwLTkwZjgtOTk1MmYzMGQyNWE5IiwiaWF0IjoxNzczNzI5NzI5fQ.XGLzrYn7KkpMnBz89o_MxTt3WTi_BE5HGZq9Wl0qaeI

---

## Skills Reference

> Use the `Skill` tool to invoke any skill below. Skills give Claude specialized knowledge and workflows — always use the right skill rather than guessing.

---

### Design & Visual

| Skill | When to Use |
|-------|-------------|
| **`ui-ux-pro-max`** | Building or reviewing ANY webpage/UI. 50+ styles, 161 palettes, 99 UX guidelines, 10 stacks (React, Next.js, Vue, Svelte, SwiftUI, Flutter, Tailwind, shadcn/ui, HTML). Use for: landing pages, dashboards, admin panels, SaaS, mobile apps, buttons, modals, forms, charts, color systems, typography, accessibility. **Required before writing any UI code.** |
| **`design`** | All-in-one design hub. Routes to sub-skills. Use for: logo generation (55 styles, Gemini AI), corporate identity program (CIP), HTML slides/pitch decks, social media images, brand identity, icon design (SVG, 15 styles), banners. |
| **`banner-design`** | Designing banners specifically — social covers, ad banners, website heroes, print banners. Platforms: Facebook, Twitter/X, LinkedIn, YouTube, Instagram, Google Display. Styles: minimalist, gradient, glassmorphism, neon, 3D, duotone, etc. |
| **`brand`** | Brand voice, visual identity, messaging frameworks, style guides, asset management, consistency audits. Use when writing branded content, tone of voice, or reviewing marketing assets for brand compliance. |
| **`design-system`** | Design token architecture (primitive → semantic → component), CSS variables, spacing/typography scales, component specs, Tailwind theme config. Use for systematic design-to-code handoff. |
| **`ui-styling`** | Building React UIs with shadcn/ui (Radix UI + Tailwind). Use for: accessible components (dialogs, dropdowns, forms, tables), dark mode, responsive layouts, theme customization, canvas-based visual designs/posters. |

---

### Presentations & Slides

| Skill | When to Use |
|-------|-------------|
| **`slides`** | Strategic HTML presentations with Chart.js and data visualization. Use for: marketing decks, pitch decks, data-driven slides. Outputs a single HTML file. |
| **`frontend-slides`** | Animation-rich, zero-dependency HTML presentations. Use when the user wants stunning visuals, converting PPT/PPTX to web, or slides for a talk/pitch. More visually creative than `slides`. |

---

### Video

| Skill | When to Use |
|-------|-------------|
| **`remotion-video`** | Creating videos programmatically with React + Remotion. Use for: tutorial videos with motion graphics, data-driven/batch videos, music visualizations, auto-subtitles, 3D product animations, AI-narrated explainers. Outputs MP4. |

---

### Claude Code Configuration

| Skill | When to Use |
|-------|-------------|
| **`update-config`** | Editing `settings.json` or `settings.local.json`. Use for: adding permissions ("allow npm commands"), setting env vars ("set DEBUG=true"), configuring hooks ("when Claude stops, show X"), troubleshooting automated behaviors. |
| **`keybindings-help`** | Customizing keyboard shortcuts in `~/.claude/keybindings.json`. Use for: rebinding keys, adding chord shortcuts, changing the submit key. |

---

### Code Quality & Development

| Skill | When to Use |
|-------|-------------|
| **`simplify`** | After writing code — reviews for reuse, quality, and efficiency, then fixes issues found. Run after completing a feature or refactor. |
| **`claude-api`** | Building apps with the Anthropic Claude API or Agent SDK. Triggered when code imports `anthropic` / `@anthropic-ai/sdk` / `claude_agent_sdk`, or user asks to use Claude API directly. |

---

### Automation & Scheduling

| Skill | When to Use |
|-------|-------------|
| **`loop`** | Running a command on a recurring interval within the current session (e.g. "check deploy every 5 min", "keep running /babysit-prs"). Use `/loop 5m /command`. Do NOT use for one-off tasks. |
| **`schedule`** | Creating persistent scheduled agents (cron jobs) that run remotely even when Claude Code is closed. Use for: recurring automated tasks, scheduled reports, polling workflows. |

---

### Skill Decision Tree

```
Need to build a UI/webpage?
  → Ask UI/UX style question first (per Webpage rule above)
  → Use ui-ux-pro-max for design decisions
  → Use ui-styling if using shadcn/ui + Tailwind
  → Use frontend-design for distinctive production-grade components

Need to create visuals/assets?
  → Logo / CIP / social images → design
  → Banner specifically → banner-design
  → Brand voice/consistency → brand
  → Token system → design-system

Need slides/presentations?
  → Data-driven with charts → slides
  → Animated / visually stunning → frontend-slides

Need a video?
  → React-based motion graphics, tutorial overlays → remotion-video

Need to configure Claude Code itself?
  → settings.json / hooks / permissions → update-config
  → Keyboard shortcuts → keybindings-help

Writing code?
  → After finishing → simplify
  → Using Anthropic SDK → claude-api

Need automation?
  → Repeat in this session → loop
  → Persistent cron job → schedule
```
