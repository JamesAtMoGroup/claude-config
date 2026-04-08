---
name: ElevenLabs STS in pipeline
description: article-video pipeline 使用 ElevenLabs Speech-to-Speech 換聲，不是 TTS
type: feedback
---

每個 .mp3 音檔在進入 ffmpeg 前，必須先跑 ElevenLabs STS 換成指定聲音。

**Why:** James 提供自己的錄音，但希望輸出是指定 AI 聲音。

**How to apply:**
- Voice ID: `9lHjugDhwqoxA5MhX0az`
- API Key: 存於 `~/.zshenv` ELEVENLABS_API_KEY
- 腳本：`~/.claude/scripts/elevenlabs-sts.js <input.mp3> <output_sts.mp3>`
- Model: `eleven_multilingual_sts_v2`
- SDK path: `/opt/homebrew/lib/node_modules/@elevenlabs/elevenlabs-js`
