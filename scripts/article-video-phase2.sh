#!/usr/bin/env bash
# article-video-phase2.sh YYYY-MM-DD
# Phase 2: Scene Dev（claude -p）→ TypeScript 檢查
# 前提：inbox/YYYY-MM-DD/.phase1_done 必須存在
set -euo pipefail

export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
source ~/.zshenv 2>/dev/null || true

DATE="${1:?Usage: article-video-phase2.sh YYYY-MM-DD}"
INBOX="/Users/jamesshih/Projects/article-video/inbox/$DATE"
PROJECT="/Users/jamesshih/Projects/article-video"
LOG="$PROJECT/pipeline.log"

log()  { echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" >> "$LOG"; echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*"; }
fail() { log "❌ FAILED at step: $*"; ~/.claude/scripts/imessage_send.sh "❌ article-video $DATE Phase2 失敗：$*"; exit 1; }

# ── Validate phase1 artifacts ───────────────────────────────────────────────
[ -f "$INBOX/.phase1_done" ] || fail "Phase 1 尚未完成，缺少 .phase1_done"

SCRIPT_FILE=$(find "$INBOX" -maxdepth 1 \( -name "*.md" -o -name "*.txt" \) 2>/dev/null | sort | head -1)
[ -f "$SCRIPT_FILE" ] || fail "找不到逐字稿"

TITLE=$(python3 -c "
import sys
line = open('$SCRIPT_FILE', encoding='utf-8').readline().strip().lstrip('#').strip()
sys.stdout.write(line)
")

PROCESSED_WAV="$PROJECT/public/audio/${DATE}-processed.wav"
VTT_OUT="$PROJECT/out/$DATE/${DATE}.vtt"

[ -f "$PROCESSED_WAV" ] || fail "找不到 processed audio：$PROCESSED_WAV"
[ -f "$VTT_OUT" ]       || fail "找不到 VTT：$VTT_OUT"

log "▶ Phase 2 開始 | $DATE | $TITLE"

# ── Step 1: Claude Scene Dev ────────────────────────────────────────────────
log "[1/2] Claude Scene Dev 中..."
DATE_NODASH="${DATE//-/_}"
AUDIO_FILENAME="${DATE}-processed.wav"

cd "$PROJECT"
claude -p "
你是 Article Video Scene Dev Agent。

═══════════════════════════════════════════════════
⚠️  第一步：強制讀取以下所有 Skill 檔案，不可跳過
    任何一個沒讀完就開始寫程式 = 失敗
═══════════════════════════════════════════════════

請依序 Read 以下檔案（全部讀完再動筆）：

1. /Users/jamesshih/.claude/skills/article-video.md
   → 設計系統、動畫規則、font size 最小值、ContentColumn 規格、subtitle safe zone
   → ⚠️ 禁止用 spring() 做入場動畫（只能用 Easing.bezier + interpolate）
   → ⚠️ font size 最小值：Space Mono ≥11*S；Body text ≥14*S；Featured ≥20*S；Heading ≥22*S

2. /Users/jamesshih/.claude/commands/remotion-video.md
   → Remotion API：useCurrentFrame, interpolate, spring, Sequence

3. /Users/jamesshih/Projects/article-video/src/VideoComposition_2026_04_02.tsx
   → ⚠️ 必讀的高品質 reference：看它的動畫如何用視覺隱喻
   → IsolatedBrainAnimation（大腦 + 周圍 blocked 服務圖示）
   → BrainHandsAnimation（大腦 + 延伸手臂）
   → USBUnifyAnimation（USB 插入動畫）
   → 這些才是正確的「視覺隱喻動畫」，不是文字卡片

4. /Users/jamesshih/Projects/article-video/src/VideoComposition_2026_04_01.tsx
   → 另一個 reference

讀完全部後，才可以開始寫程式。

═══════════════════════════════════════════════════
集數資訊
═══════════════════════════════════════════════════

- 日期：$DATE
- 標題：$TITLE
- 音檔：public/audio/$AUDIO_FILENAME
- VTT：out/$DATE/${DATE}.vtt
- 逐字稿：$SCRIPT_FILE

═══════════════════════════════════════════════════
工作內容
═══════════════════════════════════════════════════

1. 讀取 VTT 全文，計算 TOTAL_FRAMES（最後 cue 結束秒數 × 30）
2. 規劃 3–5 個 Concept Animations（視覺隱喻，不是文字卡）
3. 寫入 src/VideoComposition_${DATE_NODASH}.tsx
4. 更新 src/Root.tsx（Composition id: ArticleVideo-${DATE}）
5. 更新 package.json（build:${DATE} → out/${DATE}/${DATE}.mp4）
6. npx tsc --noEmit 確認零錯誤

═══════════════════════════════════════════════════
強制規則 — 違反任何一條 = 必須重做
═══════════════════════════════════════════════════

【動畫系統】
- 禁止 spring() 做入場 → 改用 Easing.bezier + interpolate
- 標準 hooks：useFadeUp(startFrame) / useFadeIn(startFrame)（從 04-02 複製）
- easeOutBack = custom math（從 04-02 複製）
- spring() 僅允許：ContentColumn scrollUp (damping:200)、iMessage slide (damping:22,stiffness:130)

【Font Size 最小值 — 強制】
- Space Mono badge/label：≥ 11*S（33px）
- Body text (Noto Sans TC)：≥ 14*S（42px）— 任何 12*S 或 13*S 都是違規
- Featured/highlight：≥ 20*S（60px）
- Section heading：≥ 22*S（66px）

【Motion Graphics — 視覺隱喻要求】
- 每個動畫必須是視覺隱喻，不是文字卡片
- 範例：AI Agent 自主性 → 大腦 + 步驟箭頭（自主走完流程）；開源 vs 閉源 → 開鎖 box vs 上鎖 vault；多模態 → 耳+口+眼 圍繞 AI brain
- 位置：content column（x 960–2880）外；右側 right:40*S，左側 left:40*S
- 禁止 left:"50%" 或任何置中定位
- 同側不可同時有兩個動畫（做重疊檢查）
- triggerFrame = Math.round(vttSeconds × 30) - sceneStartFrame（從 VTT 讀，不得猜）
- useCurrentFrame() 只在 component 頂層呼叫一次

【TitleScene】
- AbsoluteFill 置中（flex center），不用 ContentColumn
- paddingBottom: SUBTITLE_SAFE
- Badge 只寫「每日 AI 知識庫」，不加日期

【ContentColumn】
- 用 height（不是 maxHeight）+ overflow:\"hidden\"（不是 overflowY）

【背景音樂】
緊接在主音檔 Audio 後：
<Audio src={staticFile(\"audio/course_background_music.wav\")}
  volume={(f) => { const v=0.10; const fi=interpolate(f,[0,45],[0,v],{extrapolateRight:\"clamp\"}); const fo=interpolate(f,[TOTAL_FRAMES-150,TOTAL_FRAMES],[v,0],{extrapolateLeft:\"clamp\",extrapolateRight:\"clamp\"}); return Math.min(fi,fo); }}
  loop />
（TOTAL_FRAMES 替換為實際常數）

完成後輸出：「Scene Dev 完成」
" --allowedTools "Read,Write,Edit,Bash,Glob,Grep" 2>&1 | tee -a "$LOG"

log "[1/2] ✅ Scene Dev 完成"

# ── Step 2: TypeScript 檢查 ─────────────────────────────────────────────────
log "[2/2] TypeScript 檢查..."
cd "$PROJECT"
npx tsc --noEmit 2>&1 | tee -a "$LOG" && log "[2/2] ✅ TypeScript 通過" || fail "TypeScript 錯誤"

# ── 完成 ────────────────────────────────────────────────────────────────────
touch "$INBOX/.phase2_done"
log "✅ Phase 2 完成 | $DATE | $TITLE"
~/.claude/scripts/imessage_send.sh "🎨 Phase 2 完成：${DATE}「${TITLE}」— 等待 Render"
