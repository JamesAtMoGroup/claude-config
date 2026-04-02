# GSAP Performance Tips & Common Pitfalls

## GPU Acceleration (force3D)

GSAP's default `force3D: 'auto'` is the best setting for most cases:
- During animation: uses `translate3d()` / `matrix3d()` → triggers GPU layer
- After animation completes: switches back to 2D → conserves GPU memory

```js
// Config (default — best for most cases)
gsap.config({ force3D: 'auto' });

// Force GPU permanently (use sparingly — wastes VRAM)
gsap.config({ force3D: true });

// Disable GPU (fixes Safari blur on SVG/text when scaling)
gsap.to('#svgEl', { scale: 1.5, force3D: false }); // per-tween
```

**Safari blur fix:** If text or SVG elements look blurry during upscaling:
```js
gsap.to('.text', { scale: 1.1, force3D: false }); // disable 3D for this tween
```

## CSS will-change

GSAP manages GPU layers automatically. Avoid setting `will-change: transform` manually
on many elements — it wastes GPU memory. Only use it on elements you KNOW will animate
and keep the count low.

```css
/* Use sparingly */
.will-animate {
  will-change: transform, opacity;
}
```

## overwrite — Prevent Conflicting Tweens

Without overwrite, starting a new tween on an element while another is running creates conflicts:

```js
// Default (no overwrite) — tweens stack and fight
gsap.to('.box', { x: 100 });
gsap.to('.box', { x: 200 }); // conflicts with first tween!

// overwrite: 'auto' — kill only the conflicting properties (recommended default)
gsap.defaults({ overwrite: 'auto' });

// overwrite: true — kill ALL tweens on same targets before starting
gsap.to('.box', { x: 200, overwrite: true });
```

Set globally for hover/interactive animations:
```js
gsap.defaults({ overwrite: 'auto' }); // best practice for interactive sites
```

## Properties That Trigger Reflow (Avoid Animating These)

Layout-triggering properties cause the browser to recalculate layout every frame:

```js
// AVOID (triggers layout reflow):
gsap.to('.box', { width: 200, height: 100, top: 50, left: 30 });

// PREFER (GPU-composited, no reflow):
gsap.to('.box', { scaleX: 2, scaleY: 0.5, y: 50, x: 30 });
```

| Avoid | Prefer |
|-------|--------|
| `width`, `height` | `scaleX`, `scaleY` |
| `top`, `left` | `y`, `x` |
| `margin`, `padding` | `x`, `y` with `position: fixed` |
| `border-width` | `box-shadow` or outline tricks |

## FOUC (Flash of Unstyled Content)

Elements flash at their CSS state before GSAP applies starting values:

```js
// Problem: .box is visible, then suddenly jumps to x:0 after GSAP loads
gsap.from('.box', { x: -100 }); // initial state -100 applied after render

// Solution 1: gsap.set() immediately (runs synchronously)
gsap.set('.box', { x: -100, opacity: 0 });
// Then animate in
gsap.to('.box', { x: 0, opacity: 1, delay: 0.1 });

// Solution 2: CSS initial state
// .box { opacity: 0; transform: translateX(-100px); }
// Then GSAP animates to visible state

// Solution 3: visibility hidden until ready
document.querySelector('.box').style.visibility = 'hidden';
gsap.from('.box', {
  x: -100,
  opacity: 0,
  onStart() { this.targets()[0].style.visibility = 'visible'; }
});
```

## React Strict Mode Double-Invocation

React 18 Strict Mode runs effects twice in development. Without `useGSAP`, this causes:
- Duplicate animations playing simultaneously
- Conflicting states

```js
// WRONG — useEffect without cleanup
useEffect(() => {
  gsap.to('.box', { x: 100 }); // runs twice in dev, animations stack!
}, []);

// CORRECT — useGSAP handles this automatically
useGSAP(() => {
  gsap.to('.box', { x: 100 }); // properly cleaned up between invocations
});
```

## Memory Leaks — Always Kill/Revert

```js
// ScrollTrigger stays alive after navigation if not killed
const trigger = ScrollTrigger.create({ ... });
// On cleanup:
trigger.kill();

// Tween not garbage collected if stored in closure
let tween = gsap.to('.box', { x: 100 });
// On cleanup:
tween.kill();
tween = null;

// Best practice in React: use useGSAP (handles all of this automatically)
```

## Batch DOM Reads

GSAP reads properties before animating. Mixing reads/writes outside GSAP causes thrashing:

```js
// WRONG — read/write interleaving
elements.forEach(el => {
  const height = el.offsetHeight; // read (triggers layout)
  el.style.height = height + 'px'; // write (invalidates layout)
});

// CORRECT — batch reads then batch writes via GSAP
const heights = elements.map(el => el.offsetHeight); // batch read
gsap.to(elements, {
  height: (i) => heights[i] + 'px', // batch write via GSAP
});
```

## Reducing Tween Count

```js
// WRONG — one tween per element (expensive)
elements.forEach(el => gsap.to(el, { opacity: 0, duration: 1 }));

// CORRECT — one tween targeting all
gsap.to(elements, { opacity: 0, duration: 1, stagger: 0.1 });
```

## autoRemoveChildren for Fire-and-Forget Timelines

```js
// Timelines keep references to children, preventing GC
const tl = gsap.timeline({
  autoRemoveChildren: true, // children removed after completing (saves memory)
});
```

## autoSleep

GSAP powers down after 120 frames of inactivity to save CPU. In Remotion or
server-side environments, disable it:

```js
gsap.config({ autoSleep: 0 }); // never sleep (for Remotion video rendering)
```

## Debugging Tips

```js
// Enable markers (ScrollTrigger)
scrollTrigger: { markers: true }  // REMOVE IN PRODUCTION

// Log tween progress
gsap.to('.box', {
  x: 100,
  onUpdate() { console.log(this.progress().toFixed(3)); }
});

// Check what's animating on an element
gsap.getTweensOf('.box');

// Kill all animations on an element
gsap.killTweensOf('.box');

// Kill everything
gsap.globalTimeline.clear();
```

## Common Mistakes Checklist

| Mistake | Fix |
|---------|-----|
| Animating `top/left` instead of `x/y` | Use transform shorthands `x`, `y` |
| No `overwrite` on hover animations | Set `overwrite: 'auto'` |
| Missing `gsap.registerPlugin()` | Always register before using any plugin |
| Using `useEffect` in React | Use `useGSAP` from `@gsap/react` |
| Event handlers without `contextSafe` | Wrap with `contextSafe()` |
| `force3D: true` everywhere | Use default `'auto'` or `false` for SVG/text |
| `markers: true` in production | Always remove debug markers |
| Forgetting to kill ScrollTriggers | Use `useGSAP` or call `.kill()` manually |
| Animating `width`/`height` | Use `scaleX`/`scaleY` + `transformOrigin` |
| Random values in Remotion | Only use deterministic values for video rendering |
