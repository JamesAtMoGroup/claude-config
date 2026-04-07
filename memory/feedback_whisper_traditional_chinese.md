---
name: Whisper outputs Simplified Chinese — must correct to Traditional Chinese
description: Whisper --language zh produces Simplified Chinese; always run a correction pass after transcription
type: feedback
---

Whisper with `--language zh` transcribes in Simplified Chinese (城市, 账单, 记录...), not Traditional Chinese (程式, 帳單, 記錄...).

**Why:** CH1-1 VTTs came back in Simplified Chinese. Required a post-processing correction pass that added extra time and tokens.

**How to apply:** After every Whisper run, immediately apply a Traditional Chinese correction script before QA or any downstream use. Key conversions:
- 城市 → 程式 (code/program — context-dependent, verify)
- 账单 → 帳單
- 记录 → 記錄
- 时间 → 時間
- 视频 → 影片
- 软件 → 軟體
- 里 → 裡 (inside)
- 面 → 裡面 / 裡 (context)

Beyond character substitution, verify brand names and course terminology against the DOCX script:
- 「Vibe Coding」not 「vibe coding」or 「vibecoding」
- Chapter-specific terms from the script take precedence over Whisper output

**Script location:** `~/.claude/scripts/` — if a correction script doesn't exist, create one and save it there for reuse.
