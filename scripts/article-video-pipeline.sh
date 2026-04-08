#!/usr/bin/env bash
# article-video-pipeline.sh YYYY-MM-DD
# Full pipeline: audio → STS (with auto-split for >290s) → whisper → scene dev → render → upload
set -euo pipefail

export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
source ~/.zshenv 2>/dev/null || true

DATE="${1:?Usage: article-video-pipeline.sh YYYY-MM-DD}"
INBOX="/Users/jamesshih/Projects/article-video/inbox/$DATE"
PROJECT="/Users/jamesshih/Projects/article-video"
LOG="$PROJECT/pipeline.log"
BGMUSIC="$PROJECT/public/audio/bgmusic.mp3"
GDRIVE_FOLDER_ID="1Q2Jdflw80FXXDpGMw22OFVbwlqsMoWGz"
STS_MAX=290  # ElevenLabs 上限 300s，保留 10s 緩衝
TMPDIR="/tmp/article-video-$DATE"  # 所有中間檔放這裡，inbox 永遠只有原始檔
mkdir -p "$TMPDIR"
trap "rm -rf $TMPDIR" EXIT  # pipeline 結束（成功或失敗）自動清除

log()  { echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOG"; }
fail() { log "❌ FAILED at step: $*"; ~/.claude/scripts/imessage_send.sh "❌ article-video $DATE 失敗：$*"; exit 1; }

# ── Validate inbox ──────────────────────────────────────────────────────────
[ -d "$INBOX" ] || fail "inbox 資料夾不存在: $INBOX"

SCRIPT_FILE=$(find "$INBOX" -maxdepth 1 \( -name "*.md" -o -name "*.txt" \) 2>/dev/null | sort | head -1)
[ -f "$SCRIPT_FILE" ] || fail "找不到逐字稿（.md 或 .txt）"

TITLE=$(python3 -c "
import sys
line = open('$SCRIPT_FILE', encoding='utf-8').readline().strip().lstrip('#').strip()
sys.stdout.write(line)
")
[ -n "$TITLE" ] || fail "逐字稿第一行（標題）為空"

log "▶ 開始 pipeline | $DATE | $TITLE"

# ── Step 1: ElevenLabs STS（自動切段：超過 ${STS_MAX}s 先切半再合併）───────────
log "[1/7] ElevenLabs Voice Changer 中..."

AUDIO_FILES=($(find "$INBOX" -maxdepth 1 \( -name "*.mp3" -o -name "*.wav" \) 2>/dev/null | sort))
[ ${#AUDIO_FILES[@]} -eq 0 ] && fail "找不到音檔（.mp3 或 .wav）"

# STS 函式：中間檔全部放 TMPDIR，inbox 不留任何中間檔
run_sts() {
  local INPUT="$1"
  local OUTPUT="$2"
  local BASENAME
  BASENAME=$(basename "${INPUT%.*}")
  local DURATION
  DURATION=$(python3 -c "
import subprocess
r = subprocess.run(['ffprobe','-v','error','-show_entries','format=duration','-of','csv=p=0','$INPUT'], capture_output=True, text=True)
print(int(float(r.stdout.strip() or 0)))
")

  if [ "${DURATION:-0}" -le "$STS_MAX" ]; then
    node ~/.claude/scripts/elevenlabs-sts.js "$INPUT" "$OUTPUT" 2>&1 | tee -a "$LOG"
    [ -f "$OUTPUT" ] || fail "STS 失敗：$INPUT"
  else
    log "  ⚠️ 音檔 ${DURATION}s > ${STS_MAX}s，自動切段後 STS"
    local HALF=$(( DURATION / 2 ))
    local PART_A="$TMPDIR/${BASENAME}_partA.wav"
    local PART_B="$TMPDIR/${BASENAME}_partB.wav"
    local STS_A="$TMPDIR/${BASENAME}_partA_sts.mp3"
    local STS_B="$TMPDIR/${BASENAME}_partB_sts.mp3"

    ffmpeg -y -i "$INPUT" -t "$HALF" "$PART_A" -loglevel error
    ffmpeg -y -i "$INPUT" -ss "$HALF" "$PART_B" -loglevel error

    node ~/.claude/scripts/elevenlabs-sts.js "$PART_A" "$STS_A" 2>&1 | tee -a "$LOG"
    [ -f "$STS_A" ] || fail "STS 失敗（前半）：$PART_A"

    node ~/.claude/scripts/elevenlabs-sts.js "$PART_B" "$STS_B" 2>&1 | tee -a "$LOG"
    [ -f "$STS_B" ] || fail "STS 失敗（後半）：$PART_B"

    # 合併前後半（concat list 也放 TMPDIR）
    local CONCAT_LIST="$TMPDIR/${BASENAME}_concat.txt"
    printf "file '%s'\nfile '%s'\n" "$STS_A" "$STS_B" > "$CONCAT_LIST"
    ffmpeg -y -f concat -safe 0 -i "$CONCAT_LIST" "$OUTPUT" -loglevel error
    log "  ✅ 切段 STS 完成，已合併 → $OUTPUT"
  fi
}

STS_FILES=()
for f in "${AUDIO_FILES[@]}"; do
  STS_OUT="$TMPDIR/$(basename "${f%.*}")_sts.mp3"  # STS 輸出也在 TMPDIR
  run_sts "$f" "$STS_OUT"
  STS_FILES+=("$STS_OUT")
done

RAW_WAV="$TMPDIR/${DATE}-raw.wav"
PROCESSED_WAV="$PROJECT/public/audio/${DATE}-processed.wav"

if [ ${#STS_FILES[@]} -eq 1 ]; then
  ffmpeg -y -i "${STS_FILES[0]}" "$RAW_WAV" -loglevel error
else
  CONCAT_LIST="$TMPDIR/${DATE}-concat.txt"
  printf "file '%s'\n" "${STS_FILES[@]}" > "$CONCAT_LIST"
  ffmpeg -y -f concat -safe 0 -i "$CONCAT_LIST" "$RAW_WAV" -loglevel error
fi

# 正規化 + BG music（SOP: -20 LUFS, Peak -2 dBFS, NO anlmdn）
ffmpeg -y \
  -i "$RAW_WAV" \
  -stream_loop -1 -i "$BGMUSIC" \
  -filter_complex "
    [0:a]highpass=f=80[hp];
    [hp]equalizer=f=120:width_type=o:width=2:gain=2,
        equalizer=f=3000:width_type=o:width=1.5:gain=1.5[eq];
    [eq]acompressor=threshold=0.06:ratio=4:attack=5:release=100:makeup=4[comp];
    [comp]loudnorm=I=-20:LRA=5:TP=-2[loud];
    [1:a]volume=0.08[bg];
    [loud][bg]amix=inputs=2:duration=first:dropout_transition=3[out]
  " -map "[out]" -ar 44100 -ac 2 \
  "$PROCESSED_WAV" -loglevel error -y
rm -f "$RAW_WAV"
log "[1/7] ✅ 音檔處理完成 → $PROCESSED_WAV"

# ── Step 2: Whisper 轉字幕 ──────────────────────────────────────────────────
log "[2/7] Whisper 轉字幕中..."
mkdir -p "$PROJECT/out/$DATE"

# 等其他 Whisper 結束（記憶體衝突）
WHISPER_WAIT=0
while pgrep -f "whisper" | grep -v $$ > /dev/null 2>&1; do
  if [ "$WHISPER_WAIT" -eq 0 ]; then
    log "  ⏳ 偵測到其他 Whisper 在執行中，等待中..."
  fi
  WHISPER_WAIT=$(( WHISPER_WAIT + 30 ))
  sleep 30
done
[ "$WHISPER_WAIT" -gt 0 ] && log "  ✅ 等待了 ${WHISPER_WAIT}s，開始 Whisper"

/Users/jamesshih/Library/Python/3.9/bin/whisper "$PROCESSED_WAV" \
  --model medium \
  --language zh \
  --output_format vtt \
  --output_dir "$PROJECT/out/$DATE" \
  --task transcribe 2>&1 | tee -a "$LOG" || fail "Whisper 失敗"

WHISPER_VTT=$(find "$PROJECT/out/$DATE" -name "*.vtt" 2>/dev/null | head -1)
[ -f "$WHISPER_VTT" ] || fail "Whisper 未產生 VTT"
VTT_OUT="$PROJECT/out/$DATE/${DATE}.vtt"
mv "$WHISPER_VTT" "$VTT_OUT" 2>/dev/null || true
log "[2/7] ✅ VTT 完成 → $VTT_OUT"

# ── Step 3: Claude Scene Dev ────────────────────────────────────────────────
log "[3/7] Claude Scene Dev 中..."
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

log "[3/7] ✅ Scene Dev 完成"

# ── Step 4: TypeScript 檢查 ─────────────────────────────────────────────────
log "[4/7] TypeScript 檢查..."
cd "$PROJECT"
npx tsc --noEmit 2>&1 | tee -a "$LOG" && log "[4/7] ✅ TypeScript 通過" || fail "TypeScript 錯誤"

# ── Step 5: Render ──────────────────────────────────────────────────────────
log "[5/7] Render 中..."
cd "$PROJECT"
npm run "build:${DATE}" 2>&1 | tee -a "$LOG"
MP4_OUT="$PROJECT/out/$DATE/${DATE}.mp4"
[ -f "$MP4_OUT" ] || fail "Render 未產生 mp4"
log "[5/7] ✅ Render 完成 → $MP4_OUT"

# ── Step 6: Google Drive 上傳 ───────────────────────────────────────────────
log "[6/7] 上傳 Google Drive..."
rclone copy "$PROJECT/out/$DATE/" gdrive: \
  --drive-root-folder-id "$GDRIVE_FOLDER_ID" \
  --drive-use-trash=false 2>&1 | tee -a "$LOG"
log "[6/7] ✅ 上傳完成"

# ── Step 7: 完成通知 ─────────────────────────────────────────────────────────
log "[7/7] ✅ Pipeline 完成 | $TITLE | $DATE"
~/.claude/scripts/imessage_send.sh "✅ ${TITLE} (${DATE}) 完成！已上傳 Google Drive。"
