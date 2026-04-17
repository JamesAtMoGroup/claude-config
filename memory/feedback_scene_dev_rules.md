---
name: Scene Dev mandatory rules — VTT timing, asset size, safe zones, font sizes, animation DURATION
description: Hard rules for all video Scene Dev + QA agents; validated by CH1-2 and article-video 2026-04-10 iteration. Violations cause visible quality failures.
type: feedback
originSessionId: 1e791791-9d59-4762-94e3-4e43d41aa5d0
---
Rules validated through CH1-1 and CH1-2 iteration. **CH1-2 is the approved quality baseline — future chapters must not repeat the same mistakes.**

## Rule 0 — Read the script .txt and implement every 備注 exactly

Before writing any scene, read `chapters/{chapter}/章節{chapter}_逐字講稿.txt`.

Find every `**備注**` block. Each specifies:
- **使用相關素材**: exact filenames to embed
- **呈現方式**: exact layout — follow it literally, not approximately

Rules:
- Asset appears at the VTT frame when the speaker says the content just before the 備注
- "併排並拉箭頭" = horizontal row with arrow (NOT a 2×2 grid)
- "影片置中" = **full-screen AbsoluteFill overlay** (zIndex: 999, covers entire 3840×2160 including nav/subtitle). NOT inside SceneWrap. Mute speaker audio during the video via volume callback. Always convert `.mov` → `.mp4` first (ffmpeg libx264) for browser compatibility. Fade in/out 18f.
- **Video filenames must be ASCII** — Chinese/CJK characters in filenames cause URL encoding failures in the browser preview. Always rename to ASCII before using in code (e.g. `跨部門彙整.mp4` → `kuabumen-demo.mp4`).
- **Prefetch video assets** — add a `useEffect` at the composition root that creates a hidden `<video>` element to preload heavy assets before they appear.
- Asset goes in the scene matching the script section number — never moved elsewhere
- Callouts must NOT fire before the speaker says the related topic — `from` ≥ VTT cue start for that topic

**Why:** CH1-1 scene 3.2 had both 備注 markers: PNGs should be horizontal row + .mov centered in scene 3.2. Instead the agent used a 2×2 grid for PNGs and placed the .mov in scene 4.3 (wrong scene entirely). Callouts in Scene11Hero fired at 15f and 150f — before the speaker said anything related.

---

## Rule 1 — Motion graphics timing from VTT, never guessed

Every `startFrame`, callout `from/to`, and scroll trigger MUST come from reading the actual `.vtt` file.
Never approximate (e.g. "~21s = 630f"). Read the cue, multiply by 30.

```
VTT: "00:21.620 --> 00:24.100 但如果你能夠把這件事情自動化"
→ startFrame = Math.round(21.62 * 30) = 648
```

**Why:** All CH1-1 timings were guessed, causing motion graphics to appear seconds before or after the speaker mentioned the concept. James had to call it out and request a full fix pass.

**How to apply:** Before writing any scene, open the segment's `.vtt`, find each key concept cue, and annotate the exact frame. Then use those frames as `startFrame` values.

---

## Rule 2 — Assets must be large enough to read at 4K

- Minimum image width: `400 * S` (800px). Prefer `420–520 * S`.
- **2 images**: each `flex: 1` (50% each) ✅
- **3 images**: ❌ never 3-column (each ≈1000px but spreadsheets become unreadable) → ✅ 2+1 layout: top row 2 images (50% each), bottom row 1 image centered at 50% width
- **4+ images**: 2×2 grid, not horizontal row or vertical stack
- Video embeds: `width: "100%"` or at least `600 * S`.

**Why:** CH1-1 scene 3.2 had 4 department PNG screenshots too small — unreadable. CH1-2 scene 3.2 had 3 registration sheet PNGs in a 3-column row, each at 1000px — spreadsheet text unreadable at 4K. James called it out twice.

**How to apply:** After sizing any image, ask: "Can someone read the text in this screenshot on a 3840px wide screen?" If not, increase size or change layout. For 3 images, always use 2+1.

---

## Rule 2b — SVG text inside viewBox-scaled SVG

When writing `<text>` inside an `<svg>` that uses `viewBox`, the coordinate space is already scaled by the SVG's width/height ratio. Rule:

```
Target screen pixels = SVG_fontSize × S
→ SVG fontSize = target_px / S (NOT target_px * S)
→ Use fontSize={28} for 56px, fontSize={32} for 64px, fontSize={40} for 80px
```

❌ `fontSize="18"` → 36px, unreadable label  
❌ `fontSize={18 * S}` → double-scaled, 144px gigantic  
✅ `fontSize={28}` → 56px screen (label)  
✅ `fontSize={40}` → 80px screen (key result)

Never use string attribute `fontSize="N"` in SVG — always JSX number. Add inline comment `// target: 56px screen`.

**Why:** CH1-2 had `fontSize="18"` SVG text AND `14*S`/`16*S` CSS labels throughout — all too small. James repeatedly called out tiny text before it was fixed. CH1-2 is now the reference implementation.

**How to apply:** After writing any SVG `<text>`, verify the rendered size = SVG_fontSize × S ≥ 56px.

## Rule 2c — Motion graphic containers must stay within safe zone

Any animated container (burst, grid, diagram) must have height ≤ 1696px (H - NAV_H - SUBTITLE_H). If a radial burst or scatter layout would exceed this, replace with a compact `flex-wrap` grid of pills instead.

**Why:** CH1-2 IconBurstSVG had `height: 500*S = 1000px`, causing content to overflow the subtitle zone when stacked with surrounding cards.

## Rule 2d — CSS font sizes: absolute minimum 18*S, proven by CH1-2

**Rule:** No CSS `fontSize` value may be below `18 * S`. Minimum by role:
- Absolute bottom: `18 * S` (36px screen)
- Labels, captions, tags: `20 * S` (40px screen)
- Body text: `26–28 * S` (52–56px screen)

**Mandatory QA grep — must run before DONE:**
```bash
grep -n "fontSize: [0-9]\{1,2\} \* S" src/FullVideo*.tsx
# Any result with 10–17 * S = FAIL. Fix all before proceeding.
```

**Why:** CH1-2 had `12*S`/`14*S`/`16*S` values throughout — "房間裡的天才" label at 28px, "現況/痛點" tags at 28px, "範例（直接貼上即可）" at 28px, comparison table tags at 32px. All were unreadable at 4K. James called it out repeatedly ("文字超級小"). Fixed by bumping ALL sub-18*S values: 12→18, 14→20, 16→20.

**How to apply:** After writing any scene, run the grep. If any value < 18*S exists, it is a bug. Do not output DONE until the grep is clean.

## Rule 2e — Scene tail-end images: overlay, not inside SceneWrap

**Rule:** Any image/asset that appears late (bottom) in a long scene must be rendered as a `position: absolute` overlay **outside SceneWrap**, filling the safe zone (top: NAV_H, height: H−NAV_H−SUBTITLE_H).

```tsx
// ✅ Correct: outside SceneWrap, positioned overlay
<div style={{
  position: "absolute", top: NAV_H, left: 0, right: 0,
  height: H - NAV_H - SUBTITLE_H,
  background: C.bg,
  opacity: interpolate(frame, [triggerStart, triggerFrame], [0, 1], clamp),
  zIndex: 15, pointerEvents: "none",
}}>
  {/* images here */}
</div>

// ❌ Wrong: inside SceneWrap — overflow:hidden + scroll clips bottom images
<SceneWrap>
  {/* late-appearing images here — will be cut off by subtitle zone */}
</SceneWrap>
```

**Why:** CH1-2 Scene32ClearCmd had "合併後的成果" images at frame 2049 inside SceneWrap. scrollY of 1200px wasn't enough to bring them above the subtitle zone (320px). They were always clipped. Fixed by moving to AbsoluteFill overlay.

**How to apply:** If a scene has content that appears after frame 1500 AND the scene has significant content before it → use overlay pattern for tail-end images.

## Rule 1b — DURATION 必須計算到「這段話說完的最後一句 VTT」+ 90f buffer（article-video 專用）

```
DURATION = (last_topic_vtt_seconds × 30 - scene_start_frame - triggerLocalFrame) + 90
```

- 動畫內含有數字/統計資料 → DURATION 必須覆蓋到那個數字被講者說出來的時刻
- 禁止隨意填 200/280/300 等固定短值

**Why:** 2026-04-10 MetaShiftAnimation DURATION=200（≈6.7秒），但 App 87% 統計在 trigger 後 628 frames 才被說出 → 動畫消失後統計才出現，畫面完全空白。

---

## Rule 1c — 動畫內每個 step/element 的 delay 必須對齊 VTT（article-video 專用）

```
step_delay = Math.round(step_vtt_seconds × 30) - scene_start_frame - triggerLocalFrame
```

- 禁止用固定小 stagger（delay: 30/70/110/150）除非 VTT 真的均勻分布

**Why:** 2026-04-10 AgentAutonomy delay=[30,70,110,150]，但 VTT 中「拆解」在 trigger 後 336 frames 才說 → 步驟比講者早出現 5 秒以上。

---

## Rule 1d — Phase A 內容高度必須估算，超過 CONTENT_H=1620px 就用 element fade-out（article-video 專用）

估算方式：每張卡片（上下padding + 文字行高之和 + marginBottom）逐一加總。

超過 1620px → element fade-out pattern：
```tsx
const EARLY_FADE_START = LATE_CARD_AT - 120;
const EARLY_REMOVE     = LATE_CARD_AT - 10;
const showEarly        = frame < EARLY_REMOVE;
const earlyOpacity     = frame > EARLY_FADE_START
  ? interpolate(frame, [EARLY_FADE_START, EARLY_REMOVE], [1, 0], clamp) : 1;
```

**Why:** 2026-04-10 Scene1 有 4 張卡（Mythos+Partners+ZeroDayBug+FreeBSD），Scene3 有 5 張卡（header+intro+model1+model2+model3），全堆疊超過 1620px → ContentColumn 截掉最後一張卡。TypeScript 完全抓不到這個問題。

---

## Rule 1e — Scene Dev 完成後必須輸出 VTT 同步驗證表（article-video 專用）

```
動畫名稱 | trigger(local) | trigger VTT | 講者台詞 | DURATION | 覆蓋到VTT
（無法填出「覆蓋到」= DURATION 不夠，必須重算）
```

phase2.sh 的 Step 3 會自動用 Python 驗算並輸出這張表。

**Why:** TypeScript check 只能驗型別，無法驗邏輯正確性。沒有這張表，trigger 搞錯、DURATION 不夠、step delay 猜錯都不會被發現，只能靠 James 在 Studio 裡一幀一幀 scrub 才看到問題。

---

## Rule 3 — All content must stay within the safe zone

Safe zone boundaries:
- Top: `NAV_H = 144px` (never place content above)
- Bottom: `H - SUBTITLE_H = 1840px` (never exceed without scroll)

If content overflows bottom:
1. Calculate `maxScroll = totalContentHeight - (H - NAV_H - SUBTITLE_H - paddingTop)`
2. Add `scrollY = interpolate(frame, [triggerStart, triggerEnd], [0, maxScroll], clamp)`
3. Trigger = VTT frame when the overflowing content is being spoken
4. Pass `scrollY` to `SceneWrap`

**Why:** CH1-1 scene 3.2 "自動化後，每週少..." result block was completely hidden behind the subtitle reserved area. Scene 4.3 had the video embed at the very bottom, covered by subtitle zone.

**How to apply:** Before finalizing a scene, estimate total content height. If it exceeds 1696px, add scroll. Never let important content render below 1840px without bringing it into view via scroll.
