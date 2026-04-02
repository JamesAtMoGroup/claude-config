# Motion One — Timeline & Sequencing

## animate() as Sequence (Hybrid Engine)

The hybrid `animate()` function (from `"motion"`) doubles as a sequencer. Pass an array of segments instead of a single target:

```js
import { animate } from "motion"

const sequence = [
  // [target, keyframes, options?]
  ["header", { opacity: [0, 1] }, { duration: 0.4 }],
  ["nav", { y: [-20, 0], opacity: [0, 1] }, { duration: 0.3 }],
  ["main", { opacity: [0, 1] }],
]

animate(sequence)
```

By default, each segment plays **after** the previous one finishes.

---

## The `at` Parameter — Timing Control

The `at` option controls when a segment starts within the sequence timeline.

### Absolute Time

```js
animate([
  ["header", { opacity: 1 }, { duration: 1 }],
  ["nav", { x: [0, 100] }, { at: 0.5 }],  // starts at 0.5s from sequence start
])
```

### Relative Time

```js
animate([
  ["header", { opacity: 1 }, { duration: 1 }],
  // "+0.3" means 0.3s AFTER the previous segment ends (1.3s)
  ["nav", { y: [20, 0] }, { at: "+0.3" }],
  // "-0.2" means 0.2s BEFORE the previous segment ends
  ["footer", { opacity: 1 }, { at: "-0.2" }],
])
```

### Simultaneous with Previous (`"<"`)

```js
animate([
  ["h1", { opacity: 1 }, { duration: 0.5 }],
  // "<" = start at same time as the previous segment
  ["p", { opacity: 1 }, { at: "<" }],
])
```

### Labels

Define named points in time, then reference them:

```js
animate([
  ["header", { x: 100 }, { duration: 1 }],
  "intro-done",                            // label at t=1s
  ["nav", { opacity: 1 }, { duration: 0.3 }],
  ["hero", { scale: [0.9, 1] }, { at: "intro-done" }],  // starts at t=1s
])
```

---

## Per-Segment Options

Each segment can use all standard `animate()` options except `repeatDelay` and `repeatType`:

```js
animate([
  [
    "li",
    { opacity: [0, 1], y: [20, 0] },
    {
      duration: 0.4,
      ease: "easeOut",
      delay: stagger(0.05),  // stagger within this segment
    },
  ],
  [".cta", { scale: [0.8, 1] }, { type: "spring", bounce: 0.4 }],
])
```

---

## Playback Controls on Sequences

The sequence `animate()` call returns the same `AnimationPlaybackControls`:

```js
const seq = animate([
  ["#a", { opacity: 1 }],
  ["#b", { x: 100 }],
])

seq.pause()
seq.play()
seq.time = 0.5   // seek anywhere
seq.speed = 2    // fast-forward
await seq.finished
```

---

## Sequencing Patterns

### Staggered List Reveal

```js
animate([
  ["ul", { opacity: 1 }, { duration: 0.2 }],
  ["li", { opacity: [0, 1], x: [-30, 0] }, { delay: stagger(0.08), at: "<" }],
])
```

### Hero Section Choreography

```js
animate([
  [".hero-bg", { opacity: [0, 1] }, { duration: 0.6 }],
  [".hero-title", { y: [40, 0], opacity: [0, 1] }, { duration: 0.5 }],
  [".hero-sub", { y: [20, 0], opacity: [0, 1] }, { duration: 0.4, at: "-0.2" }],
  [".hero-cta", { scale: [0.8, 1], opacity: [0, 1] }, { at: "+0.1", type: "spring", bounce: 0.3 }],
])
```

### Modal Open/Close

```js
async function openModal() {
  animate([
    [".overlay", { opacity: [0, 1] }, { duration: 0.2 }],
    [".modal", { scale: [0.9, 1], opacity: [0, 1] }, { duration: 0.3, at: "<" }],
  ])
}

async function closeModal() {
  await animate([
    [".modal", { scale: [1, 0.9], opacity: [1, 0] }, { duration: 0.2 }],
    [".overlay", { opacity: [1, 0] }, { duration: 0.15, at: "-0.1" }],
  ]).finished
  // DOM removal happens after animation completes
  modal.remove()
}
```

### Path Drawing + Text Reveal

```js
animate([
  ["path.line", { pathLength: [0, 1] }, { duration: 1.5, ease: "easeInOut" }],
  [".label", { opacity: [0, 1] }, { duration: 0.4, at: ">" }],
])
```

---

## Key Differences from GSAP Timeline

| Feature | Motion animate() | GSAP timeline() |
|---------|-----------------|-----------------|
| Syntax | Array of segments | `.to()`, `.from()` chained |
| Position param | `at` option | Position parameter string |
| Labels | String in array | `.addLabel()` |
| Simultaneous | `at: "<"` | `"<"` position |
| Nested timelines | Not supported | Yes (full nesting) |
| Individual controls | Via returned controls | Via tween reference |

Motion's sequence is simpler but less powerful than GSAP for deeply nested or complex orchestration. For most UI transitions and reveal animations, it's sufficient.
