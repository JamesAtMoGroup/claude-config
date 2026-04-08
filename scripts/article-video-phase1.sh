#!/usr/bin/env bash
# article-video-phase1.sh YYYY-MM-DD
# Phase 1: STS → ffmpeg normalize + BG music → Whisper → .vtt
# 成功後寫 inbox/YYYY-MM-DD/.phase1_done
set -euo pipefail

export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
source ~/.zshenv 2>/dev/null || true

DATE="${1:?Usage: article-video-phase1.sh YYYY-MM-DD}"
INBOX="/Users/jamesshih/Projects/article-video/inbox/$DATE"
PROJECT="/Users/jamesshih/Projects/article-video"
LOG="$PROJECT/pipeline.log"
BGMUSIC="$PROJECT/public/audio/bgmusic.mp3"
STS_MAX=290
TMPDIR="/tmp/article-video-$DATE"
mkdir -p "$TMPDIR"
trap "rm -rf $TMPDIR" EXIT

log()  { echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOG"; }
fail() { log "❌ FAILED at step: $*"; ~/.claude/scripts/imessage_send.sh "❌ article-video $DATE Phase1 失敗：$*"; exit 1; }

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

log "▶ Phase 1 開始 | $DATE | $TITLE"

# ── Step 1: ElevenLabs STS ──────────────────────────────────────────────────
log "[1/3] ElevenLabs Voice Changer 中..."

AUDIO_FILES=($(find "$INBOX" -maxdepth 1 \( -name "*.mp3" -o -name "*.wav" \) 2>/dev/null | sort))
[ ${#AUDIO_FILES[@]} -eq 0 ] && fail "找不到音檔（.mp3 或 .wav）"

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

    local CONCAT_LIST="$TMPDIR/${BASENAME}_concat.txt"
    printf "file '%s'\nfile '%s'\n" "$STS_A" "$STS_B" > "$CONCAT_LIST"
    ffmpeg -y -f concat -safe 0 -i "$CONCAT_LIST" "$OUTPUT" -loglevel error
    log "  ✅ 切段 STS 完成，已合併 → $OUTPUT"
  fi
}

STS_FILES=()
for f in "${AUDIO_FILES[@]}"; do
  STS_OUT="$TMPDIR/$(basename "${f%.*}")_sts.mp3"
  run_sts "$f" "$STS_OUT"
  STS_FILES+=("$STS_OUT")
done

# ── Step 2: ffmpeg 正規化 + BG music ────────────────────────────────────────
log "[2/3] ffmpeg 正規化 + BG music 中..."

RAW_WAV="$TMPDIR/${DATE}-raw.wav"
PROCESSED_WAV="$PROJECT/public/audio/${DATE}-processed.wav"

if [ ${#STS_FILES[@]} -eq 1 ]; then
  ffmpeg -y -i "${STS_FILES[0]}" "$RAW_WAV" -loglevel error
else
  CONCAT_LIST="$TMPDIR/${DATE}-concat.txt"
  printf "file '%s'\n" "${STS_FILES[@]}" > "$CONCAT_LIST"
  ffmpeg -y -f concat -safe 0 -i "$CONCAT_LIST" "$RAW_WAV" -loglevel error
fi

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
log "[2/3] ✅ 音檔處理完成 → $PROCESSED_WAV"

# ── Step 3: Whisper 轉字幕 ──────────────────────────────────────────────────
log "[3/3] Whisper 轉字幕中..."
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
log "[3/3] ✅ VTT 完成 → $VTT_OUT"

# ── 完成 ────────────────────────────────────────────────────────────────────
touch "$INBOX/.phase1_done"
log "✅ Phase 1 完成 | $DATE | $TITLE"
~/.claude/scripts/imessage_send.sh "$(python3 -c "print(f'✅ Phase 1 完成：$DATE「$TITLE」— 等待 Scene Dev')")"
