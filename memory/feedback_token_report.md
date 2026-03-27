---
name: token usage report at session end
description: Always report total tokens used at the end of every session
type: feedback
---

At the end of every session, report the total token usage to James.

**Why:** James wants visibility into AI resource consumption per session.

**How to apply:** Final message of every session must include a line like:
`Session tokens used: ~X,XXX input / ~X,XXX output`
