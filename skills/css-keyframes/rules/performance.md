# CSS Animation Performance

## The Core Rule

**Only animate `transform` and `opacity` for smooth 60fps animations.**

Everything else risks triggering layout reflow or repaint — both are CPU-heavy and cause jank.

---

## Browser Rendering Pipeline

Each frame goes through these stages (some can be skipped):

```
JS → Style → Layout → Paint → Composite
```

| Stage | Cost | Triggered by |
|-------|------|-------------|
| Layout (reflow) | Most expensive | `width`, `height`, `top`, `left`, `margin`, `padding`, `font-size` |
| Paint (repaint) | Medium | `color`, `background`, `box-shadow`, `border-color` |
| Composite | Cheapest | `transform`, `opacity` |

Composite-only properties run entirely on the GPU compositor thread — they never block the main thread.

---

## Properties: Good vs. Bad

### Compositor-safe (GPU, no layout or paint)

```css
/* These animate cheaply — prefer these always */
transform: translateX(100px);
transform: translateY(50%);
transform: scale(1.2);
transform: rotate(45deg);
transform: skew(10deg);
opacity: 0.5;

/* Modern individual transform properties (Chrome 104+, Safari 14.1+) */
translate: 100px 0;
scale: 1.2;
rotate: 45deg;
```

### Paint only (no layout, but still causes repaint)

```css
/* Acceptable for static/non-animated states, avoid animating */
color: red;
background-color: blue;
border-color: green;
box-shadow: ...;
outline: ...;
```

### Layout-triggering (avoid animating — causes reflow)

```css
/* NEVER animate these */
width: 200px;
height: 100px;
top: 50px;        /* use transform: translateY() instead */
left: 100px;      /* use transform: translateX() instead */
margin: 20px;
padding: 10px;
font-size: 2rem;
```

### Animating between display states

Animating `display` is now supported (Chrome 116+, limited support elsewhere). The browser treats `display: none` as a discrete value, flipping at 50% by default or 0%/100% when transitioning to/from none.

```css
/* Supported — Chrome 116+ */
@keyframes fade-out {
  from { opacity: 1; display: block; }
  to   { opacity: 0; display: none; }
}

.el { animation: fade-out 0.3s ease forwards; }
```

---

## Transform vs. Positional Properties

Benchmarks show the difference is dramatic:

| Approach | Frame drop rate |
|----------|----------------|
| Animating `top`/`left` | ~50% frames dropped |
| Animating `transform` | ~1% frames dropped |

```css
/* BAD — causes layout on every frame */
@keyframes move-bad {
  from { left: 0; top: 0; }
  to   { left: 200px; top: 100px; }
}

/* GOOD — compositor only */
@keyframes move-good {
  from { transform: translate(0, 0); }
  to   { transform: translate(200px, 100px); }
}
```

---

## will-change

Hints to the browser that this element will animate, so it can pre-promote it to its own GPU layer.

```css
/* Apply before animation starts */
.will-animate {
  will-change: transform;
}

/* Remove after animation ends (via JS or transition) */
```

### Values

```css
will-change: auto;            /* default — no hint */
will-change: transform;       /* promotes layer, GPU-ready */
will-change: opacity;         /* same */
will-change: transform, opacity; /* multiple */
will-change: contents;        /* entire subtree may change */
```

### Rules for will-change

1. **Use sparingly** — 1–2 elements per page at most
2. **Apply just before needed** — set on hover/focus/JS trigger, remove after
3. **Never apply to every element globally** — `* { will-change: transform }` is an anti-pattern
4. **Don't use it to prevent hypothetical problems** — only fix actual jank you can measure
5. Overuse creates excessive GPU memory consumption (crash risk on mobile)

```css
/* GOOD: apply on hover, browser prepares layer */
.card {
  transition: transform 0.3s ease;
}
.card:hover {
  will-change: transform;
  transform: scale(1.05);
}

/* BAD: applied everywhere preemptively */
* { will-change: transform; } /* never do this */
```

### Forcing GPU layer without will-change (legacy fallback)

```css
/* Old trick — create stacking context to promote layer */
.gpu-layer {
  transform: translateZ(0);       /* or: */
  transform: translate3d(0, 0, 0);
  /* Not recommended; use will-change instead */
}
```

---

## CSS contain

The `contain` property isolates an element from the rest of the document — style/layout changes inside don't affect outside.

```css
.animation-container {
  contain: layout;          /* layout changes don't escape */
  contain: paint;           /* painting is clipped to border-box */
  contain: strict;          /* layout + style + paint + size */
  contain: content;         /* layout + style + paint (no size) */
}
```

Use on animation containers that hold many moving elements to prevent the browser from recalculating the whole page layout.

---

## content-visibility

```css
.offscreen-section {
  content-visibility: auto;      /* skip rendering when offscreen */
  contain-intrinsic-size: 0 500px; /* reserve space to avoid layout shift */
}
```

Combined with animations: elements that are off-screen don't get rendered at all, reducing animation overhead for pages with many sections.

---

## Composite Layer Promotion — When It Happens Automatically

Browsers promote elements to their own compositor layers when they:
- Have `will-change: transform` or `will-change: opacity`
- Have a CSS animation or transition running on `transform` or `opacity`
- Have `position: fixed` or `position: sticky`
- Have `isolation: isolate`
- Have `transform: translateZ(0)` or `translate3d()`

Once promoted, animating `transform`/`opacity` on that element is purely GPU work.

---

## Measuring Performance

Use Chrome DevTools:
1. **Performance panel** → Record → scroll/interact → look for long frames (red bars)
2. **Layers panel** → Inspect which elements are promoted to GPU layers
3. **Rendering panel** → Enable "Paint flashing" to see what triggers repaints

Target: every frame under 16ms (60fps) or 8ms (120fps).

---

## Animation Performance Checklist

- Animate only `transform` and `opacity`
- Use `translate`, `scale`, `rotate` individual properties for clarity (modern browsers)
- Never animate `width`, `height`, `top`, `left`, `margin`, `padding`
- Use `will-change` only when you measure actual jank — apply just before, remove after
- Add `contain: layout` on animation containers with many children
- Wrap entry animations in `@media (prefers-reduced-motion: no-preference)` or disable via `prefers-reduced-motion: reduce`
- For infinite loops, make sure they're actually needed — remove when element is offscreen (IntersectionObserver + `animation-play-state`)
- Profile before optimizing — don't add `will-change` speculatively

---

## Pausing Offscreen Animations (IntersectionObserver)

```javascript
const observer = new IntersectionObserver((entries) => {
  entries.forEach(entry => {
    const el = entry.target;
    el.style.animationPlayState = entry.isIntersecting ? 'running' : 'paused';
  });
});

document.querySelectorAll('.infinite-animation').forEach(el => observer.observe(el));
```

This prevents continuous GPU work for animations not visible to the user.
