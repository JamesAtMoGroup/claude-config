---
name: mcp-response-analyzer
description: Intercept large MCP responses (Gmail, Google Calendar, GitHub, any JSON tool), save to /tmp/, extract only what's needed. Use when any MCP tool returns >2,000 tokens. Saves 90–97% tokens.
allowed-tools: Read, Grep, Bash
---

# MCP Response Analyzer

## When to Use

Trigger this skill whenever an MCP tool returns a large response. Do NOT let the raw response sit in context.

**Covered MCPs:**
- `mcp__claude_ai_Gmail__*` — email threads, search results, drafts
- `mcp__claude_ai_Google_Calendar__*` — event lists, free/busy queries
- GitHub API responses — repo trees, file lists, PR data
- Any JSON response estimated >2,000 tokens

---

## The Pattern (always follow this order)

### Step 1 — Call the MCP tool but immediately externalize

```bash
# Save response to /tmp/ with timestamp
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
FILE="/tmp/mcp_<tool>_$TIMESTAMP.json"
```

Write the full MCP response to that file immediately. Do not process it inline.

### Step 2 — Extract only what's needed

Use `Bash` with `python3` or `grep` to pull the minimal fields:

```bash
# Gmail — extract sender, subject, snippet, date only
python3 -c "
import json, sys
data = json.load(open('$FILE'))
messages = data.get('messages', [data]) if isinstance(data, dict) else data
for m in messages[:10]:
    print({
        'id': m.get('id',''),
        'from': next((h['value'] for h in m.get('payload',{}).get('headers',[]) if h['name']=='From'), ''),
        'subject': next((h['value'] for h in m.get('payload',{}).get('headers',[]) if h['name']=='Subject'), ''),
        'date': next((h['value'] for h in m.get('payload',{}).get('headers',[]) if h['name']=='Date'), ''),
        'snippet': m.get('snippet','')[:120]
    })
"
```

```bash
# Google Calendar — extract title, start, end, attendees only
python3 -c "
import json
data = json.load(open('$FILE'))
events = data.get('items', [data]) if isinstance(data, dict) else data
for e in events[:20]:
    print({
        'summary': e.get('summary',''),
        'start': e.get('start',{}).get('dateTime', e.get('start',{}).get('date','')),
        'end': e.get('end',{}).get('dateTime', e.get('end',{}).get('date','')),
        'attendees': [a.get('email') for a in e.get('attendees',[])[:3]]
    })
"
```

```bash
# GitHub tree / file list — filter by extension or path
python3 -c "
import json
data = json.load(open('$FILE'))
tree = data.get('tree', data) if isinstance(data, dict) else data
for f in tree:
    p = f.get('path','') if isinstance(f,dict) else str(f)
    if any(p.endswith(ext) for ext in ['.md','.tsx','.ts','.json','.py']):
        print(p)
" | head -50
```

### Step 3 — Return compact summary

Output format:
```
Found: <N> items (<filter applied>)
<compact list — max 10 items, key fields only>
Token savings: ~<X>% (full response: ~<estimated> tokens → summary: ~<actual> tokens)
Full data: $FILE
```

### Step 4 — Keep file for follow-up

If the user needs to drill into a specific item, read only that item from the saved file — not the whole response again.

### Step 5 — Clean up at session end

```bash
rm -f /tmp/mcp_*.json
```

---

## Token Savings Reference

| MCP Tool | Typical raw size | After extraction | Savings |
|----------|-----------------|------------------|---------|
| Gmail search (20 threads) | 15,000–30,000 tokens | 300–600 tokens | ~97% |
| Gmail read thread (long) | 5,000–20,000 tokens | 200–400 tokens | ~95% |
| Google Calendar list (30 days) | 3,000–8,000 tokens | 200–400 tokens | ~93% |
| GitHub repo tree (full) | 2,000–5,000 tokens | 100–200 tokens | ~95% |

---

## Quick Reference — File Naming

```
/tmp/mcp_gmail_search_20260327_143022.json
/tmp/mcp_gmail_thread_20260327_143045.json
/tmp/mcp_gcal_events_20260327_143100.json
/tmp/mcp_github_tree_20260327_143200.json
```
