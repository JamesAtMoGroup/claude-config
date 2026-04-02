# WAAPI Performance — Compositor Thread & Hardware Acceleration

## The Core Advantage

WAAPI and CSS animations share the same internal browser code path. Both can offload certain animations to the **compositor thread** (often GPU-backed), completely separate from the main JavaScript thread.

This means: even if your JS is crunching heavy computations, a compositor-eligible WAAPI animation keeps running smoothly at 60fps (or 120fps on high-refresh displays).

```
Main Thread:  [JS work] [JS work] [layout] [paint]  ...jank possible here
Compositor:   [animate transform] [animate opacity]  ...always smooth
```

## Compositor-Eligible Properties

Only these CSS properties reliably run off the main thread:

| Property | Notes |
|---|---|
| `transform` | translate, rotate, scale, skew, matrix — all compositor-safe |
| `opacity` | Fully compositor-safe |
| `filter` | blur, brightness, contrast, etc. — compositor-safe in most browsers |
| `clip-path` | Compositor-safe in Chrome/Edge; check Firefox/Safari |
| `backdrop-filter` | Generally compositor-safe |

**Everything else** (color, width, height, top, left, margin, padding, border, font-size...) triggers layout or paint, which runs on the main thread and can cause jank.

## What Triggers Layout (Avoid Animating)

These force the browser to recalculate layout on every frame — expensive:

```
width, height, max-width, min-height
top, right, bottom, left
margin, padding
border-width
font-size, line-height
display, position
```

**Instead, use transforms:**

```js
// BAD — triggers layout reflow
el.animate({ left: ['0px', '200px'] }, 500);

// GOOD — compositor-safe
el.animate({ transform: ['translateX(0)', 'translateX(200px)'] }, 500);

// BAD — triggers layout
el.animate({ width: ['100px', '200px'] }, 500);

// GOOD — compositor-safe
el.animate({ transform: ['scaleX(1)', 'scaleX(2)'] }, 500);
// (anchor to left edge with transform-origin if needed)
```

## WAAPI vs Other JS Approaches

| Technique | Compositor? | Notes |
|---|---|---|
| `element.animate()` (transform/opacity) | YES | Hardware accelerated |
| CSS `@keyframes` (transform/opacity) | YES | Same code path as WAAPI |
| CSS Transitions (transform/opacity) | YES | Same compositor path |
| `requestAnimationFrame` + style mutation | NO | Always main thread |
| GSAP (without WAAPI) | NO | rAF-based, main thread |
| GSAP + WAAPI mode | YES | Hardware accelerated |
| Motion One `animate()` | YES | Built on WAAPI |
| `setInterval` / `setTimeout` | NO | Terrible — avoid |

```
TIER 1 (compositor, hardware accelerated):
  element.animate()  →  transform + opacity + filter
  CSS @keyframes     →  transform + opacity + filter
  ScrollTimeline     →  compositor-eligible properties

TIER 2 (main thread but optimized):
  requestAnimationFrame  →  anything but can jank

TIER 3 (avoid):
  setTimeout/setInterval animations
  Direct style mutations in scroll event handlers
```

## `will-change` — Use Sparingly

```css
/* Hint to browser to promote element to its own compositor layer */
.animated-element {
  will-change: transform, opacity;
}
```

**Warning:** `will-change` allocates GPU memory. Using it on too many elements causes memory pressure. Only apply it:
- Before a known upcoming animation
- On elements that animate frequently and persistently
- Remove it after animation completes:

```js
el.style.willChange = 'transform';
await el.animate(keyframes, options).finished;
el.style.willChange = 'auto'; // release GPU memory
```

## Scroll-Driven Animations on Compositor

When a `ScrollTimeline` or `ViewTimeline` drives compositor-eligible properties, the entire animation (including scroll progress tracking) runs off the main thread:

```js
// This runs fully on compositor — scroll events never touch JS
el.animate(
  { transform: ['translateY(0)', 'translateY(-100px)'], opacity: [1, 0] },
  {
    timeline: new ScrollTimeline({ source: document.documentElement }),
    fill: 'both',
  }
);
```

Compare with the old `scroll` event approach:

```js
// BAD — main thread, can jank
window.addEventListener('scroll', () => {
  const progress = window.scrollY / document.body.scrollHeight;
  el.style.transform = `translateY(${-progress * 100}px)`; // layout/paint
});
```

## Reducing Reflows with `getComputedTiming()`

Read animation state without triggering layout:

```js
const timing = anim.effect.getComputedTiming();
timing.progress;         // 0–1 progress, no layout trigger
timing.currentIteration; // which iteration
timing.duration;         // total duration
```

**Never** read layout-triggering properties inside animation callbacks:

```js
// BAD — causes layout thrashing in animation loop
anim.onfinish = () => {
  const width = el.offsetWidth; // layout trigger!
};

// GOOD — read outside, cache value
const width = el.offsetWidth; // read once before animation
anim.onfinish = () => {
  doSomethingWith(width); // use cached value
};
```

## Pausing Off-Screen Animations

Pause animations when elements are not visible to save GPU/CPU:

```js
const observer = new IntersectionObserver((entries) => {
  entries.forEach(entry => {
    const anim = entry.target.getAnimations()[0];
    if (!anim) return;
    if (entry.isIntersecting) {
      anim.play();
    } else {
      anim.pause();
    }
  });
});

observer.observe(animatedElement);
```

## Prefers-Reduced-Motion

Always respect the user's motion preference:

```js
const prefersReduced = window.matchMedia('(prefers-reduced-motion: reduce)').matches;

el.animate(
  [{ opacity: 0 }, { opacity: 1 }],
  {
    duration: prefersReduced ? 0 : 400,
    // duration: 0 still fires .finished, but instantly
  }
);

// Or skip animation entirely for significant motion:
if (!prefersReduced) {
  el.animate(
    [{ transform: 'translateX(-100vw)' }, { transform: 'translateX(0)' }],
    { duration: 600, easing: 'cubic-bezier(0.25, 0.46, 0.45, 0.94)', fill: 'both' }
  );
}
```

## How Motion One Uses WAAPI

Motion One (motion.dev) uses a **hybrid engine**:

1. For `transform` and `opacity` → directly calls `element.animate()` → hardware accelerated
2. For values WAAPI can't animate (CSS variables, SVG attributes, Three.js) → falls back to `requestAnimationFrame`
3. Extends WAAPI with features it lacks: spring physics, custom easing functions, independent transform axes

```js
// Motion One internally translates this:
animate(el, { x: 100, opacity: 0 }, { type: 'spring' });

// Into roughly this WAAPI call:
el.animate(
  [{ transform: 'none', opacity: 1 }, { transform: 'translateX(100px)', opacity: 0 }],
  { duration: springDuration, easing: springEasingArray, fill: 'both' }
);
```

WAAPI's biggest DX limitations that Motion One solves:
- No spring animations natively → Motion One simulates spring → generates WAAPI-compatible cubic-bezier approximation
- No independent `x`/`y`/`rotate` → Motion One composes transform strings
- No CSS variable animation → Motion One uses rAF fallback
- Verbose API → Motion One provides simpler `animate(el, props, options)` syntax

## ZH-TW 重點

| 概念 | 說明 |
|------|------|
| Compositor thread | GPU 執行緒，不受 JS 主執行緒阻塞 |
| 可以 hardware accelerate 的屬性 | `transform`, `opacity`, `filter`, `clip-path` |
| 避免 animate 的屬性 | `width`, `height`, `top`, `left`, `margin` — 觸發 layout |
| `will-change` | 提示瀏覽器預先建立 GPU layer，用完要 reset 為 `auto` |
| scroll 事件 + style mutation | 最差的方式，永遠在主執行緒，容易 jank |
| ScrollTimeline + transform | 最佳方式，完全 off-main-thread |
| Motion One | WAAPI 的封裝層，加上 spring、CSS 變數支援、簡化語法 |
