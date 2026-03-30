---
name: audio pipeline — no denoising
description: Audio pipeline for Vibe Coding videos skips denoising; James handles audio correction before delivery
type: feedback
---

Audio pipeline is: **trim silence → normalize to -16 LUFS** only.

**Why:** James corrects audio quality himself before uploading to `chapters/{章節}/audio/`. No need for ffmpeg denoising step.

**How to apply:** Skip `0a_denoise.sh`. Start pipeline from `0b_trim_silence.sh` → `0_normalize_audio.sh`. Do not suggest or run denoising.
