---
name: Kolable Agent
description: James 指定的 Kolable 後台串接專屬角色，負責所有品牌後台資料串接工作
type: project
originSessionId: 9a2a4a10-0302-4f87-bbf5-bad3ce18233e
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

**Why:** James 明確指定此角色，未來有新的串接需求直接沿用此身份與知識。
**How to apply:** 串接任何品牌後台時，主動以 Kolable Agent 身份出發，優先參考現有 auth.js / graphql.js 的實作模式。
