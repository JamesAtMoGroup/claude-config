# Scroll-Driven Animations — ScrollTimeline & ViewTimeline

## Concept

Scroll-driven animations replace **time** with **scroll position** as the driver of animation progress. The animation does not run on its own — it plays forward as you scroll down and reverses as you scroll up.

Two timeline types exist:
- **`ScrollTimeline`** — driven by a scrollable container's scroll position (0% = top, 100% = bottom)
- **`ViewTimeline`** — driven by a subject element's visibility within a scroll container

Both can be used with `element.animate()` via the `timeline` option, or with the CSS `animation-timeline` property.

---

## ScrollTimeline

### Constructor

```js
new ScrollTimeline({
  source: scrollableElement,  // the scroller (default: document.documentElement)
  axis: 'block',              // 'block' (vertical, default) | 'inline' (horizontal)
})
```

### Basic Example — rotate on page scroll

```js
const timeline = new ScrollTimeline({
  source: document.documentElement, // scroll the whole page
  axis: 'block',
});

const box = document.querySelector('.box');
box.animate(
  { rotate: ['0deg', '720deg'], left: ['0%', '100%'] },
  {
    duration: 1,    // duration is ignored when using scroll timeline (scroll = time)
    fill: 'both',
    timeline,
  }
);
```

**Note:** `duration` is required syntactically but has no effect when a `ScrollTimeline` is used — scroll position maps 0–100% directly to animation progress.

### Properties

```js
timeline.source;  // → the scrolling element
timeline.axis;    // → 'block' | 'inline'
```

### Scrollable Container (not the whole page)

```js
const scroller = document.querySelector('.carousel');

const timeline = new ScrollTimeline({
  source: scroller,   // this specific container, not the page
  axis: 'inline',     // horizontal scroll
});

const indicator = document.querySelector('.scroll-indicator');
indicator.animate(
  { scaleX: [0, 1] },
  { timeline, fill: 'both' }
);
```

---

## ViewTimeline

A `ViewTimeline` is driven by how much of a **subject element** is visible within its scroll container. Progress goes from 0% (element just entering view) to 100% (element fully exited).

### Constructor

```js
new ViewTimeline({
  subject: element,    // the element to track visibility of
  axis: 'block',       // 'block' (default) | 'inline'
  inset: 'auto',       // adjust the "active" viewport box — CSS inset shorthand or CSS.px()
})
```

### Basic Example — fade in on scroll

```js
const card = document.querySelector('.card');

const timeline = new ViewTimeline({
  subject: card,
  axis: 'block',
});

card.animate(
  {
    opacity: [0, 1],
    transform: ['translateY(40px)', 'translateY(0)'],
  },
  {
    fill: 'both',
    timeline,
    rangeStart: 'entry 0%',    // start animating when element starts entering
    rangeEnd: 'entry 100%',    // finish when element fully entered
  }
);
```

### Properties

```js
timeline.subject;      // → reference to the subject element
timeline.axis;         // → 'block' | 'inline'
timeline.startOffset;  // → CSSNumericValue — scroll position where timeline begins
timeline.endOffset;    // → CSSNumericValue — scroll position where timeline ends
```

### rangeStart / rangeEnd

These clip which portion of the view timeline drives the animation:

| Range keyword | Meaning |
|---|---|
| `entry 0%` | Element's leading edge enters the scrollport |
| `entry 100%` | Element's trailing edge has entered (fully visible) |
| `exit 0%` | Element's leading edge starts leaving |
| `exit 100%` | Element fully exited |
| `cover 0%` | Same as `entry 0%` |
| `cover 100%` | Same as `exit 100%` |
| `contain 0%` | Element is just fully contained in scrollport |
| `contain 100%` | Element about to start leaving |

```js
img.animate(
  { opacity: [0, 1], transform: ['scaleX(0)', 'scaleX(1)'] },
  {
    fill: 'both',
    timeline: new ViewTimeline({ subject: img }),
    rangeStart: 'cover 0%',
    rangeEnd: 'cover 100%',
  }
);
```

### inset — adjusting the viewport box

```js
// Shrink the "active" view zone from both edges by 100px
new ViewTimeline({
  subject: el,
  inset: [CSS.px(100), CSS.px(100)],  // [startOffset, endOffset]
})
```

---

## CSS Scroll-Driven Animations (declarative)

The same ScrollTimeline / ViewTimeline concepts are available purely in CSS:

### CSS ScrollTimeline

```css
.progress-bar {
  animation: grow-width linear both;
  animation-timeline: scroll();          /* scroll(root block) */
  animation-duration: auto;             /* auto = driven by scroll */
}

@keyframes grow-width {
  from { width: 0%; }
  to   { width: 100%; }
}
```

```css
/* Specific scroller and axis */
animation-timeline: scroll(nearest inline);
```

### CSS ViewTimeline

```css
.card {
  animation: fade-in linear both;
  animation-timeline: view();
  animation-range: entry 0% entry 100%;
  animation-duration: auto;
}

@keyframes fade-in {
  from { opacity: 0; transform: translateY(30px); }
  to   { opacity: 1; transform: translateY(0); }
}
```

```css
/* Named view timeline — share across elements */
.scroller {
  view-timeline-name: --my-timeline;
  view-timeline-axis: block;
}

.animated-child {
  animation-timeline: --my-timeline;
}
```

---

## Hybrid: CSS Defines Timeline, JS Reads It

```js
// CSS has defined: scroll-timeline-name: --my-scroll on .scroller
// JS can create a matching ScrollTimeline
const scroller = document.querySelector('.scroller');

const timeline = new ScrollTimeline({ source: scroller });
// No need to use named timelines in JS — just reference the element directly
```

---

## document.timeline (Default Time-Based)

All standard `element.animate()` calls use `document.timeline` by default:

```js
document.timeline;           // DocumentTimeline object
document.timeline.currentTime; // ms since page load (like performance.now())

// Explicitly specifying it (same as default):
el.animate(keyframes, { duration: 500, timeline: document.timeline });

// Switching back from scroll to time:
anim.timeline = document.timeline;
```

---

## Performance Note

When animating compositor-eligible properties (`transform`, `opacity`, `filter`, `clip-path`) with a `ScrollTimeline` or `ViewTimeline`, the scroll-driven animation runs **off the main thread** — hardware accelerated, immune to main-thread jank. This is one of the biggest advantages over scroll event listeners + `requestAnimationFrame`.

---

## ZH-TW 說明

| 概念 | 說明 |
|------|------|
| `ScrollTimeline` | 以捲動容器的捲動進度（0%–100%）驅動動畫 |
| `ViewTimeline` | 以特定元素在視窗中的可見度驅動動畫 |
| `source` | 捲動容器（ScrollTimeline 用），預設是整個頁面 |
| `subject` | 被追蹤可見度的元素（ViewTimeline 用）|
| `axis: 'block'` | 垂直捲動（預設）；`'inline'` 是水平 |
| `rangeStart/End` | 限定 ViewTimeline 哪個區段驅動動畫 |
| `entry 0%` | 元素開始進入視窗時 |
| `entry 100%` | 元素完全進入視窗時 |
| `fill: 'both'` | 捲動動畫通常都要設這個，否則動畫在範圍外會重置 |
| CSS `animation-timeline: scroll()` | 純 CSS 版 ScrollTimeline |
| CSS `animation-timeline: view()` | 純 CSS 版 ViewTimeline |
