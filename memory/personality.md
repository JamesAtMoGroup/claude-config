---
name: James's Personality & Working Style
description: How James thinks, communicates, makes decisions, and prefers to collaborate
type: user
---

# James's Personality & Working Style

## How He Communicates

- **Direct and efficient.** He tells you what he wants, not how he feels about it. He doesn't pad requests.
- **Bilingual context.** His work is bilingual (Traditional Chinese / English). When writing course content, always assume ZH-TW for student-facing text.
- **Shows not tells.** He often provides exact values (`rgba(255,255,255,0.08)`, `borderRadius: 20`) rather than describing a vibe. Follow the spec exactly.
- **Context-dense.** His instructions carry a lot of implicit knowledge. If he says "Remotion video," he means the whole ecosystem: skill file, glass style, no timestamp, TTS ready.

## Decision-Making Style

- **Taste-first.** He picks tools and aesthetics based on feel before function. If something looks wrong, it gets fixed regardless of whether it "works."
- **System-builder.** He prefers building infrastructure over one-off solutions. He'll invest in a skill library so future work is faster.
- **Prefers his stack.** Zeabur (not Vercel), Supabase (not Firebase), LINE (not WhatsApp), n8n (not Zapier). Don't suggest alternatives unless asked.
- **Moves fast, documents precisely.** He expects things to be done, not discussed. But he documents his preferences with surgical precision once he's made a decision.

## Work Preferences

- **Dark mode everything.** All UI defaults to dark. Never propose a light-mode-first design.
- **Glassmorphism as a baseline.** It's not a style choice anymore — it's the default until told otherwise.
- **No fluff in code.** Don't add extra comments, unused variables, or fallback states for things that can't happen.
- **No timeframes in student-facing content.** Course content should be schedule-free and pace-agnostic.
- **No instructor bio.** The course teaches; James doesn't introduce himself.

## How to Collaborate Well With James

1. **Do it, don't ask.** If you can do something yourself, do it. Only ask when there's a genuine decision to make.
2. **Match the aesthetic.** When in doubt, dark + glass + orange-teal-yellow.
3. **Read the skill first.** Every domain has a skill file. Use it before guessing.
4. **Sync to GitHub when done.** After any significant section of work, push to `JamesAtMoGroup/claude-config`.
5. **Be concise.** He reads diffs, not summaries. Short responses are better than thorough ones.

## Red Lines

- Don't expose API keys or credentials in any file tracked by git
- Don't suggest platforms he's already replaced (Vercel, Firebase, Zapier)
- Don't add instructor bios or fixed course timelines
- Don't use light mode as a default
- Don't skip the skill file for a domain that has one
