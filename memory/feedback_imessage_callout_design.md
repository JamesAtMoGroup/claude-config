---
name: iMessage callout design — use article-video spec
description: Vibe Coding video iMessage callouts must use the same design as article-video, not the old label/side/yPct system
type: feedback
---

Vibe Coding 課程影片的 iMessage 字卡設計，必須與 article-video 完全一致。

**Why:** James 認為 article-video 的 iMessage 字卡設計更好，兩個專案應統一。

**How to apply:** 在所有 Vibe Coding video 場景中，使用 article-video 的 Callout 規格：

```ts
interface Callout {
  from: number;    // 開始幀（global）
  to:   number;    // 結束幀
  sender: string;  // 寄件人名稱（bold 第二行）
  text:   string;  // 訊息內文（typewriter 效果）
}
```

視覺規格（Vibe Coding S=2，從 article-video S=3 等比縮放）：
- NOTIF_W: 290 * S = 580px
- NOTIF_TOP: 12 * S = 24px（距 nav bar）
- NOTIF_RIGHT: 20 * S = 40px
- NOTIF_SLOT: 148 * S = 296px
- NOTIF_SLIDE_H: 110 * S = 220px
- FADE_OUT_FRAMES: 50
- borderRadius: 14 * S = 28px
- icon: 38*S = 76px，green gradient，speech bubble
- Row 1: "iMessage" 11*S=22px, opacity 0.45 + "剛剛" right
- Row 2: sender 13*S=26px, bold, opacity 0.92
- Row 3: body 13*S=26px, fontWeight 800, opacity 0.60, typewriter 0.85 chars/frame

堆疊行為：
- 新通知從頂部右側滑入（spring damping:22 stiffness:130）
- 舊通知被 spring 推下 NOTIF_SLOT
- 深度透明度：depth 0=100%, 1=65%, 2=35%
- 最多同時顯示 2 張

廢棄舊版的 label/side/yPct 系統，全面改用此規格。
