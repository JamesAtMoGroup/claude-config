# Course Video Production Skill

課程影片剪輯工作流程，使用 Remotion 將講者音檔 + HTML 簡報 + 逐字稿整合成完整課程影片。

**觸發詞**：「剪課程影片」、「製作影片」、「remotion 課程」、`/course-video`

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
素材來源：~/Projects/vibe-coding-video/chapters/{章節}/
  ├── audio/                    ← 講者錄音 .wav + .vtt（命名：章節_小節.wav，如 0-1_1.1.wav）
  ├── {章節} 影片製作相關素材/   ← 插入用圖片 / 影片（逐字稿 **備注** 引用的檔案）
  ├── (N){章節}.html             ← 對應的簡報畫面（影片視覺的基準）
  └── 逐字講稿.docx              ← 完整講稿；**備注** 標記插入點與素材檔名

Remotion 專案：~/Projects/vibe-coding-video/
  ├── chapters/        ← 所有章節素材（0-1, 0-2, 0-3, 1-1, 1-2...）
  ├── src/
  │   ├── Root.tsx
  │   ├── FullVideo.tsx   ← CH0-1
  │   ├── FullVideo02.tsx ← CH0-2
  │   └── hooks.ts
  └── public/
      ├── audio/       ← 音檔（pipeline 後從 chapters/{章節}/audio/ 複製進來）
      └── aischool-logo.webp
```

輸出位置：`~/Projects/vibe-coding-video/out/CH{章節}/`

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

### 輸出解析度（強制）

> **所有渲染輸出必須是 4K（3840×2160）。**
> 以 1920×1080 為設計基準，所有 px 值乘以 `S = 2`。

```ts
const S = 2;                               // 4K scale factor from 1080p baseline
const W = 1920 * S;                        // 3840
const H = 1080 * S;                        // 2160
const NAV_H       = 72  * S;              // 144px — progress bar
const CONTAINER_W = 860 * S;             // 1720px — content column
const containerLeft = Math.round((W - CONTAINER_W) / 2); // = 1060px
```

Composition 設定：
```tsx
<Composition width={3840} height={2160} fps={30} />
```

### 整體結構（4K = 3840×2160，S=2 設計基準）

```
┌─────────────────────────────────────────────────────────────────┐
│  Progress Bar (144px)                                           │
│  ████████░░░░░░░░░░░░░░░░░░░░░░ (8% fill, green glow)         │
│  （無課程名稱、無章節計數）                                       │
├─────────────────────────────────────────────────────────────────┤
│               Content Column (1720px)              │[iMessage] │
│   ← centered: (3840-1720)/2 = 1060px →            │ top-right │
│   Hero / Section Cards / Analogy Boxes             │  notify   │
└─────────────────────────────────────────────────────────────────┘
```

### 畫面圖層（從底到頂）

```
1. Background orbs  — 微型徑向漸層（matching HTML body::before/::after）
                      top-right: rgba(124,255,178,0.07), 1200px
                      bottom-left: rgba(124,255,178,0.04), 1000px
2. Progress Bar     — 頂部 144px，slide-in from top
3. Content Column   — 1720px 置中欄，translateY scroll 動畫
   ├── Hero Section
   ├── Section 01 Content
   └── (後續 sections...)
4. iMessage Notifications — top-right 堆疊通知（取代舊版左右字卡）
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

## iMessage 通知系統（Motion Graphics）

> **與 article-video 完全相同的設計規格**，以 S=2 縮放。

### 設計規格（4K，S = 2）

```ts
const NOTIF_W         = 290 * S;   // 580px  卡片寬度
const NOTIF_TOP       = 12  * S;   // 24px   距 nav bar
const NOTIF_RIGHT     = 20  * S;   // 40px   距右邊
const NOTIF_SLOT      = 148 * S;   // 296px  每張通知佔用的垂直空間
const NOTIF_SLIDE_H   = 110 * S;   // 220px  從頂部滑入距離
const FADE_OUT_FRAMES = 50;        // 1.67s  結束後緩慢淡出
```

### 視覺樣式

```
background: rgba(28,28,30,0.90)
backdropFilter: blur(48px)
border: 1px solid rgba(255,255,255,0.13)
borderRadius: 14*S = 28px
boxShadow: 0 24px 120px rgba(0,0,0,0.6)

icon: 38*S=76px, borderRadius 9*S=18px
      green gradient (145deg, #3DDC6A → #25A244)
      CSS speech bubble

rows:
  1. "iMessage" 11*S=22px, opacity 0.45  +  "剛剛" right
  2. sender     13*S=26px, bold, opacity 0.92
  3. body       13*S=26px, fontWeight 800, opacity 0.60, typewriter 0.85 chars/frame
```

### 堆疊行為

```
新通知從頂部右側滑入（spring damping:22 stiffness:130）
舊通知被 spring 推下 NOTIF_SLOT（296px）
深度透明度：depth 0=100%, 1=65%, 2=35%
舊通知在 to + 50f 後淡出
最多同時顯示 2 張
全部固定在 top-right（無左右交替）
```

### Callout 資料結構

```ts
interface Callout {
  from: number;    // 開始幀
  to:   number;    // 結束幀（最少 from+90）
  sender: string;  // 寄件人（補充視角來源，非重述 slides 內容）
  text:   string;  // 訊息內文（補充觀點，無 emoji）
}
```

**字卡內容規則：**
- sender = 視角來源（如「學習提醒」「實戰提示」「觀念釐清」）
- text = 補充說明、類比、額外洞見 — **不重複 slides 已有文字**
- 最短顯示：`to - from >= 90 frames`
- 相鄰字卡重疊 20–30 幀製造堆疊感

**廢棄：** 舊版 `label / side / yPct` 系統已完全移除，不再使用。

---

## 音頻同步工作流程

### Step 0（前置）— 逐字稿轉純文字（必做，否則 agent 無法校對）

逐字講稿為 `.pages` 格式，agent 無法直接讀取。**每次開始製作新章節影片前，先由 James 手動匯出**：

Pages → 檔案 → 轉存為 → 純文字（.txt）→ 存到 `chapters/{章節}/章節{章節}_逐字講稿.txt`

或用 terminal：
```bash
textutil -convert txt "chapters/0-1/章節0-1_逐字講稿.pages" -output "chapters/0-1/章節0-1_逐字講稿.txt"
```

> **沒有 .txt 就不能開始 Transcription Agent**。沒有可讀的逐字稿，VTT 校正是空話。

---

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
    from: 133, to: 300,          // VTT 精確幀號
    sender: "學習提醒",           // 視角來源（非重述 slides 內容）
    text: "「寫程式」感覺離我很遠",  // 補充說明，無 emoji
  },
  // ...
];
```

> **廢棄**：`label / side / yPct` 欄位已完全移除。請一律使用 `sender / text`。

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

## 完整影片製作流程（強制 Multi-Agent SOP）

```
[Phase 1 — 三個 Agent 並行啟動]

  Audio Agent:
    1. 來源：chapters/{章節}/{章節} 音檔/*.wav
    2. trim silence → normalize -16 LUFS（不做降噪，James 自行處理）
    3. 輸出到 public/audio/{章節}_*.wav
    4. 回報每支音檔的 duration_sec 和 frames（Math.ceil(sec*30)+10）

  Transcription Agent:
    前提：chapters/{章節}/章節{章節}_逐字講稿.txt 必須存在（見 Step 0）
    1. Whisper 轉錄每支音檔 → VTT（--language zh）
    2. 對照 .txt 逐字稿逐行校正：
       - 繁簡轉換：opencc s2twp 全量轉換（消除簡體字）
         ⚠️  opencc 可能過度轉換，需手動還原：「消息」←非「訊息」、「類型」←非「型別」等
            原則：以逐字稿原文為準，opencc 結果與逐字稿不符時以逐字稿為準
       - 專有名詞：grep 出 Vibe Coding / AI Coding 等，確認拼寫正確
       - 聽音近似錯誤：逐字稿有「程式」→ VTT 出現「城市」；「午休」→「五修」；「乙方」→「以方」等
       - 校正後再過一遍：grep "城市|五修|以方|VibeCod|ViveCod|Vycod|Live Coding|AI Codein"
    3. 找出逐字講稿中 **備注** 標記對應的 VTT 時間點 → 決定音檔分割點
    4. 用 ffmpeg 分割有 **備注** 的音檔（如 4.3 → 4.3a/b/c）
    5. 回報所有分割時間點和新的 frames

  Visual Concept Agent:  ← 不可省略
    1. 讀逐字講稿全文
    2. 為每個段落決定：
       a. 教材 slides 動畫方式（progressive_append / scroll / row_by_row / fade）
       b. 補充視覺動畫 ← 每個段落都要主動判斷，不可留白
          逐句掃描，出現以下任一情境就必須設計對應動畫：

          【觸發情境 → 動畫類型對照表】
          ┌─────────────────────────────┬──────────────────────────────────────────────────┐
          │ 觸發情境                     │ 動畫類型                                          │
          ├─────────────────────────────┼──────────────────────────────────────────────────┤
          │ 比喻 / 類比（「就像...」）    │ SVG draw-in：繪製對應物件輪廓（依序描繪）           │
          │ 流程 / 步驟說明              │ 流程圖逐步 pop-in：每步驟獨立 spring，講者說到才出現 │
          │ 費用 / 數字 / 比例           │ Counter 動畫：數字從 0 跑到目標值                  │
          │ 兩者比較對照                 │ Left/Right reveal：兩欄從中間向外展開               │
          │ 強調關鍵詞 / 結論            │ Underline draw：關鍵字下方線條由左至右畫出           │
          │ 工具 / 概念圖示              │ Icon bounce-in：icon 彈跳出現（scale 0.6→1.1→1）   │
          │ 完成 / 確認感                │ Checkmark draw：SVG 打勾路徑動畫                   │
          │ 舉例列點（多個例子逐一說）   │ 例子逐一 slide-in from left，講者說到才出現          │
          └─────────────────────────────┴──────────────────────────────────────────────────┘

          風格規範：
          - 配色：霓虹綠 (#7CFFB2) 線條 / icon，黑底或半透明背景
          - 位置：不遮擋教材主內容，放置於空白區域（左側、右側、或內容下方）
          - 時機：對應台詞的 VTT 開始幀 + 0–5f（與講者同步，不超前）
          - 每個場景至少設計 1 個補充視覺動畫；若該段落無任何觸發情境，需在 spec 中明確標記 "visual_anim: none" 並說明原因

    3. 輸出 visual-spec-{章節}.json，格式：
       {
         "scenes": [
           {
             "scene_id": "3.1",
             "slide_anim": "progressive_append",
             "visual_anims": [
               {
                 "type": "flow_diagram_step_by_step",
                 "trigger_text": "AI 生成程式碼，你把它貼進 Apps Script",
                 "vtt_start_sec": 42.3,
                 "description": "3 步驟流程圖，每步驟獨立 pop-in",
                 "position": "below_content"
               }
             ]
           }
         ]
       }

[Phase 2 — Phase 1 全部完成後]

  Scene Dev Agent:
    1. 讀 visual-spec.json + 所有 VTT + 音頻 frames
    2. 讀 (N){章節}.html 確認視覺基準
    3. 實作所有場景（依規格，不得一次顯示全部內容）
    4. 實作補充視覺動畫
    5. 所有字卡最短 90 frames，內容不重複 slides

    ── 每實作完一個場景，必須逐項 check 以下清單，全部 ✅ 才可繼續下一場景 ──

    【Scene Dev Per-Scene Checklist】
    □ Progressive Animation
        - 場景內有幾個項目（列點 / 卡片 / 表格列）？每個項目是否有獨立 useFadeUp(startFrame)？
        - 有沒有任何兩個項目的 startFrame 相同？（不可相同）
        - 用 VTT 時間點驗證每個 startFrame，非估算值
    □ Subtitle 安全區
        - 最後一個可見項目的底部 y ≤ canvasH - SUBTITLE_H - 20px？
        - 若有 scroll 動畫：maxScroll = contentH - (canvasH - topOffset - SUBTITLE_H - 20)，是否已套用？
    □ 媒體插入（若本場景有 **備注** 素材）
        - 素材是否用 <Video> 全螢幕？width/height 均為 100%？
        - 絕對沒有 inset / 角落小視窗？
        - 插入後所有後續段落的起始幀是否已加上媒體幀數偏移？
        - EFFECTIVE_STARTS 陣列是否已更新？
    □ Callout 字卡時機
        - 每張字卡的 from 是否對照 VTT，在講者說完對應內容後 + 10–20f 緩衝？
        - 沒有任何字卡在講者還未說到該內容前出現？
        - 每張字卡 to - from ≥ 90 frames？
    □ 場景轉場
        - 教材內容是否包在 <SceneScroller> 裡？
        - BgOrbs / ProgressBar / CalloutCard 是否在 SceneScroller 外？
    □ 補充視覺動畫（強制）
        - 讀 visual-spec.json 中本場景的 visual_anims 陣列
        - 陣列內每一個動畫項目是否都已實作？
        - 若 visual_anims 為空或標記 "none"：是否有說明原因？重新確認講稿是否真的沒有比喻/流程/數字/比較等觸發情境
        - 動畫出現的 startFrame 是否對照 VTT（與講者台詞同步，不超前）？
        - 動畫位置沒有遮擋教材主內容？
    □ 視覺一致性
        - 場景內容是否對應 HTML 的對應 section？
        - 文字、標題、項目數量與 HTML 一致？

[Phase 3]

  QA Agent:
    ── 以下每項必須逐一執行並回報結果，非僅確認檔案存在 ──

    【QA Checklist — 全部 ✅ 才可通知 James】

    □ 字幕安全區（逐場景）
        對每個場景，讀 TSX 計算最後一個項目的底部 y 值
        → 驗證 ≤ canvasH - SUBTITLE_H - 20px
        → 有 scroll 的場景：maxScroll 計算值是否正確
    □ Progressive Animation（逐場景）
        讀 TSX，找出每個含多項目的場景
        → 每個項目是否有獨立且不同的 useFadeUp startFrame？
        → 有無項目 startFrame 為 0 或相同值（代表同時出現）？
    □ 媒體插入（若有）
        讀 TSX 找 <Video> / <Img> 媒體場景
        → <Video> 是否全螢幕（style width/height 100%）？
        → 有無 position absolute / inset 的小視窗用法？
        → EFFECTIVE_STARTS 偏移是否正確（後續段落都加了 MP4 幀數）？
    □ Callout 字卡時機
        對每張字卡的 from，對照對應 VTT segment 的時間戳
        → from 是否 ≥ 對應台詞結束幀 + 10f？
        → to - from 是否 ≥ 90？
    □ 字卡內容
        → 字卡文字不重複 slides 已有的標題/項目文字
        → 用詞對照逐字講稿（「單元」非「章節」等）
    □ VTT 專有名詞
        grep 所有 segment VTT：
        → 不得出現：Vycoding / VibeCoding / ViveCoding / Live Coding / AI Codein / AICoding
        → 不得出現：城市碼 / 聊天室的AI / Appsgreed / AppsGrid / 以方 / 越越浴室
        → 發現 → 直接修正 → 記錄
    □ 補充視覺動畫（逐場景，最重要之一）
        讀 visual-spec.json 的每個場景 visual_anims 陣列
        → 每個 visual_anim 項目是否在 TSX 中有對應實作？（逐一比對，不可有缺）
        → 標記 "none" 的場景：講稿中確認沒有比喻/流程/數字/比較觸發詞？
        → 動畫 startFrame 是否對照 VTT（與台詞同步，不超前）？
        → 動畫位置沒有遮擋教材主內容？
        → 至少回報：共有幾個動畫、哪幾個場景有、哪幾個場景標記 none
    □ 視覺一致性（場景 vs HTML）
        → TSX slides 內容與 (N){章節}.html 對應 section 一致

    → 回報每項 ✅/❌ + 問題清單 → iMessage + 對話通知 James

[Phase 4 — James 通過後]
  Render Agent:
    1. 渲染 out/CH{章節}-{章節標題}/CH{章節}-{章節標題}-complete.mp4（--gl=angle --codec=h264 --overwrite）
       輸出目錄命名格式：out/CH{章節}-{章節中文標題}/（如 out/CH0-1-AI 寫程式、Vibe Coding 是什麼/）
    2. 合併所有段落 VTT → out/CH{章節}-{章節標題}/CH{章節}-{章節標題}-subtitles.vtt
       - 用 merge_vtt.py（或同等腳本），依各段落 frame start ÷ 30 = offset 秒數
       - 4.3 等被分割音檔需特別處理：依 4.3a/b/c 的 frame start 分區映射時間戳
       - 邊界處理：clipping + boundary condition 必須用 `<= B2`（非 `< B2`），否則邊界幀映射到錯誤區段
       - 輸出排序後的全局時間軸（00:00:00.000 → 結尾）
    3. 合併完成後必須執行驗證：
       ```python
       # 檢查 MP4 insert 期間有無字幕（必須為零）
       MP4_INSERTS = [(551.000, 606.900), (643.000, 670.100)]  # ← 依章節更新
       # 檢查關鍵詞彙
       assert "Vibe Coding" in content
       assert "Vycoding" not in content
       # 所有修正過的詞彙都要驗證
       ```
    4. 完成後回報：mp4 檔案大小、VTT cue 總數、最後一條 cue 時間戳、驗證結果

  Scene Dev Agent（render 同時可並行）:
    1. 對照本次修改過的所有場景，將 TSX 中 slides 內容同步回 (N){章節}.html
       - 廣義/狹義 拆卡、leisure ideas 改 3 卡、移除 quiz 等每次改動都要同步
    2. 將更新後的 HTML 複製到輸出目錄：
       cp chapters/{章節}/(N){章節}.html out/CH{章節}/CH{章節}.html
    3. 回報同步了哪些 HTML section

[交付標準 — 三件全齊才算完成]
  ✓ out/CH{章節}-{章節標題}/CH{章節}-{章節標題}-complete.mp4
  ✓ out/CH{章節}-{章節標題}/CH{章節}-{章節標題}-subtitles.vtt（全局時間軸，驗證無 MP4 insert 字幕）
  ✓ out/CH{章節}-{章節標題}/（N）{章節}.html（與 TSX slides 一致）
  ✓ chapters/{章節}/(N){章節}.html（原始來源，同步更新）
```

---

## ⚠️ 媒體插入規則（逐字稿 **備注**）— Scene Dev 必讀

逐字稿中 `**備注**：使用相關素材 {檔名}（片長 N 秒）` 代表在**該句台詞結束後立刻**插入媒體（不是等整段結束）。
Transcription Agent 負責找到對應 VTT 時間點，並分割音檔。

```
素材位置：chapters/{章節}/{章節} 影片製作相關素材/{檔名}
```

| 類型 | 顯示時長 | 旁白音頻 | 背景音樂 |
|------|---------|---------|---------|
| 圖片（.png/.jpg） | 固定 3 秒（90 幀） | 暫停 | 繼續 |
| 影片（.mp4/.mov） | 逐字稿提供的片長 | 暫停 | 繼續 |

**Remotion 實作**：
- 插入點 = 對應音頻 Sequence 結束後的下一幀
- 媒體 Sequence：無 `<Audio>` 旁白，BGM 由外層 loop 持續播放
- 圖片用 `<Img>` + 淡入淡出（0→1 前 15 幀，1→0 後 15 幀）
- **影片用 `<Video>` 全螢幕覆蓋整個畫面（width:100%, height:100%），絕對不可做成角落 inset 或小視窗**
- `durationInFrames = Math.ceil(秒數 * 30)`
- 插入後的音頻 Sequence 起始幀需加上媒體佔用的幀數
- 全域 `EFFECTIVE_STARTS` 陣列必須在插入點之後的所有段落加上媒體幀數偏移

---

## Spring 標準設定

| 用途 | damping | stiffness | 說明 |
|------|---------|-----------|------|
| 字卡滑入 | 18 | 110 | 快速有力 |
| useFadeUp (頁面元素) | 22 | 90 | 模擬 CSS ease |
| 品牌片頭 Logo 入場 | 18 | 60 | 慢速 cinematic |

---

## Scene Dev 強制規則

### 版面（最重要）
- 內容永遠不可被 SUBTITLE_H 擋住
- 超過一頁的內容必須用 `translateY` scroll 動畫（模擬人類向上滑動）
- Scroll 時機依 VTT 確認
- **Scroll 上限**：scroll 動畫的最終 translateY 值必須保留底部安全距離，確保最後一個項目底部 ≤ `canvasH - SUBTITLE_H - 20px`。計算方式：`maxScroll = contentH - (canvasH - topOffset - SUBTITLE_H - 20)`

### Progressive Animation（強制）
- 同一場景有多個項目（列點、卡片、表格列）→ 必須依旁白順序逐一出現
- **絕不可一次全部顯示——這是最常見的錯誤，必須主動檢查每個 list/table**
- 每個項目必須有獨立的 `useFadeUp(startFrame)` hook，startFrame 各不相同
- **教材 slide 內容**（card、analogy box、列點、表格列）→ 講者**正在說**對應內容時跳出來，讓觀眾對應視覺
- **iMessage 字卡（Callout）** → 講者說完相關內容**之後**出現，作為觀眾反應/補充視角
- 每個項目的 startFrame 必須對照 VTT，不可估算
- Scene Dev 實作完成後，必須自我審查：「這個場景有沒有任何 list/table 是同時出現的？」如有，立刻修正

### 場景轉場（必須）
- 每個場景的教材內容（card、table、analogy 等）必須包在 `<SceneScroller>` 裡
- `SceneScroller` 使用 `useSceneTransition()` hook，自動加上 scroll-up 進場（700px from below）和出場（700px upward）
- BgOrbs、ProgressBar、CalloutCard **不放在 SceneScroller 內**（它們固定不動）
- 有 SVG 補充動畫的場景，SVG 也放在 `<SceneScroller>` 裡一起滾
- SceneMediaInsert（MP4 全屏插入）不需要 SceneScroller

### 字卡（Callout）規則
- 最短顯示時長：**90 frames（3秒）**，低於此值一律延長
- 字卡不重複 slides 上已有的文字
- 字卡用途：補充視角、額外說明、類比
- 字卡 `from` = VTT 中對應台詞說完後 + 10–20f 緩衝（不早於台詞結束幀）
- 用詞必須對照逐字講稿（如「單元」非「章節」）

### 補充視覺動畫（強制）
- 依 visual-spec.json 逐一實作，每個 `visual_anims` 項目都必須實作，不可跳過
- 不修改教材主內容，僅在指定位置新增
- 每種動畫類型的標準實作：

  **SVG draw-in（類比 / 物件輪廓）**
  ```tsx
  const drawProgress = interpolate(frame, [startF, startF + 45], [0, 1], clamp);
  <svg><path strokeDasharray="200" strokeDashoffset={200 * (1 - drawProgress)} .../></svg>
  ```

  **流程圖逐步 pop-in**
  ```tsx
  // 每個 step 獨立 useFadeUp，startFrame 對照 VTT 逐步出現
  const step1 = useFadeUp(vttFrame_step1);
  const step2 = useFadeUp(vttFrame_step2);
  const step3 = useFadeUp(vttFrame_step3);
  ```

  **Counter 動畫（數字）**
  ```tsx
  const count = Math.floor(interpolate(frame, [startF, startF + 60], [0, targetValue], clamp));
  ```

  **Underline draw（關鍵詞強調）**
  ```tsx
  const lineW = interpolate(frame, [startF, startF + 30], [0, 100], clamp);
  <div style={{ borderBottom: `3px solid ${C.primary}`, width: `${lineW}%` }} />
  ```

  **Icon bounce-in**
  ```tsx
  const s = spring({ frame: f, fps, config: { damping: 12, stiffness: 200 } });
  const scale = interpolate(s, [0, 1], [0.6, 1], clamp);
  ```

  **Checkmark draw**
  ```tsx
  // SVG polyline 24,12 12,24 0,16，stroke-dashoffset 動畫
  ```

  **Slide-in from left（例子列點）**
  ```tsx
  const x = interpolate(progress, [0, 1], [-60, 0], clamp);
  // 每個例子獨立 startFrame，對照 VTT
  ```

## 常見錯誤

| 錯誤 | 原因 | 解法 |
|------|------|------|
| 影片看起來跟 HTML 完全不一樣 | 做成電影片頭風格，而非課程頁面 | 畫面元素必須 1:1 對應 HTML |
| 字卡跟台詞對不上 | 用估算秒數 | 改用 Whisper VTT |
| 字卡遮住主內容 | 字卡出現在 content column 內 | 字卡限制在 left:40/right:40，column 外側 |
| 多個項目同時出現 | 沒有 progressive animation | 每個項目依 VTT 時間點逐一出現 |
| 字卡不到 3 秒消失 | from/to 差距 < 90 | 強制最小 90 frames |
| 字卡重複 slides 內容 | 把字卡當作重述工具 | 字卡只寫補充視角 |
| 素材在整段結束後才插入 | 插入點錯誤 | 依 VTT 時間點分割音檔，即時插入 |
| `Math.random()` 讓畫面閃爍 | Remotion 要求純函數渲染 | 改用 `random("seed")` from remotion |
| 兩張字卡同時出現 | from/to 設定重疊 | 確保 cards[i].to < cards[i+1].from |
| 字卡比講者早出現 | from 設在內容被提到的瞬間，但 typewriter 還在打 | from 設在講者說完該詞後（+10–20f 緩衝），不可早於講者說出關鍵字的那一幀 |
| 畫面比講者落後 | Scene 切換 startFrame 用估算值 | 依 VTT 對應段落的開始幀設定場景切換，不可估算 |

---

## Render 通過後 — 三包輸出（誰最適合誰負責）

| 輸出項目 | 負責 Agent | 內容 |
|----------|-----------|------|
| `.mp4` | Render Agent | 渲染影片 |
| `.vtt` | Render Agent | 合併所有段落 VTT，含分割音檔的時間映射 |
| `.html` | Scene Dev Agent | 將 TSX slides 改動同步回 HTML |

**Scene Dev Agent — HTML 同步範圍**（James 通過後立即執行）：
- 文字修改（用詞統一、錯字修正）
- 排版優化（字型大小、間距、顏色調整）
- 移除溢出內容（為解決 SUBTITLE_H overflow 而刪除或拆分的區塊）
- 拆分場景（原本一個 HTML section 被拆成多個 TSX 場景，如廣義/狹義拆卡）
- 移除在 TSX 中刪掉的元素（如 quiz-box 移除後 HTML 也要移除）

**HTML 設計系統必須與 TSX `C` constants 完全一致**（每次建新章節 HTML 都要對照）：
```css
--bg: #000000          /* C.bg */
--surface: #0d0d0d     /* C.surface */
--surface2: #111111    /* C.surface2 */
--primary: #7cffb2     /* C.primary — 綠色，不是紫色 */
--primary-light: rgba(124,255,178,0.07)
--text: #ffffff
--text-muted: #888888  /* C.muted */
--border: rgba(124,255,178,0.14)
--radius: 22px
```
- Progress bar：只顯示進度條本身，不顯示課程名稱或章節計數（如「AI 寫程式入門課程」「章節 0-1 / 4」）
- AnalogyBox label：Space Mono + dot span（`<span class="label-dot"></span>`）+ 文字，不用 emoji
- Takeaway counter dot：`color: #000000`（黑字在綠底上）

**目的**：HTML 是課程平台最終版本。影片與 HTML 必須保持一致，學生在平台看到的頁面要和影片裡的 slides 相同。
