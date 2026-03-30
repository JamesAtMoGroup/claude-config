---
name: iMessage QA approval flow — pending implementation
description: QA Agent sends iMessage to James before render; waits for "通過" reply to proceed
type: project
---

Need to implement iMessage QA approval flow for Vibe Coding video production.

**Plan:**
1. QA Agent prepares QA report (callout sync, media insert points, subtitle accuracy)
2. Send iMessage to 0981928525 via AppleScript with QA summary
3. Polling script reads ~/Library/Messages/chat.db every 30s
4. When "通過" reply detected → trigger Render Agent

**Why:** James wants human approval checkpoint before render to avoid wasted render time on bad QA.

**How to apply:** Implement after Terminal Full Disk Access is confirmed enabled (James quit+reopened Terminal to activate it).

**Status:** ✅ IMPLEMENTED & TESTED (2026-03-30)
- `~/.claude/scripts/imessage_send.sh "<message>"` — sends iMessage via AppleScript
- `~/.claude/scripts/imessage_wait_approval.sh [timeout_sec]` — polls chat.db every 30s, returns exit 0 on 通過, exit 2 on rejection, exit 1 on timeout
- Handle confirmed: `+886981928525` (iMessage)
- Dry run tested: sent test message, received "通過" reply, DB query confirmed working

**How to use in agent flow:**
```bash
~/.claude/scripts/imessage_send.sh "🎬 QA Report:\n$QA_SUMMARY\n\n請回覆「通過」開始 render"
~/.claude/scripts/imessage_wait_approval.sh 3600 && trigger_render
```
