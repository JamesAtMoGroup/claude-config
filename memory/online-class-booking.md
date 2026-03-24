---
name: online-class-booking project notes
description: Deployment details, stack, and architecture for the online-class-booking platform
type: project
---

## Repo & Deployment
- GitHub: https://github.com/James-C-K/online-class-booking
- Live: https://learning-online-booking.zeabur.app (Zeabur, auto-deploy from main)
- DB/Auth: Supabase — project ref: ivhsfvqyuykmetjmppgf (Tokyo)
- SSH key: ~/.ssh/github_id_ed25519 (added to GitHub as "class-booking")
- Source files: `/Users/jamesshih/Library/Mobile Documents/com~apple~CloudDocs/Antigravity Project/Class-Booking/`
- **Deployment: GitHub + Zeabur + Supabase ONLY. No Vercel, no Railway.**

> **Credentials:** Supabase keys are stored in `.env.local` — never commit them.

## Stack
- Next.js 16 (App Router), JavaScript, Tailwind CSS + custom glassmorphism dark CSS
- Supabase (Auth + PostgreSQL + SSR) — `@supabase/ssr`
- cookies() is ASYNC in Next.js 16 — always `await cookies()`
- createClient() in supabase-server.js is async — always `await createClient()`
- Bilingual: EN / ZH-TW via custom LanguageContext
- proxy.js (not middleware.js) for Next.js 16 route guard
- export function named `proxy` (not `middleware`)

## Supabase Config
- Site URL: https://learning-online-booking.zeabur.app
- Redirect URLs: https://learning-online-booking.zeabur.app/**
- Email confirmations: ON
- Auth callback: /auth/callback

## Current Status (2026-03-12)
- Phase 1 COMPLETE (pending live verification)
- GAP_ANALYSIS_v1.md added to repo (88 gaps identified)
- PROGRESS.md restructured with pre-build blockers section
- See PROGRESS.md in repo for full task list

## Pre-Build Blockers (must do before coding payout & booking)
1. Rate & commission versioning (InstructorRate + SubjectVersion tables with valid_from)
2. Subject versioning + subject_type (session_based | project_based | hybrid)
3. Soft delete: add is_archived to profiles — never hard-delete users
4. Full session status lifecycle (completed, no_show_student, late_cancelled, disputed, etc.)
5. Payout period model + payout rules per session status

## Key Architecture
- /dashboard → role router → /dashboard/student | /dashboard/teacher | /dashboard/admin
- Sidebar: glassmorphism, role-based nav, language toggle, sign out
- All server components use: const supabase = await createClient()
- All client components use: import { supabase } from '@/lib/supabase'
