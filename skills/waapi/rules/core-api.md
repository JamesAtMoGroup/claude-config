# WAAPI Core API — element.animate()

## What WAAPI Is

The Web Animations API (WAAPI) is the native browser animation engine, the same engine that powers CSS `@keyframes` animations and CSS Transitions. It exposes that engine directly to JavaScript — no DOM class-toggling, no `setTimeout`, no `requestAnimationFrame` loops needed.

**Key insight:** CSS animations don't run separately from WAAPI. CSS animations *are* WAAPI under the hood. Writing `element.animate()` gives you the same performance path as a CSS `@keyframes` animation, plus full JavaScript control.

## element.animate() Syntax

```js
const animation = element.animate(keyframes, options);
```

Returns an `Animation` object instance that is **already playing**.

### Minimal Example

```js
const el = document.querySelector('.box');

el.animate(
  [{ transform: 'translateX(0)' }, { transform: 'translateX(200px)' }],
  300  // duration in ms — shorthand for { duration: 300 }
);
```

### Full Options Object

```js
el.animate(keyframes, {
  // Required (or pass integer as second arg)
  duration: 500,            // ms — NOT seconds like CSS

  // Iteration
  iterations: Infinity,     // or a number; CSS: animation-iteration-count
  iterationStart: 0,        // 0.0–1.0, where in the cycle to start

  // Easing
  easing: 'ease-out',       // default: 'linear' (CSS default is 'ease' — different!)

  // Direction
  direction: 'normal',      // normal | reverse | alternate | alternate-reverse

  // Fill
  fill: 'none',             // none | forwards | backwards | both

  // Timing offsets
  delay: 0,                 // ms before animation starts
  endDelay: 0,              // ms to hold after animation ends

  // Identity
  id: 'my-animation',       // string id for getAnimations() lookup

  // Pseudo-element (Chrome 84+)
  pseudoElement: '::before', // animate a pseudo-element

  // Custom timeline (scroll-driven — see scroll-timeline.md)
  timeline: document.timeline, // default; swap for ScrollTimeline/ViewTimeline
});
```

### CSS vs WAAPI Property Name Mapping

| CSS | WAAPI JS |
|-----|----------|
| `animation-duration` | `duration` (ms not s) |
| `animation-iteration-count` | `iterations` |
| `animation-timing-function` | `easing` |
| `animation-fill-mode` | `fill` |
| `animation-direction` | `direction` |
| `animation-delay` | `delay` |
| `background-color` | `backgroundColor` (camelCase) |
| `float` | `cssFloat` (reserved word) |
| `offset` | `cssOffset` (reserved for keyframe position) |

## Implicit Keyframes (from/to shorthand)

The browser infers the missing start or end state from the element's computed style:

```js
// Animate FROM current state TO translateX(300px)
el.animate({ transform: 'translateX(300px)' }, 500);

// Animate FROM translateX(300px) TO current state
el.animate({ transform: 'translateX(300px)', offset: 0 }, 500);

// Animate FROM current → through translateX(300px) at 50% → back to current
el.animate({ transform: 'translateX(300px)', offset: 0.5 }, 500);
```

## Sequencing with Promises

```js
async function sequence(el) {
  // Step 1
  await el.animate(
    [{ opacity: 0 }, { opacity: 1 }],
    { duration: 300, fill: 'forwards' }
  ).finished;

  // Step 2 — runs only after step 1 finishes
  await el.animate(
    [{ transform: 'translateY(0)' }, { transform: 'translateY(-20px)' }],
    { duration: 200, fill: 'forwards' }
  ).finished;
}
```

## Getting All Animations on a Page/Element

```js
// All active animations on the document
document.getAnimations();

// All animations on a specific element
el.getAnimations();

// Including pseudo-elements
el.getAnimations({ subtree: true });
```

## Two-Model Architecture

WAAPI is built on two conceptual models:

1. **Timing Model** — manages time. `document.timeline` is the master clock (ms since page load to infinity). Each `Animation` sits on a timeline with a `startTime`.

2. **Animation Model** — manages visual change. A `KeyframeEffect` is like a "DVD" containing keyframes + duration. An `Animation` is the "DVD player" that reads the effect and outputs visual changes.

```js
// Manual assembly (equivalent to element.animate())
const effect = new KeyframeEffect(
  el,                                          // target element
  [{ opacity: 0 }, { opacity: 1 }],            // keyframes
  { duration: 400, easing: 'ease-out' }        // options
);
const animation = new Animation(effect, document.timeline);
animation.play();
```

## Relationship to CSS Animations

```
CSS @keyframes  ←──┐
CSS Transitions ←──┤  Both implemented as WAAPI under the hood
element.animate ←──┘  (same code path in browser internals)
```

This means:
- WAAPI animations and CSS animations share the same compositor queue
- You can query CSS animations via `element.getAnimations()`
- Compositing rules (what goes off-main-thread) apply identically

## ZH-TW 重點筆記

- **時長單位是毫秒**：`duration: 300` 代表 0.3 秒（CSS 寫 `0.3s`）
- **預設 easing 是 `linear`**，CSS 預設是 `ease`，要特別指定
- `fill: 'forwards'` 讓動畫停在最後一個狀態
- `iterations: Infinity` 無限循環
- `element.animate()` 立即開始播放，回傳 `Animation` 物件
- 可用 `await animation.finished` 等待完成再做下一步
