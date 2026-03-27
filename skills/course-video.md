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
| HeyGen avatar 生成 | `5_heygen_avatar.sh` | ⑦（背景執行） |
| Remotion render | `4_render.sh <composition> <chapter>` | ⑧ 最後 |

**重要**：每次有新音檔，必須依序跑完 ①②③ 再 render。

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
const SUBTITLE_H  = 160;   // 底部字幕保留空間
// 內容欄水平置中：left = Math.round((1920 - 1500) / 2) = 210px
// 內容區垂直：top: NAV_H, bottom: SUBTITLE_H
```

### 字體大小標準（手機可讀）

| 元素 | 字體大小 |
|------|---------|
| Hero 主標題 | 88px |
| Hero 副標題 | 36px |
| Hero meta badge | 20px |
| Section Header h2 | 52px |
| Section Number badge | 22px |
| Card 內文 | 36px |
| AnalogyBox 內文 | 34px |
| AnalogyBox 標籤 | 18px |
| 三欄 Grid 標題 | 30px |
| 三欄 Grid 說明 | 24px |
| Takeaway 條目 | 36px |

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
  const stackOffset = calcStackOffset(c, allCallouts, frame, fps); // ← hook 規則：在 return null 之前
  if (frame < c.from || frame > c.to) return null;
  // ...
  top: NAV_H + NOTIF_TOP + stackOffset,
};
```

### 字卡文字規則

- **禁用 `\n`** — 改用 `，`、`：`、`、` 等標點分隔
- 例：`"AI 幫我們，實現困難的事"` 而非 `"AI 幫我們\n實現困難的事"`
- 外層 div 用 `maxWidth: NOTIF_W`（非固定 width）— 讓短文字不留多餘空白
- 移除 `minHeight`（讓卡片高度由文字決定）
- 字體：34px, fontWeight: 800

### 渲染方式

```tsx
// 每個 scene 傳入本 scene 的 callout 陣列
{CALLOUTS.map((c, i) => <CalloutCard key={i} c={c} allCallouts={CALLOUTS} />)}
```

---

## HeyGen Avatar 規格

- Avatar ID：`f7af57d29abd4254a1e43441ec16ce40`
- 腳本：`scripts/5_heygen_avatar.sh`
- 正確 upload endpoint：`https://upload.heygen.com/v1/asset`（注意：不是 api.heygen.com）
- Content-Type：`audio/x-wav`（不是 `audio/wav`）
- 輸出目錄：`public/avatar/0-1_*.mp4`

### Remotion 圓形 Avatar

```tsx
const AVATAR_SIZE = 180;

const AvatarOverlay: React.FC<{ segmentId: string }> = ({ segmentId }) => {
  const frame = useCurrentFrame();
  const fadeIn = interpolate(frame, [0, 20], [0, 1], clamp);
  return (
    <div style={{
      position: "absolute", bottom: 40, right: 40,
      width: AVATAR_SIZE, height: AVATAR_SIZE,
      borderRadius: "50%", overflow: "hidden",
      border: "3px solid rgba(124,255,178,0.6)",
      boxShadow: "0 0 20px rgba(124,255,178,0.25), 0 4px 16px rgba(0,0,0,0.6)",
      opacity: fadeIn, zIndex: 20,
    }}>
      <Video
        src={staticFile(`avatar/0-1_${segmentId}.mp4`)}
        style={{ width: "100%", height: "100%", objectFit: "cover" }}
        muted
      />
    </div>
  );
};
// 在每個 scene 加：<AvatarOverlay segmentId="1.1" />
```

**Placeholder 建立**（尚未跑 HeyGen 時先用）：
```bash
ffmpeg -f lavfi -i color=black:size=400x400:rate=30 -t 1 -c:v libx264 public/avatar/placeholder.mp4
for id in 1.1 2.1 2.2 ...; do cp placeholder.mp4 public/avatar/0-1_${id}.mp4; done
```

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
| HeyGen 上傳失敗 | 用了 api.heygen.com/v1/asset | 改用 upload.heygen.com/v1/asset，Content-Type: audio/x-wav |
| iMessage 字卡有大量空白 | 固定 width + minHeight | 改 maxWidth，移除 minHeight |
| 手機畫面文字太小 | CONTAINER_W 太窄，字體太小 | CONTAINER_W=1500，字體至少 36px 內文 |

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

7. HeyGen Avatar（背景執行）
   bash scripts/5_heygen_avatar.sh &

8. Render
   npx remotion render FullVideo out/CH{章節}-complete.mp4 --codec=h264
```
