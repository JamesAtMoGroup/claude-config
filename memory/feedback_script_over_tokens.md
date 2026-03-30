---
name: Script over tokens rule
description: Any task achievable by a script must never use Claude tokens — scripts are always preferred over agent execution for automatable work
type: feedback
---

能用 script 做到的事，絕對不使用 token。

**Why:** Token 是有成本的資源，應保留給真正需要 Claude 判斷力的事（規劃、設計決策、內容生成）。機械性的狀態讀取、檔案解析、dashboard 更新、git push 等純自動化任務一律用 script 處理。

**How to apply:**
- 每次準備用 Claude agent 執行某個任務前，先問：「這件事可以寫成 script 嗎？」
- 可以 → 寫 script，加進 `~/.claude/scripts/`，設 cron 或手動觸發
- 不可以（需要判斷、創作、理解語意）→ 才動用 token
- Dashboard 狀態更新、progress 檔解析、git sync、檔案 copy、格式轉換：全部 script
- 優先序判斷、內容撰寫、設計決策、錯誤診斷：才用 Claude
