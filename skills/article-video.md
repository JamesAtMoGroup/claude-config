# Article Video Production Skill

每日 AI 知識庫影片製作工作流程——使用 Remotion 將 TTS 音檔 + 逐字稿 + Markdown 文章整合成每日知識短片。

**觸發詞**：「做 article-video」、「今天的 AI 知識庫影片」、「article-video YYYY-MM-DD」、`/article-video`

---

## 核心設計原則

> **影片是「文章的動態視覺呈現」，不是投影片。**
> 每個 Scene 對應文章的一個章節，視覺元素精準對齊 VTT 時間戳。

- S=3 (4K from 720p baseline) — 所有 px 值 ×3
- 黑底 neon green accent — `#000000` bg, `#7cffb2` primary
- Space Mono + Noto Sans TC
- iMessage callouts 疊加在右上角

---

## 專案結構

```
~/Projects/article-video/
├── ai-knowledge-YYYY-MM-DD/
│   ├── ai-knowledge-YYYY-MM-DD.md          ← 原始文章
│   ├── ai-knowledge-YYYY-MM-DD_script.md   ← 逐字稿
│   └── visual-spec-YYYY-MM-DD.json         ← Visual Concept Agent 輸出
├── public/
│   └── audio/
│       └── ai-knowledge-YYYY-MM-DD.wav     ← 正規化後音檔 (-20 LUFS)
├── out/
│   └── YYYY-MM-DD/
│       ├── ai-knowledge-YYYY-MM-DD.vtt     ← QA 通過的 VTT
│       └── YYYY-MM-DD.mp4                  ← 最終輸出
└── src/
    ├── Root.tsx
    └── VideoComposition_YYYY_MM_DD.tsx      ← 每日獨立檔案
```

---

## 視覺設計系統

### Scale（強制，勿改）

```ts
const S = 3;              // 4K scale factor from 720p baseline
const W = 1280 * S;       // 3840
const H = 720  * S;       // 2160
const NAV_H       = 50 * S;   // 150px — progress bar
const CONTAINER_W = 640 * S;  // 1920px — content column
const COL_LEFT    = (W - CONTAINER_W) / 2;  // 960px

const SUBTITLE_SAFE = 120 * S;  // 360px — bottom safe zone（勿改）
const CONTENT_GAP   = 10 * S;   // 30px — navbar 與 content 之間的間距
const CONTENT_TOP   = NAV_H + CONTENT_GAP;         // 180px
const CONTENT_H     = H - CONTENT_TOP - SUBTITLE_SAFE; // 1620px
```

### Design Tokens

```ts
const C = {
  bg:           "#000000",
  surface:      "#0d0d0d",
  primary:      "#7cffb2",
  primaryLight: "rgba(124,255,178,0.07)",
  primaryBorder:"rgba(124,255,178,0.14)",
  text:         "#ffffff",
  muted:        "#888888",
  yellow:       "#ffd166",
  yellowLight:  "rgba(255,209,102,0.1)",
  yellowBorder: "rgba(255,209,102,0.2)",
  red:          "#ff6b6b",
  redLight:     "rgba(255,107,107,0.08)",
  redBorder:    "rgba(255,107,107,0.2)",
} as const;
```

### 字型

| 用途 | 字型 |
|------|------|
| 標題 / 正文 | `Noto Sans TC`, `PingFang TC` |
| 標籤 / badge / monospace | `Space Mono` |

### Font Size 最小值（強制）

| 元素 | 最小 |
|------|------|
| Space Mono labels / badge | ≥ 11*S = 33px |
| Body text | ≥ 14*S = 42px |
| Featured text / highlight | ≥ 20*S = 60px |
| Section heading | ≥ 22*S = 66px |

---

## ContentColumn — 強制規則

```tsx
function ContentColumn({ children, scrollUp }: {
  children: React.ReactNode;
  scrollUp?: { at: number; amount: number };
}) {
  const { fps } = useVideoConfig();
  const frame = useCurrentFrame();

  let scrollY = 0;
  if (scrollUp) {
    const scrollF = Math.max(0, frame - scrollUp.at);
    const p = spring({ frame: scrollF, fps, config: { damping: 200 } }); // smooth, no bounce
    scrollY = interpolate(p, [0, 1], [0, -scrollUp.amount], clamp);
  }

  return (
    <AbsoluteFill style={{ overflow: "hidden" }}>
      {/* Fixed-height clip box — overflow:hidden clips ALL 4 edges */}
      <div style={{
        position: "absolute", top: CONTENT_TOP, left: COL_LEFT,
        width: CONTAINER_W,
        height: CONTENT_H,        // ← 固定高度，非 maxHeight
        overflow: "hidden" as const, // ← 全向 clip（含 top edge，防止 scrollUp 進入 navbar 區）
      }}>
        <div style={{ transform: `translateY(${scrollY}px)` }}>
          {children}
        </div>
      </div>
    </AbsoluteFill>
  );
}
```

**關鍵**：必須用 `height`（不是 `maxHeight`）+ `overflow: hidden`（不是 `overflowY`），才能確保 scrollUp 動畫不會讓內容進入 navbar 區域。

---

## ProgressBar — 強制規則

```tsx
<AbsoluteFill style={{ pointerEvents: "none", zIndex: 10 }}>
  <div style={{
    position: "absolute", top: 0, left: 0, right: 0,
    height: NAV_H,
    background: "rgba(0,0,0,0.92)",
    backdropFilter: "blur(12px)",
    WebkitBackdropFilter: "blur(12px)",
    borderBottom: `1px solid ${C.primaryBorder}`,
    padding: `${8 * S}px ${80 * S}px`,
    ...
  }}>
```

- `zIndex: 10` — 確保 navbar 永遠在所有 scene content 之上
- padding 必須 × S
- 無 mm:ss 時間戳，只顯示 chapter label
- **左側只顯示「每日 AI 知識庫」，不加日期（禁止寫 `· YYYY-MM-DD`）**
- TitleScene badge 同樣只寫「每日 AI 知識庫」，不加日期

---

## Animation System（強制）

> **Skills**: `remotion-best-practices` (timing.md, animations.md) + `motion-design` (easing-tokens.md) + `gsap` (easing.md — 命名參考)
> **禁止使用 CSS transitions / Tailwind animation classes** — Remotion 逐幀渲染，CSS 動畫無效。
> **GSAP 注意**：`gsap` skill 的 `rules/remotion.md` 尚未建立。勿嘗試在 Remotion 中直接 run GSAP tweens（clock-based，不相容）。GSAP 命名（expo.out 等）僅作為 easing 意圖溝通的參考語言。

**禁止使用 `spring()` 做元素入場動畫。** Spring 有無限的拖尾，且 duration 不可控。改用 `Easing.bezier()` + `interpolate()`：

```tsx
import { interpolate, Easing } from "remotion";

// ── Easing tokens（對應 motion-design / GSAP skill 命名）─────────
// GSAP name    → Token       → Cubic-bezier
// expo.out     → E.outExpo   → (.19, 1, .22, 1)      最 aggressive
// power2.out   → E.outCubic  → (.215, .61, .355, 1)  moderate
// power3.out   → E.outQuart  → (.165, .84, .44, 1)   strong default
// back.out(1.7)→ easeOutBack → custom math (no bezier equivalent)
const E = {
  outExpo:  Easing.bezier(0.19, 1, 0.22, 1),       // GSAP: expo.out
  outCubic: Easing.bezier(0.215, 0.61, 0.355, 1),  // GSAP: power2.out
  outQuart: Easing.bezier(0.165, 0.84, 0.44, 1),   // GSAP: power3.out
} as const;

// easeOutBack 不在 motion-design tokens 內，保留 custom math
const easeOutBack = (t: number, s = 1.55) => {
  const c = Math.min(t, 1);
  return 1 + (s + 1) * Math.pow(c - 1, 3) + s * Math.pow(c - 1, 2);
};

// prog helper — clamps 0..1
const prog = (f: number, dur: number) => Math.min(f / dur, 1);
```

### Spring 標準 Config（remotion-best-practices）

| 用途 | Config |
|------|--------|
| ScrollUp（ContentColumn） | `{ damping: 200 }` — smooth, no bounce |
| iMessage slide-in / push | `{ damping: 22, stiffness: 130 }` — snappy |
| Playful pop（少用） | `{ damping: 8 }` — bouncy |

### 用途對照表

| 動畫 | Easing | Duration |
|------|--------|---------|
| 卡片/區塊 slide-up 進場（`useFadeUp`） | `E.outExpo` for translateY, `E.outCubic` for opacity | 22f / 14f |
| Opacity fade-in（`useFadeIn`） | `E.outCubic` | 22f |
| 卡片/節點 scale pop-in | `easeOutBack` (s=1.55, custom) | 18f |
| Arrow / bar draw (scaleX) | `E.outCubic` | 12f |
| 清單項目 translateY | `E.outExpo` | 20f |
| ScrollUp（ContentColumn） | `spring({ damping: 200 })` — **例外** |
| iMessage card slide-in / push | `spring({ damping: 22, stiffness: 130 })` — **例外** |

### 標準 Hooks

```tsx
// Slide up + fade in — easeOutExpo
function useFadeUp(startFrame: number) {
  const frame = useCurrentFrame();
  const f = Math.max(0, frame - startFrame);
  const ty = interpolate(f, [0, 22], [22 * S, 0], { easing: E.outExpo,  extrapolateRight: "clamp" });
  const op = interpolate(f, [0, 14], [0, 1],      { easing: E.outCubic, extrapolateRight: "clamp" });
  return { opacity: op, transform: `translateY(${ty}px)` };
}

// Simple opacity — easeOutCubic
function useFadeIn(startFrame: number) {
  const frame = useCurrentFrame();
  const f = Math.max(0, frame - startFrame);
  return { opacity: interpolate(f, [0, 22], [0, 1], { easing: E.outCubic, extrapolateRight: "clamp" }) };
}
```

### Scene-to-Scene 轉場（可選）

需要跨 Scene fade/slide 轉場時，使用 `@remotion/transitions`：

```tsx
import { TransitionSeries, springTiming } from "@remotion/transitions";
import { fade } from "@remotion/transitions/fade";

<TransitionSeries>
  <TransitionSeries.Sequence durationInFrames={sceneADuration}>
    <SceneA />
  </TransitionSeries.Sequence>
  <TransitionSeries.Transition
    presentation={fade()}
    timing={springTiming({ config: { damping: 200 }, durationInFrames: 20 })}
  />
  <TransitionSeries.Sequence durationInFrames={sceneBDuration}>
    <SceneB />
  </TransitionSeries.Sequence>
</TransitionSeries>
```

注意：轉場會縮短總 frame 數（`totalFrames - transitionDuration`），需更新 `TOTAL_FRAMES`。

---

## Concept Animations (Motion Graphics)

每支影片應在 3–5 個 VTT 關鍵時刻加入 **concept animation** — 浮動於畫面上的視覺隱喻，與講者台詞精確同步。

### 設計原則

- **VTT-synced**: 每個動畫對應一個 VTT 台詞，triggerFrame = `Math.round(vttSeconds × 30)`
- **Overlay pattern**: 使用 `position: absolute` 浮於場景上方，`zIndex: 50`，`pointerEvents: none`
- **不遮 slides（禁止）**: 動畫必須定位在 content column（x 960–2880）以外；右側用 `right: 40*S`，左側用 `left: 40*S`；**禁止 `left: "50%"` 或任何置中定位**
- **Envelope**: 每個動畫有 fade-in (0–10f) → hold → fade-out (DURATION-20f → DURATION) 包絡線
- **Duration**: 160–360 frames（足夠讓講者說完該段落）；超過 DURATION return null 停止 render
- **Hook safety**: `useCurrentFrame()` 只在 component 頂層呼叫一次，**絕對禁止在 `.map()` 、條件式（`{showA && ...}`）、或任何 JSX prop 展開內呼叫 hook**
- **列點動畫必須逐一出現**: 有多個列點的動畫，每個點的 `appearsAt` 必須對齊 VTT 時間戳；**禁止用固定小 stagger（如 `i * 60`）一次全部列出**
- **累積顯示**: 列點出現後持續留在畫面，不消失，直到整體 DURATION 結束才淡出

### Motion Graphics 重疊禁止規則（Anti-overlap）

> 同一時間點，同一側（左或右）只能有一個 motion graphic 在畫面上。

**必做的重疊檢查流程**（Scene Dev Agent 寫完所有動畫後必須執行）：

1. 列出每個 Scene 的所有動畫：`triggerLocalFrame`、`DURATION`、位置（左/右）
2. 確認同側動畫無時間重疊：`triggerA + DURATION_A < triggerB`
3. 如有重疊，擇一處理：
   - 縮短先出現的動畫 DURATION（在下一個動畫開始前 15f 結束）
   - 或將其中一個移至對側（右→左，或左→右）
4. 跨越 Phase A→B 轉場的長效動畫（如累積列點），必須確認後續同側動畫不重疊

**常見錯誤範例**（已修正，勿再重複）：
- ThreeReasonsAnimation（右，長達 1700f）+ AgentFlowAnimation（右，同時段）→ 衝突，AgentFlow 應移左側
- MCPToolsListAnimation（右）+ USBUnifyAnimation（右，在 MCPTools 結束前啟動）→ 縮短 MCPTools DURATION
- EcosystemBurstAnimation（右）+ ThreeReasons 的累積 card（右，同時顯示）→ EcosystemBurst 移左側

### 標準組件模板

```tsx
function ConceptAnimation({ triggerFrame }: { triggerFrame: number }) {
  const frame = useCurrentFrame();   // ← 頂層唯一一次
  const f = Math.max(0, frame - triggerFrame);
  const DURATION = 80;

  const envelope = interpolate(f, [0, 10, DURATION-12, DURATION], [0, 1, 1, 0], clamp);
  if (f > DURATION) return null;    // ← if after hooks is fine

  // ... 動畫計算 ...

  return (
    <div style={{
      position: "absolute",
      /* 位置: right/left/top/bottom × S */
      opacity: envelope,
      pointerEvents: "none", zIndex: 50,
    }}>
      {/* SVG / emoji / div 組合 */}
    </div>
  );
}
```

### 注入方式

- **TitleScene**: 在 `<AbsoluteFill>` 內，`<SceneFade>` 之外加入 `<ConceptAnimation triggerFrame={X} />`
- **Scene1/2/3**: 若 Scene 原本 return 單一 `<ContentColumn>`，改用 fragment 包裹並加 `<AbsoluteFill>` overlay:
  ```tsx
  return (
    <>
      <ContentColumn>...</ContentColumn>
      <AbsoluteFill style={{ pointerEvents: "none" }}>
        <ConceptAnimation triggerLocalFrame={localFrame} />
      </AbsoluteFill>
    </>
  );
  ```
- Scene 內部用 **local frame** (global - sceneStart)，TitleScene 直接用 global frame

### 每支影片建議 5 個動畫時機

| 場景 | 台詞類型 | 動畫概念 |
|------|---------|---------|
| TitleScene | 核心痛點/問題 | 視覺隱喻 (brain, question mark, broken icon) |
| Scene 1 A | 概念對比 before | Static/limited 的視覺 (閉眼、牆壁、鎖頭) |
| Scene 1 B | 概念對比 after | Dynamic/enhanced 的視覺 (搜尋、流動、解鎖) |
| Scene 2 | 數據/限制說明 | 圖表動畫 (freeze line, wall, countdown) |
| Scene 3 | 技術流程 | 流程動畫 (slice, convert, flow arrows) |

### 04-01 RAG 影片已實作動畫

| Global Frame | 台詞 | 組件 |
|------|------|------|
| 415 | 它記不住你的事情 | `BrainForgetAnimation` — 腦部記憶節點逐個消失 + ❓ 上浮 |
| 4022 | 知識凍結在訓練截止日 | `KnowledgeFreezeAnimation` — 時間軸凍結線 + ❄️ |
| 6716 | 把文件切成小片段 | `DocumentSliceAnimation` — 文件切片 → 向量 token |

### 動畫位置規則

- 不遮擋主要資訊卡片
- TitleScene: `bottom: 280*S` centered
- Scene overlay: `right: 80*S, top: 180*S` 或 `left: 110*S, top: 50%`
- 字幕安全區 `SUBTITLE_SAFE = 120*S` 以下禁放動畫

### 配色

使用現有 `C` tokens，動畫元素遵循場景主色。常用:
- 主動/正面: `C.primary` (#7cffb2 綠) + `boxShadow glow`
- 靜態/限制: `rgba(255,255,255,0.15)` + 淡出
- 冰凍/截止: `rgba(147,197,253,0.8)` (ice blue)
- 警告/注意: `C.red` or `C.yellow`

---

## 畫面填滿規則（Screen Fullness）

**每個 Phase 的可視內容必須充分填滿畫面。** 空白區域超過 40% 視為不合格。

### 多節點圖表 — dim/bright 模式（強制）

當一個 Phase 包含多步驟概念圖（flow diagram / timeline / step cards），**必須從 Phase 開始就顯示所有節點**，用 `activeAt` 控制每個節點的 dim→bright 轉場，而不是條件式新增節點。

```tsx
// ✅ 正確：所有節點一開始就顯示，dimmed 等待激活
function FlowNode({ ..., activeAt }: { ...; activeAt?: number }) {
  const frame = useCurrentFrame();
  const dimF = activeAt !== undefined ? Math.max(0, frame - activeAt) : 1e9;
  const activeT = activeAt !== undefined ? easeOutPower3(prog(dimF, 22)) : 1;
  const opacityMult = interpolate(activeT, [0, 1], [0.28, 1], clamp);
  // ...opacity: entranceOpacity * opacityMult
}

// ❌ 禁止：用 {step1Active && <Node />} 條件式新增節點 → 畫面突然跳變
```

同理適用於 arrows between nodes：同樣加 `activeAt` prop，`dimmed` opacity = 0.22。

### WordReveal — 逐字入場動畫（強制用於所有標題）

**所有 section title、HighlightPulse 主文、TitleScene h1 必須使用 `WordReveal`**，不得用整塊 fade-in。

```tsx
// 呼叫 useCurrentFrame 在 top level — React hooks 安全 ✓
function WordReveal({ text, startFrame, staggerPerWord = 4, fontSize, color, fontFamily, fontWeight, letterSpacing }: {
  text: string; startFrame: number; staggerPerWord?: number;
  fontSize?: number; color?: string; fontFamily?: string;
  fontWeight?: number | string; letterSpacing?: string;
}) {
  const frame = useCurrentFrame();
  return (
    <span style={{ display: "inline" }}>
      {text.split(" ").map((word, i) => {
        const f  = Math.max(0, frame - (startFrame + i * staggerPerWord));
        const ty = interpolate(f, [0, 20], [18 * S, 0], { easing: E.outExpo,  extrapolateRight: "clamp" });
        const op = interpolate(f, [0, 12], [0, 1],       { easing: E.outCubic, extrapolateRight: "clamp" });
        return (
          <span key={i} style={{ display: "inline-block", opacity: op, transform: `translateY(${ty}px)`, marginRight: "0.28em", fontSize, color, fontFamily, fontWeight, letterSpacing }}>
            {word}
          </span>
        );
      })}
    </span>
  );
}
```

- SectionBadge h2: `staggerPerWord={5}`
- HighlightPulse 主文: `staggerPerWord={4}`, startFrame = `delay + 4`
- TitleScene h1 行1: `staggerPerWord={6}`, startFrame = `10`
- TitleScene h1 行2: `staggerPerWord={6}`, startFrame = `28`

### SceneFade — scene 邊界 fade（強制）

每個 scene 頭尾各 12 frames 淡入/淡出，消除硬切：

```tsx
function SceneFade({ children, durationInFrames }: { children: React.ReactNode; durationInFrames: number }) {
  const frame = useCurrentFrame();
  const fadeIn  = interpolate(frame, [0, 12], [0, 1], { extrapolateRight: "clamp" });
  const fadeOut = interpolate(frame, [durationInFrames - 12, durationInFrames], [1, 0], { extrapolateLeft: "clamp" });
  return <div style={{ opacity: Math.min(fadeIn, fadeOut), height: "100%" }}>{children}</div>;
}
```

每個 Scene function 的最外層 content 必須包在 `<SceneFade durationInFrames={sceneEndFrame - sceneStartFrame}>` 內。

### RippleRing — 節點激活漣漪（diagram node activeAt 必加）

```tsx
function RippleRing({ activeAt, color }: { activeAt: number; color: string }) {
  const frame = useCurrentFrame();
  const f = Math.max(0, frame - activeAt);
  if (f > 28) return null;
  const scale   = interpolate(f, [0, 24], [0.85, 1.9], { easing: E.outExpo, extrapolateRight: "clamp" });
  const opacity = interpolate(f, [0, 4, 24, 28], [0, 0.55, 0.2, 0], { extrapolateRight: "clamp" });
  return (
    <div style={{ position: "absolute", inset: 0, border: `${2 * S}px solid ${color}`, borderRadius: 12 * S, transform: `scale(${scale})`, opacity, pointerEvents: "none" }} />
  );
}
```

節點 outer div 需加 `position: "relative"`，並在 `activeAt` 存在時渲染 `<RippleRing activeAt={activeAt} color={ringColor} />`。

### StepExplainCard — 填補步驟間空白

當圖表（diagram）下方有大塊空白，且 VTT 中 narrator 在解釋每個步驟時，**必須在對應 VTT 時間點加入 `StepExplainCard`** 填補空白並與旁白同步：

```tsx
function StepExplainCard({ delay, color, border, label, text }: {
  delay: number; color: string; border: string; label: string; text: string;
}) {
  const frame = useCurrentFrame();
  const f = Math.max(0, frame - delay);
  const opacity    = easeOutPower3(prog(f, 18));
  const translateY = (1 - easeOutExpo(prog(f, 22))) * 14 * S;
  return (
    <div style={{ opacity, transform: `translateY(${translateY}px)`, marginBottom: 12 * S }}>
      <div style={{
        borderLeftWidth: 3 * S, borderLeftStyle: "solid", borderLeftColor: color,
        paddingLeft: 16 * S, paddingTop: 4 * S, paddingBottom: 4 * S,
        borderRadius: `0 ${10 * S}px ${10 * S}px 0`,
        background: `${border}22`,
      }}>
        <div style={{ fontFamily: "'Space Mono',monospace", fontSize: 11 * S, color,
          letterSpacing: "0.06em", marginBottom: 6 * S }}>{label}</div>
        <div style={{ fontFamily: "'Noto Sans TC',sans-serif",
          fontSize: 15 * S, color: C.text, lineHeight: 1.65 }}>{text}</div>
      </div>
    </div>
  );
}
```

**使用時機**：Phase B 包含 diagram + 多個步驟說明時，每個步驟的 VTT 時間點加一張 card。

---

## Scene Dev Agent — 強制規則

### Phase A/B 結構

每個 Scene 分 Phase A（前段）和 Phase B（後段）：
- Phase A 顯示核心概念，接近尾聲時 fade out
- Phase B 顯示深入內容，於 Phase A 完全消失後才顯示
- **A_FADE_START 必須對齊 VTT timestamp**（Phase A 最後一句話結束的時間）

```tsx
const A_FADE_START = VTT_END_FRAME;   // VTT 最後一句 × 30
const A_REMOVE     = A_FADE_START + 80;
const showA  = frame < A_REMOVE;
const aOpacity = frame > A_FADE_START
  ? interpolate(frame, [A_FADE_START, A_REMOVE], [1, 0], clamp) : 1;
const showB = frame >= A_REMOVE + 20;  // Phase B 在 A 消失後 20 frames 出現
```

### Element Delay 規則

所有 element delay = 對應 VTT cue 的 **scene-local frame**（seconds × 30 - sceneStart）。

**絕對禁止猜測** — 必須用 VTT 文件交叉比對。

Phase B 第一個元素的 delay **必須等於 showB 的 frame 值**（不得早於 showB）。

### Scroll-Up 規則

當 Phase B 元素累計高度可能超過 `CONTENT_H = 1620px` 時，`ContentColumn` 必須加上 `scrollUp` prop：

```tsx
<ContentColumn scrollUp={{ at: triggerFrame, amount: overflowPx + 20 }}>
```

- `triggerFrame` = 導致 overflow 的第一個新元素出現時的 scene-local frame
- overflow 估算：逐一計算各元素 padding + font-size × lineHeight × lines + marginBottom

### 30 秒無視覺元素規則

任何場景中，連續超過 30 秒（900 frames）不出現新視覺元素，必須安排新 Phase 或新元素。

### React Rules of Hooks

- **絕對禁止** 在 `.map()` 或條件式 `if` 內呼叫 hook
- 所有使用 hook 的動態元素必須抽出為獨立 named component（不可用 inline function）

---

## iMessage Callout — 強制規則

```ts
const NOTIF_W       = 290 * S;
const NOTIF_TOP     = 12 * S;
const NOTIF_RIGHT   = 20 * S;
const NOTIF_SLOT    = 148 * S;   // 多張時 push-down 間距
const NOTIF_SLIDE_H = 110 * S;   // 入場滑入高度
```

- 右上角 stack，新卡片從上推舊卡片往下
- spring slide-in（damping 22, stiffness 130）+ typewriter 效果
- sender 欄填思考題觸發角色（如「想一想」、「親身經歷」）
- 全局 frame 定位（非 scene-local）

---

## 音檔規格

- **-20 LUFS, Peak -2 dBFS**（article-video 固定規格）
- 不做 denoise — James 自行校正
- 輸出到 `public/audio/ai-knowledge-YYYY-MM-DD.wav`
- Whisper large-v3-turbo 轉錄，常見誤認：RAG→RAC、播報員→不报員（需 QA 修正）

---

## Visual Concept Agent — 設計輔助 Skills

Visual Concept Agent 在規劃 scene 視覺佈局時，應載入以下 skill 輔助決策：

### `ui-ux-pro-max` — 適用於：
- **Glassmorphism card 設計**：backdrop-blur 強度、border-opacity、surface color、shadow 層次
- **視覺層次（visual hierarchy）**：標題 / 副標 / body / label 的尺寸比例
- **色彩系統**：accent color 搭配、對比度、muted vs. highlight 平衡

> **限制**：Tailwind 和 CSS transition 在 Remotion 無效。所有 ui-ux-pro-max 輸出必須手動轉換為 inline `style={{}}` + 乘以 S。

### `motion-design` — 適用於：
- 評估每個 Phase 的動畫**用途與頻率**（responsiveness / spatial / illustrative）
- 選擇正確 easing token（對應 `E.outExpo` / `E.outCubic` / `E.outQuart`）
- 決定哪些元素需要動畫，哪些不需要（"every animation needs a job"）

> **限制**：duration 以 frames 計（30fps），不是 ms。motion-design 的 ms 值 ÷ 33 ≈ frames。

### 不適用的 skills：
- `ui-styling`（shadcn/ui + Tailwind — 在 Remotion 無效）
- 其他 frontend 相關 skill（CSS transitions 禁用）

---

## VTT-First Pipeline（強制順序）

```
1. Audio Agent     → 正規化音檔 (-20 LUFS)
2. Transcription   → Whisper → .vtt → 與逐字稿交叉比對 QA
3. Visual Concept  → 讀 VTT + 文章 + ui-ux-pro-max + motion-design → 輸出 visual-spec-YYYY-MM-DD.json
4. Scene Dev Agent → 讀 spec + VTT → 寫 VideoComposition_YYYY_MM_DD.tsx
5. QA Agent        → Studio 預覽 → iMessage 傳報告 → 等「通過」
6. Render Agent    → npm run build:YYYY-MM-DD
7. Upload Agent    → rclone 上傳 out/YYYY-MM-DD/ 到 Google Drive → iMessage 通知完成
```

**VTT 必須存在且 QA 通過，才能進入 Scene Dev。**

### Render 後自動上傳 Google Drive

每次 render 完成後，**必須立即**上傳到 Google Drive：

```bash
rclone copy /Users/jamesshih/Projects/article-video/out/YYYY-MM-DD/ gdrive: \
  --drive-root-folder-id 1Q2Jdflw80FXXDpGMw22OFVbwlqsMoWGz \
  --drive-use-trash=false \
  --progress
```

- Remote: `gdrive`（~/.config/rclone/rclone.conf 已設定）
- Folder ID: `1Q2Jdflw80FXXDpGMw22OFVbwlqsMoWGz`（每日 AI 知識庫）
- **必須用 `--drive-root-folder-id`**，不可用 `gdrive:folder-id`（會建立同名資料夾於根目錄）
- 上傳完成後傳 iMessage 通知

---

## Root.tsx + package.json 更新

每個新影片需要：

```tsx
// Root.tsx
import { VideoComposition_YYYY_MM_DD, TOTAL_FRAMES_YYYY_MM_DD } from "./VideoComposition_YYYY_MM_DD";
// 在 RemotionRoot 中加入：
<Composition
  id="ArticleVideo-YYYY-MM-DD"
  component={VideoComposition_YYYY_MM_DD}
  durationInFrames={TOTAL_FRAMES_YYYY_MM_DD}
  fps={30} width={3840} height={2160}
/>
```

```json
// package.json scripts
"build:YYYY-MM-DD": "remotion render ArticleVideo-YYYY-MM-DD out/YYYY-MM-DD/{標題}-YYYY-MM-DD.mp4 --codec h264"
```

---

## 場景命名與輸出

| 項目 | 值 |
|------|----|
| Composition ID | `ArticleVideo-YYYY-MM-DD` |
| 輸出路徑 | `out/YYYY-MM-DD/YYYY-MM-DD.mp4` + `.vtt` |
| TypeScript export | `VideoComposition_YYYY_MM_DD`, `TOTAL_FRAMES_YYYY_MM_DD`, `SCENES_YYYY_MM_DD` |
| Studio port | 3002 |

---

## Checklist（Scene Dev 完成前必須全部勾選）

### 基礎結構
- [ ] VTT QA 通過
- [ ] 場景邊界 = VTT seconds × 30（非猜測）
- [ ] CONTENT_TOP = 180px, CONTENT_H = 1620px
- [ ] ContentColumn: `height` + `overflow:hidden`（非 maxHeight/overflowY）
- [ ] ProgressBar: `zIndex: 10`，padding × S

### 動畫系統
- [ ] `E` easing token 物件（outExpo / outCubic / outQuart）+ `easeOutBack` + `prog` 已定義於檔案頂端
- [ ] **零個** `spring()` 用於元素入場動畫（spring 只允許 iMessage + scrollUp）
- [ ] `useFadeUp` 用 `E.outExpo`，`useFadeIn` 用 `E.outCubic`（皆透過 `interpolate()` + `Easing.bezier()`）
- [ ] ScrollUp spring config 為 `{ damping: 200 }`
- [ ] 所有標題文字使用 `WordReveal`（非整塊 fade-in）
- [ ] 每個 Scene 頭尾包 `SceneFade`（12f 淡入/淡出）
- [ ] Flow diagram 節點含 `activeAt` 時加 `RippleRing`

### 畫面填滿
- [ ] 每個 Phase 可視內容填滿 > 60% 畫面高度
- [ ] 多步驟圖表：所有節點從 Phase 開始就顯示，用 `activeAt` 控制 dim→bright（無條件式節點新增）
- [ ] Phase B 步驟說明空白處已加 `StepExplainCard`（對齊 VTT 時間點）

### VTT 對齊
- [ ] A_FADE_START 對齊 VTT timestamp（Phase A 最後一句結束）
- [ ] Phase B 第一元素 delay = showB frame
- [ ] Scroll-up 已評估（Phase B 高度 > 1620px 時強制加入，否則不加）

### Concept Animations
- [ ] 5 concept animations synced to VTT timestamps (1 per scene + title)
- [ ] Each animation: envelope fade-in/out, duration 70-90f, zIndex 50, pointerEvents none
- [ ] Animations don't overlap subtitle safe zone (bottom 120*S)

### 程式品質
- [ ] React hooks 無條件式呼叫（`.map()` 內 / `if` 內均禁止）
- [ ] Font sizes 符合最小值（body ≥ 14*S，featured ≥ 20*S）
- [ ] `npx tsc --noEmit` 無錯誤
- [ ] Root.tsx + package.json 已更新
