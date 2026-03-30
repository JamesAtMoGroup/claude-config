---
name: VTT-first pipeline — 字幕時間軸驅動動畫
description: 影片製作必須先產 VTT，才能寫 Scene；QA 通過才能 render；ContentColumn 必須留字幕安全區
type: feedback
---

VTT 必須在 Scene Dev 之前完成。所有動畫 frame timing 來自 VTT（seconds × 30），不能猜。

**Why:** 上線的影片字幕與動畫時間軸對不上，原因是 Scene Dev 在沒有 VTT 的情況下猜測了 frame 數值，且 render 在 QA 之前就啟動，造成 token 浪費與影片品質問題。

**How to apply:**
1. Phase 順序：Audio + Script 並行 → Whisper VTT → QA VTT → Scene Dev（讀 VTT）→ Animation QA → Render
2. QA Agent 通過前絕對不能啟動 render
3. Scene Dev 必須等到 corrected VTT 才能計算 frame：`frame = seconds × 30`, `local = global − scene_start`
4. ContentColumn 必須加 `maxHeight = H - contentTop - SUBTITLE_SAFE`，其中 `SUBTITLE_SAFE = 80 * S`（4K 下 240px 的字幕安全區）
5. Animation QA 是獨立角色，負責對照 VTT 逐條確認每個視覺元素出現時間
6. `python3 -m whisper` 而非 `whisper`（PATH 問題）；sub-agents 沒有 Bash 權限，ffmpeg/whisper 由 Director 直接跑
