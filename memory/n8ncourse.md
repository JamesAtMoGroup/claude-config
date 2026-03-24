---
name: n8ncourse project structure
description: Repo structure, design system, naming conventions, and content rules for the n8ncourse GitHub Pages site
type: project
---

All course content lives in **JamesAtMoGroup/n8ncourse** (GitHub Pages).

**CRITICAL CONVENTION:** Lecture pages are named `lectureN/index.html` — NEVER `dayN/`. Display labels use "Lecture N" not "Day N".

## Repo layout
```
n8ncourse/
├── index.html          ← landing + 每日知識庫 (nav: 我的主頁 / 每日知識庫)
├── admin.html          ← CMS (requires classic GitHub PAT with repo scope)
├── knowledge.json      ← 每日知識庫 data
├── courses.json        ← course card data (day, title, status, url)
├── CLAUDE.md           ← full design system + content rules (source of truth)
├── lecture1/index.html ← Lecture 1 (chapters + checkboxes + progress)
├── lecture2/index.html ← Lecture 2 (4 sections, sidebar, no checkboxes)
└── audio/              ← audio files uploaded via admin
```

## Live URLs
- Main: https://jamesatmogroup.github.io/n8ncourse/
- Lecture 1: https://jamesatmogroup.github.io/n8ncourse/lecture1/
- Lecture 2: https://jamesatmogroup.github.io/n8ncourse/lecture2/
- Admin: https://jamesatmogroup.github.io/n8ncourse/admin.html

## Design tokens (dark theme — never use Claude.ai/light CSS variables)
- `--bg: #0e0918`, `--bg-2: #1a1624`
- `--accent: #ee4f27`, `--accent-2: #fd8925`
- `--text-1: #ffffff`, `--text-2: #c8c4b0`, `--text-3: #8a859e`
- `--success: #34d399`, `--info: #60a5fa`
- Font: Inter. Logo: "X Learn"

## Lecture page layout (ALL lecture pages must follow this)
- Left sidebar (272px): brand tag + section list + 整體進度 bar
- Top bar: hamburger + ← 返回主頁 link + breadcrumb + progress pill
- Scrollable content: panel hero + panel body per section
- Animated background orbs (3, fixed, blurred)
- Mobile: sidebar slides in via hamburger

## Forbidden content / language rules
- ❌ `三週`, `本週`, `第 N 週` → use `接下來`, `第 N 階段`, `之後`
- ❌ `昨天` → use `上一次`
- ❌ Any time-specific words that tie content to a schedule
- ❌ `關於講師` / instructor bio tabs

**Why:** Owner wants content that isn't tied to specific days/weeks, so it stays evergreen. Instructor identity is intentionally hidden from students.
**How to apply:** When writing or editing any lecture page, check for forbidden words before finishing.
