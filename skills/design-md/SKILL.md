---
name: design-md
description: "Curated DESIGN.md files for 58+ top brands (Stripe, Apple, Notion, Linear, Vercel, Airbnb, Spotify, Tesla, etc.). Drop a brand's DESIGN.md into your project so AI agents can generate pixel-perfect UI matching that brand's design system. Actions: list brands, copy DESIGN.md to project, preview a brand's design tokens."
argument-hint: "[brand-name] [project-path]"
license: MIT
metadata:
  author: VoltAgent/awesome-design-md
  version: "1.0.0"
---

# DESIGN.md

Curated collection of DESIGN.md files for 58+ top brands. Drop one into your project and tell Claude "build me a page that looks like this."

## Available Brands

airbnb, airtable, apple, bmw, cal, claude, clay, clickhouse, cohere, coinbase, composio, cursor, elevenlabs, expo, ferrari, figma, framer, hashicorp, ibm, intercom, kraken, lamborghini, linear.app, lovable, minimax, mintlify, miro, mistral.ai, mongodb, notion, nvidia, ollama, opencode.ai, pinterest, posthog, raycast, renault, replicate, resend, revolut, runwayml, sanity, semrush, sentry, spacex, spotify, stripe, supabase, superhuman, tesla, together.ai, uber, vercel, voltagent, warp, webflow, wise, x.ai, zapier

## How to Use

### 1. Copy a DESIGN.md into your project

```bash
cp ~/.claude/skills/design-md/design-md/<brand>/DESIGN.md <your-project>/DESIGN.md
```

Examples:
```bash
cp ~/.claude/skills/design-md/design-md/stripe/DESIGN.md ./DESIGN.md
cp ~/.claude/skills/design-md/design-md/notion/DESIGN.md ./DESIGN.md
cp ~/.claude/skills/design-md/design-md/linear.app/DESIGN.md ./DESIGN.md
```

### 2. Tell Claude to use it

> "Build me a landing page that looks like this" (DESIGN.md in project root)
> "Use the DESIGN.md to style the login screen"
> "Follow the design system in DESIGN.md for all new components"

### 3. Preview a brand's design (optional)

Open the preview files in browser:
```bash
open ~/.claude/skills/design-md/design-md/<brand>/preview.html
open ~/.claude/skills/design-md/design-md/<brand>/preview-dark.html
```

## What Each DESIGN.md Contains

| Section | Content |
|---------|---------|
| Visual Theme & Atmosphere | Mood, density, design philosophy |
| Color Palette & Roles | Semantic name + hex + functional role |
| Typography Rules | Font families, full hierarchy table |
| Component Stylings | Buttons, cards, inputs, navigation with states |
| Layout Principles | Spacing scale, grid, whitespace philosophy |
| Depth & Elevation | Shadow system, surface hierarchy |
| Do's and Don'ts | Design guardrails and anti-patterns |
| Responsive Behavior | Breakpoints, touch targets, collapsing strategy |
| Agent Prompt Guide | Quick color reference, ready-to-use prompts |

## Update

```bash
cd ~/.claude/skills/design-md && git pull
```
