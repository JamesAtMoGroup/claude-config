---
name: Audio folder path has space and chapter prefix — easy to get wrong
description: Audio folders are named "{chapter} 音檔/" with a space and chapter prefix, not just "音檔/"
type: feedback
---

Audio folders follow this exact pattern (note the space):
```
chapters/{chapter}/{chapter} 音檔/
# Examples:
chapters/0-3/0-3 音檔/
chapters/1-1/1-1 音檔/
```

NOT:
- `chapters/{chapter}/音檔/`  ← missing chapter prefix
- `chapters/{chapter}/{chapter}音檔/`  ← missing space

**Why:** Agents repeatedly wrote the path without the space or without the chapter prefix, causing file-not-found errors during audio normalization and VTT generation.

**How to apply:** Always quote the path in shell commands to handle the space:
```bash
whisper "chapters/1-1/1-1 音檔/1-1_1.1.wav" ...
ffmpeg -i "chapters/1-1/1-1 音檔/1-1_1.1.wav" ...
```
