# CSS Animation Patterns — Copy-Paste Library

All patterns follow the same structure: define `@keyframes`, then apply with `animation`. Add `animation-fill-mode: forwards` where you want the end state to persist.

---

## Fade

### Fade In

```css
@keyframes fadeIn {
  from { opacity: 0; }
  to   { opacity: 1; }
}

.fade-in { animation: fadeIn 0.3s ease forwards; }
```

### Fade Out

```css
@keyframes fadeOut {
  from { opacity: 1; }
  to   { opacity: 0; }
}

.fade-out { animation: fadeOut 0.3s ease forwards; }
```

### Fade In + Scale (modal/dialog entrance)

```css
@keyframes fadeInScale {
  from { opacity: 0; transform: scale(0.95); }
  to   { opacity: 1; transform: scale(1); }
}

.modal { animation: fadeInScale 0.2s cubic-bezier(0.2, 0, 0, 1) forwards; }
```

---

## Slide

### Slide In from Bottom

```css
@keyframes slideInUp {
  from { opacity: 0; transform: translateY(1.5rem); }
  to   { opacity: 1; transform: translateY(0); }
}

.slide-in-up { animation: slideInUp 0.4s cubic-bezier(0.2, 0, 0, 1) forwards; }
```

### Slide In from Left

```css
@keyframes slideInLeft {
  from { opacity: 0; transform: translateX(-1.5rem); }
  to   { opacity: 1; transform: translateX(0); }
}

.slide-in-left { animation: slideInLeft 0.4s cubic-bezier(0.2, 0, 0, 1) forwards; }
```

### Slide In from Right

```css
@keyframes slideInRight {
  from { opacity: 0; transform: translateX(1.5rem); }
  to   { opacity: 1; transform: translateX(0); }
}

.slide-in-right { animation: slideInRight 0.4s cubic-bezier(0.2, 0, 0, 1) forwards; }
```

### Slide Out to Top (exit)

```css
@keyframes slideOutUp {
  from { opacity: 1; transform: translateY(0); }
  to   { opacity: 0; transform: translateY(-1.5rem); }
}

.slide-out-up { animation: slideOutUp 0.3s ease-in forwards; }
```

### Full-panel slide in (drawer/sheet)

```css
@keyframes slideInFromRight {
  from { transform: translateX(100%); }
  to   { transform: translateX(0); }
}

.drawer {
  animation: slideInFromRight 0.35s cubic-bezier(0.2, 0, 0, 1) forwards;
}
```

---

## Scale

### Scale In (pop-in)

```css
@keyframes scaleIn {
  from { transform: scale(0); opacity: 0; }
  to   { transform: scale(1); opacity: 1; }
}

.scale-in { animation: scaleIn 0.2s cubic-bezier(0.34, 1.56, 0.64, 1) forwards; }
```

### Scale Out (pop-out)

```css
@keyframes scaleOut {
  from { transform: scale(1); opacity: 1; }
  to   { transform: scale(0); opacity: 0; }
}

.scale-out { animation: scaleOut 0.15s ease-in forwards; }
```

### Heartbeat

```css
@keyframes heartbeat {
  0%   { transform: scale(1); }
  14%  { transform: scale(1.3); }
  28%  { transform: scale(1); }
  42%  { transform: scale(1.3); }
  70%  { transform: scale(1); }
}

.heartbeat { animation: heartbeat 1.3s ease-in-out infinite; }
```

---

## Shake / Error

```css
@keyframes shake {
  0%, 100% { transform: translateX(0); }
  10%, 50%, 90% { transform: translateX(-6px); }
  30%, 70% { transform: translateX(6px); }
}

.shake { animation: shake 0.5s cubic-bezier(0.36, 0.07, 0.19, 0.97) forwards; }
```

### Horizontal wobble (gentler)

```css
@keyframes wobble {
  0%   { transform: rotate(0deg); }
  15%  { transform: rotate(-5deg); }
  30%  { transform: rotate(5deg); }
  45%  { transform: rotate(-3deg); }
  60%  { transform: rotate(3deg); }
  75%  { transform: rotate(-1deg); }
  100% { transform: rotate(0deg); }
}

.wobble { animation: wobble 0.6s ease-in-out forwards; }
```

---

## Bounce

### Bounce (attention — element bounces in place)

```css
@keyframes bounce {
  0%, 100% {
    transform: translateY(0);
    animation-timing-function: cubic-bezier(0.8, 0, 1, 1);
  }
  50% {
    transform: translateY(-30%);
    animation-timing-function: cubic-bezier(0, 0, 0.2, 1);
  }
}

.bounce { animation: bounce 1s infinite; }
```

### Bounce In (entrance)

```css
@keyframes bounceIn {
  0%   { transform: scale(0.3); opacity: 0; }
  50%  { transform: scale(1.05); }
  70%  { transform: scale(0.9); }
  100% { transform: scale(1); opacity: 1; }
}

.bounce-in { animation: bounceIn 0.6s cubic-bezier(0.68, -0.55, 0.27, 1.55) forwards; }
```

---

## Spin / Rotate

### Continuous spin (loading icon)

```css
@keyframes spin {
  to { transform: rotate(360deg); }
}

.spin { animation: spin 1s linear infinite; }
```

### Reverse spin

```css
.spin-reverse { animation: spin 1s linear infinite reverse; }
```

### Spin with ease (single rotation)

```css
.spin-once { animation: spin 0.6s ease-in-out forwards; }
```

---

## Pulse / Glow

### Opacity pulse (skeleton loader base)

```css
@keyframes pulse {
  0%, 100% { opacity: 1; }
  50%       { opacity: 0.5; }
}

.pulse { animation: pulse 2s cubic-bezier(0.4, 0, 0.6, 1) infinite; }
```

### Glow pulse (CTA button, notification badge)

```css
@keyframes glowPulse {
  0%, 100% { box-shadow: 0 0 0 0 rgba(99, 102, 241, 0.4); }
  50%       { box-shadow: 0 0 0 12px rgba(99, 102, 241, 0); }
}

.glow-pulse { animation: glowPulse 2s ease-in-out infinite; }
```

### Ping (ripple outward — notification dot)

```css
@keyframes ping {
  75%, 100% {
    transform: scale(2);
    opacity: 0;
  }
}

.ping { animation: ping 1s cubic-bezier(0, 0, 0.2, 1) infinite; }
```

Usage pattern (badge dot with pinging overlay):

```html
<span class="relative flex h-3 w-3">
  <span class="ping absolute inline-flex h-full w-full rounded-full bg-sky-400 opacity-75"></span>
  <span class="relative inline-flex h-3 w-3 rounded-full bg-sky-500"></span>
</span>
```

---

## Skeleton Loading

### Shimmer sweep (most common pattern)

```css
@keyframes shimmer {
  from { background-position: -200% 0; }
  to   { background-position: 200% 0; }
}

.skeleton {
  background: linear-gradient(
    90deg,
    #e2e8f0 25%,
    #f1f5f9 50%,
    #e2e8f0 75%
  );
  background-size: 200% 100%;
  animation: shimmer 1.5s linear infinite;
  border-radius: 4px;
}
```

Usage:

```html
<div class="skeleton" style="height: 1rem; width: 70%; margin-bottom: 0.5rem;"></div>
<div class="skeleton" style="height: 1rem; width: 90%; margin-bottom: 0.5rem;"></div>
<div class="skeleton" style="height: 1rem; width: 50%;"></div>
```

### Dark mode skeleton

```css
@media (prefers-color-scheme: dark) {
  .skeleton {
    background: linear-gradient(90deg, #1e293b 25%, #334155 50%, #1e293b 75%);
    background-size: 200% 100%;
  }
}
```

### Skeleton card component

```css
.skeleton-card {
  padding: 1.5rem;
  border-radius: 0.75rem;
  background: white;
  box-shadow: 0 1px 3px rgba(0,0,0,0.1);
}

.skeleton-avatar {
  width: 3rem;
  height: 3rem;
  border-radius: 50%;
}

.skeleton-line { height: 0.875rem; border-radius: 0.25rem; }
.skeleton-line + .skeleton-line { margin-top: 0.5rem; }
```

---

## Stagger (Sequential Entrance)

```css
@keyframes fadeSlideUp {
  from { opacity: 0; transform: translateY(1rem); }
  to   { opacity: 1; transform: translateY(0); }
}

.stagger-item {
  animation: fadeSlideUp 0.4s ease forwards;
  opacity: 0; /* initial state before animation */
}

.stagger-item:nth-child(1) { animation-delay: 0ms; }
.stagger-item:nth-child(2) { animation-delay: 80ms; }
.stagger-item:nth-child(3) { animation-delay: 160ms; }
.stagger-item:nth-child(4) { animation-delay: 240ms; }
.stagger-item:nth-child(5) { animation-delay: 320ms; }
```

### CSS custom property stagger (cleaner for dynamic lists)

```css
.stagger-item {
  animation: fadeSlideUp 0.4s ease calc(var(--i, 0) * 80ms) forwards;
  opacity: 0;
}
```

```html
<li style="--i: 0" class="stagger-item">Item 1</li>
<li style="--i: 1" class="stagger-item">Item 2</li>
<li style="--i: 2" class="stagger-item">Item 3</li>
```

---

## Typewriter

```css
@keyframes typing {
  from { width: 0; }
  to   { width: 28ch; }
}

@keyframes blink-cursor {
  from, to { border-right-color: transparent; }
  50%       { border-right-color: currentColor; }
}

.typewriter {
  overflow: hidden;
  white-space: nowrap;
  border-right: 2px solid;
  width: 28ch;
  animation:
    typing       3s steps(28, end) forwards,
    blink-cursor 0.75s step-end infinite;
}
```

---

## Marquee (horizontal scroll loop)

```css
@keyframes marquee {
  from { transform: translateX(0); }
  to   { transform: translateX(-50%); }
}

.marquee-track {
  display: flex;
  width: max-content;
  animation: marquee 20s linear infinite;
}

/* Content must be duplicated to fill: [A B C] [A B C] */
/* Then translateX(-50%) moves exactly one copy's worth */
```

---

## Reduced Motion Override

Always add at the end of your animation CSS:

```css
@media (prefers-reduced-motion: reduce) {
  *,
  *::before,
  *::after {
    animation-duration: 0.01ms !important;
    animation-iteration-count: 1 !important;
    transition-duration: 0.01ms !important;
  }
}
```

For specific critical animations (like shimmer for skeleton), provide a static fallback:

```css
@media (prefers-reduced-motion: reduce) {
  .skeleton {
    animation: none;
    background: #e2e8f0;
  }
}
```
