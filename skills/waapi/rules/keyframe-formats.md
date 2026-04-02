# Keyframe Formats — WAAPI

## Two Accepted Formats

WAAPI accepts keyframes in two forms. Both work with `element.animate()`, `new KeyframeEffect()`, and `KeyframeEffect.setKeyframes()`.

---

## Format 1: Array of Keyframe Objects

An array where each object represents one keyframe. Properties are camelCase CSS properties.

```js
el.animate(
  [
    { opacity: 0, transform: 'translateY(20px)', color: '#000' },  // 0%
    { opacity: 0.5, color: '#431236', offset: 0.3 },               // 30% (explicit)
    { opacity: 1, transform: 'translateY(0)',   color: '#000' },   // 100%
  ],
  { duration: 800, easing: 'ease-out' }
);
```

### Per-Keyframe Special Keys

| Key | Values | Notes |
|-----|--------|-------|
| `offset` | `0.0`–`1.0` or `null` | Explicit position on timeline. `null` = auto-distribute |
| `easing` | any CSS easing string | Easing applied FROM this keyframe TO the next |
| `composite` | `'replace'` \| `'add'` \| `'accumulate'` \| `'auto'` | Override per-keyframe compositing |

### Per-Keyframe Easing Example

```js
el.animate(
  [
    { opacity: 1, easing: 'ease-out' },   // ease-out FROM here TO next
    { opacity: 0.1, easing: 'ease-in' }, // ease-in FROM here TO next
    { opacity: 0 }                        // end
  ],
  1000
);
```

### Explicit Offsets

```js
el.animate(
  [
    { opacity: 1 },                    // offset: 0   (auto)
    { opacity: 0.1, offset: 0.7 },    // offset: 0.7 (explicit — 70% through)
    { opacity: 0 }                     // offset: 1   (auto)
  ],
  2000
);
```

Offsets must be in ascending order. Unspecified offsets are evenly spaced between adjacent specified offsets.

---

## Format 2: Property-Value Object

An object where each CSS property is a key, and the value is an **array** of values progressing through the animation.

```js
el.animate(
  {
    opacity: [0, 1],
    transform: ['translateY(20px)', 'translateY(0)'],
    backgroundColor: ['#f00', '#0f0', '#00f'],  // 3 values = evenly spaced
  },
  800
);
```

### Object Format Special Keys

```js
el.animate(
  {
    opacity: [0, 0.9, 1],
    offset: [0, 0.8],          // applies to opacity values: [0→0, 0.9→0.8, 1→1 (auto)]
    easing: ['ease-in', 'ease-out'],  // repeats if fewer values than keyframes
    composite: ['replace', 'add'],
  },
  2000
);
```

### Mixed Array Lengths

When property arrays have different lengths, values are evenly distributed independently:

```js
el.animate(
  {
    opacity: [0, 1],                         // 0%, 100%
    backgroundColor: ['red', 'yellow', 'green'], // 0%, 50%, 100%
  },
  1000
);
```

---

## CSS Property Name Rules

| CSS property | WAAPI JS key |
|---|---|
| `background-color` | `backgroundColor` |
| `border-top-left-radius` | `borderTopLeftRadius` |
| `clip-path` | `clipPath` |
| `font-size` | `fontSize` |
| `float` | `cssFloat` (JS reserved word!) |
| `offset` (CSS Motion Path) | `cssOffset` (conflicts with keyframe offset!) |

All multi-word properties use camelCase. `float` and `offset` are the two exceptions needing the `css` prefix.

---

## Composite Operations

Composite determines how an animation's value **combines** with the element's underlying value (from CSS or other animations).

### replace (default)

Completely replaces the underlying value.

```js
// Element has CSS: transform: translateX(100px)
// Animation with 'replace':
el.animate(
  [{ transform: 'rotate(45deg)' }],
  { duration: 500, composite: 'replace' }
);
// Result: rotate(45deg) — translateX(100px) is GONE
```

### add

Additive compositing — combines both transform lists. Useful for layered animations.

```js
el.animate(
  [{ transform: 'translateX(-200px)' }],
  { duration: 300, composite: 'add' }
);
el.animate(
  [{ transform: 'rotate(20deg)' }],
  { duration: 500, composite: 'add' }
);
// Result: translateX(-200px) rotate(20deg) — both applied simultaneously
```

### accumulate

Smarter than `add` — combines values numerically where meaningful.

```js
// Underlying: blur(2px)
// Animation: blur(5px) with composite: 'accumulate'
// Result: blur(7px)   ← not "blur(2px) blur(5px)" (which would be additive)
```

| Operation | transform example | blur example |
|---|---|---|
| `replace` | `rotate(45deg)` | `blur(5px)` |
| `add` | `existing rotate(45deg)` | `blur(2px) blur(5px)` |
| `accumulate` | `existing + 45deg` | `blur(7px)` |

### Per-Keyframe Composite Override

```js
el.animate(
  [
    { transform: 'translateX(0)',    composite: 'replace' },
    { transform: 'translateX(50px)', composite: 'add' },     // add at 50%
    { transform: 'translateX(100px)', composite: 'replace' }, // replace at 100%
  ],
  500
);
```

---

## iterationComposite

Controls how values build **across iterations** (only meaningful when `iterations > 1`).

```js
el.animate(
  [{ transform: 'translateX(0)' }, { transform: 'translateX(100px)' }],
  {
    duration: 1000,
    iterations: 3,
    iterationComposite: 'accumulate',  // 'replace' (default) | 'accumulate'
  }
);
// With 'accumulate':
// Iteration 1: 0px → 100px
// Iteration 2: 100px → 200px  (accumulates from previous end)
// Iteration 3: 200px → 300px
```

---

## KeyframeEffect and KeyframeEffect.setKeyframes()

`KeyframeEffect` is the low-level object that holds keyframes. You can create and modify animations more surgically with it:

```js
// Create a KeyframeEffect separately
const effect = new KeyframeEffect(
  el,                                           // target (or null)
  [{ opacity: 0 }, { opacity: 1 }],             // keyframes
  { duration: 400, easing: 'ease-out' }         // options
);

// Inspect current keyframes
effect.getKeyframes();
// Returns array of computed keyframe objects with all offsets filled in

// Replace keyframes at runtime
effect.setKeyframes([
  { transform: 'scale(1)' },
  { transform: 'scale(1.5)' }
]);

// Clone an existing effect
const cloned = new KeyframeEffect(effect);

// Use effect with Animation constructor (manual assembly)
const animation = new Animation(effect, document.timeline);
animation.play();
```

### KeyframeEffect vs element.animate()

```js
// These are equivalent:
const anim1 = el.animate(keyframes, options); // shorthand

const effect = new KeyframeEffect(el, keyframes, options); // manual
const anim2 = new Animation(effect, document.timeline);
anim2.play();
```

Use `KeyframeEffect` directly when:
- You want to clone/reuse effects across elements
- You need to modify keyframes after creation
- You're building an animation system/library
- You want to target a pseudo-element (`pseudoElement: '::before'`)

---

## ZH-TW 說明

| 格式 | 說明 |
|------|------|
| 陣列格式 | 每個物件代表一個關鍵影格，適合複雜時序 |
| 物件格式 | 每個 CSS 屬性對應一個值陣列，簡潔直觀 |
| `offset` | 關鍵影格在時間軸上的位置（0–1），不設定則自動均分 |
| `easing` 在關鍵影格上 | 只作用到「下一個」關鍵影格，不是整段動畫 |
| `composite: 'replace'` | 預設值，完全取代既有樣式 |
| `composite: 'add'` | 把 transform 列表疊加（不合併數值） |
| `composite: 'accumulate'` | 數值相加（blur(2)+blur(5)=blur(7)）|
| `iterationComposite: 'accumulate'` | 每次循環的終點作為下次起點（讓元素持續移動）|
