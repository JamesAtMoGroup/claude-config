# Motion One — Core API

## animate()

The primary function. Animates HTML/SVG elements or CSS selectors.

### Signature

```ts
animate(
  target: Element | Element[] | NodeList | string,
  keyframes: DOMKeyframesDefinition,
  options?: AnimationOptionsWithOverrides
): AnimationPlaybackControls
```

### Basic Examples

```js
import { animate } from "motion"

// Single element
animate("#box", { opacity: [0, 1], x: [0, 100] }, { duration: 0.5 })

// CSS selector (all matching elements)
animate("li", { opacity: 1, y: [20, 0] }, { duration: 0.4, delay: stagger(0.1) })

// NodeList / array
const cards = document.querySelectorAll(".card")
animate(cards, { scale: [0.8, 1] }, { duration: 0.3 })
```

### Keyframes

Pass arrays to define multi-step keyframes:

```js
// Two-step: from → to
animate(el, { x: [0, 100] })

// Multi-step keyframe sequence
animate(el, { x: [0, 50, 100, 50, 0] }, { duration: 2 })

// null = read current value from DOM (implicit from)
animate(el, { opacity: [null, 0] })

// Different easing per keyframe step
animate(el, { x: [0, 100, 0] }, { ease: ["easeIn", "easeOut"] })

// Per-keyframe offset (0–1)
animate(el, {
  x: [0, 100, 50],
  offset: [0, 0.8, 1]
})
```

### Transition Options

```js
animate(el, { x: 100 }, {
  duration: 1,         // seconds
  delay: 0.2,
  repeat: Infinity,    // or a number
  repeatType: "loop",  // "loop" | "reverse" | "mirror"
  repeatDelay: 0.5,
  ease: "easeInOut",   // see Easing section
  direction: "normal", // "normal" | "reverse" | "alternate"
  endDelay: 0,
  onComplete: () => console.log("done"),
})
```

### Per-Value Options

Override transition options on a per-property basis:

```js
animate(
  el,
  { x: 100, rotate: 360, opacity: 1 },
  {
    duration: 1,
    rotate: { duration: 0.5, ease: "easeOut" },
    opacity: { duration: 0.3, delay: 0.1 },
  }
)
```

---

## Easing

### Named Easings

```
"linear"
"easeIn" | "easeOut" | "easeInOut"
"circIn" | "circOut" | "circInOut"
"backIn" | "backOut" | "backInOut"
"anticipate"
```

### Cubic Bezier

```js
animate(el, { x: 100 }, { ease: [0.17, 0.67, 0.83, 0.67] })
```

### Steps

```js
animate(el, { x: 100 }, { ease: "steps(6, end)" })
```

### Custom Function

```js
animate(el, { x: 100 }, { ease: (t) => t * t })
```

---

## spring()

Physics-based spring easing. Import and use as a transition type or as a CSS generator.

```js
import { animate, spring } from "motion"

// As transition type
animate(el, { x: 100 }, {
  type: "spring",
  stiffness: 300,   // higher = snappier (default: 100)
  damping: 20,      // higher = less bounce (default: 10)
  mass: 1,
  restSpeed: 0.01,
})

// Duration + bounce (easier to reason about)
animate(el, { x: 100 }, {
  type: "spring",
  duration: 0.6,    // seconds — visual duration to first reach target
  bounce: 0.3,      // 0 = no bounce, 1 = very bouncy
})

// spring() as CSS transition generator
import { spring } from "motion"
el.style.transition = spring({ visualDuration: 0.5, bounce: 0.25 }).toString()
// Returns "duration easing" pair for use in CSS
```

### Spring Parameters

| Param | Description |
|-------|-------------|
| `stiffness` | Spring strength. Higher = more sudden. Default: 100 |
| `damping` | Opposing force. 0 = oscillates forever. Default: 10 |
| `mass` | Simulated object mass. Higher = slower start. Default: 1 |
| `bounce` | 0–1 shorthand for damping ratio. Easier to use. |
| `duration` | Visual duration (seconds) to reach target for first time |
| `visualDuration` | Alias; drives bounce feel but total may exceed this |

---

## stagger()

Spread delays across a set of elements.

```js
import { animate, stagger } from "motion"

// Basic: 0.1s gap between each element
animate("li", { opacity: 1, y: [20, 0] }, { delay: stagger(0.1) })

// From center outward
animate("li", { scale: [0, 1] }, { delay: stagger(0.05, { from: "center" }) })

// From last to first
animate("li", { x: [-50, 0] }, { delay: stagger(0.08, { from: "last" }) })

// From a specific index
animate("li", { opacity: 1 }, { delay: stagger(0.1, { from: 3 }) })

// Start offset — first animation begins at 0.5s, then staggers
animate("li", { opacity: 1 }, { delay: stagger(0.1, { startDelay: 0.5 }) })

// Ease the stagger timing distribution
animate("li", { y: [30, 0] }, { delay: stagger(0.1, { ease: "easeOut" }) })
```

### stagger() Options

| Option | Type | Description |
|--------|------|-------------|
| `from` | `"first" \| "center" \| "last" \| number` | Direction. Default: `"first"` |
| `startDelay` | `number` | Added to the first element's delay |
| `ease` | easing | Distributes delays non-linearly across the list |

---

## Playback Controls

`animate()` returns an `AnimationPlaybackControls` object:

```js
const animation = animate(el, { x: 100 }, { duration: 2 })

animation.play()     // resume if paused or finished
animation.pause()    // freeze at current time
animation.stop()     // stop & commit current values (cannot restart)
animation.cancel()   // revert to initial state
animation.finish()   // jump to end state immediately

animation.time = 0.5       // seek to 0.5s
animation.speed = 2        // 2x playback speed
animation.speed = -1       // play in reverse
console.log(animation.duration) // total duration in seconds (read-only)

// then() — Promise API
await animation.then(() => console.log("complete"))
// or with .finished
await animation.finished
```

---

## SVG Path Animations

Special properties for path drawing:

```js
// Draw a path on scroll or entry
animate("path", {
  pathLength: [0, 1],
  pathSpacing: 1,
  pathOffset: 0,
}, { duration: 2, ease: "easeInOut" })
```

Works with: `circle`, `ellipse`, `line`, `path`, `polygon`, `polyline`, `rect`.

---

## CSS Variable Animation

```js
// Animate a CSS custom property
animate(document.documentElement, {
  "--primary-hue": [200, 340],
}, { duration: 1 })
```

---

## Mini Engine Import

For maximum tree-shaking when only animating transform/opacity/filter:

```js
import { animate } from "motion/mini"
// ~2.3kb vs 17kb hybrid
// Does NOT support: sequences, motion values, JS-only values
```
