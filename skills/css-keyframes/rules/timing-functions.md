# CSS Easing / Timing Functions

Used in `animation-timing-function` and `transition-timing-function`. Can also be placed inside keyframe blocks to control easing between that stop and the next.

---

## Three Categories

1. **Linear** — constant rate
2. **Cubic-Bezier** — smooth curve (includes all named keywords)
3. **Steps** — discrete jumps

---

## Linear

### `linear` keyword

Constant speed from start to finish. Equivalent to `cubic-bezier(0, 0, 1, 1)` and `linear(0, 1)`.

```css
animation-timing-function: linear;
```

### `linear()` function (CSS Easing Level 2)

Piecewise linear — interpolates between control points. Useful for bounce/spring effects without JS.

```css
/* Syntax: linear(output [input%], output [input%], ...) */
animation-timing-function: linear(0, 0.5 25%, 1);

/* Bounce effect via linear() */
animation-timing-function: linear(
  0, 0.004, 0.016, 0.035, 0.063, 0.098, 0.141, 0.191,
  0.25, 0.316, 0.391, 0.473, 0.563, 0.66, 0.765, 0.876,
  1 36.4%, 0.907, 0.83, 0.771, 0.729, 0.707 45.5%,
  0.726, 0.788, 0.888, 1 55%, 0.946, 0.908, 0.89 60.6%,
  0.908, 1 68.2%, 0.972, 0.956 72.7%, 0.972, 1
);
```

Generator: https://linear-easing-generator.netlify.app/

---

## Cubic-Bezier Named Keywords

All are shorthand for `cubic-bezier(x1, y1, x2, y2)` with control points in range [0,1].

| Keyword | Equivalent | Feel |
|---------|-----------|------|
| `ease` | `cubic-bezier(0.25, 0.1, 0.25, 1)` | Slow start, fast middle, slow end (default) |
| `ease-in` | `cubic-bezier(0.42, 0, 1, 1)` | Slow start, fast end |
| `ease-out` | `cubic-bezier(0, 0, 0.58, 1)` | Fast start, slow end |
| `ease-in-out` | `cubic-bezier(0.42, 0, 0.58, 1)` | Slow start and end |
| `linear` | `cubic-bezier(0, 0, 1, 1)` | Constant speed |

### Custom cubic-bezier

```css
/* cubic-bezier(x1, y1, x2, y2) */
/* x values must be [0, 1]; y values can exceed this range for overshoot */
animation-timing-function: cubic-bezier(0.34, 1.56, 0.64, 1); /* spring overshoot */
animation-timing-function: cubic-bezier(0.68, -0.55, 0.27, 1.55); /* elastic */
```

Tool for building curves: https://cubic-bezier.com/

### Common custom curves

```css
/* Material Design standard — snappy feels natural for UI */
--ease-standard:    cubic-bezier(0.2, 0, 0, 1);
--ease-decelerate:  cubic-bezier(0, 0, 0.2, 1);   /* entering elements */
--ease-accelerate:  cubic-bezier(0.4, 0, 1, 1);   /* exiting elements */

/* Springy / overshoot */
--ease-spring:      cubic-bezier(0.34, 1.56, 0.64, 1);
--ease-back-out:    cubic-bezier(0.34, 1.56, 0.64, 1);

/* Expo variants */
--ease-expo-out:    cubic-bezier(0.16, 1, 0.3, 1);
--ease-expo-in:     cubic-bezier(0.7, 0, 0.84, 0);
--ease-expo-in-out: cubic-bezier(0.87, 0, 0.13, 1);
```

---

## Steps

Jumps between states in discrete steps — no interpolation between them. Good for sprite animations, typewriter effects, counting.

```css
/* steps(<integer>, <step-position>) */
animation-timing-function: steps(4, end);
animation-timing-function: steps(1, jump-start);

/* Named aliases */
animation-timing-function: step-start; /* = steps(1, jump-start) */
animation-timing-function: step-end;   /* = steps(1, jump-end) */
```

### Step positions

| Value | Jump at | Aliases |
|-------|---------|---------|
| `jump-start` | Beginning of each step | `start` |
| `jump-end` | End of each step (default) | `end` |
| `jump-none` | No jump at 0% or 100% — steps distributed across range | — |
| `jump-both` | Jump at both start and end | — |

### Sprite sheet animation

```css
@keyframes walk {
  to { background-position: -800px 0; } /* 8 frames × 100px */
}

.character {
  width: 100px;
  height: 100px;
  background: url('sprite.png') 0 0;
  animation: walk 0.8s steps(8, end) infinite;
}
```

### Typewriter effect

```css
@keyframes type {
  from { width: 0; }
  to   { width: 20ch; }
}

.typewriter {
  overflow: hidden;
  white-space: nowrap;
  width: 20ch;
  animation: type 2s steps(20, end) forwards;
}
```

---

## Per-Keyframe Timing

Timing functions applied inside a keyframe control easing from **that keyframe to the next**:

```css
@keyframes bounce {
  0%   {
    transform: translateY(0);
    animation-timing-function: ease-in; /* ease-in from 0% → 50% */
  }
  50%  {
    transform: translateY(-60px);
    animation-timing-function: ease-out; /* ease-out from 50% → 100% */
  }
  100% { transform: translateY(0); }
}
```

---

## Cheat Sheet: Which to Use

| Scenario | Recommended |
|----------|------------|
| UI element entering | `ease-out` or `cubic-bezier(0.2, 0, 0, 1)` |
| UI element exiting | `ease-in` or `cubic-bezier(0.4, 0, 1, 1)` |
| Continuous loop | `linear` or `ease-in-out` |
| Playful / bouncy | `cubic-bezier(0.34, 1.56, 0.64, 1)` |
| Progress bar | `linear` |
| Sprite animation | `steps(N, end)` |
| Typewriter | `steps(N, end)` |
| Complex spring | `linear()` with bounce stops |
| Scroll progress | `linear` (timeline drives it) |
