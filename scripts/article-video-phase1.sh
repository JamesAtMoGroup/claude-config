#!/usr/bin/env bash
# article-video-phase1.sh YYYY-MM-DD
# Phase 1: STS（智慧切段）→ processed.wav → Whisper → .vtt
# 成功後寫 inbox/YYYY-MM-DD/.phase1_done
set -euo pipefail

export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
source ~/.zshenv 2>/dev/null || true

DATE="${1:?Usage: article-video-phase1.sh YYYY-MM-DD}"
INBOX="/Users/jamesshih/Projects/article-video/inbox/$DATE"
PROJECT="/Users/jamesshih/Projects/article-video"
LOG="$PROJECT/pipeline.log"
STS_MAX=290                        # ElevenLabs 單次上限（秒）
TMPDIR="/tmp/article-video-$DATE"
mkdir -p "$TMPDIR"
trap "rm -rf $TMPDIR" EXIT

log()  { echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" >> "$LOG"; echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*"; }
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

# ── Step 1: ElevenLabs STS（智慧切段）──────────────────────────────────────
log "[1/2] ElevenLabs Voice Changer 中..."

AUDIO_FILES=($(find "$INBOX" -maxdepth 1 \( -name "*.mp3" -o -name "*.wav" \) 2>/dev/null | sort))
[ ${#AUDIO_FILES[@]} -eq 0 ] && fail "找不到音檔（.mp3 或 .wav）"
INPUT="${AUDIO_FILES[0]}"

# 取得音檔長度
DURATION=$(python3 -c "
import subprocess
r = subprocess.run(['ffprobe','-v','error','-show_entries','format=duration','-of','csv=p=0','$INPUT'], capture_output=True, text=True)
print(int(float(r.stdout.strip() or 0)))
")
log "  音檔長度：${DURATION}s"

PROCESSED_WAV="$PROJECT/public/audio/${DATE}-processed.wav"

if [ "${DURATION:-0}" -le "$STS_MAX" ]; then
  # ── 短音檔：直接 STS ──────────────────────────────────────────────────────
  log "  ≤ ${STS_MAX}s，直接 STS"
  STS_OUT="$TMPDIR/${DATE}_sts.mp3"
  node ~/.claude/scripts/elevenlabs-sts.js "$INPUT" "$STS_OUT" 2>&1 | tee -a "$LOG"
  [ -f "$STS_OUT" ] || fail "STS 失敗：$INPUT"
  ffmpeg -y -i "$STS_OUT" "$PROCESSED_WAV" -loglevel error
else
  # ── 長音檔：在中點附近找 silence，智慧切段 ──────────────────────────────
  log "  > ${STS_MAX}s，偵測靜音切點..."
  HALF=$(( DURATION / 2 ))

  # silencedetect：靜音 ≥ 0.3s、< -35dB；取最靠近中點的靜音起點
  SPLIT_POINT=$(ffmpeg -i "$INPUT" \
    -af "silencedetect=noise=-35dB:d=0.3" \
    -f null - 2>&1 | \
    grep "silence_start" | \
    sed 's/.*silence_start: //' | \
    python3 -c "
import sys
times = [float(l.strip()) for l in sys.stdin if l.strip()]
if not times:
    print($HALF)
else:
    print(min(times, key=lambda t: abs(t - $HALF)))
")
  log "  切點：${SPLIT_POINT}s（中點：${HALF}s）"

  PART_A="$TMPDIR/${DATE}_partA.wav"
  PART_B="$TMPDIR/${DATE}_partB.wav"
  STS_A="$TMPDIR/${DATE}_partA_sts.mp3"
  STS_B="$TMPDIR/${DATE}_partB_sts.mp3"

  ffmpeg -y -i "$INPUT" -t "$SPLIT_POINT" "$PART_A" -loglevel error
  ffmpeg -y -i "$INPUT" -ss "$SPLIT_POINT" "$PART_B" -loglevel error

  log "  STS 前半段..."
  node ~/.claude/scripts/elevenlabs-sts.js "$PART_A" "$STS_A" 2>&1 | tee -a "$LOG"
  [ -f "$STS_A" ] || fail "STS 失敗（前半）：$PART_A"

  log "  STS 後半段..."
  node ~/.claude/scripts/elevenlabs-sts.js "$PART_B" "$STS_B" 2>&1 | tee -a "$LOG"
  [ -f "$STS_B" ] || fail "STS 失敗（後半）：$PART_B"

  # 合併並輸出為 wav
  CONCAT_LIST="$TMPDIR/${DATE}_concat.txt"
  printf "file '%s'\nfile '%s'\n" "$STS_A" "$STS_B" > "$CONCAT_LIST"
  ffmpeg -y -f concat -safe 0 -i "$CONCAT_LIST" "$PROCESSED_WAV" -loglevel error
  log "  ✅ 切段 STS 完成，已合併 → $PROCESSED_WAV"
fi

log "[1/2] ✅ processed.wav 完成 → $PROCESSED_WAV"

# ── Step 2: Whisper 轉字幕 ──────────────────────────────────────────────────
log "[2/2] Whisper 轉字幕中..."
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
log "[2/2] ✅ VTT 完成 → $VTT_OUT"

# ── 完成 ────────────────────────────────────────────────────────────────────
touch "$INBOX/.phase1_done"
log "✅ Phase 1 完成 | $DATE | $TITLE"
~/.claude/scripts/imessage_send.sh "✅ Phase 1 完成：${DATE}「${TITLE}」— 等待 Scene Dev"
