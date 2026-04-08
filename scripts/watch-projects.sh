#!/usr/bin/env bash
# ~/.claude/scripts/watch-projects.sh
# Detects new directories in ~/Projects/ — zero tokens
# Writes a flag file to trigger Project Onboarding Agent on next Claude session
# Cron: 0 * * * * ~/.claude/scripts/watch-projects.sh

PROJECTS_DIR="$HOME/Projects"
FLAG_DIR="$HOME/.claude/dashboard/.new-project"
KNOWN_FILE="$HOME/.claude/dashboard/.known-projects"

mkdir -p "$FLAG_DIR"

# Build known projects list on first run
if [ ! -f "$KNOWN_FILE" ]; then
  ls "$PROJECTS_DIR" > "$KNOWN_FILE"
  echo "[watch-projects] Initialized known projects list."
  exit 0
fi

# Compare current vs known
current=$(ls "$PROJECTS_DIR")
known=$(cat "$KNOWN_FILE")

while IFS= read -r project; do
  if ! grep -qx "$project" "$KNOWN_FILE"; then
    echo "[watch-projects] New project detected: $project"
    echo "$project" > "$FLAG_DIR/$project"
    echo "[watch-projects] Flag written: $FLAG_DIR/$project"
    echo "[watch-projects] → Project Onboarding Agent will run on next Claude session."
  fi
done <<< "$current"

# Update known list
ls "$PROJECTS_DIR" > "$KNOWN_FILE"
