#!/usr/bin/env bash
# article-video-watch.sh
# 每 5 分鐘掃描 inbox/ 一次
# 一次只跑一個 episode（sequential）
# 成功 → .pipeline_done | 失敗 → .pipeline_failed + iMessage 通知 → 自動跑下一個
# 要重試失敗的 episode：刪除 .pipeline_failed 即可

export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

INBOX="/Users/jamesshih/Projects/article-video/inbox"
LOG="/Users/jamesshih/Projects/article-video/pipeline.log"
PIPELINE="$HOME/.claude/scripts/article-video-pipeline.sh"
BUSY_LOCK="/tmp/article-video-pipeline.busy"
SCAN_INTERVAL=300  # 5 分鐘

# 單一 watcher 實例（mkdir 原子鎖）
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

# 啟動時若已有 pipeline 在跑，補設 busy lock（防止重啟時雙重觸發）
if pgrep -f "article-video-pipeline.sh" > /dev/null 2>&1; then
  touch "$BUSY_LOCK"
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] ⚠️ 偵測到已有 pipeline 在執行，設定 busy lock" | tee -a "$LOG"
fi

echo "[$(date '+%Y-%m-%d %H:%M:%S')] 👀 Watcher 啟動，每 ${SCAN_INTERVAL}s 掃描一次 $INBOX" | tee -a "$LOG"

scan_and_trigger() {
  # 有 episode 正在執行 → 跳過本次掃描
  [ -f "$BUSY_LOCK" ] && return

  for dir in "$INBOX"/*/; do
    [ -d "$dir" ] || continue
    local EPISODE_DIR="${dir%/}"
    local DATE
    DATE=$(basename "$EPISODE_DIR")

    [[ "$DATE" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]] || continue

    # 已完成或已失敗 → 跳過（刪除 .pipeline_failed 可重試）
    [ -f "$EPISODE_DIR/.pipeline_done" ] && continue
    [ -f "$EPISODE_DIR/.pipeline_failed" ] && continue

    # 必須同時有逐字稿 + 音檔
    local HAS_SCRIPT HAS_AUDIO
    HAS_SCRIPT=$(find "$EPISODE_DIR" -maxdepth 1 \( -name "*.md" -o -name "*.txt" \) 2>/dev/null | head -1)
    HAS_AUDIO=$(find "$EPISODE_DIR" -maxdepth 1 \( -name "*.mp3" -o -name "*.wav" \) 2>/dev/null | head -1)
    [ -n "$HAS_SCRIPT" ] || continue
    [ -n "$HAS_AUDIO" ] || continue

    local LOG_LINE IMSG_LINE
    LOG_LINE=$(python3 - "$HAS_SCRIPT" "$DATE" <<'PYEOF'
import sys, datetime
path, date = sys.argv[1], sys.argv[2]
title = open(path, encoding='utf-8').readline().strip().lstrip('#').strip()
ts = datetime.datetime.now().strftime('%Y-%m-%d %H:%M:%S')
print(f'[{ts}] 🚀 觸發 pipeline：{date}「{title}」')
PYEOF
)
    IMSG_LINE=$(python3 - "$HAS_SCRIPT" "$DATE" <<'PYEOF'
import sys
path, date = sys.argv[1], sys.argv[2]
title = open(path, encoding='utf-8').readline().strip().lstrip('#').strip()
print(f'🎬 開始製作 {date}「{title}」', end='')
PYEOF
)

    echo "$LOG_LINE" | tee -a "$LOG"
    ~/.claude/scripts/imessage_send.sh "$IMSG_LINE"

    # 標記 busy，阻止下一個 episode 同時觸發
    touch "$BUSY_LOCK"

    {
      if bash "$PIPELINE" "$DATE"; then
        touch "$EPISODE_DIR/.pipeline_done"
      else
        touch "$EPISODE_DIR/.pipeline_failed"
        FAIL_MSG=$(python3 - "$HAS_SCRIPT" "$DATE" <<'PYEOF'
import sys
path, date = sys.argv[1], sys.argv[2]
title = open(path, encoding='utf-8').readline().strip().lstrip('#').strip()
print(f'❌ {date}「{title}」失敗，已跳過。刪除 .pipeline_failed 可重試。', end='')
PYEOF
)
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] ❌ pipeline 失敗：$DATE" | tee -a "$LOG"
        ~/.claude/scripts/imessage_send.sh "$FAIL_MSG"
      fi
      rm -f "$BUSY_LOCK"
    } &

    # 一次只跑一個，找到第一個就停
    break
  done
}

while true; do
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] 🔍 掃描 inbox..." | tee -a "$LOG"
  scan_and_trigger
  sleep "$SCAN_INTERVAL"
done
