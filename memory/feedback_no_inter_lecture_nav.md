---
name: No meta tags, inter-lecture nav, or X Learn branding in n8ncourse pages
description: Forbidden elements for all n8ncourse lecture and course pages
type: feedback
---

## Lecture hero 區塊絕對不能有：
1. **Meta tag 列** — 例如「完全免費開始」「不需寫程式」「約 N 分鐘」「含理論與實作框架」
2. **跨講次導航** — `上一堂：Lecture N ／ 下一堂：Lecture N` 任何形式
3. **頁尾 callout 導航** — 「下一堂（Lecture N）：...」callout block

Hero 區塊只保留：LECTURE N badge、h1 標題、subtitle 描述文字。

## Logo 規則（所有 n8ncourse 頁面）
- ❌ 絕對不用「X Learn」logo — 已全面換成 `aischool-logo.webp`
- `n8ncourse/index.html`：nav 完全不放 logo（避免與「← 返回課程選單」重疊）
- Lecture 頁面：logo 只放 36px 圖片，不加任何文字
- 頁面 title 用 `| AI School`，footer 用 `© AI School`

## n8ncourse/index.html nav 結構
- 左側：`<a href="../" class="nav-back">← 返回課程選單</a>`（14px, font-weight 500, 正式 nav 元素，非 fixed 定位）
- 右側：nav-badge + nav-user + btn-logout
- `justify-content: space-between` 自動分左右

**Why:** X Learn 是舊品牌，已換成 AI School。Logo + 返回按鈕同時在左側會重疊，移除 logo 是唯一乾淨的解法。

**How to apply:** 新增或編輯任何 n8ncourse 頁面時，先對照以上規則，不得出現 X Learn、meta tag、inter-lecture nav。
