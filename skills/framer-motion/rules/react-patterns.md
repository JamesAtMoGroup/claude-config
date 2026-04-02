# React Patterns — Framer Motion

## Installation & Import

```bash
# Modern package (2025+)
npm install motion

# Legacy (still works, same API)
npm install framer-motion
```

```tsx
// Modern import
import { motion, AnimatePresence, useScroll } from "motion/react"

// Legacy import (still valid)
import { motion, AnimatePresence, useScroll } from "framer-motion"
```

---

## Next.js App Router

### Client Components

All motion components require the browser — mark files with `"use client"`.

```tsx
// components/animated-card.tsx
"use client"
import { motion } from "motion/react"

export function AnimatedCard({ children }) {
  return (
    <motion.div
      initial={{ opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
    >
      {children}
    </motion.div>
  )
}
```

### Server Components — Using the Client Entrypoint

```tsx
// components/motion-div.tsx
"use client"
import * as motion from "motion/react-client"
export { motion }

// app/page.tsx (Server Component — no "use client" needed here)
import { motion } from "@/components/motion-div"

export default function Page() {
  return <motion.div animate={{ opacity: 1 }}>Hello</motion.div>
}
```

### Page Transitions with template.tsx

Use `template.tsx` (not `layout.tsx`) for per-page transitions — it re-mounts on route changes.

```tsx
// app/template.tsx
"use client"
import { motion } from "motion/react"

export default function Template({ children }: { children: React.ReactNode }) {
  return (
    <motion.div
      initial={{ opacity: 0, y: 8 }}
      animate={{ opacity: 1, y: 0 }}
      transition={{ duration: 0.3, ease: "easeOut" }}
    >
      {children}
    </motion.div>
  )
}
```

---

## LazyMotion — Reduce Bundle Size

```tsx
// app/providers.tsx
"use client"
import { LazyMotion } from "motion/react"

// Synchronous — bundled with the app
import { domAnimation } from "motion/react"
export function Providers({ children }) {
  return <LazyMotion features={domAnimation}>{children}</LazyMotion>
}

// Asynchronous — only loaded when LazyMotion renders (better for performance)
const loadFeatures = () =>
  import("motion/react").then((mod) => mod.domAnimation)

export function Providers({ children }) {
  return <LazyMotion features={loadFeatures}>{children}</LazyMotion>
}
```

```tsx
// Inside LazyMotion, use <m.div> instead of <motion.div>
import { m } from "motion/react"

<m.div animate={{ opacity: 1 }} />   // works with LazyMotion
<motion.div animate={{ opacity: 1 }} /> // bypasses LazyMotion (full bundle)
```

---

## motion() Higher-Order Component

Wrap custom components to make them animatable.

```tsx
import { motion } from "motion/react"
import { forwardRef } from "react"

// Custom component must forward refs
const MyButton = forwardRef(({ children, ...props }, ref) => (
  <button ref={ref} {...props}>{children}</button>
))

const MotionButton = motion(MyButton)

// Now use like any motion component
<MotionButton
  whileHover={{ scale: 1.05 }}
  whileTap={{ scale: 0.95 }}
  animate={{ opacity: 1 }}
>
  Click me
</MotionButton>
```

---

## Animation on Mount Pattern

```tsx
// Stagger reveal list on first render
function FeatureList({ features }) {
  return (
    <motion.ul
      initial="hidden"
      animate="visible"
      variants={{
        hidden: {},
        visible: { transition: { staggerChildren: 0.1 } },
      }}
    >
      {features.map((f) => (
        <motion.li
          key={f}
          variants={{
            hidden: { opacity: 0, x: -20 },
            visible: { opacity: 1, x: 0 },
          }}
        >
          {f}
        </motion.li>
      ))}
    </motion.ul>
  )
}
```

---

## Conditional Animation Pattern

```tsx
// Different animations based on state
function StatusBadge({ status }) {
  const variants = {
    active: { backgroundColor: "#10b981", scale: 1 },
    inactive: { backgroundColor: "#6b7280", scale: 0.9 },
    error: { backgroundColor: "#ef4444", scale: 1, x: [0, -4, 4, -4, 4, 0] },
  }

  return (
    <motion.div
      variants={variants}
      animate={status}
      transition={{ duration: 0.3 }}
    />
  )
}
```

---

## useAnimation with External Triggers

```tsx
import { motion, useAnimation } from "motion/react"
import { useEffect } from "react"

function ErrorShake({ hasError }) {
  const controls = useAnimation()

  useEffect(() => {
    if (hasError) {
      controls.start({
        x: [0, -10, 10, -10, 10, 0],
        transition: { duration: 0.4 },
      })
    }
  }, [hasError, controls])

  return <motion.input animate={controls} />
}
```

---

## Remotion Compatibility

**Framer Motion does NOT work with Remotion.** Remotion controls time imperatively (via `useCurrentFrame`), while Framer Motion is driven by real wall-clock time. They are fundamentally incompatible.

For Remotion, use:
- Remotion's built-in `spring()` and `interpolate()` functions
- CSS keyframes via Remotion's `<AbsoluteFill>`
- Manual easing with `interpolate(frame, [0, 30], [0, 1], { extrapolateRight: "clamp" })`

```tsx
// In Remotion — use this instead of Framer Motion
import { useCurrentFrame, spring, interpolate, useVideoConfig } from "remotion"

function RemotionCard() {
  const frame = useCurrentFrame()
  const { fps } = useVideoConfig()

  const opacity = spring({ frame, fps, from: 0, to: 1, durationInFrames: 20 })
  const y = interpolate(frame, [0, 20], [30, 0], { extrapolateRight: "clamp" })

  return (
    <div style={{ opacity, transform: `translateY(${y}px)` }}>
      Card
    </div>
  )
}
```

---

## ZH-TW Resources — Traditional Chinese

| Resource | Language | Type |
|----------|----------|------|
| [Fooish React Framer Motion 教學](https://www.fooish.com/reactjs/libraries/framer-motion.html) | 繁體中文 | Tutorial |
| [iT 邦幫忙 — Who & Why framer-motion](https://ithelp.ithome.com.tw/m/articles/10290366) | 繁體中文 | Series |
| [Framer Motion 中文文件](https://motion.framer.wiki/) | 簡體中文 | Full docs mirror |
| [GitHub 中文教程](https://github.com/Yinglinhan/framer-motion-chinese-tutorial) | 簡體中文 | Tutorial repo |

iT 邦幫忙 has a full series in Traditional Chinese (繁體中文) covering the fundamentals through advanced patterns.

---

## TypeScript Types

```tsx
import type {
  Variants,
  Transition,
  MotionProps,
  TargetAndTransition,
  VariantLabels,
  AnimationControls,
} from "motion/react"

// Type your variants
const cardVariants: Variants = {
  hidden: { opacity: 0, y: 20 },
  visible: { opacity: 1, y: 0 },
}

// Extend HTML element with motion props
interface CardProps extends MotionProps {
  title: string
}

function Card({ title, ...motionProps }: CardProps) {
  return <motion.div {...motionProps}>{title}</motion.div>
}
```

---

## Common React + Motion Patterns

### Animated Counter

```tsx
import { useSpring, useMotionValue, useTransform } from "motion/react"
import { useEffect, useRef } from "react"

function AnimatedNumber({ value }: { value: number }) {
  const motionValue = useMotionValue(0)
  const rounded = useTransform(motionValue, (v) => Math.round(v))
  const spring = useSpring(motionValue, { stiffness: 100, damping: 30 })

  useEffect(() => {
    motionValue.set(value)
  }, [value, motionValue])

  return <motion.span>{rounded}</motion.span>
}
```

### Animated Route Wrapper (React Router)

```tsx
import { AnimatePresence, motion } from "motion/react"
import { useLocation, Routes, Route } from "react-router-dom"

function AnimatedRoutes() {
  const location = useLocation()

  return (
    <AnimatePresence mode="wait">
      <Routes location={location} key={location.pathname}>
        <Route path="/" element={
          <motion.div
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
          >
            <HomePage />
          </motion.div>
        } />
      </Routes>
    </AnimatePresence>
  )
}
```
