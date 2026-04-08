---
name: HTML style injection — never consume existing </style> tag
description: When injecting a new <style> block into existing HTML, always prepend before </head> — never replace </style></head> as a unit, which destroys the closing tag of the main style block.
type: feedback
---

When injecting a new `<style>` block into an existing HTML file, **always insert it before `</head>`**, not by replacing `</style></head>` as a matched pair.

**Why:** Replacing `</style>\n</head>` with a new `<style>` block consumes the original `</style>`, leaving the main style block unclosed. This causes all subsequent CSS (including the injected nav styles) to be invalid — resulting in broken layouts (e.g. everything shifted to one side).

**How to apply:**
- Correct: `html.replace('</head>', NEW_STYLE_BLOCK + '</head>', 1)` — preserves existing `</style>`
- Wrong: `html.replace('</style>\n</head>', NEW_STYLE_BLOCK + '</head>', 1)` — destroys existing `</style>`
- In regex: use `re.sub(r"(</head>)", NEW_CSS + r"\1", html, count=1)` — always safe
- Always verify with `grep -c "</style>"` before and after injection; count should increase by exactly 1 per new style block
- This rule applies to all HTML injection in sync_drive.py and any manual Edit on lecture pages
