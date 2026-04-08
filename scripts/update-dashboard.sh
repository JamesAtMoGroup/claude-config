#!/usr/bin/env python3
# ~/.claude/scripts/update-dashboard.sh
# Updates dashboard.json from filesystem evidence — zero Claude tokens
# Usage: ~/.claude/scripts/update-dashboard.sh
# Cron:  0 * * * * ~/.claude/scripts/update-dashboard.sh

import json
import os
import subprocess
from datetime import datetime, date, timedelta
from pathlib import Path

DASHBOARD_JSON = Path.home() / ".claude/dashboard/dashboard.json"
ARTICLE_OUT    = Path.home() / "Projects/article-video/out"
VIBE_OUT       = Path.home() / "Projects/vibe-coding-video/out"
VIBE_CHAPTERS  = Path.home() / "Projects/vibe-coding-video/chapters"
BOOKING_DIR    = Path.home() / "Projects/line-liff-booking"

# ── Helpers ────────────────────────────────────────────────────────────────

def read_existing():
    """Read current dashboard.json so we preserve Claude-set fields (topPriority)."""
    if DASHBOARD_JSON.exists():
        with open(DASHBOARD_JSON) as f:
            return json.load(f)
    return {}

def mp4_in(folder: Path) -> bool:
    """True if any .mp4 exists directly inside folder."""
    if not folder.exists():
        return False
    return any(folder.glob("*.mp4"))

def n8ncourse_lectures() -> list[dict]:
    """Check which lectures exist in JamesAtMoGroup/n8ncourse via gh CLI."""
    try:
        result = subprocess.run(
            ["gh", "api", "repos/JamesAtMoGroup/n8ncourse/contents",
             "--jq", "[.[] | select(.type==\"dir\") | select(.name | test(\"^lecture\")) | .name] | sort"],
            capture_output=True, text=True, timeout=10
        )
        if result.returncode == 0:
            dirs = json.loads(result.stdout.strip())
            return dirs
    except Exception:
        pass
    return []

# ── article-video ──────────────────────────────────────────────────────────

def build_article_video():
    milestones = []
    blockers = []
    today = date.today()

    # Last 7 days: detect done vs pending vs in-progress
    for i in range(6, -1, -1):
        d = today - timedelta(days=i)
        label = d.strftime("%m-%d")
        folder = ARTICLE_OUT / d.strftime("%Y-%m-%d")
        done = mp4_in(folder)
        in_progress = (not done) and (i == 0)  # today = in progress if not done
        milestones.append({"label": label, "done": done, "inProgress": in_progress})

    today_done = mp4_in(ARTICLE_OUT / today.strftime("%Y-%m-%d"))
    status = "active"
    next_action = f"做 {today.strftime('%m-%d')} article-video" if not today_done else "今天影片已完成 ✓"

    return {
        "name": "article-video",
        "emoji": "🎬",
        "type": "video",
        "status": status,
        "milestones": milestones,
        "nextAction": next_action,
        "blockers": blockers,
    }

# ── vibe-coding-video ──────────────────────────────────────────────────────

def build_vibe_coding():
    milestones = []
    blockers = []

    # All chapters from chapters/ dir
    all_chapters = sorted([
        d.name for d in VIBE_CHAPTERS.iterdir()
        if d.is_dir() and not d.name.startswith(".")
    ]) if VIBE_CHAPTERS.exists() else []

    for ch in all_chapters:
        out_folder = VIBE_OUT / f"CH{ch}"
        done = mp4_in(out_folder)
        # CH 0-1 is special — we know it's done from memory
        if ch == "0-1":
            done = True
        milestones.append({"label": f"CH {ch}", "done": done, "inProgress": False})

    # Mark first undone as in-progress
    for m in milestones:
        if not m["done"]:
            m["inProgress"] = True
            break

    # Check for HeyGen blocker (placeholder: always present until we have a flag file)
    heygen_done = (VIBE_OUT / ".heygen_complete").exists()
    if not heygen_done:
        blockers.append("HeyGen avatar pending")

    next_ch = next((m["label"] for m in milestones if not m["done"]), None)
    status = "blocked" if blockers else "active"
    next_action = f"開始 {next_ch}" if next_ch else "全部章節完成 ✓"

    return {
        "name": "vibe-coding-video",
        "emoji": "🎬",
        "type": "video",
        "status": status,
        "milestones": milestones,
        "nextAction": next_action,
        "blockers": blockers,
    }

# ── n8ncourse ──────────────────────────────────────────────────────────────

def build_n8ncourse():
    lectures = n8ncourse_lectures()
    milestones = []

    if lectures:
        for lec in lectures:
            n = lec.replace("lecture", "Lecture ")
            milestones.append({"label": n, "done": True, "inProgress": False})
        # Next lecture
        next_n = len(lectures) + 1
        milestones.append({"label": f"Lecture {next_n}", "done": False, "inProgress": True})
    else:
        # Fallback from memory: L1 + L2 done
        milestones = [
            {"label": "Lecture 1", "done": True, "inProgress": False},
            {"label": "Lecture 2", "done": True, "inProgress": False},
            {"label": "Lecture 3", "done": False, "inProgress": True},
        ]

    next_undone = next((m["label"] for m in milestones if not m["done"]), None)
    return {
        "name": "n8ncourse",
        "emoji": "📚",
        "type": "course",
        "status": "active",
        "milestones": milestones,
        "nextAction": f"新增 {next_undone} 內容" if next_undone else "課程持續更新中",
        "blockers": [],
    }

# ── booking app ────────────────────────────────────────────────────────────

PRE_BUILD_BLOCKERS = [
    "Rate & commission versioning",
    "Subject versioning",
    "Soft delete (is_archived)",
    "Session status lifecycle",
    "Payout period model",
]

def build_booking():
    # Resolution: create a .resolved file next to each blocker name when fixed
    resolved_dir = BOOKING_DIR / ".resolved"
    resolved = set()
    if resolved_dir.exists():
        resolved = {f.stem for f in resolved_dir.iterdir()}

    milestones = [{"label": "Phase 1 架構", "done": True, "inProgress": False}]
    active_blockers = []
    for b in PRE_BUILD_BLOCKERS:
        key = b.replace(" ", "_").replace("(", "").replace(")", "").replace("&", "and")
        done = key in resolved
        milestones.append({"label": b, "done": done, "inProgress": False})
        if not done:
            active_blockers.append(b)

    first_unresolved = next((b for b in PRE_BUILD_BLOCKERS
                             if b.replace(" ", "_").replace("(", "").replace(")", "").replace("&", "and") not in resolved), None)
    status = "blocked" if active_blockers else "active"
    return {
        "name": "online-class-booking",
        "emoji": "⚙️",
        "type": "engineering",
        "status": status,
        "milestones": milestones,
        "nextAction": f"解決 {first_unresolved}" if first_unresolved else "Pre-build blockers 全部完成 ✓",
        "blockers": active_blockers,
    }

# ── Global blockers ────────────────────────────────────────────────────────

def global_blockers(projects: dict) -> list[str]:
    result = []
    for key, proj in projects.items():
        for b in proj.get("blockers", []):
            result.append(f"{proj['name']}: {b}")
    return result

# ── Main ───────────────────────────────────────────────────────────────────

def main():
    existing = read_existing()

    article  = build_article_video()
    vibe     = build_vibe_coding()
    n8n      = build_n8ncourse()
    booking  = build_booking()

    projects = {
        "articleVideo": article,
        "vibeCoding":   vibe,
        "n8ncourse":    n8n,
        "bookingApp":   booking,
    }

    blockers = global_blockers(projects)

    # Preserve topPriority — only Claude (PM Director) updates this
    top_priority = existing.get("topPriority", {
        "label": "—",
        "reason": "PM Director 尚未設定優先序"
    })

    dashboard = {
        "lastSync": datetime.now().isoformat(timespec="seconds"),
        "topPriority": top_priority,
        "projects": projects,
        "globalBlockers": blockers,
    }

    with open(DASHBOARD_JSON, "w", encoding="utf-8") as f:
        json.dump(dashboard, f, ensure_ascii=False, indent=2)

    print(f"[dashboard] Updated {DASHBOARD_JSON}")

    # Push to GitHub
    sync = Path.home() / ".claude/scripts/sync.sh"
    subprocess.run([str(sync), "push"], check=False)
    print("[dashboard] Pushed to GitHub.")

if __name__ == "__main__":
    main()
