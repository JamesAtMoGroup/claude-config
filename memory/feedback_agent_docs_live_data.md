---
name: Agent docs must point to live files — never hardcode project status
description: Agents must read progress.md and live files for current state; never write hardcoded status into AGENTS.md or shared docs
type: feedback
---

Never hardcode project status, chapter completion dates, or file paths into AGENTS.md or any shared agent doc.

**Why:** The PM Director section of agents.md had hardcoded "CH0-3 完成 2026-03-27" style data — which was stale and wrong. James noticed immediately: "isn't this supposed to be what other agents need to know? And this information isn't even correct."

**How to apply:**
- Agent docs (AGENTS.md, rules/*.md) must only contain **instructions**, **patterns**, and **rules** — not live state.
- For live state, always direct agents to read: `progress.md` (single source of truth for chapter state).
- When writing example output in docs, use placeholders like `{chapter}`, `{date}`, `{status}` — never real chapter names or dates.
- If an agent needs to know current chapter status → it reads `progress.md` directly.
