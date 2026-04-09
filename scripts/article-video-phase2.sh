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
你是 Article Video Director Agent。請為以下集數執行完整的 Scene Dev 流程。

集數資訊：
- 日期：$DATE
- 標題：$TITLE
- 音檔：public/audio/$AUDIO_FILENAME
- VTT：out/$DATE/${DATE}.vtt
- 逐字稿：$SCRIPT_FILE

請依序完成：
1. 讀取 VTT 與逐字稿，計算 TOTAL_FRAMES（duration × 30）
2. 設計 Visual Concept（場景分配、motion graphics 規劃）
3. 寫入 src/VideoComposition_${DATE_NODASH}.tsx（完整可 render 的 TSX）
4. 更新 src/Root.tsx，加入新 Composition（id: ArticleVideo-${DATE}）
5. 更新 package.json，加入 build:${DATE} script，輸出路徑：out/${DATE}/${DATE}.mp4

規則：
- 參考 .agents/rules/project.md 所有規則
- Motion graphics 不可取代 slide 內容，只能疊加
- 同一側不可同時出現兩個 motion graphic
- Navbar 只顯示「每日 AI 知識庫」，無日期
- S=3（4K）

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
~/.claude/scripts/imessage_send.sh "$(python3 - <<PYEOF
print(f'🎨 Phase 2 完成：$DATE「$TITLE」— 等待 Render')
PYEOF
)"
