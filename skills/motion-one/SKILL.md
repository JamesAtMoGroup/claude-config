---
name: motion-one
description: Motion One — lightweight WAAPI-based animation library. animate(), timeline(), scroll(), inView(), stagger(). Use for performant web animations without the GSAP bundle size.
---

# Motion One Skill

Motion (motion.dev) is a modern animation library built on the Web Animations API (WAAPI) and native browser scroll APIs. It was created by Matt Perry (also creator of Framer Motion) and is the fastest-growing animation library with 30M+ monthly npm downloads.

## When to Use This Skill

- Building performant web animations without GSAP's bundle weight
- Scroll-linked parallax or progress-driven effects
- Intersection-based reveal animations (inView)
- Timeline-sequenced multi-element choreography
- React or Vue projects needing declarative animation APIs
- Projects where bundle size is critical

## File Map

| File | Contents |
|------|----------|
| `rules/core-api.md` | animate(), stagger(), spring(), easing, keyframes, playback controls |
| `rules/timeline.md` | timeline() sequencing, at parameter, labels, offsets |
| `rules/scroll-inview.md` | scroll(), inView(), offset, container, axis |
| `rules/react-integration.md` | motion component, AnimatePresence, variants, React hooks |
| `rules/comparison.md` | Motion vs GSAP vs Framer Motion — when to use which |

## Quick Reference

```bash
npm install motion
```

```js
// JavaScript (hybrid engine, 17kb)
import { animate, timeline, scroll, inView, stagger } from "motion"

// Mini engine (WAAPI only, 2.3kb)
import { animate } from "motion/mini"

// React
import { motion, AnimatePresence, useScroll, useInView } from "motion/react"

// Vue (motion-v package)
import { motion, useAnimate, useScroll } from "motion-v"
```

## Two Engines

| Engine | Import | Size | Capability |
|--------|--------|------|------------|
| Mini | `motion/mini` | ~2.3kb | WAAPI only — transforms, opacity, filter. Hardware accelerated. |
| Hybrid | `motion` | ~17kb | Mini + JS values, sequences, motion values, Three.js, canvas |

## Key Principle

Motion defers to the browser's WAAPI for hardware-accelerated animations (transforms, opacity, filter) and only falls back to JS (`requestAnimationFrame`) when animating values the browser can't natively handle (e.g., custom properties, canvas). This makes it faster than pure-JS libraries for the common case.
