---
name: n8ncourse / aischool platform structure
description: Repo structure, agent architecture, deployment, nav/logo rules, and content rules for the aischool platform and n8ncourse content
type: project
originSessionId: b5416625-96b7-424d-9f4a-e1d919960fbb
---
All course content lives in **JamesAtMoGroup/n8ncourse** (Zeabur).
Working directory: `~/Projects/n8ncourse`

## Repo layout (as of 2026-04-07)
```
root/
├── login.html          ← platform login (Kolable API, localStorage)
├── index.html          ← course series portal (auth guard)
├── courses.json        ← course series list (NOT lecture list)
├── admin.html          ← CMS
├── assets/
│   └── aischool-logo.webp
├── docs/
│   ├── spec.md / rule.md / skill.md / progress.md
└── n8ncourse/
    ├── index.html      ← n8n course homepage
    ├── courses.json    ← lecture list (29 lectures, 3 open)
    ├── knowledge.json
    ├── lecture1/ lecture2/ lecture3/
```

## Auth
- Login: POST https://crmnotetool.zeabur.app/api/member/search { email, brandKey: "aischool" }
- Session: localStorage key `aischool_user` = { email, name }
- NO Supabase — all pages use localStorage only
- Login redirects to `./` (portal) after success

## Logo Rules (CRITICAL — never revert to X Learn)
- NEVER use "X Learn" branding — fully replaced with aischool-logo.webp
- Root index.html nav: img 44px only, no text
- n8ncourse/index.html nav: NO logo at all (removed to avoid overlap)
- Lecture pages nav: img 36px only, no text, links to `../`
- Page titles: `| AI School`, footer: `© AI School`

## Nav Structure
### n8ncourse/index.html
- Left: `<a href="../" class="nav-back">← 返回課程選單</a>` (14px, font-weight 500)
- Right: nav-badge + nav-user + btn-logout
- No logo — removing it was intentional to prevent overlap with the back link

### Lecture pages
- Left: logo img (36px, links to `../`) + `← 返回課程` back button
- These are separate elements, both on the left

## Brand tokens
### Platform pages (login.html + root index.html)
- --bg: #000000, --accent: #7cffb2, Font: Noto Sans TC

### n8ncourse pages (DO NOT CHANGE)
- --bg: #0e0918, --accent: #ee4f27, Font: Inter

## Live URLs
- Platform: https://n8ncourse.zeabur.app/ (portal)
- Login: https://n8ncourse.zeabur.app/login.html
- n8ncourse: https://n8ncourse.zeabur.app/n8ncourse/

## courses.json — Thumbnails
- Root courses.json `"thumbnail"` field: null = letter placeholder; set to image URL/path for actual image
- To add thumbnail: upload image to `assets/` and set `"thumbnail": "./assets/filename.webp"` in root courses.json

## Google Drive Sync (GitHub Actions)

- Workflow: `.github/workflows/sync-vibecoding.yml`
- Schedule: **每小時整點自動掃一次**（`cron: '0 * * * *'`）
- 手動觸發：GitHub Actions → `workflow_dispatch`
- 掃描腳本：`.github/scripts/sync_drive.py`
- 來源：`COURSES_ROOT_FOLDER_ID`（GitHub Secret）
- 同步目標：`vibecoding/`、`n8ncourse/`、`courses.json`、`sync_manifest.json`
- 認證 Secrets：`GOOGLE_CLIENT_ID`、`GOOGLE_CLIENT_SECRET`、`GOOGLE_REFRESH_TOKEN`、`COURSES_ROOT_FOLDER_ID`

---

## Forbidden (all lecture pages)
- Meta tag badges in hero, upper/next lecture nav, instructor bio, timeframe words
- "X Learn" branding anywhere
- Hero only: LECTURE N badge + h1 + subtitle
