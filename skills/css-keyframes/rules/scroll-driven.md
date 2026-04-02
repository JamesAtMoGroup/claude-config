# CSS Scroll-Driven Animations

Link CSS keyframe animations to scroll position instead of time — no JavaScript required.

## Browser Support (2025/2026)

- Chrome/Edge 115+ — full support
- Safari — partial support (view() supported, some gaps)
- Firefox — limited; polyfill available

Always wrap scroll-driven animations in `@supports`:

```css
@supports (animation-timeline: scroll()) {
  /* scroll-driven animation code */
}
```

Polyfill: https://github.com/flackr/scroll-timeline

---

## Key Concept: animation-timeline

The `animation-timeline` property replaces the default time-based `DocumentTimeline` with a scroll- or view-based one.

```css
/* Default — time-based */
animation-timeline: auto;

/* Anonymous scroll progress */
animation-timeline: scroll();

/* Anonymous view progress */
animation-timeline: view();

/* Named timeline */
animation-timeline: --my-timeline;
```

**Critical ordering rule:** `animation-timeline` is a reset-only value in the `animation` shorthand. Always declare it **after** the shorthand:

```css
/* CORRECT */
.el {
  animation: grow linear;
  animation-timeline: scroll(); /* applied after shorthand */
}

/* BROKEN — shorthand resets animation-timeline to auto */
.el {
  animation-timeline: scroll();
  animation: grow linear; /* resets timeline! */
}
```

---

## Type 1: Scroll Progress Timeline

Animation progresses from 0%→100% as the **scroller** scrolls from start to end.

### Anonymous scroll timeline — `scroll()`

```css
@keyframes progress-bar {
  from { transform: scaleX(0); }
  to   { transform: scaleX(1); }
}

.progress {
  transform-origin: left;
  animation: progress-bar linear;
  animation-timeline: scroll(root block);
}
```

`scroll(<scroller> <axis>)` parameters:

| Scroller | Description |
|----------|-------------|
| `nearest` | Nearest scrollable ancestor (default) |
| `root` | Root element (`<html>`) |
| `self` | The element itself |

| Axis | Description |
|------|-------------|
| `block` | Block axis — vertical in horizontal writing mode (default) |
| `inline` | Inline axis — horizontal in horizontal writing mode |
| `y` | Vertical scroll axis |
| `x` | Horizontal scroll axis |

### Named scroll timeline

Define on the scroll container; consume on any descendant:

```css
/* Define on scroll container */
.scroll-container {
  scroll-timeline-name: --page-scroll;
  scroll-timeline-axis: block;
  /* shorthand: scroll-timeline: --page-scroll block; */
  overflow-y: scroll;
}

/* Consume on any descendant */
.progress-bar {
  animation: progress-bar linear;
  animation-timeline: --page-scroll;
}
```

---

## Type 2: View Progress Timeline

Animation progresses as an **element enters and exits the viewport** (or a scroll container). 0% = element enters from bottom; 100% = element exits from top.

### Anonymous view timeline — `view()`

```css
@keyframes fade-in-up {
  from { opacity: 0; transform: translateY(40px); }
  to   { opacity: 1; transform: translateY(0); }
}

.card {
  animation: fade-in-up ease-out both;
  animation-timeline: view();
}
```

`view(<axis> <inset>)` parameters:

```css
animation-timeline: view();                    /* block axis, auto inset */
animation-timeline: view(inline);              /* inline axis */
animation-timeline: view(block 100px);         /* 100px inset on both sides */
animation-timeline: view(block 10% auto);      /* 10% inset start, auto end */
```

Inset narrows the "active" region — positive values shrink the viewport window where the animation is active.

### Named view timeline

```css
/* Define on the observed element */
.section {
  view-timeline-name: --section-in;
  view-timeline-axis: block;
  /* shorthand: view-timeline: --section-in block; */
}

/* Animate a child or sibling */
.section .heading {
  animation: fade-in-up ease-out both;
  animation-timeline: --section-in;
}
```

---

## animation-range

Control which **portion** of the timeline's progress drives the animation. Default is `normal` (0%–100% of total range).

```css
/* Longhand */
animation-range-start: normal;   /* = 0% of timeline */
animation-range-end: normal;     /* = 100% of timeline */

/* Shorthand */
animation-range: 20% 80%;        /* only active from 20%–80% of scroll */
animation-range: entry 0% exit 100%; /* named range keywords */
```

### Named range values (view timelines)

| Range keyword | Meaning |
|---------------|---------|
| `entry` | Phase when element enters the scroller |
| `exit` | Phase when element exits the scroller |
| `entry-crossing` | Start of entry crossing threshold |
| `exit-crossing` | End of exit crossing threshold |
| `contain` | Entire time element is fully visible |
| `cover` | Entire time any part is visible |

```css
/* Animate only during entry phase */
.card {
  animation: fade-up linear both;
  animation-timeline: view();
  animation-range: entry 0% entry 100%;
}

/* Different in/out animations */
.section {
  animation: reveal linear both;
  animation-timeline: view();
  animation-range: entry 0% cover 50%; /* visible-in range */
}
```

---

## timeline-scope

Makes a named timeline accessible to **non-descendant elements**. Declare on a shared ancestor:

```css
/* Scroll container and animated element are siblings */
.wrapper {
  timeline-scope: --my-scroll; /* promote scope to this ancestor */
}

.wrapper .scroll-area {
  scroll-timeline-name: --my-scroll;
  overflow-y: scroll;
}

.wrapper .sidebar { /* sibling of .scroll-area, not a descendant */
  animation: highlight linear;
  animation-timeline: --my-scroll;
}
```

---

## Practical Patterns

### Page scroll progress bar

```css
@keyframes grow-x {
  from { transform: scaleX(0); }
  to   { transform: scaleX(1); }
}

.progress-bar {
  position: fixed;
  top: 0; left: 0;
  width: 100%;
  height: 4px;
  background: var(--accent);
  transform-origin: left;
  animation: grow-x linear;
  animation-timeline: scroll(root block);
}
```

### Scroll-reveal on entry

```css
@keyframes reveal-up {
  from { opacity: 0; translate: 0 2rem; }
  to   { opacity: 1; translate: 0 0; }
}

.reveal {
  animation: reveal-up ease-out both;
  animation-timeline: view();
  animation-range: entry 0% entry 60%;
}
```

### Parallax header image

```css
@keyframes parallax {
  from { transform: translateY(0); }
  to   { transform: translateY(-30%); }
}

.hero-image {
  animation: parallax linear;
  animation-timeline: scroll(root block);
}
```

### Sticky section highlight (via named timeline + scope)

```css
.page { timeline-scope: --sections; }

.sections-container {
  scroll-timeline-name: --sections;
  overflow-y: scroll;
}

.nav-indicator {
  animation: move-indicator linear;
  animation-timeline: --sections;
}
```

---

## Accessibility

```css
/* Respect prefers-reduced-motion */
@media (prefers-reduced-motion: reduce) {
  .reveal {
    animation: none;
    opacity: 1;
    transform: none;
  }
}

/* Or use the no-preference media query to only enable when safe */
@media (prefers-reduced-motion: no-preference) {
  .reveal {
    animation: reveal-up ease-out both;
    animation-timeline: view();
  }
}
```
