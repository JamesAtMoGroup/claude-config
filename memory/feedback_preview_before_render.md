---
name: Preview before render — mandatory approval step
description: Never render video before James previews and approves in Remotion Studio
type: feedback
---

Never render a video before James has reviewed it in Remotion Studio (localhost:3000) and explicitly approved it.

**Why:** James was upset that CH1-1 was rendered without his review. He needs to visually approve the scenes before committing to a full render.

**How to apply:** After Scene Dev is complete, start `npm run dev` and tell James to preview in Remotion Studio. Wait for explicit approval ("ok render", "通過", "go ahead") before spawning the Render Agent.
