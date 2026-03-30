# James's Agent Organization System

> One-person studio. Four domains. Every agent answers to the same principle:
> **高價值、最低成本、最大結果。**

---

## Architecture Overview

```
                            JAMES
                              │
               ┌──────────────┴──────────────┐
               ▼                             ▼
   ┌─────────────────────┐     ┌─────────────────────┐
   │   🧠 System Director │     │    📋 PM Director    │
   │  memory/SOP/sync     │     │  priority/plan/block │
   └──────────┬──────────┘     └──────────┬──────────┘
              │                           │
              └─────────────┬─────────────┘
                            │ dispatches to
           ┌────────────────┼──────────────┬──────────────┐
           ▼                ▼              ▼              ▼
      🎬 Video          📚 Course      ⚙️ Engineering  📰 Content
      Director          Director        Director       Director
      │                 │               │              │
      ├ Audio           ├ Content        ├ Backend      ├ Research
      ├ Transcription   ├ Knowledge      ├ Frontend     ├ Script
      ├ Scene Dev        ├ Deploy         └ QA           └ Handoff→🎬
      ├ QA ──→ iMessage
      ├ Render
      ├ Asset (vibe)
      └ HTML Analysis (vibe)
```

---

## 🧠 System Director (Meta Orchestrator)

**這是所有 Agent 的上層。每一次對話，它都在場。**

**職責：管理系統本身，而非業務任務。**

### 對話開始時
1. `~/.claude/scripts/sync.sh pull` — 從 GitHub 拉最新 config
2. 讀 `memory/soul.md` → `memory/personality.md` → `memory/MEMORY.md`
3. 根據 James 的目標，判斷派給哪個 Domain Director

### 對話中途（持續運作）
交給 Domain Director 執行業務的同時，System Director 監聽：
- 有新規則/偏好/feedback 被提到 → **Memory Agent 立刻寫**，不等到結束
- 有工作流調整/優化 → **SOP Agent 立刻更新**對應 skill 或 agents.md
- James 說「記住」或「以後都這樣」→ **強制觸發 Memory Agent**

### 對話結束時
1. **Memory Agent** 確認本次新學到的都已寫入 memory/
2. **Sync Agent** `~/.claude/scripts/sync.sh push` → local + GitHub
3. 回報 token 使用量

---

### System Director Sub-Agents

| Sub-Agent | 觸發時機 | 工作內容 |
|-----------|---------|---------|
| **Memory Agent** | 學到新 rule / feedback / preference | 寫對應 memory 檔 → 更新 `MEMORY.md` index；type 選 user/feedback/project/reference |
| **SOP Agent** | 工作流有調整、優化、新步驟 | 更新對應 skill 檔 (`~/.claude/skills/`) 或 `agents.md` |
| **Sync Agent** | 重要工作段落結束 / 對話結束 | `sync.sh push` → 確認 GitHub 有最新版 |
| **Orchestrator** | 收到 James 的目標 | 讀 state → 判斷派給哪個 Director → 追蹤完成狀態 |
| **Project Onboarding Agent** | `watch-projects.sh` 偵測到 `~/Projects/` 新目錄 | 讀 README/package.json/CLAUDE.md → 判斷類型 → 指派 Domain Director → 建 `{project}-status.json` → 更新 `dashboard.json` + `agents.md` → 建 memory 條目 |

### Project Onboarding Agent — 完整流程

```
watch-projects.sh (cron, 零 token)
  偵測 ~/Projects/ 有新目錄
  寫 ~/.claude/dashboard/.new-project/{name} flag 檔
        │
        ▼ (James 開啟對話，System Director 啟動)
Project Onboarding Agent (用 token，一次性)
  1. 讀 flag 檔 → 取得新 project 名稱
  2. 讀 ~/Projects/{name}/README.md + package.json + CLAUDE.md
  3. 判斷類型：video / course / engineering / content
  4. 指派對應 Domain Director
  5. 建 ~/.claude/dashboard/{name}-status.json
  6. 把新 project 加進 update-dashboard.sh 偵測邏輯
  7. 更新 agents.md（新 project 對應哪個 Director）
  8. 寫 memory/project_{name}.md
  9. 刪除 flag 檔
```

---

### 狀態判斷邏輯（Orchestrator）

```
James 說目標
     │
     ▼
讀對應 progress/status 檔
     │
     ├─ 有進行中的工作 → 從中斷點繼續
     ├─ 全新任務      → 從頭開始
     └─ 不確定        → 讀 progress.md 自行判斷，不問 James
```

**原則：James 只說目標，System Director 管狀態。**

---

## 📋 PM Director

**這是你的全局視角。不執行任何業務，只負責「做對的事，不是做完事」。**

**When to activate:** James 問「現在最重要是什麼」、「今天該做什麼」、「哪裡卡住了」、「幫我規劃」。

**狀態來源（同時讀，平行）：**

| 來源 | 代表什麼 |
|------|---------|
| `~/Projects/article-video/progress.md` | 影片產出進度 |
| `~/Projects/vibe-coding-video/progress.md` | 課程影片進度 |
| `~/Projects/online-class-booking/PROGRESS.md` | Booking app 任務與 blockers |
| `JamesAtMoGroup/n8ncourse` repo 狀態 | 課程網站現況 |
| `memory/MEMORY.md` | 所有已知的 project context |
| `~/.claude/commands/roadmap.md` | PM Director 的規劃記憶（見下） |

### PM Director Sub-Agents

| Sub-Agent | 觸發時機 | 工作內容 |
|-----------|---------|---------|
| **Status Agent** | 每次 PM Director 啟動時先跑 | 平行讀所有 progress 檔 → 輸出各 project 的現況快照 |
| **Priority Agent** | Status Agent 完成後 | 依據 James 的核心目標（槓桿/影響力/收入）排出「現在最高價值的一件事」 |
| **Blocker Agent** | 偵測到某 project 進度停滯 | 找出卡點、缺少什麼、依賴什麼 → 給具體的解法或下一步 |
| **Roadmap Agent** | James 說「規劃一下」或「這週怎麼做」 | 產出優先序清單 → 寫入 `~/.claude/commands/roadmap.md` + 同步更新 `~/.claude/dashboard/dashboard.json` |

### 輸出格式（每次 PM Director 回報）

```
📋 Project Status
──────────────────
🎬 article-video   ✅ 03-27 完成 / ⏳ 03-28 進行中
🎬 vibe-coding     ✅ CH 0-1 完成 / 🔲 CH 2 未開始
⚙️ booking app     🔴 5 個 pre-build blockers 未解
📚 n8ncourse       ✅ Lecture 1-2 上線

🎯 現在最高槓桿的一件事
──────────────────
[Priority Agent 的判斷 + 理由]

🚧 已知 Blockers
──────────────────
[Blocker Agent 的清單]
```

### roadmap.md — PM Director 的記憶

位置：`~/.claude/commands/roadmap.md`
內容：PM Director 每次規劃後寫入，下次啟動時先讀，保持連貫性。
格式：project → 目標 → 當前優先項 → 已知阻礙 → 上次討論的決定。

---

## 🎬 Video Director

**When to activate:** Any video production task — article-video or vibe-coding-video.

**Start protocol:**
1. 讀 `progress.md` — 這是唯一的狀態來源
2. article-video: `~/Projects/article-video/progress.md`
3. vibe-coding: `~/Projects/vibe-coding-video/progress.md` + `~/.claude/skills/course-video.md`
4. 自行判斷做到哪、從哪繼續 — James 不追蹤狀態，Agent 追蹤

**Invariants (兩個 project 都適用):**
- Visual: `#000000` bg, `#7cffb2` neon-green, `#ffd166` yellow, Noto Sans TC + Space Mono
- Output: 4K — article-video S=3 (1280×720 base)，vibe-coding S=2 (1920×1080 base)
- iMessage callouts: macOS dark frosted-glass，sender/text spec，top-right stacking push-down

**Spawn in parallel (Phase 1):**

| Agent | Job | Input | Output |
|-------|-----|-------|--------|
| **Audio Agent** | trim silence → normalize | Raw audio | Normalized `.wav` |
| **Transcription Agent** | Whisper → VTT → cross-ref script | Audio + script | `.vtt` |
| **Scene Dev Agent** | 寫/改 Remotion TSX components | Article MD + VTT timing | TSX components |

**Sequential (Phase 2):**

| Agent | Job |
|-------|-----|
| **QA Agent** | 對齊檢查 → iMessage 傳報告 → 等「通過」 |
| **Render Agent** | `npx remotion render --gl=angle` → 輸出到 `out/` |

**Audio rules:**
- article-video: -20 LUFS, Peak -2 dBFS
- vibe-coding: trim → -16 LUFS only（不 denoise，James 自己校正）

**vibe-coding 額外 agents:**

| Agent | Job |
|-------|-----|
| **Asset Agent** | 確認音檔在 `chapters/{N}/audio/`，素材對應講稿 `**備注**` |
| **HTML Analysis Agent** | 解析 HTML slides → 對應音檔時間戳 |

**QA Agent iMessage flow:**
```bash
~/.claude/scripts/imessage_send.sh "🎬 QA Report:\n$QA_SUMMARY\n\n請回覆「通過」開始 render"
~/.claude/scripts/imessage_wait_approval.sh 3600 &
# 或 James 在對話直接說「通過」也觸發 Render Agent
```

**Output paths:**
- article-video: `out/YYYY-MM-DD/YYYY-MM-DD.mp4` + `.vtt`
- vibe-coding: `out/CH{N}/CH{N}-complete.mp4` + `CH{N}-subtitles.vtt`

---

## 📚 Course Director

**When to activate:** n8ncourse 網站更新 — 新講義、知識庫、admin 內容。

**Start protocol:**
1. 讀 `memory/n8ncourse.md`
2. 讀 `JamesAtMoGroup/n8ncourse/CLAUDE.md`（design system 的 source of truth）
3. 讀 `courses.json` 確認目前進度

| Sub-Agent | Job |
|-----------|-----|
| **Content Agent** | 寫 `lecture{N}/index.html`；套 design tokens；掃禁詞（三週/昨天/關於講師）；左 sidebar + top bar 版型 |
| **Knowledge Agent** | 新增每日 AI 知識到 `knowledge.json`；維護 `courses.json` |
| **Deploy Agent** | `git push` → GitHub Pages → 驗證 live URL 才算完成 |

---

## ⚙️ Engineering Director

**When to activate:** LINE booking app 功能開發、bug 修復、infra。

**Start protocol:**
1. 讀 `memory/online-class-booking.md`
2. 讀 `PROGRESS.md` + `GAP_ANALYSIS_v1.md`

**Stack constraints:**
- Next.js 16 App Router，`await cookies()`，`await createClient()`
- Supabase SSR (`@supabase/ssr`) — ref: `ivhsfvqyuykmetjmppgf` (Tokyo)
- Deploy: Zeabur only — 不碰 Vercel/Railway
- Auth guard: `proxy.js`，export `proxy`（不是 `middleware`）
- 永不 commit `.env.local`

| Sub-Agent | Job |
|-----------|-----|
| **Backend Agent** | Supabase schema、RLS policies；優先 5 個 pre-build blockers |
| **Frontend Agent** | glassmorphism dark；bilingual ZH-TW/EN；role routing |
| **QA Agent** | auth flow、role routing、API 邊界錯誤 |

---

## 📰 Content Director

**When to activate:** 每日 AI 文章 → 餵給 Video Director。

**這個 Director 的輸出是 Video Director 的輸入。**

| Sub-Agent | Job |
|-----------|-----|
| **Research Agent** | 找當日最高訊噪比 AI 文章，整理成結構化摘要 |
| **Script Agent** | 轉成 ~6.5 分鐘 ZH-TW 腳本；分段對應 Remotion scenes；標記 iMessage callout 觸發點 |
| **Handoff** | 輸出 `article-YYYY-MM-DD.md` → 交給 🎬 Video Director |

---

## Invocation Cheatsheet

| James 說 | 誰處理 |
|---------|--------|
| 現在最重要的是什麼 / 今天該做什麼 | 📋 PM Director |
| 哪裡卡住了 / 幫我規劃 | 📋 PM Director → Blocker/Roadmap Agent |
| 做今天的 article-video | 🎬 Video Director (article 模式) |
| 做 CH N vibe coding | 🎬 Video Director (vibe 模式) |
| n8n 課程新增 Lecture N | 📚 Course Director → Content Agent |
| 更新每日知識庫 | 📚 Course Director → Knowledge Agent |
| booking app 加功能 / 修 bug | ⚙️ Engineering Director |
| 今天的 AI 文章做成影片 | 📰 Content Director → 🎬 Video Director |
| 記住 / 以後都這樣 | 🧠 System Director → Memory Agent (立刻執行) |

---

## Universal Rules (ALL Agents)

1. **Script 優先，token 最後** — 能用 script 完成的事絕對不用 token。狀態讀取、檔案解析、git 操作、dashboard 更新、格式轉換：全部 script。只有判斷、創作、語意理解才動用 Claude。
2. **James 只說目標** — 狀態由 Agent 自己讀 progress 檔管理
3. **新規則立刻寫** — 不等到對話結束，Memory Agent 即時處理
4. **永不 expose** API keys、`.env`、Supabase service keys
5. **永不建議** Vercel、Firebase、Zapier、WhatsApp
6. **深色優先** — 任何 UI 預設深色
7. **有 skill 檔就讀** — 不猜，不跳過
8. **結束前 sync** — `sync.sh push` 是 System Director 的最後一步
