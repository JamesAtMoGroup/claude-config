# Core API — Framer Motion / Motion

## motion Component

The `motion` component is the foundation. It wraps any HTML or SVG element and adds animation superpowers via props.

```tsx
import { motion } from "motion/react"

// Basic fade + slide in
<motion.div
  initial={{ opacity: 0, y: 20 }}
  animate={{ opacity: 1, y: 0 }}
  transition={{ duration: 0.4 }}
/>

// SVG
<motion.circle cx={50} cy={50} r={25} animate={{ scale: 1.2 }} />
```

### Core Props

| Prop | Type | Purpose |
|------|------|---------|
| `initial` | VariantLabel \| TargetAndTransition | State before mount |
| `animate` | VariantLabel \| TargetAndTransition | Target animated state |
| `exit` | TargetAndTransition | State when unmounting (needs AnimatePresence) |
| `transition` | Transition | Controls timing, easing, spring |
| `style` | MotionStyle | Can accept MotionValues |
| `variants` | Variants | Named animation states |
| `whileHover` | VariantLabel \| TargetAndTransition | Animate on hover |
| `whileTap` | VariantLabel \| TargetAndTransition | Animate on press |
| `whileDrag` | VariantLabel \| TargetAndTransition | Animate while dragging |
| `whileInView` | VariantLabel \| TargetAndTransition | Animate when in viewport |
| `whileFocus` | VariantLabel \| TargetAndTransition | Animate when focused |

### Animatable Properties

```tsx
// Transform (GPU-accelerated — prefer these)
x, y, z, rotate, rotateX, rotateY, rotateZ
scale, scaleX, scaleY
skew, skewX, skewY
originX, originY, originZ
perspective

// Opacity
opacity

// Color
backgroundColor, color, borderColor, fill, stroke

// Dimensions (triggers layout — avoid for perf)
width, height, top, left, right, bottom
```

---

## animate() — Imperative Animation

The standalone `animate()` function for imperative control outside React components.

```tsx
import { animate } from "motion/react"

// Animate a DOM element
animate("#box", { x: 100 }, { duration: 0.5 })

// Animate a single value (returns an animation controller)
const animation = animate(0, 100, {
  duration: 1,
  onUpdate: (latest) => console.log(latest),
})

// Control
animation.pause()
animation.play()
animation.stop()
animation.cancel()

// With sequence using animateSequence (Motion 11+)
import { animateSequence } from "motion"
animateSequence([
  ["#box", { x: 100 }],
  ["#box", { y: 100 }, { at: "+0.2" }],
])
```

---

## useAnimate

Manual animation hook — returns a `[scope, animate]` pair. `scope` is a ref to the root element; `animate` is an imperative animation function scoped to that subtree.

```tsx
import { useAnimate, stagger } from "motion/react"
import { useEffect } from "react"

function Component() {
  const [scope, animate] = useAnimate()

  const handleClick = async () => {
    // Animate scoped children
    await animate("li", { opacity: 0, x: -20 }, { delay: stagger(0.05) })
    await animate("li", { opacity: 1, x: 0 })
  }

  return (
    <ul ref={scope}>
      <li>Item 1</li>
      <li>Item 2</li>
      <li>Item 3</li>
    </ul>
  )
}
```

### stagger() Helper

```tsx
import { stagger } from "motion/react"

// Stagger 0.1s between each child
animate("li", { opacity: 1 }, { delay: stagger(0.1) })

// Stagger from last child
animate("li", { opacity: 1 }, { delay: stagger(0.1, { from: "last" }) })

// Stagger from center
animate("li", { opacity: 1 }, { delay: stagger(0.1, { from: "center" }) })
```

---

## useMotionValue

Creates a reactive value that drives animations without causing React re-renders.

```tsx
import { useMotionValue, motion } from "motion/react"

function DragBox() {
  const x = useMotionValue(0)

  return (
    <motion.div
      style={{ x }}
      drag="x"
      // x updates as the user drags — no re-renders
    />
  )
}
```

### Methods

```tsx
const x = useMotionValue(0)

x.get()           // get current value
x.set(100)        // set value (triggers subscribers)
x.getVelocity()   // get current velocity (px/s)

// Subscribe to changes
const unsubscribe = x.on("change", (latest) => {
  console.log(latest)
})
unsubscribe()
```

---

## useTransform

Derives a new MotionValue by mapping one range to another.

```tsx
import { useTransform, useMotionValue, motion } from "motion/react"

function ParallaxHero() {
  const { scrollY } = useScroll()

  // Map scrollY 0–500 → opacity 1–0
  const opacity = useTransform(scrollY, [0, 500], [1, 0])

  // Map scrollY → translateY for parallax
  const y = useTransform(scrollY, [0, 500], [0, -150])

  return <motion.div style={{ opacity, y }}>Hero</motion.div>
}
```

### Clamp & Extrapolation

```tsx
// Clamp output to defined range (default: extrapolate beyond bounds)
const opacity = useTransform(scrollY, [0, 500], [1, 0], { clamp: true })
```

### useTransform with Custom Function

```tsx
const doubled = useTransform(x, (latest) => latest * 2)
```

---

## useSpring

Creates a MotionValue that animates to its target with spring physics.

```tsx
import { useSpring, useMotionValue, motion } from "motion/react"

function SmoothFollow() {
  const x = useMotionValue(0)
  const springX = useSpring(x, { stiffness: 300, damping: 30 })

  return (
    <motion.div
      style={{ x: springX }}
      onMouseMove={(e) => x.set(e.clientX)}
    />
  )
}
```

### Spring Config Options

| Option | Default | Description |
|--------|---------|-------------|
| `stiffness` | 100 | Spring stiffness (higher = faster) |
| `damping` | 10 | Opposing force (higher = less bounce) |
| `mass` | 1 | Mass of object |
| `velocity` | 0 | Initial velocity |
| `restSpeed` | 0.01 | Threshold to stop |
| `restDelta` | 0.01 | Position threshold to stop |

```tsx
// Bouncy
{ stiffness: 400, damping: 10 }

// Smooth
{ stiffness: 150, damping: 30 }

// Stiff, no bounce
{ stiffness: 500, damping: 50 }
```

---

## Keyframes

Define arrays as keyframe sequences.

```tsx
// Animate through a sequence of values
<motion.div animate={{ x: [0, 100, 50, 200] }} />

// Null wildcard = use current value
<motion.div animate={{ x: [null, 100, 0] }} />

// Custom timing with `times` (0–1 progress)
<motion.div
  animate={{ x: [0, 100, 0] }}
  transition={{
    duration: 2,
    times: [0, 0.7, 1],   // spend 70% going to 100, 30% returning
    ease: ["easeIn", "easeOut"],  // per-segment easing
  }}
/>
```

---

## Transition Options

```tsx
// Tween (default for most properties)
transition={{ type: "tween", duration: 0.5, ease: "easeInOut" }}

// Spring (default for x, y, scale, rotate)
transition={{ type: "spring", stiffness: 300, damping: 25 }}

// Inertia (for drag momentum)
transition={{ type: "inertia", velocity: 200 }}

// Easing options
ease: "linear" | "easeIn" | "easeOut" | "easeInOut" | "circIn" | "circOut"
      | "backIn" | "backOut" | "backInOut" | "anticipate"
      | [0.17, 0.67, 0.83, 0.67]  // custom cubic bezier

// Repeat
transition={{ repeat: Infinity, repeatType: "reverse", duration: 1 }}
// repeatType: "loop" | "reverse" | "mirror"

// Delay
transition={{ delay: 0.2 }
```
