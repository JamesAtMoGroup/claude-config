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
| **Integration & Render Agent** | 組裝 Root.tsx、執行 render、輸出 MP4 + VTT |

小任務可合併 Agent，但 **Director 必須獨立存在**。

### Script-first 原則（強制）

> **能用腳本完成的事，絕對不讓 Agent 即興執行。**

| 任務 | 腳本 | 順序 |
|------|------|------|
| 背景噪音消除 | `0a_denoise.sh` | ① 必須最先 |
| 前後靜音裁切 | `0b_trim_silence.sh` | ② |
| 音量正規化 | `0_normalize_audio.sh` | ③ |
| Whisper 轉錄 | `1_transcribe.sh <chapter>` | ④ |
| 品牌名修正 | `2_correct_vtts.sh <chapter>` | ⑤ |
| 幀數計算 | `3_calc_frames.sh <chapter>` | ⑥ |
| Remotion render | `4_render.sh <composition> <chapter>` | ⑦ 最後 |
| VTT 合併 | `6_merge_vtt.sh` | ⑧ render 完後立即執行 |
| HTML 講義同步 | 比對 TSX 更新 HTML，複製到 `out/CH{chapter}/` | ⑨ VTT 合併後 |

**重要**：每次有新音檔，必須依序跑完 ①②③ 再 render。

---

## 輸出規格（強制）

每個章節的完成檔案必須放在 `out/CH{chapter}/` 資料夾下，包含：

```
out/
  CH{chapter}/
    CH{chapter}-complete.mp4   — 完整影片
    CH{chapter}-subtitles.vtt  — 合併完整字幕
    ch{chapter}.html           — 同步更新的 HTML 講義
```

- `4_render.sh` 輸出路徑：`out/CH{chapter}/CH{chapter}-complete.mp4`
- `6_merge_vtt.sh` 同步產生：`out/CH{chapter}/CH{chapter}-subtitles.vtt`
- VTT 以每個 segment 的累計幀數（÷30 = 秒數）為 offset 合併，時間戳格式為 `HH:MM:SS.mmm`

### HTML 講義同步規則（強制）

> **影片 render 完成後，必須同步更新 HTML 講義，並將更新後的 HTML 存入輸出資料夾。**

步驟：
1. 讀取來源 HTML（`~/Downloads/{chapter}/(N)ch{chapter}.html`）
2. 比對 TSX 場景的最終文字內容 vs HTML 中對應的段落
3. 更新差異部分（文字精簡、句子刪除等在製作過程中的調整）
4. 複製更新後的 HTML 到 `out/CH{chapter}/ch{chapter}.html`

注意：
- HTML 保留 web 排版樣式（字型大小、CSS）不需改成影片的大尺寸
- HTML 的 emoji 可以保留（僅影片不可用 emoji）
- 只更新**文字內容**，不動 HTML 結構與樣式

---

## 音訊標準（強制）

### 音訊處理管線

```bash
# ① 降噪（highpass + afftdn + lowpass）
ffmpeg -af "highpass=f=80,afftdn=nf=-25,lowpass=f=12000"

# ② 裁切前後靜音（silencedetect + atrim，不刪內部停頓）
silencedetect=noise=-45dB:d=0.3 → atrim

# ③ 音量正規化 EBU R128
ffmpeg -af "loudnorm=I=-16:LRA=11:TP=-1.5"
```

### Remotion 音量設定

| 音源 | 設定 |
|------|------|
| 講者音檔（正規化後） | `volume={1.0}` |
| 背景音樂 | `volume={0.10} loop` |

- 背景音樂全程循環（`loop` prop）
- 跳過清單：`course_background_music.wav`、`intro-stinger.wav`

---

## 畫面規格（1920×1080，30fps）

### 佈局常數

```tsx
const NAV_H       = 72;    // Progress Bar 高度
const CONTAINER_W = 1500;  // 內容欄寬度（手機友善）
const SUBTITLE_H  = 160;   // 底部字幕保留空間（不放內容）
// 內容欄水平置中：left = Math.round((1920 - 1500) / 2) = 210px
// 內容區垂直：top: NAV_H, bottom: SUBTITLE_H
```

### 字體大小標準（手機可讀，最低標準）

| 元素 | 字體大小 | 備註 |
|------|---------|------|
| Hero 主標題 | 88px | |
| Hero 副標題 / Card 內文 | 36px | |
| Hero meta badge | 20px | |
| Section Header h2 | 52px | |
| Section Number badge | 22px | |
| AnalogyBox 內文 | 34px | |
| AnalogyBox 標籤 | 18px | Space Mono |
| 三欄 Grid 標題 | 30px | |
| 三欄 Grid 說明 | 24px | |
| Takeaway 條目 | 36px | |
| 比較表格 header | 28px | |
| 比較表格 label 欄 | 26px fontWeight 700 | |
| 比較表格 內容欄 | 26px | |
| 學習路徑 step 標題 | 28px | |
| 學習路徑 step 說明 | 24px | |
| 學習路徑 step 號碼圓圈 | 48×48px, 18px | Space Mono |
| Quiz 「想一想」label | 18px | Space Mono uppercase |
| Quiz 主文 | 26px | |
| Quiz 條列項目 | 24px | |
| Nav bar 章節文字 | 16px | Space Mono |

> **原則**：任何直接展示給學員的內容，最小字體不得低於 24px。UI chrome（nav bar、標籤）最小 16px。

### 色彩系統

```ts
const C = {
  bg:           "#000000",
  surface:      "#0d0d0d",
  surface2:     "#111111",
  primaryLight: "rgba(124, 255, 178, 0.07)",
  primary:      "#7cffb2",
  text:         "#ffffff",
  muted:        "#888888",
  yellow:       "#ffd166",
  border:       "rgba(124,255,178,0.14)",
};
```

### 字型

| 用途 | 字型 |
|------|------|
| 標題 / 正文（繁中） | `Noto Sans TC`, `PingFang TC` |
| 標籤 / 代碼 / 章節號 | `Space Mono` |

### 嚴格禁止
- **禁用 emoji** — 用 CSS 6px 方塊 + `#7cffb2` glow，或純文字標籤，或 `✦`
- **禁用 `\n` 在字卡文字** — 改用 `，`、`：`、`、` 等標點

---

## 元件規格

### useFadeUp（頁面元素入場）

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
```

**VTT 同步原則**：每個內容區塊的 `startFrame` 必須來自 VTT 時間戳 × 30，不得估算。
- Section Header：固定 frame 15（早出現介紹主題）
- 後續每個 Card / AnalogyBox：= VTT 講者提到該主題的秒數 × 30

### useFocusHighlight（焦點提示）

```tsx
function useFocusHighlight(startFrame: number, duration = 75) {
  const frame = useCurrentFrame();
  const f = frame - startFrame;
  if (f < 0 || f > duration) return {};
  const intensity = interpolate(f, [0, duration], [1, 0], clamp);
  return {
    boxShadow: `0 0 ${Math.round(intensity * 24)}px rgba(124,255,178,${(intensity * 0.55).toFixed(2)})`,
    borderColor: `rgba(124,255,178,${(0.14 + intensity * 0.5).toFixed(2)})`,
  };
}
// 用法：與 useFadeUp 使用同一個 startFrame，傳入 Card/AnalogyBox 的 highlightStyle prop
```

### Card 元件

```tsx
<Card fadeStyle={card} highlightStyle={cardHL}>
  內文...
</Card>
// padding: "36px 44px", borderRadius: 22, fontSize: 36
```

### AnalogyBox 元件

```tsx
<AnalogyBox label="一句話理解" fadeStyle={analogy} highlightStyle={analogyHL}>
  內文...
</AnalogyBox>
// padding: "32px 38px", borderRadius: "0 16px 16px 0", label: 18px, body: 34px
```

### 比較表格（CompareTable）

```tsx
// borderRadius: 22, overflow: hidden
// th: padding "22px 28px", fontSize 28
// td label: padding "20px 28px", fontSize 26, fontWeight 700
// td content: padding "20px 28px", fontSize 26
```

### 學習路徑 Steps

```tsx
// 步驟號碼圓圈：width/height 48, borderRadius "50%", fontSize 18, Space Mono
// 步驟標題：fontSize 28, fontWeight 700
// 步驟說明：fontSize 24
```

### Quiz Box

```tsx
// "想一想" label：Space Mono, fontSize 18, uppercase, color C.yellow
// 主文：fontSize 26, lineHeight 1.7
// 條列項目：fontSize 24
```

---

## iMessage 字卡規格（S=2 for 1080p）

### 常數

```tsx
const S             = 2;
const NOTIF_W       = 290 * S;   // 580px 固定寬度
const NOTIF_TOP     = 12  * S;   // 24px below nav
const NOTIF_RIGHT   = 20  * S;   // 40px from right
const NOTIF_SLIDE_H = 110 * S;   // 220px 從上方往下滑入
const NOTIF_SLOT_H  = 100 * S;   // 200px per slot（含 gap）
const FADE_OUT_F    = 50;        // 1.67s 淡出
```

### 字體大小

| 元素 | 大小 |
|------|------|
| 「訊息」app 標籤 | 18px |
| 「剛剛」時間戳 | 15px |
| 寄件者名稱 / label | 22px, fontWeight 700 |
| 訊息內文 | 34px, fontWeight 800 |

### 入場動畫：從頂部往下滑

```tsx
// 從 nav bar 上方往下滑入（translateY）
const progress = spring({ frame: localF, fps, config: { damping: 22, stiffness: 130 } });
const slideY   = interpolate(progress, [0, 1], [-NOTIF_SLIDE_H, 0], clamp);
```

### 多張疊加（stacking）

```tsx
// 純函數（不是 Hook）— 傳入 frame/fps
function calcStackOffset(c: Callout, allCallouts: Callout[], frame: number, fps: number): number {
  let offset = 0;
  for (const other of allCallouts) {
    if (other.from <= c.from) continue; // 只有「更新的字卡」把它往下推
    if (frame < other.from) continue;
    const localF = frame - other.from;
    if (frame <= other.to) {
      const p = spring({ frame: localF, fps, config: { damping: 22, stiffness: 100 } });
      offset += p * NOTIF_SLOT_H;
    } else {
      const expiredF = frame - other.to;
      const p = spring({ frame: expiredF, fps, config: { damping: 22, stiffness: 100 } });
      offset += (1 - p) * NOTIF_SLOT_H;
    }
  }
  return offset;
}

// CalloutCard 內：所有 hooks 必須在 return null 之前呼叫
const CalloutCard: React.FC<{ c: Callout; allCallouts: Callout[] }> = ({ c, allCallouts }) => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();
  const stackOffset = calcStackOffset(c, allCallouts, frame, fps); // ← 在 return null 之前
  if (frame < c.from || frame > c.to) return null;
  // ...
  top: NAV_H + NOTIF_TOP + stackOffset,
};
```

### 字卡文字規則

- **禁用 `\n`** — 改用 `，`、`：`、`、` 等標點分隔
- 外層 div 用 `maxWidth: NOTIF_W`（非固定 width）— 讓短文字不留多餘空白
- 移除 `minHeight`（讓卡片高度由文字決定）

### 渲染方式

```tsx
// 每個 scene 傳入本 scene 的 callout 陣列
{CALLOUTS.map((c, i) => <CalloutCard key={i} c={c} allCallouts={CALLOUTS} />)}
```

---

---

## 逐字稿同步原則

### VTT → Frame

```
frame = Math.round(seconds × 30)
```

**永遠用 VTT，不估算**。估算誤差可達 1-2 秒。

### VTT 校正優先修正

| 問題 | 處理 |
|------|------|
| 英文品牌名辨識錯誤 | 修正（如 Vycoding → Vibe Coding） |
| 繁簡混用 | 改為繁體 |
| 口語補詞 | 保留（反映實際說話） |

### 字卡時機

- 字卡 `from` = VTT 講者說出該關鍵詞的幀號
- 字卡文字不超過 15 個字
- 每張至少顯示 90 幀（3 秒）

---

## 音頻同步工作流程

### 幀數計算

```
durationInFrames = Math.ceil(audioDurationSec × 30) + 10
```

**注意**：每次重新跑音訊管線（denoise → trim → normalize）後，必須重新計算幀數。
音檔時長會因 trim 改變（通常縮短 1–7 秒）。

---

## 常見錯誤與解法

| 錯誤 | 原因 | 解法 |
|------|------|------|
| React error #310（hooks rendered more） | hooks 在 conditional return 之後呼叫 | 把所有 hooks 移到 return null 之前 |
| 字卡跟台詞對不上 | 用估算秒數 | 用 Whisper VTT |
| 音訊被放大時背景噪音明顯 | normalize 前未降噪 | 先跑 0a_denoise.sh |
| 靜音間隙使 segments 跳接不自然 | 未裁切前後靜音 | 跑 0b_trim_silence.sh（用 silencedetect+atrim，不用 silenceremove） |
| iMessage 字卡有大量空白 | 固定 width + minHeight | 改 maxWidth，移除 minHeight |
| 手機畫面文字太小 | CONTAINER_W 太窄，字體太小 | CONTAINER_W=1500，內容字體至少 24px，主要文字 36px |
| 表格文字太小 | fontSize 13/14 | th: 28px, td label: 26px fontWeight 700, td content: 26px |
| Step/Quiz 文字太小 | fontSize 13-15 | Step 標題 28px, 說明 24px；Quiz 主文 26px, 條列 24px |
| `.lottie` 無法 import | dotLottie 是 ZIP 格式 | unzip -p 解壓為 JSON 再 import |

---

## 完整製作流程（新章節）

```
1. 確認素材
   - 音檔：{章節} 音檔/*.wav
   - 簡報：(N){章節}.html
   - 講稿：逐字講稿.docx

2. 音訊管線（必須依序）
   bash scripts/0a_denoise.sh
   bash scripts/0b_trim_silence.sh
   bash scripts/0_normalize_audio.sh

3. 轉錄 VTT
   bash scripts/1_transcribe.sh {章節}

4. VTT 校正
   bash scripts/2_correct_vtts.sh {章節}

5. 計算幀數
   bash scripts/3_calc_frames.sh {章節}
   → 更新 FullVideo.tsx 的 SEGMENTS 陣列

6. 建立 Scene 元件（Director + Scene Agent）
   - 1:1 對應 HTML 元素
   - useFadeUp startFrame 來自 VTT × 30
   - useFocusHighlight 與 useFadeUp 同一 startFrame
   - 字卡 CALLOUTS 來自 VTT 關鍵詞時間戳
   - 所有字體符合本 skill 的最低字體標準

7. Render（輸出到章節資料夾）
   bash scripts/4_render.sh FullVideo {章節}
   → 輸出：out/CH{章節}/CH{章節}-complete.mp4

8. 合併 VTT（render 後立即執行）
   bash scripts/6_merge_vtt.sh
   → 輸出：out/CH{章節}/CH{章節}-subtitles.vtt

9. 驗收清單
   ✓ 所有文字在手機畫面清晰可讀
   ✓ 底部 SUBTITLE_H=160px 保留空白（不放內容）
   ✓ iMessage 字卡從頂部滑入、堆疊正確、文字無換行
   ✓ out/CH{章節}/ 包含 .mp4 + .vtt
```
