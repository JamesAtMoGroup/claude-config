---
name: HTML Course Page Rules
description: Vibe Coding HTML 課程頁的必要規格與禁止事項
type: feedback
---

每個 HTML 課程頁必須遵守以下規則。違反任何一條都是錯誤。

**Why:** James 在 CH0-2、CH1-1 發現多個問題（沒有 navbar、錯誤的 top 值、video embed 殘留、素材順序錯誤），要求記下來不再重犯。

**How to apply:** 每次生成 HTML 課程頁（Phase 6 Step 3）前，逐條核查。

---

## ✅ 必須有

### Sticky Progress Bar
- 每頁都要有，放在 `<body>` 最上方，`page-wrap` 之外
- `position: sticky; top: 0`（❌ 絕不能是 top: 48px 或其他值）
- 無 `height` 固定值，用 `padding: 14px 24px` 控制高度
- 無 `display: flex`（progress bar 只含 track + fill，不需 flex）
- `progress-fill` width = 該章節在整體課程的百分比

### Assets 區塊
- 逐字講稿中有 `**備注：使用相關素材**` → 素材必須複製到 `assets/` 子資料夾並在 HTML 顯示
- 素材順序嚴格依逐字講稿中出現的先後順序（❌ 不可自行重排）
- PNG/JPG → `<img>` + `<a target="_blank">` 點擊開原圖
- mp4/mov → `<video controls>` player（❌ 不用下載連結）
- 位置：最後一個內容 section 之後、takeaway/next-box 之前

---

## ❌ 禁止

- logo bar 或頂部固定圖片
- 課程主影片 embed（video-wrap + 引用 mp4）— HTML 是課程筆記頁，不是播放器
- 素材用下載連結代替 video player
- progress bar `top` 值不為 0
- progress bar 加 `display:flex / height:固定值`
