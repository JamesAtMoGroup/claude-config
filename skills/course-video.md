# Course Video Production Skill

課程影片剪輯工作流程，使用 Remotion 將講者音檔 + HTML 簡報 + 逐字稿整合成完整課程影片。

**觸發詞**：「剪課程影片」、「製作影片」、「remotion 課程」、`/course-video`

---

## 執行規則（強制）

> **每次執行此技能，必須使用多 Agent 團隊，不得由單一 Agent 獨立完成。**

### 標準團隊結構

| 角色 | 職責 |
|------|------|
| **Director** | 讀取 skill + `progress.md`，分配任務，審查產出，做最終決定 |
| **Asset & Transcription Agent** | 確認素材、執行 Whisper VTT、複製音檔 |
| **VTT Correction Agent** | 比對逐字稿修正 VTT 錯誤 |
| **HTML Analysis & Scene Planning Agent** | 讀取 HTML、對應段落、建立時間軸計畫 |
| **Scene Development Agent** | 撰寫 Remotion TSX 元件 |
| **Integration & Render Agent** | 組裝 Root.tsx、執行 render、輸出 MP4 |

小任務可合併 Agent，但 **Director 必須獨立存在**。

---

## 核心設計原則（最重要）

> **影片畫面必須與 `(N){章節}.html` 的視覺和內容一致。**
> 影片不是電影片頭，不是抽象動態背景——而是「HTML 課程頁面活起來」。

正確理解：
- 影片看起來就像在看那份 HTML 頁面，只是元素會動
- Progress bar、章節卡片、類比框、Section Header——全部都要在影片裡出現
- Callout Cards 是影片獨有的（HTML 沒有），疊加在兩側空白處

---

## 專案結構

```
素材來源：~/Downloads/Vibe Coding 剪輯/{章節}/
  ├── {章節} 音檔/      ← 講者錄音 .wav（命名：章節_小節.wav，如 0-1_1.1.wav）
  ├── (N){章節}.html   ← 對應的簡報畫面（影片視覺的基準）
  └── 逐字講稿.docx    ← 完整講稿，章節結構對應音檔編號

Remotion 專案：~/Projects/vibe-coding-video/
  ├── src/
  │   ├── Root.tsx
  │   ├── Video30s.tsx   ← 當前 composition
  │   ├── Opening.tsx    ← 課程頁面場景
  │   └── hooks.ts       ← useMorphIn, useGlitch, useTypewriter
  └── public/
      ├── audio/         ← 音檔（從素材資料夾複製進來）
      └── aischool-logo.webp
```

輸出位置：`~/Downloads/Vibe Coding 剪輯/`

---

## 視覺設計系統

### 色彩（exact match to HTML CSS variables）

```ts
const C = {
  bg:           "#000000",              // 純黑背景
  surface:      "#0d0d0d",             // 卡片底色
  surface2:     "#111111",
  primaryLight: "rgba(124, 255, 178, 0.07)",
  primary:      "#7cffb2",             // neon 綠，主 accent
  text:         "#ffffff",
  muted:        "#888888",
  yellow:       "#ffd166",
  border:       "rgba(124,255,178,0.14)",
};
```

### 字型

| 用途 | 字型 | 說明 |
|------|------|------|
| 標題 / 正文 | `Noto Sans TC`, `PingFang TC` | 繁中主字型 |
| 標籤 / 代碼 / 章節號 | `Space Mono` | monospace，技術感 |

### 嚴格禁止
- **禁止使用任何 emoji** — 包含字卡 icon、Tags、標題。AI 感過強。
- 替代方案：CSS 幾何圖形（6px 方塊 + glow）、純文字標籤、`✦`（排版符號，非 emoji）

---

## 畫面佈局（Page Layout）

### 整體結構（1920×1080）

```
┌─────────────────────────────────────────────────────────────────┐
│  Progress Bar (72px)                                            │
│  [Logo] AI 寫程式入門課程              章節 0-1 / 4            │
│  ████████░░░░░░░░░░░░░░░░░░░░░░ (8% fill, green glow)         │
├─────────────────────────────────────────────────────────────────┤
│ [Callout] │         Content Column (860px)          │ [Callout] │
│  Left     │   ← centered: (1920-860)/2 = 530px →   │   Right   │
│   zone    │                                         │    zone   │
│  530px    │  Hero / Section Cards / Analogy Boxes   │   530px   │
│           │                                         │           │
└─────────────────────────────────────────────────────────────────┘
```

```ts
const NAV_H       = 72;   // progress bar height
const CONTAINER_W = 860;  // content column (corresponds to HTML max-width: 780px)
const containerLeft = Math.round((width - CONTAINER_W) / 2); // = 530px
```

### 畫面圖層（從底到頂）

```
1. Background orbs  — 微型徑向漸層（matching HTML body::before/::after）
                      top-right: rgba(124,255,178,0.07), 600px
                      bottom-left: rgba(124,255,178,0.04), 500px
2. Progress Bar     — 頂部 72px，slide-in from top
3. Content Column   — 860px 置中欄，translateY scroll 動畫
   ├── Hero Section
   ├── Section 01 Content
   └── (後續 sections...)
4. Callout Cards    — 兩側浮動字卡（left:40 / right:40）
```

**已移除的元素（舊版遺留，請勿重新加入）**：
- 浮動粒子（Particle）
- 程式碼字元漂移（CodeChar）
- 角落 L 型框線（CornerLines）
- 開場掃描線（ScanSweep）
- 中央 GlowRing
- Glitch 亂碼特效

---

## HTML 元素對應（Opening.tsx 元件）

每個 HTML class 都有對應的 React 元件，樣式要精確 match：

### ProgressBar → `.progress-bar-wrap`
```tsx
// 完整 match HTML .progress-bar-wrap
background: "rgba(0,0,0,0.92)", backdropFilter: "blur(12px)"
borderBottom: "1px solid rgba(124,255,178,0.14)"
padding: "14px 40px"
// 內部：logo + "AI 寫程式入門課程" | "章節 0-1 / 4"
// 下方：3px 進度軌道，8% 填充，#7cffb2 with glow
```

### HeroSection → `.hero`
```tsx
// 對應 HTML .hero
padding: "56px 0 44px"
borderBottom: "1px solid rgba(124,255,178,0.14)"
marginBottom: 52

// hero-meta 行：CH 0-1 badge + 完全零基礎 tag + 約10分鐘 tag
// chapter-badge：Space Mono, 13px, border: 1px solid #7cffb2, borderRadius 99
// tag-beginner：rgba(124,255,178,0.1) bg, #7cffb2 color
// tag-time：rgba(255,209,102,0.1) bg, #ffd166 color

// h1：Noto Sans TC, 54px, fontWeight 900, lineHeight 1.25, letterSpacing -0.02em
// hero-sub：Noto Sans TC, 19px, #888888, lineHeight 1.75
```

### SectionHeader → `.section-header`
```tsx
display: "flex", alignItems: "center", gap: 16
// section-num badge：Space Mono 13px, rgba(124,255,178,0.08) bg, border 1px, borderRadius 99
// h2：Noto Sans TC 24px, fontWeight 700, letterSpacing -0.01em
```

### Card → `.card`
```tsx
background: "#0d0d0d"
border: "1px solid rgba(124,255,178,0.14)"
borderRadius: 16
padding: "28px 32px"
// p：Noto Sans TC 17px, #888888, lineHeight 1.8
// strong：color #ffffff
// highlight span：color #7cffb2, fontWeight 700
```

### AnalogyBox → `.analogy`
```tsx
background: "rgba(124, 255, 178, 0.07)"
borderLeft: "4px solid #7cffb2"
borderRadius: "0 16px 16px 0"
padding: "24px 28px"
// label：Space Mono 12px, #7cffb2, uppercase, letterSpacing 0.08em
// p：Noto Sans TC 16px, #c8ffe0, lineHeight 1.75
// strong：color #ffffff
```

---

## 頁面 Scroll 動畫

影片用 `translateY` 模擬頁面往上捲動，根據音頻進度決定 scroll 時機：

```tsx
// Hero section 高度估計 ≈ 440px（含 padding、兩行標題、描述、border）
// scroll 420px 會讓 Section 01 進入視野

const scrollY = interpolate(frame, [600, 700], [0, 420], clamp);

// Content container
<div style={{ overflow: "hidden", ... }}>
  <div style={{ transform: `translateY(-${scrollY}px)` }}>
    <HeroSection />
    <Section01 />
    {/* 更多 sections... */}
  </div>
</div>
```

**Scroll 時機原則**：
- 當講者開始討論下一個 section 的內容時，開始 scroll
- Scroll 動畫持續 ~100 frames（約 3.3 秒），讓觀眾跟得上

---

## useFadeUp Hook（HTML fadeUp 動畫對應）

取代 `useMorphIn`，更直接對應 HTML 的 `animation: fadeUp 0.6s ease both`：

```tsx
function useFadeUp(startFrame: number) {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();
  const f = Math.max(0, frame - startFrame);
  const progress = spring({ frame: f, fps, config: { damping: 22, stiffness: 90 } });
  const opacity = interpolate(f, [0, 18], [0, 1], clamp);
  const y = interpolate(progress, [0, 1], [24, 0], clamp);
  return { opacity, transform: `translateY(${y}px)` };
}

// 使用方式：
const meta  = useFadeUp(28);  // frame 28 開始出現
const title = useFadeUp(50);
const sub   = useFadeUp(75);

<div style={{ ...meta }}>...</div>       // 直接 spread 到 style
<div style={{ color: "red", ...title }}>  // 與其他 style 合併
```

**useFadeUp vs useMorphIn**：
- `useFadeUp`：用於 HTML 頁面元素（hero、card、section header），模擬頁面載入感
- `useMorphIn`：保留在 hooks.ts，可用於更需要「溶入感」的特殊場合（blur + scale）

---

## 字卡（Callout Cards）

### 設計規格

```tsx
// Glass card 樣式
background: "rgba(0,0,0,0.82)"
backdropFilter: "blur(20px)"
border: "1px solid rgba(124,255,178,0.22)"
borderLeft / borderRight: "3px solid #7cffb2"  // 依出現在左/右側決定
borderRadius: 14
padding: "18px 24px"
maxWidth: 280

// Label（category）
fontFamily: "'Space Mono', monospace"
fontSize: 12
color: "#7cffb2"
textTransform: "uppercase"
letterSpacing: "0.07em"

// 前置 accent dot（取代 emoji）
width: 6, height: 6, background: "#7cffb2"
borderRadius: 1  // 6px 方塊
boxShadow: "0 0 6px #7cffb2"  // 呼吸 glow

// 主文字
fontFamily: "'Noto Sans TC', sans-serif"
fontSize: 26
fontWeight: 700
color: "#ffffff"
lineHeight: 1.4
whiteSpace: "pre-wrap"
minHeight: "2.8em"  // 防止 typewriter 造成版面跳動
```

### 出現動畫（三合一）

```tsx
// 1. Slide in from side + spring
const progress = spring({ frame: localF, fps, config: { damping: 18, stiffness: 110 } });
const slideX = interpolate(progress, [0, 1], [side === "right" ? 240 : -240, 0], clamp);

// 2. Typewriter 主文字（1.2 字/幀，card 滑入後 10f 開始）
const CHARS_PER_FRAME = 1.2;
const charsVisible = interpolate(Math.max(0, localF - 10),
  [0, text.length / CHARS_PER_FRAME], [0, text.length], clamp);
const displayText = text.slice(0, Math.floor(charsVisible));
// 游標：`localF % 16 < 8 ? 1 : 0`（8f on / 8f off 閃爍）

// 3. Label underline draw（frames 4-26）
const underlineW = interpolate(localF, [4, 26], [0, 100], clamp);

// 4. Accent dot pulse（Math.sin 驅動）
const dotPulse = interpolate(Math.sin((localF / 32) * Math.PI * 2), [-1, 1], [0.5, 2.0], clamp);

// 5. Fade in/out
const opacity = interpolate(localF, [0, 16, duration - 16, duration], [0, 1, 1, 0], clamp);
```

### 位置規則（新版）

```
content column：860px，left = 530px，right = 1390px
left callouts：left: 40px，maxWidth: 280px（最寬到 320px，不超過 530px）
right callouts：right: 40px，maxWidth: 280px（從右邊算起）
```

- 左右交替，**絕不同時顯示兩張**
- 垂直位置 `yPct` 在 0.15-0.60 之間

---

## 音頻同步工作流程

### Step 1 — 轉錄音檔為 VTT（精確時間戳）

```bash
/Users/jamesshih/Library/Python/3.9/bin/whisper "$AUDIO_PATH" \
  --language zh \
  --model small \
  --output_format vtt \
  --output_dir "$OUTPUT_DIR"
```

> **永遠使用 VTT，不估算秒數**。估算誤差可達 1-2 秒，字卡會跟台詞對不上。

### Step 1.5 — VTT 校正（對照逐字稿）

**Whisper 轉錄必須與逐字稿比對後才能使用**。

| 差異類型 | 說明 | 處理方式 |
|---------|------|---------|
| 口語加詞 | 講者即興補充（如「其實」「當中」「就」「那」） | 保留 VTT（反映實際說話內容） |
| 口語變體 | 同義不同詞（如「離我很遠」→「離自己很遙遠」） | 保留 VTT |
| 辨識錯誤 | 專有名詞、英文詞辨識失敗 | **修正 VTT** |
| 標點差異 | 逗號、句號、引號不同 | 視需要調整 |

**最常見錯誤**：英文詞、品牌名、課程專有術語。
例：`Vycoding` → `Vibe Coding`（已於 0-1_1.1.vtt 修正）

### Step 2 — VTT → 幀號

```
frame = Math.round(seconds × fps)   // fps = 30
```

### Step 3 — 建立 CALLOUTS 陣列

```ts
const CALLOUTS: Callout[] = [
  {
    from: 133, to: 300,       // VTT 精確幀號
    label: "很多人的感受",    // 純文字，無 emoji
    text: "「寫程式」\n感覺離我很遠",
    side: "left", yPct: 0.28,
  },
  // ...
];
```

**字卡出現時機原則：**
- 字卡在對應台詞開始說的那一幀出現
- 持續到下一張字卡出現前（留 2 幀緩衝）
- 每張字卡至少顯示 90 幀（3 秒）以上

---

## 每段音頻對應的頁面內容

關鍵原則：**依照音頻討論的內容，決定當下畫面顯示 HTML 的哪個區塊**

| 音頻在講的內容 | 應顯示 HTML 的哪裡 |
|--------------|-----------------|
| 章節開場介紹 | Hero Section |
| 寫程式是什麼（自動化概念） | Section 01 Card 1 |
| 生活比喻（文件排序助手） | Section 01 Analogy |
| 廣義 vs 狹義程式 | Section 01 Card 2 |
| 非工程師能做什麼 | Section 02 |
| 具體使用情境 | Section 02 Usecase Grid |
| AI Coding 定義 | Section 03 Card |
| Vibe Coding 定義 | Section 03 Analogy |
| Vibe vs AI Coding 比較 | Section 04 Compare Table |
| 建議學習路徑 | Section 04 Path Steps |
| 章節重點整理 | Takeaway |

---

## 素材對應表（CH 0-1）

| 音檔 | 講稿章節 | HTML 區塊 | VTT |
|------|---------|----------|-----|
| `0-1_1.1.wav` | 一、開場白 | Hero | ✅ 已校正（Vycoding→Vibe Coding）|
| `0-1_2.1.wav` | 二、自動化概念 | Section 01 Card 1 | 待生成 |
| `0-1_2.2.wav` | 二、生活比喻 | Section 01 Analogy | 待生成 |
| `0-1_2.3.wav` | 二、廣義vs狹義 | Section 01 Card 2 | 待生成 |
| `0-1_3.0.wav` | 三、非工程師前言 | Section 02 Card | 待生成 |
| `0-1_3.1.wav` | 三、具體場景 | Section 02 Usecase | 待生成 |
| `0-1_3.2.wav` | 三、生活樂趣 | Section 02 Card + Quiz | 待生成 |
| `0-1_4.1.wav` | 四、AI Coding 定義 | Section 03 Card | 待生成 |
| `0-1_4.2.wav` | 四、Vibe Coding 定義 | Section 03 Card | 待生成 |
| `0-1_4.3.wav` | 四、實際感覺 | Section 03 Analogy | 待生成 |
| `0-1_5.1.wav` | 五、Vibe 特性 | Section 04 Compare | 待生成 |
| `0-1_5.2.wav` | 五、AI Coding 特性 | Section 04 Compare | 待生成 |
| `0-1_5.3.wav` | 五、學習路徑 | Section 04 Path + Quiz | 待生成 |
| `0-1_6.1.wav` | 六、收尾 | Takeaway | 待生成 |

---

## 完整影片製作流程

```
1. 確認素材
   - 音檔：{章節} 音檔/*.wav
   - 簡報：(N){章節}.html  ← 這是視覺的唯一基準
   - 講稿：逐字講稿.docx

2. 批次轉錄 VTT
   for each .wav → whisper --output_format vtt

3. VTT 校正（與逐字稿比對）

4. 複製音檔到 Remotion public/audio/

5. 解析 VTT → 建立每段音檔的 durationInFrames
   durationInFrames = Math.ceil(audioDurationSec * 30) + 10

6. 建立對應每段音頻的 Scene 元件
   - 直接對應 HTML 的視覺元素（ProgressBar, HeroSection, Card, AnalogyBox...）
   - useFadeUp 控制每個元素的入場時機
   - Callout Cards 依 VTT 時間戳疊加在兩側
   - 用 translateY scroll 動畫串接不同 section

7. 串接 Root.tsx → 完整影片

8. npx remotion render → 輸出到 ~/Downloads/Vibe Coding 剪輯/
```

---

## Spring 標準設定

| 用途 | damping | stiffness | 說明 |
|------|---------|-----------|------|
| 字卡滑入 | 18 | 110 | 快速有力 |
| useFadeUp (頁面元素) | 22 | 90 | 模擬 CSS ease |
| 品牌片頭 Logo 入場 | 18 | 60 | 慢速 cinematic |

---

## 常見錯誤

| 錯誤 | 原因 | 解法 |
|------|------|------|
| 影片看起來跟 HTML 完全不一樣 | 做成電影片頭風格，而非課程頁面 | 畫面元素必須 1:1 對應 HTML |
| 字卡跟台詞對不上 | 用估算秒數 | 改用 Whisper VTT |
| 字卡遮住主內容 | 字卡出現在 content column 內 | 字卡限制在 left:40/right:40，column 外側 |
| Section 01 出現太早/太晚 | scroll 時機不對 | 依 VTT 確認講者在說哪個 section 的內容 |
| `Math.random()` 讓畫面閃爍 | Remotion 要求純函數渲染 | 改用 `random("seed")` from remotion |
| 兩張字卡同時出現 | from/to 設定重疊 | 確保 cards[i].to < cards[i+1].from |
