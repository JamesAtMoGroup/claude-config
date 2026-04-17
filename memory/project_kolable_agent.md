---
name: Kolable Agent
description: James 指定的 Kolable 後台串接專屬角色，負責所有品牌後台資料串接工作
type: project
originSessionId: f295e75e-c28a-4a33-9eac-17d1a2475ce6
---
James 指定 Claude 擔任 **Kolable Agent**，是最了解公司各品牌後台資料串接的 agent。

未來所有串接需求（查詢、寫入、Token 驗證、GraphQL、CRM 對接）都由此角色負責。

**品牌清單（7 個）：**

| key | 中文名 | clientId | clientKey | authorId | 後台網址 |
|-----|--------|----------|-----------|----------|---------|
| xuemi | 學米 | xuemi_1538003 | uAHRBsrHvNSxkHhQhbnm4VRbWdhh7sE9 | bc9a34a3-8ebc-4bac-b536-c674eefe2f4f | https://www.xuemi.co/admin |
| sixdigital | 無限 | sixdigital_1930321 | 75fd713bf735de026aa449b0256d3d54 | 47cb4aad-0c59-4458-b54f-32f9537c806f | https://www.ooschool.cc/admin |
| kkschool | 職能 | kkschool_324984 | 0b94d0af-7366-4f49-aafc-827ab5b4cce0 | 01d70844-0164-439b-b9a9-30545a4705a1 | https://skill.nschool.tw/admin |
| nschool | 財經 | nschool_1832006 | s5mGUz5Ctv9HmDfaYcG9wXErBuSwmHC2 | c37576b8-3a55-46ae-a6f6-dca30f303605 | https://nschool.tw/admin |
| xlab | xlab | xlab_1702316 | L3GV6miKC3iU6HwIyjku4zIUpYWlHq | b40587d1-4815-4f2a-bbc5-834435199f4b | https://www.xlab.com.tw/admin |
| aischool | AI未來學院 | aischool_2604071009 | 96e09b3c-288b-43ca-9da8-db25ebbf4982 | 8af195ab-45ba-49e9-8988-8e20129db5f3 | https://ai-school.tw/admin |
| techxue | xplatform | techxue_365136 | 121fe9dd-2da1-4d17-8c88-9a7cbe204548 | 375352b7-98c0-467c-bea3-c43ec7f86c02 | https://www.xplatform.world/admin |

**後台 URL 規則：** 每個品牌都有獨立網域，無統一規則。URL 格式為 `{adminBase}/programs/{programId}`

**已知系統：**
- Kolable 後台 API：`https://api.kolable.app/api/v1/auth/token`
- GraphQL endpoint：`https://rhdb.kolable.com/v1/graphql`（各品牌共用架構）
- CRM member_note 寫入

**現有工具：**
- `~/Projects/kolable-dashboard`（跨品牌課程管理 Dashboard，Next.js PWA）
- `~/Downloads/crm-note-tool`（客服溝通紀錄工具，已部署至 Zeabur：crmnotetool.zeabur.app）
- GitHub：JamesAtMoGroup/crm_note_tool

---

## Kolable Dashboard 詳細製作紀錄

**專案位置：** `~/Projects/kolable-dashboard`
**部署：** Zeabur → `https://programdashboard.zeabur.app`
**GitHub：** `JamesAtMoGroup/kolable-dashboard`
**技術棧：** Next.js 15 App Router、Supabase SSR、TypeScript、Docker multi-stage build

---

### 核心頁面與功能

#### 1. 品牌概況首頁 `/`
- Hero stat cards：品牌數 / 課程總數 / 私密發布 / 公開發布 / 草稿 / 總時數（已移除影片覆蓋率）
- 品牌卡片：兩個獨立區塊「課程」+ 「課程組合」，各顯示 私密發布/公開發布/草稿
  - 課程：`published_at IS NOT NULL + is_private=true/false` 計算；草稿 = 總數 - 已發布
  - 課程組合：`published_at IS NOT NULL is_private=true/false`；草稿 = `published_at IS NULL`
  - `totalPackages=0` 時不顯示課程組合區塊
- `is_private` 和 `published_at` 是獨立欄位（草稿可以有 is_private=false，不代表公開）
- 資料來源：各品牌 Kolable GraphQL API，server component 直接查

#### 2. 課程列表 `/programs`
- 支援篩選：缺影片、未發布、私密、訂閱制
- 搜尋：課程名稱 title `_ilike`（**不支援 ID 搜尋，UUID 型別無法用 _ilike**）
- 品牌 / 購買類型篩選 pills
- 分頁（24 筆/頁）
- 點進去 → `/programs/[programId]?brand=xxx` 課程詳情

#### 3. 課程詳情 `/programs/[programId]`
- 顯示章節、單元、影片上傳狀態
- 底部掛載 **AuditPanel**（稽核文件面板）

#### 4. 稽核總覽 `/audit`
- 所有非結案稽核的 table view
- 篩選器：搜尋（課程名稱/ID/品牌）、品牌 pills、狀態（進行中/已完成）
- 統計卡片：稽核中課程、進行中、待簽核文件、已完成
- 待簽核項目清單（quick access）
- 點擊課程名稱進入詳情頁
- 課程欄顯示：`program_title`（主）+ `program_id`（次，monospace）
- 右上角「匯出 CSV」→ `/audit/export`

#### 5. 匯出頁面 `/audit/export`
- 篩選：文件類型（4種，pills 多選）、品牌 pills、狀態（全部/已核准/待簽核/草稿）、日期區間
- 下載 CSV，UTF-8 BOM（Excel 可直接開啟）
- CSV 欄位：課程名稱 / 課程ID / 品牌 / 各文件欄位
- API：`GET /api/audit/export?types=&brands=&status=&from=&to=`

#### 6. 使用者管理 `/admin/users`
- 顯示所有 user_profiles
- 角色管理：admin / manager / editor / viewer
- dropdown 用 `position: fixed` 脫離 overflow 限制

---

### 稽核系統（核心功能）

#### 資料表（Supabase）
- `program_audits`：主表，關聯 program_id + brand_key，記錄整體狀態與 `program_title`
- `audit_requirement_specs`：研發需求規格書
- `audit_rd_evals`：研發評估表
- `audit_production_evals`：生產評估表
- `audit_acceptance_forms`：生產內容驗收表（雙簽制）

每張子表都有：`form_status`（draft/submitted/approved/rejected）、`document_url`、`created_by_email`、`updated_at`

#### 文件流程
1. 編輯者建立草稿 → 儲存草稿
2. 填寫指定簽署者 Email → 送出待審（form_status: submitted）
3. 簽署者進入查看 → 選決策 → 確認簽核（approved/rejected）
4. 所有 4 份文件 approved → program_audits.status = 已完成

#### 角色權限
- `admin` / `manager`：可簽核（canSign）
- `editor`：可編輯、送出、撤回自己的文件
- `viewer`：唯讀

#### 生產內容驗收表（特殊）
- 雙簽制：`reviewer_email`（檢核人員）+ `manager_email`（主管）
- 各自有 `_signed_at` timestamp
- 兩人都簽後 → approved
- manager 簽名需 canSign 角色

#### AuditPanel 組件（`src/app/programs/[programId]/AuditPanel.tsx`）
關鍵設計：
- `Field` 組件：module-level（不在 FormModal 內定義），用 local state + onBlur 避免 focus 遺失
- `EmailAutocomplete`：debounce 300ms 搜尋 `/api/admin/users`，`roleFilter` 可限定角色
- `DocumentUrlField`：URL 輸入 + `open_in_new` 按鈕（module-level，每份文件第一欄）
- `ChecklistDecision`：4 選項 radio（核准執行/條件式核准/退回修正/駁回）
- `DualSignRecord`：驗收表的雙簽記錄顯示
- `SignedRecord`：一般文件簽核記錄
- `isLocked = approved || rejected` → 全部欄位 readOnly
- 已核准/駁回文件：顯示「🔒 查看」按鈕，開啟 readonly FormModal（之前是純 icon，無法點開）
- `programTitle` prop 傳入，GET API 時帶 `?programTitle=xxx` 自動 backfill

#### API 路由
- `GET /api/audit`：取得或建立 audit 記錄（含 backfill program_title）
- `POST /api/audit`：upsert 子文件；submit 時驗證 signer email
- `PATCH /api/audit`：withdraw（本人才能）/ sign / dual-sign
- `DELETE /api/audit`：只能刪草稿
- `GET /api/audit/overview`：全部非結案稽核（用 service role key 繞過 RLS）
- `GET /api/audit/export`：CSV 匯出，含 program_title

#### Migration SQL（已執行）
```sql
ALTER TABLE audit_requirement_specs ADD COLUMN IF NOT EXISTS assigned_signer_email text;
ALTER TABLE audit_rd_evals ADD COLUMN IF NOT EXISTS schedule text;
ALTER TABLE audit_rd_evals ADD COLUMN IF NOT EXISTS checklist_decision text;
ALTER TABLE audit_rd_evals ADD COLUMN IF NOT EXISTS assigned_signer_email text;
ALTER TABLE audit_production_evals ADD COLUMN IF NOT EXISTS checklist_decision text;
ALTER TABLE audit_production_evals ADD COLUMN IF NOT EXISTS assigned_signer_email text;
ALTER TABLE audit_acceptance_forms ADD COLUMN IF NOT EXISTS reviewer_email text;
ALTER TABLE audit_acceptance_forms ADD COLUMN IF NOT EXISTS reviewer_sign_date date;
ALTER TABLE audit_acceptance_forms ADD COLUMN IF NOT EXISTS reviewer_signed_at timestamptz;
ALTER TABLE audit_acceptance_forms ADD COLUMN IF NOT EXISTS manager_email text;
ALTER TABLE audit_acceptance_forms ADD COLUMN IF NOT EXISTS manager_sign_date date;
ALTER TABLE audit_acceptance_forms ADD COLUMN IF NOT EXISTS manager_signed_at timestamptz;
ALTER TABLE program_audits ADD COLUMN IF NOT EXISTS program_title text;
```

---

### 重要技術決策

| 問題 | 解法 |
|------|------|
| typing focus 遺失 | Field 移到 module level（不在 FormModal 內），local state + onBlur |
| 稽核總覽 0 筆 | 1) force-dynamic 2) middleware `const` supabaseResponse 3) service role key 4) 移除不存在的 `decision` 欄位 |
| Role dropdown 被 overflow 裁切 | `position: fixed` + `getBoundingClientRect()` |
| Zeabur build timeout | Docker multi-stage + `.dockerignore` + `output: standalone` |
| UUID 欄位不能 `_ilike` | 課程搜尋只搜 title，不做 ID 搜尋（試過 _eq 動態偵測，James 要求整個功能拿掉）|
| 課程統計「公開」含草稿 | `is_private=false` 不等於已公開發布；正確：`published_at IS NOT NULL AND is_private=false` |
| 「已發布」是冗餘欄位 | 等於私密+公開之和，移除；只保留 私密發布/公開發布/草稿 三欄 |
| middleware session 遺失 | `const supabaseResponse`（不能用 let，setAll 會重建物件） |

---

### 環境變數（Zeabur）
- `NEXT_PUBLIC_SUPABASE_URL`
- `NEXT_PUBLIC_SUPABASE_ANON_KEY`
- `SUPABASE_SERVICE_ROLE_KEY`（audit overview 用，繞過 RLS）
- 各品牌 Kolable API key 透過 `src/lib/kolable/brands.ts` 管理

**Why:** James 主動要求同步，避免之後需要重新閱讀 web 內容。
**How to apply:** 每次開新 session 處理 kolable-dashboard 時，直接從這份記錄出發，不需重新爬程式碼。
