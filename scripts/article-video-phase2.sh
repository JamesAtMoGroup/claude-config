#!/usr/bin/env bash
# article-video-phase2.sh YYYY-MM-DD
# Phase 2: Scene Dev（claude -p）→ TypeScript 檢查
# 前提：inbox/YYYY-MM-DD/.phase1_done 必須存在
set -euo pipefail

export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
source ~/.zshenv 2>/dev/null || true

DATE="${1:?Usage: article-video-phase2.sh YYYY-MM-DD}"
INBOX="/Users/jamesshih/Projects/article-video/inbox/$DATE"
PROJECT="/Users/jamesshih/Projects/article-video"
LOG="$PROJECT/pipeline.log"

log()  { echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" >> "$LOG"; echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*"; }
fail() { log "❌ FAILED at step: $*"; ~/.claude/scripts/imessage_send.sh "❌ article-video $DATE Phase2 失敗：$*"; exit 1; }

# ── Validate phase1 artifacts ───────────────────────────────────────────────
[ -f "$INBOX/.phase1_done" ] || fail "Phase 1 尚未完成，缺少 .phase1_done"

SCRIPT_FILE=$(find "$INBOX" -maxdepth 1 \( -name "*.md" -o -name "*.txt" \) 2>/dev/null | sort | head -1)
[ -f "$SCRIPT_FILE" ] || fail "找不到逐字稿"

TITLE=$(python3 -c "
import sys
line = open('$SCRIPT_FILE', encoding='utf-8').readline().strip().lstrip('#').strip()
sys.stdout.write(line)
")

PROCESSED_WAV="$PROJECT/public/audio/${DATE}-processed.wav"
VTT_OUT="$PROJECT/out/$DATE/${DATE}.vtt"

[ -f "$PROCESSED_WAV" ] || fail "找不到 processed audio：$PROCESSED_WAV"
[ -f "$VTT_OUT" ]       || fail "找不到 VTT：$VTT_OUT"

log "▶ Phase 2 開始 | $DATE | $TITLE"

# ── Step 1: Claude Scene Dev ────────────────────────────────────────────────
log "[1/2] Claude Scene Dev 中..."
DATE_NODASH="${DATE//-/_}"
AUDIO_FILENAME="${DATE}-processed.wav"

cd "$PROJECT"
claude -p "
你是 Article Video Scene Dev Agent。

═══════════════════════════════════════════════════
⚠️  第一步：強制讀取以下所有 Skill 檔案，不可跳過
    任何一個沒讀完就開始寫程式 = 失敗
═══════════════════════════════════════════════════

請依序 Read 以下檔案（全部讀完再動筆）：

1. /Users/jamesshih/.claude/skills/article-video.md
   → 設計系統、動畫規則、font size 最小值、ContentColumn 規格、subtitle safe zone
   → ⚠️ 禁止用 spring() 做入場動畫（只能用 Easing.bezier + interpolate）
   → ⚠️ font size 最小值：Space Mono ≥11*S；Body text ≥14*S；Featured ≥20*S；Heading ≥22*S

2. /Users/jamesshih/.claude/commands/remotion-video.md
   → Remotion API：useCurrentFrame, interpolate, spring, Sequence

3. /Users/jamesshih/Projects/article-video/src/VideoComposition_2026_04_02.tsx
   → ⚠️ 必讀的高品質 reference：看它的動畫如何用視覺隱喻
   → IsolatedBrainAnimation（大腦 + 周圍 blocked 服務圖示）
   → BrainHandsAnimation（大腦 + 延伸手臂）
   → USBUnifyAnimation（USB 插入動畫）
   → 這些才是正確的「視覺隱喻動畫」，不是文字卡片

4. /Users/jamesshih/Projects/article-video/src/VideoComposition_2026_04_01.tsx
   → 另一個 reference

讀完全部後，才可以開始寫程式。

═══════════════════════════════════════════════════
集數資訊
═══════════════════════════════════════════════════

- 日期：$DATE
- 標題：$TITLE
- 音檔：public/audio/$AUDIO_FILENAME
- VTT：out/$DATE/${DATE}.vtt
- 逐字稿：$SCRIPT_FILE

═══════════════════════════════════════════════════
工作內容
═══════════════════════════════════════════════════

1. 讀取 VTT 全文，計算 TOTAL_FRAMES（最後 cue 結束秒數 × 30）
2. 規劃 3–5 個 Concept Animations（視覺隱喻，不是文字卡）
3. 寫入 src/VideoComposition_${DATE_NODASH}.tsx
4. 更新 src/Root.tsx（Composition id: ArticleVideo-${DATE}）
5. 更新 package.json（build:${DATE} → out/${DATE}/${DATE}.mp4）
6. npx tsc --noEmit 確認零錯誤

═══════════════════════════════════════════════════
強制規則 — 違反任何一條 = 必須重做
═══════════════════════════════════════════════════

【動畫系統】
- 禁止 spring() 做入場 → 改用 Easing.bezier + interpolate
- 標準 hooks：useFadeUp(startFrame) / useFadeIn(startFrame)（從 04-02 複製）
- easeOutBack = custom math（從 04-02 複製）
- spring() 僅允許：ContentColumn scrollUp (damping:200)、iMessage slide (damping:22,stiffness:130)

【Font Size 最小值 — 強制】
- Space Mono badge/label：≥ 11*S（33px）
- Body text (Noto Sans TC)：≥ 14*S（42px）— 任何 12*S 或 13*S 都是違規
- Featured/highlight：≥ 20*S（60px）
- Section heading：≥ 22*S（66px）

【Motion Graphics — 四大強制 QA 規則（違反任一 = 重做）】

⚠️ 規則 1：triggerLocalFrame 必須精確計算，禁止估算
   triggerLocalFrame = Math.round(vtt_seconds × 30) - scene_start_frame
   觸發時機 = 講者說出該概念的第一句話的 VTT timestamp
   禁止：scene 開始 + 固定偏移、猜測值

⚠️ 規則 2：DURATION 必須計算到「這段話說完的最後一句」+ 90 frame buffer
   DURATION = (last_topic_vtt_seconds × 30 - scene_start_frame - triggerLocalFrame) + 90
   動畫內含有數字/統計資料 → DURATION 必須覆蓋到那個數字被講者說出來的時刻
   禁止：隨意填 200/280/300 等固定短值

⚠️ 規則 3：動畫內每個 step/element 的 delay 必須對齊 VTT
   step_delay = Math.round(step_vtt_seconds × 30) - scene_start_frame - triggerLocalFrame
   禁止：固定小 stagger（delay: 30/70/110/150）除非 VTT 真的均勻分布

⚠️ 規則 4：Phase A 內容高度必須估算，超過 CONTENT_H=1620px 就用 element fade-out
   估算方式：每張卡片（上下padding + 文字行高之和 + marginBottom）逐一加總
   超過 1620px → 讓早期卡片在新卡片出現前 120f 淡出、10f 前 DOM 移除：
   const EARLY_FADE_START = LATE_CARD_AT - 120;
   const EARLY_REMOVE = LATE_CARD_AT - 10;
   const showEarly = frame < EARLY_REMOVE;
   const earlyOpacity = frame > EARLY_FADE_START
     ? interpolate(frame, [EARLY_FADE_START, EARLY_REMOVE], [1, 0], clamp) : 1;

⚠️ 完成後必須輸出 VTT 同步驗證表：
   動畫名稱 | trigger(local) | trigger VTT | 講者台詞 | DURATION | 覆蓋到VTT
   （無法填出「覆蓋到」= DURATION 不夠，必須重算）

【Motion Graphics — 視覺隱喻要求】
- 每個動畫必須是視覺隱喻，不是文字卡片
- 範例：AI Agent 自主性 → 大腦 + 步驟箭頭（自主走完流程）；開源 vs 閉源 → 開鎖 box vs 上鎖 vault；多模態 → 耳+口+眼 圍繞 AI brain
- 位置：content column（x 960–2880）外；右側 right:40*S，左側 left:40*S
- 禁止 left:"50%" 或任何置中定位
- 同側不可同時有兩個動畫（做重疊檢查）
- triggerFrame = Math.round(vttSeconds × 30) - sceneStartFrame（從 VTT 讀，不得猜）
- useCurrentFrame() 只在 component 頂層呼叫一次

【TitleScene】
- AbsoluteFill 置中（flex center），不用 ContentColumn
- paddingBottom: SUBTITLE_SAFE
- Badge 只寫「每日 AI 知識庫」，不加日期

【ContentColumn】
- 用 height（不是 maxHeight）+ overflow:\"hidden\"（不是 overflowY）

【背景音樂】
緊接在主音檔 Audio 後：
<Audio src={staticFile(\"audio/course_background_music.wav\")}
  volume={(f) => { const v=0.10; const fi=interpolate(f,[0,45],[0,v],{extrapolateRight:\"clamp\"}); const fo=interpolate(f,[TOTAL_FRAMES-150,TOTAL_FRAMES],[v,0],{extrapolateLeft:\"clamp\",extrapolateRight:\"clamp\"}); return Math.min(fi,fo); }}
  loop />
（TOTAL_FRAMES 替換為實際常數）

完成後輸出：「Scene Dev 完成」
" --allowedTools "Read,Write,Edit,Bash,Glob,Grep" 2>&1 | tee -a "$LOG"

log "[1/2] ✅ Scene Dev 完成"

# ── Step 2: TypeScript 檢查 ─────────────────────────────────────────────────
log "[2/2] TypeScript 檢查..."
cd "$PROJECT"
npx tsc --noEmit 2>&1 | tee -a "$LOG" && log "[2/2] ✅ TypeScript 通過" || fail "TypeScript 錯誤"

# ── Step 3: VTT 同步驗算（強制）────────────────────────────────────────────
log "[3/3] VTT 同步驗算..."
TSX_FILE=$(find "$PROJECT/src" -name "VideoComposition_${DATE//-/_}.tsx" | head -1)
[ -f "$TSX_FILE" ] || fail "找不到 TSX 檔"

python3 - <<PYEOF 2>&1 | tee -a "$LOG"
import re, sys

vtt_file = "$VTT_OUT"
tsx_file = "$TSX_FILE"
date = "$DATE"

# 讀取 VTT 建立 timestamp→text map
vtt_cues = []
with open(vtt_file, encoding='utf-8') as f:
    content = f.read()
for block in content.strip().split('\n\n'):
    lines = block.strip().split('\n')
    for i, l in enumerate(lines):
        if '-->' in l:
            start = l.split('-->')[0].strip()
            parts = start.split(':')
            if len(parts) == 2:
                secs = float(parts[0])*60 + float(parts[1])
                text = ' '.join(lines[i+1:]) if i+1 < len(lines) else ''
                vtt_cues.append((secs, text))

def secs_to_vtt(s):
    m = int(s)//60; sec = s - m*60
    return f"{m:02d}:{sec:06.3f}"

# 從 TSX 抓 triggerLocalFrame 和 scene start
tsx = open(tsx_file, encoding='utf-8').read()
scenes = {}
for m in re.finditer(r'scene(\d+)\s*:\s*\{\s*from:\s*(\d+)', tsx):
    scenes[m.group(1)] = int(m.group(2))
# summary scene
sm = re.search(r'summary\s*:\s*\{\s*from:\s*(\d+)', tsx)
if sm: scenes['summary'] = int(sm.group(1))

triggers = re.findall(r'(\w+Animation)\s+triggerLocalFrame=\{(\d+)\}', tsx)

print("\n=== VTT 同步驗算表 ===")
print(f"{'動畫名稱':<30} {'trigger':>8} {'VTT時間':>10}  講者台詞")
print("-"*80)
ok = True
for name, tstr in triggers:
    t = int(tstr)
    # 找對應的 scene start
    scene_start = 0
    for sn, sf in sorted(scenes.items(), key=lambda x: x[1], reverse=True):
        if sf <= t + max(scenes.values()):
            scene_start = sf; break
    # 用 scene 名猜
    for sn, sf in scenes.items():
        if sn in name.lower():
            scene_start = sf; break
    global_f = scene_start + t
    secs = global_f / 30.0
    # 找最近的 VTT cue
    closest = min(vtt_cues, key=lambda c: abs(c[0]-secs)) if vtt_cues else (secs, '?')
    diff = abs(closest[0] - secs)
    status = "✓" if diff < 5 else "⚠ 偏差>5秒"
    if diff >= 5: ok = False
    print(f"  {name:<28} {t:>8}  {secs_to_vtt(secs):>10}  {closest[1][:30]}  {status}")

print()
if ok:
    print("✅ 所有動畫 trigger 與 VTT 對齊（±5秒內）")
else:
    print("⚠️  有動畫 trigger 偏差超過 5 秒，請人工核對 VTT 同步")
PYEOF

log "[3/3] ✅ VTT 驗算完成"

# ── 完成 ────────────────────────────────────────────────────────────────────
touch "$INBOX/.phase2_done"
log "✅ Phase 2 完成 | $DATE | $TITLE"
~/.claude/scripts/imessage_send.sh "🎨 Phase 2 完成：${DATE}「${TITLE}」— 等待 Render"
