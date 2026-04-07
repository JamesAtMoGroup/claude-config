---
name: audio pipeline — trim leading silence only
description: Audio pipeline only trims the leading silence from each file. No normalization, no denoising, no other adjustments.
type: feedback
---

Audio pipeline is: **trim leading silence only**. Nothing else.

**Why:** James handles all audio quality (levels, clarity) himself before delivering files. He has explicitly said "音檔不需要做任何的聲音調整，只需要幫我把每個音檔一開始稍微有空白的片段剪掉即可".

**How to apply:**
- Skip normalization (`loudnorm`, `-16 LUFS`) entirely
- Skip denoising entirely
- Only run: `ffmpeg -i input.wav -af silenceremove=start_periods=1:start_threshold=-50dB output.wav`
- Do NOT suggest or apply any volume/EQ/compression adjustments
