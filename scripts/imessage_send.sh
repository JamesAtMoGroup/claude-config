#!/bin/bash
# Usage: imessage_send.sh "<message>"
# Sends an iMessage to James (0981928525 / +886981928525)

RECIPIENT="+886981928525"
MESSAGE="$1"

if [ -z "$MESSAGE" ]; then
  echo "Usage: imessage_send.sh '<message>'"
  exit 1
fi

TMPSCRIPT=$(mktemp /tmp/imessage_XXXXXX.scpt)
printf 'tell application "Messages"\n  set targetService to 1st service whose service type = iMessage\n  set targetBuddy to buddy "%s" of targetService\n  send "%s" to targetBuddy\nend tell\n' "$RECIPIENT" "$MESSAGE" > "$TMPSCRIPT"
osascript "$TMPSCRIPT"
rm -f "$TMPSCRIPT"

echo "✅ iMessage sent to $RECIPIENT"
