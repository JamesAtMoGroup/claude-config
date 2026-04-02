# Performance — Framer Motion

## Animate Compositor-Only Properties

Always prefer properties that the browser can animate on the GPU compositor thread without triggering layout or paint.

| Property | Performance | Notes |
|----------|------------|-------|
| `transform` (x, y, scale, rotate) | Excellent | GPU composited |
| `opacity` | Excellent | GPU composited |
| `filter` | Good | Usually GPU composited |
| `clipPath` | Good | Usually GPU composited |
| `width`, `height` | Poor | Triggers layout + paint |
| `top`, `left`, `right`, `bottom` | Poor | Triggers layout + paint |
| `margin`, `padding` | Poor | Triggers layout + paint |
| `backgroundColor` | Medium | Triggers paint only |

```tsx
// GOOD — use x/y transform instead of left/top
<motion.div animate={{ x: 100, y: 50, scale: 1.1, opacity: 0.8 }} />

// BAD — triggers layout recalculation
<motion.div animate={{ left: 100, top: 50, width: "200px" }} />

// GOOD — fake height collapse with scaleY
<motion.div animate={{ scaleY: 0 }} style={{ transformOrigin: "top" }} />

// GOOD — fake width animation with scaleX
<motion.div animate={{ scaleX: 0 }} style={{ transformOrigin: "left" }} />
```

---

## LazyMotion — Bundle Size Optimization

By default, importing `motion` includes all features (~34KB gzipped). Use `LazyMotion` to code-split and load only what you need.

```tsx
import { LazyMotion, domAnimation, m } from "motion/react"
// Use <m.div> instead of <motion.div> inside LazyMotion

function App() {
  return (
    <LazyMotion features={domAnimation}>
      <m.div animate={{ opacity: 1 }} />
    </LazyMotion>
  )
}
```

### Feature Sets

| Features | Size | Includes |
|----------|------|---------|
| `domAnimation` | Smaller | animate, variants, gestures, drag, scroll |
| `domMax` | Full | All of domAnimation + layout animations |

```tsx
// Async load — only fetched when LazyMotion renders (best for initial load)
const loadFeatures = () => import("motion/react").then(mod => mod.domAnimation)

<LazyMotion features={loadFeatures}>
  <m.div animate={{ opacity: 1 }} />
</LazyMotion>
```

---

## MotionValues for Continuous Updates

When tracking mouse position or scroll continuously, use `useMotionValue` + `useTransform` instead of React state. This bypasses React's render cycle entirely.

```tsx
// BAD — causes re-render on every mouse move
function MouseFollow() {
  const [pos, setPos] = useState({ x: 0, y: 0 })

  return (
    <div onMouseMove={(e) => setPos({ x: e.clientX, y: e.clientY })}>
      <div style={{ transform: `translate(${pos.x}px, ${pos.y}px)` }} />
    </div>
  )
}

// GOOD — zero re-renders
function MouseFollow() {
  const x = useMotionValue(0)
  const y = useMotionValue(0)

  return (
    <div onMouseMove={(e) => { x.set(e.clientX); y.set(e.clientY) }}>
      <motion.div style={{ x, y }} />
    </div>
  )
}
```

---

## will-change

Motion adds `will-change: transform` automatically for spring/tween animations. For continuous MotionValue-driven styles, you may want to hint the browser manually:

```tsx
// For elements that animate constantly (parallax, scroll-linked)
<motion.div
  style={{ y: scrollProgress, willChange: "transform" }}
/>
```

Do NOT add `will-change` to everything — it consumes GPU memory and can degrade performance if overused.

---

## Avoid Animating Too Many Elements Simultaneously

```tsx
// BAD — all 100 items animate at exactly the same time
{items.map((item) => (
  <motion.div key={item} animate={{ opacity: 1 }} />
))}

// GOOD — stagger animations to spread the work
const container = {
  visible: { transition: { staggerChildren: 0.05 } },
}
const item = {
  hidden: { opacity: 0 },
  visible: { opacity: 1 },
}
<motion.ul variants={container} animate="visible">
  {items.map((item) => (
    <motion.li key={item} variants={item} />
  ))}
</motion.ul>
```

---

## Reduce Motion Accessibility

Always respect `prefers-reduced-motion` for users who need it.

```tsx
import { useReducedMotion } from "motion/react"

function AnimatedHero() {
  const prefersReducedMotion = useReducedMotion()

  return (
    <motion.div
      initial={prefersReducedMotion ? false : { opacity: 0, y: 30 }}
      animate={{ opacity: 1, y: 0 }}
      transition={prefersReducedMotion ? { duration: 0 } : { duration: 0.5 }}
    />
  )
}
```

Or use CSS media query as a fallback:
```css
@media (prefers-reduced-motion: reduce) {
  * { animation-duration: 0.01ms !important; transition-duration: 0.01ms !important; }
}
```

---

## Avoiding Layout Thrashing with layout Prop

`layout` uses FLIP, which reads layout, then applies the animation. If you have many layout-animated elements, they can cause layout thrashing.

```tsx
// Wrap multiple layout-animated items to batch reads
// (Motion handles this internally, but avoid mixing layout animations
// with JavaScript that reads layout synchronously)

// Avoid this pattern:
onAnimationStart={() => {
  const size = ref.current.getBoundingClientRect() // forces layout read
  // ...
}}
```

---

## Common Pitfalls

### 1. Re-creating animation objects on every render

```tsx
// BAD — new object reference every render, causes animation restart
<motion.div animate={{ x: someValue }} transition={{ duration: 0.3 }} />
// If someValue doesn't change, this is fine. But:

// BAD — inline objects cause unnecessary recalculation
function Card() {
  // This object is recreated every render:
  const variants = { hover: { scale: 1.05 } }  // move outside component
  return <motion.div whileHover="hover" variants={variants} />
}

// GOOD — define variants outside the component
const cardVariants = { hover: { scale: 1.05 } }
function Card() {
  return <motion.div whileHover="hover" variants={cardVariants} />
}
```

### 2. Animating non-animatable values

```tsx
// BAD — display can't be animated
<motion.div animate={{ display: "none" }} />

// GOOD — use opacity + pointer-events, or AnimatePresence
<motion.div animate={{ opacity: 0, pointerEvents: "none" }} />
```

### 3. Using motion for every tiny element

```tsx
// Only use motion components where you actually need animation
// Regular <div> for structural/layout elements
// <motion.div> only for animated elements
```

### 4. Forgetting key on AnimatePresence children

```tsx
// AnimatePresence REQUIRES a key on its direct child to track exit
<AnimatePresence>
  {show && <motion.div key="modal" exit={{ opacity: 0 }} />}
</AnimatePresence>
```

### 5. Scroll animations blocking main thread

```tsx
// BAD — updating state on scroll
const [scrollY, setScrollY] = useState(0)
useEffect(() => {
  window.addEventListener("scroll", () => setScrollY(window.scrollY))
}, [])

// GOOD — use useScroll MotionValues (no React state, no re-renders)
const { scrollY } = useScroll()
const opacity = useTransform(scrollY, [0, 300], [1, 0])
<motion.div style={{ opacity }} />
```
