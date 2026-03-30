---
name: VTT-first pipeline — 字幕時間軸驅動動畫
description: 影片製作必須先產 VTT，才能寫 Scene；QA 通過才能 render；ContentColumn 必須留字幕安全區；多元素 Scene 必須做 element fade-out
type: feedback
---

VTT 必須在 Scene Dev 之前完成。所有動畫 frame timing 來自 VTT（seconds × 30），不能猜。

**Why:** 上線的影片字幕與動畫時間軸對不上，原因是 Scene Dev 在沒有 VTT 的情況下猜測了 frame 數值，且 render 在 QA 之前就啟動，造成 token 浪費與影片品質問題。字幕安全區設太小（80*S）導致 EstimateCard 在 01:25.06 仍出現在字幕區域內。

**How to apply:**
1. Phase 順序：Audio + Script 並行 → Whisper VTT → QA VTT → Scene Dev（讀 VTT）→ Animation QA → Render
2. QA Agent 通過前絕對不能啟動 render
3. Scene Dev 必須等到 corrected VTT 才能計算 frame：`frame = seconds × 30`, `local = global − scene_start`
4. ContentColumn 必須加 `maxHeight = H - contentTop - SUBTITLE_SAFE`，其中 `SUBTITLE_SAFE = 120 * S`（4K 下 360px = 17% 的字幕安全區）— **勿改回 80*S，已驗證過**
5. **多元素 Scene 的 Element Fade-Out 規則（必須執行）：** 若一個 Scene 有多個垂直疊加元素，當後來元素出現時，早期元素必須先 fade out 再從 DOM 移除（height=0）。Pattern：`const showEarly = frame < REMOVE_FRAME; const earlyOpacity = interpolate(frame, [FADE_START, REMOVE_FRAME], [1, 0], clamp);`。REMOVE_FRAME 必須早於 LaterElement.startFrame 至少 100f。
6. **AnalogyBox delay 不能 ≥ scene duration** — 否則永遠不顯示（03-30 TipsScene bug：delay=2250 = scene duration）
7. **VTT QA 逐字比對規則（非常重要）：**
   - **掃描方式（必須用這個指令）：**
     ```bash
     grep -v "^[0-9]" file.vtt | grep -v "^-->" | grep -v "^WEBVTT" | grep -v "^$" | tr '\n' '|'
     ```
     將所有字幕文字合成一行，再對照 script MD 逐字比對。
   - QA Agent 必須逐字元比對，不能只看語意。
   - Whisper 常犯的同音字錯誤：常→長、斷→段、播→撥、員→源、多餘字（如「英文方不一樣」的「方」）
   - 修正報告必須列出每一處 before→after，不能寫「已校對」
8. Animation QA 是獨立角色，負責對照 VTT 逐條確認每個視覺元素出現時間
9. `python3 -m whisper` 而非 `whisper`（PATH 問題）；sub-agents 沒有 Bash 權限，ffmpeg/whisper 由 Director 直接跑
