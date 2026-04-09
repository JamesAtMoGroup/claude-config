# Memory Index

## Who James Is
- [Soul](./soul.md) — Core values, purpose, what drives him; read at start of every conversation
- [Personality & Working Style](./personality.md) — How he thinks, communicates, makes decisions; collaboration rules

## Feedback
- [Session sync rule](./feedback_session_sync.md) — Read from laptop at start; push to laptop + GitHub at end. Never pull from GitHub to start
- [Token usage report](./feedback_token_report.md) — Always report token usage at the end of every session
- [High leverage, goal-first mindset](./feedback_leverage_mindset.md) — High value, lowest cost, biggest result; pursue goals not tasks
- [Remotion style and skill source](./feedback_remotion_style.md) — Always use claude-config GitHub repo for Remotion; Glassmorphism + YouTube Tutorial style
- [No timeframes or instructor sections](./feedback_no_timeframes.md) — Never mention 三週/fixed course duration or include instructor bios in lecture pages
- [Remotion style preference](./remotion_style_preference.md) — Default to Glassmorphism + YouTube Tutorial style; no timestamp in progress bar
- [Multi-agent requirement (all video work)](./feedback_vibe_coding_multiagent.md) — Always use Director + scoped sub-agents for ALL video work (Vibe Coding + article-video); parallelize audio/VTT/render
- [Preview before render](./feedback_preview_before_render.md) — Never render before James previews in Remotion Studio and explicitly approves
- [Scene Dev mandatory rules](./feedback_scene_dev_rules.md) — VTT timing (never guess startFrame), asset size ≥200*S (2×2 grid for 4+), all content within safe zone (top 144px, bottom 1840px)
- [Post-render deliverables](./feedback_postrender_deliverables.md) — Chapter = mp4 + .vtt + .html in out/CH{N}-{title}/; HTML has NO logo bar
- [Whisper → Traditional Chinese](./feedback_whisper_traditional_chinese.md) — Whisper outputs Simplified; always run correction pass after transcription
- [Agent docs use live files only](./feedback_agent_docs_live_data.md) — Never hardcode chapter status in agent docs; always read progress.md
- [Audio folder path has space](./feedback_audio_folder_path.md) — Path is `chapters/{ch}/{ch} 音檔/` (space + chapter prefix); always quote in shell
- [Cross-project universal rules](./feedback_cross_project_rules.md) — Both projects share: Vibe Coding style + 4K output + iMessage notifications (S=3 article-video, S=2 Vibe Coding)
- [Lottie AvatarOverlay 已捨棄](./feedback_no_lottie_avatar.md) — 所有影片不再使用右下角講者動畫；course-video.md 已更新
- [iMessage callout — use article-video design](./feedback_imessage_callout_design.md) — Vibe Coding video must use article-video iMessage spec (sender/text, top-right stack); discard old label/side/yPct system
- [Audio pipeline — no denoising](./feedback_audio_pipeline.md) — Skip denoise step; James handles audio correction himself
- [VTT-first pipeline](./feedback_vtt_first_pipeline.md) — VTT must exist before Scene Dev; QA before render; ContentColumn needs subtitle safe zone (80*S px)
- [Always update SOP immediately](./feedback_sop_update_rule.md) — Any workflow/adjustment/optimization mentioned → add to relevant SOP file immediately
- [Script over tokens](./feedback_script_over_tokens.md) — Any task a script can do must never use tokens; scripts live in ~/.claude/scripts/
- [No inter-lecture navigation](./feedback_no_inter_lecture_nav.md) — Never add "上一堂/下一堂" labels; only ← 返回主頁 for cross-lecture nav
- [HTML course page rules](./feedback_html_course_page.md) — sticky navbar (top:0, no flex/height), assets順序依逐字稿, video用player不用下載連結, 禁video-wrap embed
- [Output filename convention](./feedback_output_filename.md) — Rendered files: `{title}-{date}.{ext}` (e.g. `什麼是MCP-2026-04-13.mp4`); title first, then date
- [ElevenLabs STS in pipeline](./feedback_elevenlabs_sts.md) — Voice changer (STS) on every .mp3 before ffmpeg; voice ID 9lHjugDhwqoxA5MhX0az; API key in ~/.zshenv
- [HTML style injection rule](./feedback_html_style_injection.md) — Always insert new `<style>` before `</head>`; never replace `</style></head>` as a pair — destroys the closing tag
- [Vibecoding assets sync](./feedback_vibecoding_assets_sync.md) — Always download Drive `assets/` subfolder alongside HTML; relative paths like `assets/xxx.png` break without it
- [rclone upload subfolder rule](./feedback_rclone_upload.md) — Always upload to `gdrive:$DATE` (subfolder), never `gdrive:` (root)

## Agent System
- [Agent Organization](~/.claude/commands/agents.md) — System Director + 首席幕僚 + PM Director + 6 domain directors + sub-agents; invocation cheatsheet
- Video agents MUST read `.agents/AGENTS.md` → `rules/project.md` → `rules/pipeline.md` → `progress.md` before planning
- [James's Challenges](./challenges.md) — Ongoing difficulties, blockers, struggles James has mentioned; maintained by Chief of Staff

## Kolable Agent
- [Kolable Agent](./project_kolable_agent.md) — James 指定的品牌後台串接專屬角色；學米/無限/職能/財經/xlab；crm-note-tool 已部署

## References
- [Drive intake folder](./reference_drive_intake.md) — vibe-coding-intake (ID: 1XdvF9lI_Rcklr4KxvKpDNAC4L6QiwHnz); collaborators upload here; READY file triggers pipeline

## Projects
- [iMessage QA approval flow](./project_imessage_qa.md) — QA Agent sends report to 0981928525; waits for "通過" before render; Terminal Full Disk Access just enabled
- [online-class-booking](./online-class-booking.md) — Full deployment details and critical lessons
- [n8ncourse](./n8ncourse.md) — Repo structure, design tokens, URLs, convention that all day pages go in this one repo
- [vibe-coding-video](./vibe_coding_video.md) — Remotion course video; CH 0-1 30s sample done; HeyGen avatar pending credits
- [article-video](./article_video.md) — Daily AI knowledge explainer videos; Remotion + TTS; ~/article-video; JamesAtMoGroup/article-video
- [fomo-app](./project_fomo_app.md) — Expo RN 社交活動探索 app; ~/fomo-app; 📱 Fomo App Director (Feature/API/State/QA agents)
