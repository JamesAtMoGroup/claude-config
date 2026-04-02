# CSS @keyframes Syntax & Animation Properties

## @keyframes Rule

```css
@keyframes <name> {
  <keyframe-selector> { <declarations> }
}
```

`<name>` — any valid CSS identifier or quoted string. Case-sensitive.  
`<keyframe-selector>` — `from` (= `0%`), `to` (= `100%`), or any `<percentage>`.

### Full syntax example

```css
@keyframes slide-and-grow {
  0%   { transform: translateX(-100%); opacity: 0; }
  30%  { opacity: 1; }
  68%, 72% { transform: translateX(10px); }   /* comma-grouped selectors */
  100% { transform: translateX(0);       opacity: 1; }
}
```

### Rules & edge cases

- Keyframe percentages can be listed **in any order** — browsers sort them
- If multiple `@keyframes` blocks share the same name, **the last one wins** (no cascading)
- `!important` declarations inside keyframes are **ignored**
- If `from`/`0%` or `to`/`100%` are omitted, the browser uses the element's current computed styles
- Properties that can't be animated are silently ignored; animatable ones still run
- You can animate `display` and `content-visibility` (Chrome 116+) — browser flips at 50% by default, but at 0%/100% when transitioning from/to `none`/`hidden`

### Named keyframes with quoted strings

```css
@keyframes "my complex animation" { ... }

.el { animation-name: "my complex animation"; }
```

---

## animation Shorthand

```
animation: <duration> <timing-function> <delay> <iteration-count>
           <direction> <fill-mode> <play-state> <name>;
```

Order matters for parsing. The **first `<time>` value** is duration; **second** is delay. All other values are order-independent.

```css
.el {
  /* name duration timing delay iteration direction fill-mode */
  animation: slide-in 0.4s ease-out 0.1s 1 normal forwards;

  /* shorthand — omit defaults freely */
  animation: slide-in 0.4s ease-out forwards;
}
```

> `animation-timeline`, `animation-range-start`, `animation-range-end` are **reset-only** in the shorthand — they reset to `auto`/`normal` when you write `animation:…`. Always declare them **after** the shorthand.

---

## All Sub-properties

### animation-name

```css
animation-name: none;               /* default — no animation */
animation-name: slide-in;
animation-name: fade, slide, scale; /* multiple animations */
```

### animation-duration

```css
animation-duration: 0s;     /* default */
animation-duration: 300ms;
animation-duration: 1.5s;
```

### animation-timing-function

See `timing-functions.md` for full reference.

```css
animation-timing-function: ease;          /* default */
animation-timing-function: linear;
animation-timing-function: cubic-bezier(0.25, 0.1, 0.25, 1);
animation-timing-function: steps(4, end);
```

Can be set **per keyframe** to control easing between that stop and the next:

```css
@keyframes bounce {
  0%   { transform: translateY(0);    animation-timing-function: ease-in; }
  50%  { transform: translateY(-40px); animation-timing-function: ease-out; }
  100% { transform: translateY(0); }
}
```

### animation-delay

```css
animation-delay: 0s;      /* default */
animation-delay: 200ms;   /* waits before starting */
animation-delay: -1s;     /* negative: starts mid-animation immediately */
```

Negative delays are useful for staggering pre-existing loops — element appears as if it has been running.

### animation-iteration-count

```css
animation-iteration-count: 1;         /* default */
animation-iteration-count: infinite;
animation-iteration-count: 2.5;       /* stops mid-cycle */
```

### animation-direction

```css
animation-direction: normal;            /* default — 0% → 100% each iteration */
animation-direction: reverse;           /* 100% → 0% */
animation-direction: alternate;         /* 0%→100%, then 100%→0%, alternating */
animation-direction: alternate-reverse; /* 100%→0%, then 0%→100% */
```

### animation-fill-mode

Controls styles applied **before** (delay period) and **after** (post-completion) the animation.

```css
animation-fill-mode: none;      /* default — no styles outside active period */
animation-fill-mode: forwards;  /* retain end-state styles after completion */
animation-fill-mode: backwards; /* apply from-keyframe styles during delay */
animation-fill-mode: both;      /* backwards + forwards */
```

`forwards` is the most commonly needed value — keeps the final state visible.

### animation-play-state

```css
animation-play-state: running; /* default */
animation-play-state: paused;  /* freezes at current position */
```

Use with JS or `:hover` to toggle:

```css
.el:hover { animation-play-state: paused; }
```

### animation-composition

See main file — controls how multiple animations compositing. Values: `replace` (default), `add`, `accumulate`.

### animation-timeline

See `scroll-driven.md`. Default: `auto` (document time-based timeline).

---

## Multiple Animations on One Element

Separate with commas. Values cycle if counts differ.

```css
.el {
  animation-name:     fadeIn, slideUp, pulse;
  animation-duration: 0.3s,   0.5s,    2s;
  animation-delay:    0s,     0.1s,    0.8s;
  animation-fill-mode: forwards, forwards, none;
  animation-iteration-count: 1, 1, infinite;
}

/* Or via shorthand list */
.el {
  animation:
    fadeIn  0.3s ease forwards,
    slideUp 0.5s ease 0.1s forwards,
    pulse   2s   ease 0.8s infinite;
}
```

When counts differ, values cycle: `animation-duration: 2s, 4s` with 3 animations → durations are `2s, 4s, 2s`.

---

## CSS Custom Properties in @keyframes

Custom properties can parameterize reusable keyframe definitions. The element sets the variable; the keyframe reads it via `var()`.

```css
/* Reusable slide animation parameterized by --slide-distance */
@keyframes slide-in {
  from { transform: translateX(var(--slide-distance, -100%)); opacity: 0; }
  to   { transform: translateX(0);                           opacity: 1; }
}

.panel-left  { --slide-distance: -100%; animation: slide-in 0.4s ease forwards; }
.panel-right { --slide-distance:  100%; animation: slide-in 0.4s ease forwards; }
```

### Limitation — no interpolation between variable values

Custom properties are **substituted, not interpolated**. This means you cannot animate a variable across keyframes and get smooth transitions:

```css
/* BROKEN — color will jump, not interpolate */
@keyframes bad {
  from { --color: red; }
  to   { --color: blue; }
}
.el { color: var(--color); }

/* CORRECT — animate the property directly */
@keyframes good {
  from { color: red; }
  to   { color: blue; }
}
```

Registered custom properties (`@property`) **do** support interpolation — they have a syntax type the browser can tween.

```css
@property --angle {
  syntax: '<angle>';
  initial-value: 0deg;
  inherits: false;
}

@keyframes rotate {
  to { --angle: 360deg; }
}

.el {
  transform: rotate(var(--angle));
  animation: rotate 2s linear infinite;
}
```

---

## animation-composition

Controls what happens when multiple animations affect the same property simultaneously.

```css
animation-composition: replace;    /* default — final value replaces underlying */
animation-composition: add;        /* value concatenated (e.g. blur(2) blur(3)) */
animation-composition: accumulate; /* values combined numerically (e.g. blur(5)) */
```

### Practical example

```css
/* Base: transform: rotate(10deg) on the element */
@keyframes spin { to { transform: rotate(360deg); } }

.el {
  transform: rotate(10deg);
  animation: spin 1s linear infinite;
  animation-composition: accumulate; /* ends at rotate(370deg), not rotate(360deg) */
}
```

Multiple animations with different compositions:

```css
.el {
  animation-name: anim1, anim2;
  animation-composition: accumulate, replace;
}
```

---

## JavaScript Animation Events

```javascript
el.addEventListener('animationstart',     e => console.log('started', e.elapsedTime));
el.addEventListener('animationend',       e => console.log('ended',   e.elapsedTime));
el.addEventListener('animationiteration', e => console.log('looped',  e.elapsedTime));
el.addEventListener('animationcancel',    e => console.log('cancelled'));
```
