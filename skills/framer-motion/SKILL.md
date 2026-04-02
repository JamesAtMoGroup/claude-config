---
name: framer-motion
description: Framer Motion animation library for React — motion components, variants, AnimatePresence, gestures, layout animations, scroll-driven effects. Use when animating React UI components.
---

# Framer Motion Skill

> Previously known as **framer-motion**, now published as **motion** on npm (2025). Import from `motion/react` for React projects.

## Install

```bash
npm install motion
# or legacy
npm install framer-motion
```

## Import Pattern

```tsx
// Modern (motion package, 2025+)
import { motion, AnimatePresence } from "motion/react"

// Next.js Server Components — import from client entrypoint
import * as motion from "motion/react-client"

// Legacy (still works)
import { motion, AnimatePresence } from "framer-motion"
```

## Rules Index

| File | Coverage |
|------|----------|
| [rules/core-api.md](./rules/core-api.md) | `motion` component, `animate`, `useAnimate`, `useMotionValue`, `useTransform`, `useSpring`, keyframes |
| [rules/variants.md](./rules/variants.md) | Variants system, stagger, `delayChildren`, `staggerChildren`, orchestration |
| [rules/animate-presence.md](./rules/animate-presence.md) | `AnimatePresence`, exit animations, `mode` options |
| [rules/gestures.md](./rules/gestures.md) | Drag, hover, tap, pan, `whileHover`, `whileTap`, `whileDrag` |
| [rules/layout-animations.md](./rules/layout-animations.md) | `layout`, `layoutId`, shared element transitions, `LayoutGroup` |
| [rules/scroll.md](./rules/scroll.md) | `useScroll`, `useInView`, `whileInView`, scroll-linked parallax |
| [rules/performance.md](./rules/performance.md) | GPU acceleration, `LazyMotion`, `will-change`, common pitfalls |
| [rules/react-patterns.md](./rules/react-patterns.md) | Next.js SSR, server components, `LazyMotion`, Remotion notes, ZH-TW resources |

## Quick Reference

```tsx
// Fade in on mount
<motion.div initial={{ opacity: 0 }} animate={{ opacity: 1 }} />

// Spring physics
<motion.div animate={{ x: 100 }} transition={{ type: "spring", stiffness: 300, damping: 20 }} />

// Exit animation
<AnimatePresence>
  {isVisible && <motion.div exit={{ opacity: 0 }} />}
</AnimatePresence>

// Gesture
<motion.button whileHover={{ scale: 1.05 }} whileTap={{ scale: 0.95 }} />

// Layout transition
<motion.div layout />

// Shared element
<motion.div layoutId="hero-image" />
```
