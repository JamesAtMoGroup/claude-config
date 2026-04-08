#!/usr/bin/env bash
# article-video-watch-v2.sh
# 三階段 watcher：
#   Phase 1（STS + ffmpeg + Whisper）：掃描有音檔但無 .phase1_done 的 episode
#   Phase 2（Scene Dev + TypeScript）：掃描有 .phase1_done 但無 .phase2_done 的 episode
#   Phase 3（Render + Upload）：掃描有 .phase2_done 但無 .phase3_done 的 episode
#
# 優先序：Phase 3 > Phase 2 > Phase 1
# 一次只跑一個 phase（共用 busy lock）
# 失敗標記：.phase{N}_failed — 刪除即可重試對應 phase，其他 phase 結果保留

export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

INBOX="/Users/jamesshih/Projects/article-video/inbox"
LOG="/Users/jamesshih/Projects/article-video/pipeline.log"
PHASE1="$HOME/.claude/scripts/article-video-phase1.sh"
PHASE2="$HOME/.claude/scripts/article-video-phase2.sh"
PHASE3="$HOME/.claude/scripts/article-video-phase3.sh"
BUSY_LOCK="/tmp/article-video-pipeline.busy"
SCAN_INTERVAL=300  # 5 分鐘

# ── 單一 watcher 實例（mkdir 原子鎖）──────────────────────────────────────
WATCHER_LOCK="/tmp/article-video-watcher.lock"
if ! mkdir "$WATCHER_LOCK" 2>/dev/null; then
  OLDPID=$(cat "$WATCHER_LOCK/pid" 2>/dev/null)
  if [ -n "$OLDPID" ] && kill -0 "$OLDPID" 2>/dev/null; then
    echo "Watcher 已在執行中 (PID $OLDPID)，退出。"
    exit 0
  fi
  rm -rf "$WATCHER_LOCK"
  mkdir "$WATCHER_LOCK"
fi
echo $$ > "$WATCHER_LOCK/pid"
trap "rm -rf $WATCHER_LOCK $BUSY_LOCK" EXIT

mkdir -p "$INBOX"

# 啟動時若已有 phase script 在跑，補設 busy lock
if pgrep -f "article-video-phase[123].sh" > /dev/null 2>&1; then
  touch "$BUSY_LOCK"
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] ⚠️ 偵測到已有 phase 在執行，設定 busy lock" | tee -a "$LOG"
fi

echo "[$(date '+%Y-%m-%d %H:%M:%S')] 👀 Watcher v2 啟動，每 ${SCAN_INTERVAL}s 掃描一次 $INBOX" | tee -a "$LOG"

# ── 觸發 phase（共用邏輯）────────────────────────────────────────────────────
trigger_phase() {
  local PHASE_NUM="$1"
  local SCRIPT="$2"
  local EPISODE_DIR="$3"
  local DATE="$4"
  local HAS_SCRIPT="$5"

  local DONE_FILE="$EPISODE_DIR/.phase${PHASE_NUM}_done"
  local FAIL_FILE="$EPISODE_DIR/.phase${PHASE_NUM}_failed"

  local ICON
  case "$PHASE_NUM" in
    1) ICON="🎙" ;;
    2) ICON="🎨" ;;
    3) ICON="🎬" ;;
  esac

  local LOG_LINE IMSG_LINE
  LOG_LINE=$(python3 - "$HAS_SCRIPT" "$DATE" "$PHASE_NUM" <<'PYEOF'
import sys, datetime
path, date, phase = sys.argv[1], sys.argv[2], sys.argv[3]
title = open(path, encoding='utf-8').readline().strip().lstrip('#').strip()
ts = datetime.datetime.now().strftime('%Y-%m-%d %H:%M:%S')
print(f'[{ts}] 🚀 觸發 Phase {phase}：{date}「{title}」')
PYEOF
)
  IMSG_LINE=$(python3 - "$HAS_SCRIPT" "$DATE" "$PHASE_NUM" "$ICON" <<'PYEOF'
import sys
path, date, phase, icon = sys.argv[1], sys.argv[2], sys.argv[3], sys.argv[4]
title = open(path, encoding='utf-8').readline().strip().lstrip('#').strip()
labels = {'1': 'STS + Whisper', '2': 'Scene Dev', '3': 'Render'}
print(f'{icon} Phase {phase}（{labels[phase]}）開始：{date}「{title}」', end='')
PYEOF
)

  echo "$LOG_LINE" | tee -a "$LOG"
  ~/.claude/scripts/imessage_send.sh "$IMSG_LINE"

  touch "$BUSY_LOCK"

  {
    if bash "$SCRIPT" "$DATE"; then
      touch "$DONE_FILE"
    else
      touch "$FAIL_FILE"
      local FAIL_MSG
      FAIL_MSG=$(python3 - "$HAS_SCRIPT" "$DATE" "$PHASE_NUM" <<'PYEOF'
import sys
path, date, phase = sys.argv[1], sys.argv[2], sys.argv[3]
title = open(path, encoding='utf-8').readline().strip().lstrip('#').strip()
print(f'❌ Phase {phase} 失敗：{date}「{title}」— 刪除 .phase{phase}_failed 可重試', end='')
PYEOF
)
      echo "[$(date '+%Y-%m-%d %H:%M:%S')] ❌ Phase ${PHASE_NUM} 失敗：$DATE" | tee -a "$LOG"
      ~/.claude/scripts/imessage_send.sh "$FAIL_MSG"
    fi
    rm -f "$BUSY_LOCK"
  } &
}

scan_and_trigger() {
  [ -f "$BUSY_LOCK" ] && return

  # ── 優先 Phase 3：Phase 2 已完成，等待 Render ────────────────────────────
  for dir in "$INBOX"/*/; do
    [ -d "$dir" ] || continue
    local EPISODE_DIR="${dir%/}"
    local DATE
    DATE=$(basename "$EPISODE_DIR")
    [[ "$DATE" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]] || continue

    [ -f "$EPISODE_DIR/.phase2_done" ]   || continue
    [ -f "$EPISODE_DIR/.phase3_done" ]   && continue
    [ -f "$EPISODE_DIR/.phase3_failed" ] && continue

    local HAS_SCRIPT
    HAS_SCRIPT=$(find "$EPISODE_DIR" -maxdepth 1 \( -name "*.md" -o -name "*.txt" \) 2>/dev/null | head -1)
    [ -n "$HAS_SCRIPT" ] || continue

    trigger_phase "3" "$PHASE3" "$EPISODE_DIR" "$DATE" "$HAS_SCRIPT"
    return
  done

  # ── 次優 Phase 2：Phase 1 已完成，等待 Scene Dev ─────────────────────────
  for dir in "$INBOX"/*/; do
    [ -d "$dir" ] || continue
    local EPISODE_DIR="${dir%/}"
    local DATE
    DATE=$(basename "$EPISODE_DIR")
    [[ "$DATE" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]] || continue

    [ -f "$EPISODE_DIR/.phase1_done" ]   || continue
    [ -f "$EPISODE_DIR/.phase2_done" ]   && continue
    [ -f "$EPISODE_DIR/.phase2_failed" ] && continue

    local HAS_SCRIPT
    HAS_SCRIPT=$(find "$EPISODE_DIR" -maxdepth 1 \( -name "*.md" -o -name "*.txt" \) 2>/dev/null | head -1)
    [ -n "$HAS_SCRIPT" ] || continue

    trigger_phase "2" "$PHASE2" "$EPISODE_DIR" "$DATE" "$HAS_SCRIPT"
    return
  done

  # ── 最後 Phase 1：全新 episode ──────────────────────────────────────────
  for dir in "$INBOX"/*/; do
    [ -d "$dir" ] || continue
    local EPISODE_DIR="${dir%/}"
    local DATE
    DATE=$(basename "$EPISODE_DIR")
    [[ "$DATE" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]] || continue

    [ -f "$EPISODE_DIR/.phase1_done" ]   && continue
    [ -f "$EPISODE_DIR/.phase1_failed" ] && continue

    local HAS_SCRIPT HAS_AUDIO
    HAS_SCRIPT=$(find "$EPISODE_DIR" -maxdepth 1 \( -name "*.md" -o -name "*.txt" \) 2>/dev/null | head -1)
    HAS_AUDIO=$(find "$EPISODE_DIR" -maxdepth 1 \( -name "*.mp3" -o -name "*.wav" \) 2>/dev/null | head -1)
    [ -n "$HAS_SCRIPT" ] || continue
    [ -n "$HAS_AUDIO" ]  || continue

    trigger_phase "1" "$PHASE1" "$EPISODE_DIR" "$DATE" "$HAS_SCRIPT"
    return
  done
}

while true; do
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] 🔍 掃描 inbox..." | tee -a "$LOG"
  scan_and_trigger
  sleep "$SCAN_INTERVAL"
done
