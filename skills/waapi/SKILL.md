---
name: waapi
description: Web Animations API (WAAPI) — native browser element.animate(), Animation object, ScrollTimeline, ViewTimeline. Use for performant native animations without libraries.
---

# Web Animations API (WAAPI) Skill

WAAPI is the native browser animation engine that underlies CSS Animations and CSS Transitions. It gives JavaScript direct access to the browser's compositor-backed animation system — no library required.

## When to Use WAAPI

- Need hardware-accelerated animations without adding GSAP/Motion overhead
- Animating `transform`, `opacity`, `filter`, `clip-path` (compositor-eligible properties)
- Building scroll-driven animations with `ScrollTimeline` / `ViewTimeline`
- Need promise-based animation sequencing (`animation.finished`)
- Building a lightweight animation utility on top of the native platform

## Quick Reference

```js
// Simplest possible animation
const anim = el.animate(
  [{ opacity: 0, transform: 'translateY(20px)' }, { opacity: 1, transform: 'translateY(0)' }],
  { duration: 400, easing: 'ease-out', fill: 'both' }
);

// Await completion
await anim.finished;
```

## Rule Files

- `rules/core-api.md` — `element.animate()`, keyframes, timing options, implicit keyframes
- `rules/animation-object.md` — Animation control methods, promises, playState, commitStyles
- `rules/keyframe-formats.md` — Array vs object format, composite, iterationComposite, offset
- `rules/scroll-timeline.md` — ScrollTimeline, ViewTimeline, CSS scroll-driven animations
- `rules/performance.md` — Compositor thread, hardware acceleration, what to animate
- `rules/browser-support.md` — Browser matrix, polyfills, Motion One as WAAPI layer

## Key Gotchas

- Duration is in **milliseconds** (not seconds like CSS)
- Default easing is `linear` (CSS default is `ease`)
- Use `iterations` not `iteration-count`
- `fill: 'forwards'` animations auto-remove when replaced — call `.persist()` to prevent
- `commitStyles()` + `cancel()` is cleaner than infinite fill for persisting state

## ZH-TW 速查

| 術語 | 說明 |
|------|------|
| `element.animate()` | 在元素上建立並立即播放動畫，回傳 Animation 物件 |
| `KeyframeEffect` | 儲存關鍵影格與時序設定的物件，可傳入 `new Animation()` |
| `document.timeline` | 頁面的主時間軸（從載入開始計時） |
| `ScrollTimeline` | 以捲動位置驅動動畫進度，取代時間 |
| `ViewTimeline` | 以元素進入/離開視窗的可見度驅動動畫 |
| `animation.finished` | Promise，動畫結束時 resolve |
| `animation.ready` | Promise，動畫準備好播放時 resolve |
| `commitStyles()` | 將動畫當前樣式寫入 inline style，讓狀態持續 |
