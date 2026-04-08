#!/bin/bash
# Usage: imessage_wait_approval.sh [timeout_seconds]
# Polls chat.db waiting for "通過" reply from +886981928525
# Returns exit 0 on approval, exit 1 on timeout/rejection

HANDLE="+886981928525"
TIMEOUT="${1:-3600}"   # default: wait up to 1 hour
POLL_INTERVAL=30
ELAPSED=0
DB=~/Library/Messages/chat.db

# Get the ROWID of the latest message at script start (to only watch NEW messages)
LAST_ROWID=$(sqlite3 "$DB" "
  SELECT MAX(m.ROWID)
  FROM message m
  JOIN handle h ON m.handle_id = h.ROWID
  WHERE h.id = '$HANDLE'
    AND m.is_from_me = 0;
" 2>/dev/null)

LAST_ROWID=${LAST_ROWID:-0}
echo "⏳ Watching for reply from $HANDLE (after ROWID $LAST_ROWID)..."
echo "   Timeout: ${TIMEOUT}s | Poll interval: ${POLL_INTERVAL}s"

while [ $ELAPSED -lt $TIMEOUT ]; do
  sleep $POLL_INTERVAL
  ELAPSED=$((ELAPSED + POLL_INTERVAL))

  # Check for new messages from James
  REPLY=$(sqlite3 "$DB" "
    SELECT m.ROWID, m.text
    FROM message m
    JOIN handle h ON m.handle_id = h.ROWID
    WHERE h.id = '$HANDLE'
      AND m.is_from_me = 0
      AND m.ROWID > $LAST_ROWID
    ORDER BY m.ROWID DESC
    LIMIT 1;
  " 2>/dev/null)

  if [ -n "$REPLY" ]; then
    ROWID=$(echo "$REPLY" | cut -d'|' -f1)
    TEXT=$(echo "$REPLY" | cut -d'|' -f2-)
    echo "📩 New reply (ROWID $ROWID): $TEXT"
    LAST_ROWID=$ROWID

    # Approval keywords
    if echo "$TEXT" | grep -qE "通過|approve|ok|OK|✅|好|確認"; then
      echo "✅ QA Approved! Proceeding to render..."
      exit 0
    fi

    # Rejection keywords
    if echo "$TEXT" | grep -qE "不通過|reject|NG|拒絕|重來|重做|修改"; then
      echo "❌ QA Rejected: $TEXT"
      exit 2
    fi

    echo "⚠️  Reply received but not a clear approval/rejection. Continuing to wait..."
  fi

  echo "   Still waiting... (${ELAPSED}s elapsed)"
done

echo "⏰ Timeout after ${TIMEOUT}s — no approval received"
exit 1
