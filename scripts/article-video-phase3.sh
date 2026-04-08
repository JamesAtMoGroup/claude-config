#!/usr/bin/env bash
# article-video-phase3.sh YYYY-MM-DD
# Phase 3: Render → Upload → iMessage 通知
# 前提：inbox/YYYY-MM-DD/.phase2_done 必須存在
set -euo pipefail

export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
source ~/.zshenv 2>/dev/null || true

DATE="${1:?Usage: article-video-phase3.sh YYYY-MM-DD}"
INBOX="/Users/jamesshih/Projects/article-video/inbox/$DATE"
PROJECT="/Users/jamesshih/Projects/article-video"
LOG="$PROJECT/pipeline.log"
GDRIVE_FOLDER_ID="1Q2Jdflw80FXXDpGMw22OFVbwlqsMoWGz"

log()  { echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOG"; }
fail() { log "❌ FAILED at step: $*"; ~/.claude/scripts/imessage_send.sh "❌ article-video $DATE Phase3 失敗：$*"; exit 1; }

# ── Validate phase2 artifacts ───────────────────────────────────────────────
[ -f "$INBOX/.phase2_done" ] || fail "Phase 2 尚未完成，缺少 .phase2_done"

SCRIPT_FILE=$(find "$INBOX" -maxdepth 1 \( -name "*.md" -o -name "*.txt" \) 2>/dev/null | sort | head -1)
[ -f "$SCRIPT_FILE" ] || fail "找不到逐字稿"

TITLE=$(python3 -c "
import sys
line = open('$SCRIPT_FILE', encoding='utf-8').readline().strip().lstrip('#').strip()
sys.stdout.write(line)
")

# 確認 build script 已存在（Phase 2 應該已寫入 package.json）
cd "$PROJECT"
node -e "const p=require('./package.json'); if(!p.scripts['build:$DATE']) process.exit(1)" \
  2>/dev/null || fail "package.json 缺少 build:$DATE script（Phase 2 是否正確完成？）"

log "▶ Phase 3 開始 | $DATE | $TITLE"

# ── Step 1: Render ──────────────────────────────────────────────────────────
log "[1/2] Render 中..."
npm run "build:${DATE}" 2>&1 | tee -a "$LOG"
MP4_OUT="$PROJECT/out/$DATE/${DATE}.mp4"
[ -f "$MP4_OUT" ] || fail "Render 未產生 mp4"
log "[1/2] ✅ Render 完成 → $MP4_OUT"

# ── Step 2: Google Drive 上傳 ───────────────────────────────────────────────
log "[2/2] 上傳 Google Drive..."
rclone copy "$PROJECT/out/$DATE/" gdrive: \
  --drive-root-folder-id "$GDRIVE_FOLDER_ID" \
  --drive-use-trash=false 2>&1 | tee -a "$LOG"
log "[2/2] ✅ 上傳完成"

# ── 完成 ────────────────────────────────────────────────────────────────────
touch "$INBOX/.phase3_done"
log "✅ Pipeline 全部完成 | $DATE | $TITLE"
~/.claude/scripts/imessage_send.sh "$(python3 -c "print(f'✅ {\"$TITLE\"} ($DATE) 完成！已上傳 Google Drive。')")"
