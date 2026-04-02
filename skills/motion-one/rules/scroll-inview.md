# Motion One — scroll() and inView()

## scroll()

Binds a callback (or animation) to scroll progress. Uses the native `ScrollTimeline` API where available for hardware-accelerated performance.

### Signature

```ts
scroll(
  callback: (progress: number, info: ScrollInfo) => void,
  options?: ScrollOptions
): VoidFunction  // returns cleanup/cancel function
```

### Basic Usage

```js
import { scroll } from "motion"

// progress: 0 → 1 as page scrolls from top to bottom
const stop = scroll((progress) => {
  console.log(progress)
})

// Cleanup
stop()
```

### Animate with scroll()

Pass an animation directly as the callback:

```js
import { scroll, animate } from "motion"

// Progress bar that grows as you scroll
scroll(
  animate(".progress-bar", { scaleX: [0, 1] }, { ease: "linear" })
)

// Parallax background
scroll(
  animate(".hero-bg", { y: [0, -200] }, { ease: "linear" })
)
```

### ScrollInfo — Extended Callback

```js
scroll((progress, info) => {
  console.log(info.progress)      // 0–1
  console.log(info.scrollLength)  // total scrollable pixels on axis
  console.log(info.velocity)      // scroll velocity
})
```

---

## scroll() Options

### `container` — Track a scrollable element

```js
const carousel = document.getElementById("carousel")

scroll((progress) => {
  console.log(progress)
}, { container: carousel })
```

### `axis` — Horizontal scroll

```js
scroll((progress) => {
  console.log(progress)
}, { axis: "x" })  // default: "y"
```

### `target` — Track a specific element through the viewport

```js
// Track .hero element as it moves through the viewport
scroll(
  animate(".hero", { opacity: [1, 0] }, { ease: "linear" }),
  { target: document.querySelector(".hero") }
)
```

### `offset` — Define scroll range to track

```js
// ["start end", "end start"] = element enters bottom, leaves top (full traverse)
scroll(
  animate(".card", { y: [100, -100] }, { ease: "linear" }),
  {
    target: document.querySelector(".card"),
    offset: ["start end", "end start"],  // default
  }
)

// Element centered in viewport: start tracking
scroll(anim, {
  target: el,
  offset: ["center end", "center start"],
})

// Only animate while element is in view
scroll(anim, {
  target: el,
  offset: ["start end", "end end"],  // enter bottom → align bottom with bottom
})
```

#### Offset Shorthand Values

Each offset is `"[element-edge] [container-edge]"`:
- Edge values: `start` (0), `center` (0.5), `end` (1), or a pixel/percentage

---

## Scroll-Linked Parallax Patterns

### Full-Page Progress Bar

```js
scroll(animate(".progress", { scaleX: [0, 1] }, { ease: "linear" }))
```

### Section Parallax

```js
document.querySelectorAll(".section").forEach((section) => {
  scroll(
    animate(section.querySelector(".bg"), { y: ["-20%", "20%"] }, { ease: "linear" }),
    { target: section, offset: ["start end", "end start"] }
  )
})
```

### Horizontal Scroll Strip

```js
const strip = document.querySelector(".horizontal-strip")
scroll(
  animate(strip, { x: ["0%", "-75%"] }, { ease: "linear" }),
  { target: strip.parentElement }
)
```

### Color Interpolation on Scroll

```js
scroll((progress) => {
  const hue = Math.round(progress * 360)
  document.body.style.setProperty("--bg-hue", hue)
})
```

---

## inView()

Fires a callback when an element enters the viewport. Built on the native `IntersectionObserver` for minimal overhead (~0.5kb).

### Signature

```ts
inView(
  target: Element | Element[] | NodeList | string,
  callback: (entry: IntersectionObserverEntry) => void | (() => void),
  options?: InViewOptions
): VoidFunction
```

### Basic Usage

```js
import { inView } from "motion"

// Fires once when .card enters the viewport
inView(".card", (entry) => {
  console.log("visible:", entry.target)
})
```

### Animate on Entry

```js
import { inView, animate } from "motion"

inView(".feature-card", (entry) => {
  animate(entry.target, { opacity: [0, 1], y: [30, 0] }, { duration: 0.5 })
})
```

### Options

```js
inView(".card", (entry) => { /* ... */ }, {
  root: document.querySelector(".scroll-container"),  // custom scroll root
  margin: "-100px",             // shrink detection zone (like rootMargin)
  amount: 0.5,                  // 0–1: how much must be visible. Default: "some"
})
```

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `root` | `Element` | window | Scrollable ancestor to observe within |
| `margin` | `string` | `"0px"` | CSS margin inset on root (rootMargin) |
| `amount` | `number \| "some" \| "all"` | `"some"` | Threshold — fraction of element that must be visible |

### Staggered inView Reveal

```js
import { inView, animate, stagger } from "motion"

inView(".cards-section", () => {
  animate(
    ".cards-section .card",
    { opacity: [0, 1], y: [40, 0] },
    { delay: stagger(0.1), duration: 0.4 }
  )
})
```

### Re-trigger on Each Entry/Exit

By default, inView fires only once. Return a cleanup from the callback to re-trigger on re-entry:

```js
inView(".card", (entry) => {
  const anim = animate(entry.target, { opacity: [0, 1] })
  // Return function runs when element LEAVES viewport
  return () => anim.cancel()
})
```

This makes the animation play every time the element enters the viewport.

### Cleanup

```js
const stop = inView(".card", callback)
stop()  // disconnect the observer
```

---

## Combining scroll() + inView()

### Reveal then parallax

```js
inView(".section", (entry) => {
  // Reveal on entry
  animate(entry.target, { opacity: [0, 1] }, { duration: 0.4 })

  // Start parallax once visible
  const stopScroll = scroll(
    animate(entry.target.querySelector(".bg"), { y: [0, -60] }, { ease: "linear" }),
    { target: entry.target, offset: ["start end", "end start"] }
  )

  return stopScroll  // cleanup scroll on exit
})
```

---

## Performance Notes

- `scroll()` uses `ScrollTimeline` API natively when browser supports it — no JS on the animation thread for opacity/transform
- `inView()` uses `IntersectionObserver` — zero scroll event listeners
- Both functions return cleanup functions — always call them in component unmount / SPA route change
