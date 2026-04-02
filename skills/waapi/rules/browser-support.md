# WAAPI Browser Support, Polyfills & Motion One

## Core WAAPI Support (element.animate)

**Baseline status: Widely available since 2020**

| Feature | Chrome | Firefox | Safari | Edge | IE |
|---|---|---|---|---|---|
| `element.animate()` | 36+ | 48+ | 13.1+ | 79+ | No |
| `Animation` object (play/pause/etc) | 39+ | 48+ | 13.1+ | 79+ | No |
| `animation.finished` promise | 84+ | 63+ | 13.1+ | 84+ | No |
| `animation.ready` promise | 84+ | 63+ | 13.1+ | 84+ | No |
| `commitStyles()` | 84+ | 75+ | 13.1+ | 84+ | No |
| `KeyframeEffect` constructor | 75+ | 63+ | 13.1+ | 79+ | No |
| `Animation()` constructor | 75+ | 48+ | 13.1+ | 79+ | No |
| `updatePlaybackRate()` | 76+ | 70+ | 13.1+ | 79+ | No |
| `overallProgress` | 115+ | 114+ | 17.4+ | 115+ | No |

Overall compatibility score: ~92/100 (caniuse). IE has zero support — use a polyfill or CSS fallback.

## Scroll-Driven Animations Support

**Baseline status: Newly available (limited) — check carefully**

| Feature | Chrome | Firefox | Safari | Edge |
|---|---|---|---|---|
| `ScrollTimeline` (JS) | 115+ | No | No | 115+ |
| `ViewTimeline` (JS) | 115+ | No | No | 115+ |
| CSS `animation-timeline: scroll()` | 115+ | 110+ (partial) | No | 115+ |
| CSS `animation-timeline: view()` | 115+ | No | No | 115+ |
| Named scroll timelines | 115+ | No | No | 115+ |

**As of April 2026:**
- Chrome/Edge: Full support for both JS and CSS scroll-driven animations
- Firefox: Partial CSS support (`animation-timeline: scroll()` behind a flag in some versions); JS `ScrollTimeline` not yet shipped
- Safari: No support yet; tracking under webkit bug

**Strategy:** Use scroll-driven animations as progressive enhancement. Provide a working non-animated baseline that degrades gracefully.

```js
// Feature detection for ScrollTimeline
if ('ScrollTimeline' in window) {
  el.animate(keyframes, {
    timeline: new ScrollTimeline({ source: document.documentElement }),
    fill: 'both',
  });
} else {
  // Fallback: use IntersectionObserver to trigger a time-based animation
  const observer = new IntersectionObserver(entries => {
    if (entries[0].isIntersecting) {
      el.animate(keyframes, { duration: 600, fill: 'both' });
    }
  });
  observer.observe(el);
}
```

## Checking Specific Feature Support

```js
// Check element.animate
const supportsWAAPI = 'animate' in Element.prototype;

// Check ScrollTimeline
const supportsScrollTimeline = 'ScrollTimeline' in window;

// Check ViewTimeline
const supportsViewTimeline = 'ViewTimeline' in window;

// Check CSS scroll-driven animations
const supportsCSSScrollTimeline = CSS.supports('animation-timeline: scroll()');
const supportsCSSViewTimeline = CSS.supports('animation-timeline: view()');
```

## Polyfills

### web-animations-js (Official W3C polyfill)

- GitHub: `web-animations/web-animations-js`
- Covers: `element.animate()`, `Animation` object, `KeyframeEffect`
- Does NOT cover: `ScrollTimeline`, `ViewTimeline`
- Size: Large (~30KB gzipped) — consider this overhead carefully

```html
<!-- Load before any WAAPI usage -->
<script src="https://cdn.jsdelivr.net/npm/web-animations-js@2.3.2/web-animations.min.js"></script>
```

```js
// With modern bundlers:
import 'web-animations-js'; // polyfills globally
```

### scroll-timeline (Flackr's polyfill)

The most complete polyfill for `ScrollTimeline` and `ViewTimeline` + CSS `animation-timeline`:

- GitHub: `flackr/scroll-timeline`
- Covers: `ScrollTimeline`, `ViewTimeline`, CSS `animation-timeline`

```html
<script src="https://flackr.github.io/scroll-timeline/dist/scroll-timeline.js"></script>
```

```js
import 'https://flackr.github.io/scroll-timeline/dist/scroll-timeline.js';
```

### Motion One as a Polyfill Strategy

For most production use cases, using **Motion One** (`motion.dev`) is cleaner than raw polyfills:

- Uses WAAPI where available (Chrome/Edge) → hardware accelerated
- Falls back to rAF when WAAPI not available (older browsers)
- ~18KB (vs GSAP's ~67KB or web-animations-js's ~30KB)
- API closely mirrors WAAPI but with DX improvements

```js
import { animate, scroll, inView } from 'motion';

// Time-based (WAAPI internally):
animate(el, { opacity: [0, 1], y: [20, 0] }, { duration: 0.4 });

// Scroll-driven (uses native ScrollTimeline when available):
scroll(animate(el, { opacity: [0, 1] }));
```

## Motion One Architecture (How it Uses WAAPI)

Motion One is a **hybrid engine**:

```
animate(el, { x: 100, opacity: 0 })
    ↓
Is WAAPI available?
    ↓ YES                            ↓ NO (old browser, non-DOM target)
element.animate()                    requestAnimationFrame loop
  (compositor thread)                  (main thread fallback)
  hardware accelerated
```

Features Motion One adds on top of raw WAAPI:
1. **Spring animations** — simulates physics → generates WAAPI-compatible cubic-bezier sequences
2. **Independent transform axes** — `{ x: 100, rotate: 45 }` instead of composing transform strings
3. **CSS variable animation** — `{ '--hue': 200 }` via rAF fallback
4. **Stagger** — built-in staggering for multiple elements
5. **`inView()`** — IntersectionObserver with animation integration
6. **`scroll()`** — wraps `ScrollTimeline` with a simpler API

## Practical Decision Guide

| Situation | Recommendation |
|---|---|
| Modern browsers only, simple animation | Raw `element.animate()` |
| Need spring physics or complex sequences | Motion One |
| Already using GSAP in project | GSAP (but miss WAAPI hardware acceleration) |
| Need CSS variable animation | Motion One or rAF |
| Need scroll-driven, Chrome/Edge only | `ScrollTimeline` natively |
| Need scroll-driven, cross-browser | Motion One `scroll()` or flackr polyfill |
| Need IE11 support | web-animations-js polyfill |
| React project | Motion (Framer Motion v11+) or `element.animate()` with refs |

## ZH-TW 瀏覽器支援摘要

| 功能 | 支援狀況 |
|------|---------|
| `element.animate()` | 全主流瀏覽器（不含 IE）|
| `animation.finished` promise | Chrome 84+ / Firefox 63+ / Safari 13.1+ |
| `ScrollTimeline` / `ViewTimeline` | 目前主要是 Chrome 115+ / Edge 115+；Firefox 和 Safari 尚未完整支援 |
| CSS `animation-timeline` | Chrome 115+ / Edge 115+；Firefox 部分支援；Safari 尚未 |
| IE 11 | 完全不支援 WAAPI |
| Polyfill 選項 | `web-animations-js`（核心 WAAPI）+ `flackr/scroll-timeline`（捲動時間軸）|
| 生產建議 | 用 Motion One 自動 fallback，比手動管理 polyfill 更省力 |
