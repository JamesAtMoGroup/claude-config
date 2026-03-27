#!/usr/bin/env bash
# ~/.claude/scripts/sync.sh
# Bidirectional sync between ~/.claude/ and JamesAtMoGroup/claude-config on GitHub
# Usage:
#   sync.sh pull      — GitHub → local  (run at conversation start)
#   sync.sh push      — local → GitHub  (run after completing a section)
#   sync.sh both      — pull then push
#   sync.sh rollback  — restore everything to tag stable-2026-03-27
#   sync.sh push   — local → GitHub  (run after completing a section)
#   sync.sh both   — pull then push  (full sync)

set -euo pipefail

REPO="JamesAtMoGroup/claude-config"
CLONE_DIR="/tmp/claude-config-sync"
CLAUDE_DIR="$HOME/.claude"
MEMORY_DIR="$CLAUDE_DIR/projects/-Users-jamesshih/memory"

# ── Helpers ────────────────────────────────────────────────────────────────

log() { echo "[sync] $*"; }

ensure_clone() {
  if [ -d "$CLONE_DIR/.git" ]; then
    log "Pulling latest from GitHub..."
    git -C "$CLONE_DIR" fetch origin main --quiet
    git -C "$CLONE_DIR" reset --hard origin/main --quiet
  else
    log "Cloning $REPO..."
    rm -rf "$CLONE_DIR"
    gh repo clone "$REPO" "$CLONE_DIR" -- --quiet
  fi
}

# ── Pull: GitHub → local ───────────────────────────────────────────────────

pull() {
  ensure_clone
  log "Syncing GitHub → local..."

  # skills: repo/skills/* → ~/.claude/skills/*
  rsync -a --delete "$CLONE_DIR/skills/" "$CLAUDE_DIR/skills/"

  # commands: repo/commands/* → ~/.claude/commands/*
  rsync -a --delete "$CLONE_DIR/commands/" "$CLAUDE_DIR/commands/"

  # memory: repo/memory/* → ~/.claude/projects/-Users-jamesshih/memory/*
  rsync -a "$CLONE_DIR/memory/" "$MEMORY_DIR/"

  # top-level config files
  [ -f "$CLONE_DIR/rules.md" ]           && cp "$CLONE_DIR/rules.md"           "$CLAUDE_DIR/rules.md"
  [ -f "$CLONE_DIR/settings.json" ]      && cp "$CLONE_DIR/settings.json"      "$CLAUDE_DIR/settings.json"
  [ -f "$CLONE_DIR/settings.local.json" ] && cp "$CLONE_DIR/settings.local.json" "$CLAUDE_DIR/settings.local.json"
  [ -f "$CLONE_DIR/CLAUDE.md" ]          && cp "$CLONE_DIR/CLAUDE.md"          "$HOME/CLAUDE.md"

  log "Pull complete. Local is up to date with GitHub."
}

# ── Push: local → GitHub ───────────────────────────────────────────────────

push() {
  ensure_clone

  log "Syncing local → GitHub..."

  # skills: ~/.claude/skills/* → repo/skills/*
  rsync -a --delete \
    --exclude='*.pyc' --exclude='__pycache__' --exclude='.DS_Store' --exclude='.claude' \
    "$CLAUDE_DIR/skills/" "$CLONE_DIR/skills/"

  # Remove nested .git dirs to avoid submodule issues
  find "$CLONE_DIR/skills" -name ".git" -type d -exec rm -rf {} + 2>/dev/null || true

  # commands: ~/.claude/commands/* → repo/commands/*
  rsync -a --delete "$CLAUDE_DIR/commands/" "$CLONE_DIR/commands/"

  # memory: ~/.claude/projects/-Users-jamesshih/memory/* → repo/memory/*
  rsync -a "$MEMORY_DIR/" "$CLONE_DIR/memory/"

  # top-level config files
  cp "$CLAUDE_DIR/rules.md"            "$CLONE_DIR/rules.md"
  cp "$CLAUDE_DIR/settings.json"       "$CLONE_DIR/settings.json"
  cp "$CLAUDE_DIR/settings.local.json" "$CLONE_DIR/settings.local.json"
  cp "$HOME/CLAUDE.md"                 "$CLONE_DIR/CLAUDE.md"

  # Commit and push if there are changes
  cd "$CLONE_DIR"
  git add -A

  if git diff --cached --quiet; then
    log "Nothing changed. GitHub is already up to date."
  else
    CHANGED_FILES=$(git diff --cached --name-only | wc -l | tr -d ' ')
    git commit -m "Auto-sync: $CHANGED_FILES file(s) updated from local — $(date '+%Y-%m-%d %H:%M')"
    git push origin main
    log "Pushed $CHANGED_FILES file(s) to GitHub."
  fi
}

# ── Entry point ────────────────────────────────────────────────────────────

rollback() {
  log "Rolling back to stable-2026-03-27..."
  ensure_clone
  git -C "$CLONE_DIR" checkout "stable-2026-03-27" -- .
  pull
  log "Rollback complete. Everything restored to last known-good state."
}

case "${1:-both}" in
  pull)     pull ;;
  push)     push ;;
  both)     pull && push ;;
  rollback) rollback ;;
  *)        echo "Usage: sync.sh [pull|push|both|rollback]"; exit 1 ;;
esac
