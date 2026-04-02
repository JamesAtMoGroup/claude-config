# Motion One — React & Vue Integration

## React (Motion for React)

Motion for React (previously Framer Motion) is the same package — `motion/react`. It provides declarative animation via the `<motion.*>` component family.

### Install

```bash
npm install motion
```

```jsx
import { motion, AnimatePresence, useScroll, useInView, useAnimate } from "motion/react"
```

---

## `<motion.*>` Component

Prefix any HTML/SVG tag with `motion.` to unlock animation props:

```jsx
// Basic fade + slide in
<motion.div
  initial={{ opacity: 0, y: 20 }}
  animate={{ opacity: 1, y: 0 }}
  transition={{ duration: 0.4, ease: "easeOut" }}
>
  Hello
</motion.div>

// Exit animation
<motion.div
  initial={{ opacity: 0 }}
  animate={{ opacity: 1 }}
  exit={{ opacity: 0, y: -20 }}
/>

// Gesture props (no JS event handlers needed)
<motion.button
  whileHover={{ scale: 1.05 }}
  whileTap={{ scale: 0.95 }}
  whileFocus={{ boxShadow: "0 0 0 3px blue" }}
/>
```

### Animation Props

| Prop | Description |
|------|-------------|
| `initial` | Starting state (or `false` to disable enter animation) |
| `animate` | Target state to animate to |
| `exit` | State to animate to when removed (requires `AnimatePresence`) |
| `transition` | Duration, ease, delay, spring config, etc. |
| `whileHover` | Animate while cursor hovers |
| `whileTap` | Animate while pressed |
| `whileFocus` | Animate while focused |
| `whileDrag` | Animate while dragging |
| `whileInView` | Animate while in viewport |

### `whileInView`

```jsx
<motion.section
  initial={{ opacity: 0, y: 40 }}
  whileInView={{ opacity: 1, y: 0 }}
  viewport={{ once: true, amount: 0.3 }}
  transition={{ duration: 0.5 }}
>
  Reveals once on scroll
</motion.section>
```

`viewport` options: `once`, `amount` (0–1 or `"some"`/`"all"`), `root`, `margin`.

---

## Variants

Define named animation states for reuse and propagation:

```jsx
const containerVariants = {
  hidden: { opacity: 0 },
  visible: {
    opacity: 1,
    transition: {
      staggerChildren: 0.1,  // staggers children automatically
      delayChildren: 0.2,
    },
  },
}

const itemVariants = {
  hidden: { opacity: 0, y: 20 },
  visible: { opacity: 1, y: 0 },
}

function List() {
  return (
    <motion.ul variants={containerVariants} initial="hidden" animate="visible">
      {items.map((item) => (
        <motion.li key={item.id} variants={itemVariants}>
          {item.text}
        </motion.li>
      ))}
    </motion.ul>
  )
}
```

Children inherit parent's `initial`/`animate` variant names automatically.

---

## AnimatePresence

Enables exit animations for unmounted components:

```jsx
import { AnimatePresence, motion } from "motion/react"

function Modal({ isOpen }) {
  return (
    <AnimatePresence>
      {isOpen && (
        <motion.div
          key="modal"
          initial={{ opacity: 0, scale: 0.9 }}
          animate={{ opacity: 1, scale: 1 }}
          exit={{ opacity: 0, scale: 0.9 }}
          transition={{ duration: 0.25 }}
          className="modal"
        />
      )}
    </AnimatePresence>
  )
}
```

### AnimatePresence Modes

```jsx
// "sync" (default) — in and out animate simultaneously
// "wait" — waits for exit to finish before entering next
// "popLayout" — exiting elements are removed from layout flow immediately

<AnimatePresence mode="wait">
  <motion.div key={currentPage} ... />
</AnimatePresence>
```

---

## Layout Animations

Animate layout changes (resize, reorder) with FLIP:

```jsx
// Single element layout change
<motion.div layout />

// Layout + shared element between pages
<motion.div layoutId="hero-image" />
```

```jsx
// Reordering list
function SortableList({ items }) {
  return (
    <ul>
      <AnimatePresence>
        {items.map((item) => (
          <motion.li
            key={item.id}
            layout
            exit={{ opacity: 0 }}
          />
        ))}
      </AnimatePresence>
    </ul>
  )
}
```

---

## useAnimate Hook

For imperative animations scoped to a component:

```jsx
import { useAnimate } from "motion/react"

function Component() {
  const [scope, animate] = useAnimate()

  const handleClick = async () => {
    // CSS selectors are scoped to this component's DOM subtree
    await animate("li", { opacity: [0, 1], x: [-20, 0] }, { delay: stagger(0.05) })
    await animate(".badge", { scale: [0, 1] }, { type: "spring" })
  }

  return (
    <div ref={scope}>
      <ul>
        <li>Item 1</li>
        <li>Item 2</li>
      </ul>
      <span className="badge">New</span>
      <button onClick={handleClick}>Animate</button>
    </div>
  )
}
```

Animations started via `useAnimate` are automatically cleaned up when the component unmounts.

---

## useScroll Hook

Scroll-linked animations via motion values:

```jsx
import { useScroll, useTransform, motion } from "motion/react"
import { useRef } from "react"

function ParallaxSection() {
  const ref = useRef(null)
  const { scrollYProgress } = useScroll({
    target: ref,
    offset: ["start end", "end start"],
  })

  // Map scroll progress to CSS values
  const y = useTransform(scrollYProgress, [0, 1], ["-20%", "20%"])
  const opacity = useTransform(scrollYProgress, [0, 0.3, 0.7, 1], [0, 1, 1, 0])

  return (
    <section ref={ref}>
      <motion.div style={{ y, opacity }} className="parallax-bg" />
    </section>
  )
}
```

### useScroll Options

```js
const { scrollX, scrollY, scrollXProgress, scrollYProgress } = useScroll({
  container: containerRef,     // track a scrollable element
  target: elementRef,          // track element's position in container
  offset: ["start end", "end start"],
  axis: "x",                   // default "y"
})
```

---

## useInView Hook

```jsx
import { useInView } from "motion/react"
import { useRef } from "react"

function FadeInSection({ children }) {
  const ref = useRef(null)
  const isInView = useInView(ref, { once: true, amount: 0.3 })

  return (
    <div
      ref={ref}
      style={{
        opacity: isInView ? 1 : 0,
        transform: isInView ? "translateY(0)" : "translateY(30px)",
        transition: "all 0.5s ease",
      }}
    >
      {children}
    </div>
  )
}
```

---

## Vue Integration (motion-v)

Motion for Vue — separate package `motion-v`:

```bash
npm install motion-v
```

### Basic Usage

```vue
<script setup>
import { Motion } from "motion-v"
</script>

<template>
  <Motion
    tag="div"
    :initial="{ opacity: 0, y: 20 }"
    :animate="{ opacity: 1, y: 0 }"
    :exit="{ opacity: 0 }"
    :transition="{ duration: 0.4 }"
  />
</template>
```

### Vue Composables

```vue
<script setup>
import { useAnimate, useScroll, useInView } from "motion-v"
import { ref, onMounted } from "vue"

const [scope, animate] = useAnimate()

onMounted(() => {
  animate("li", { opacity: [0, 1] }, { delay: stagger(0.1) })
})

// Scroll-linked
const containerRef = ref(null)
const { scrollYProgress } = useScroll({ target: containerRef })

// InView
const boxRef = ref(null)
const isInView = useInView(boxRef, { once: true })
</script>
```

---

## Reduced Motion

Respect user's OS motion preference:

```jsx
// React — check with hook
import { useReducedMotion } from "motion/react"

function AnimatedComponent() {
  const shouldReduceMotion = useReducedMotion()

  return (
    <motion.div
      animate={{ x: shouldReduceMotion ? 0 : 100 }}
    />
  )
}
```

```js
// Vanilla JS — check directly
const prefersReduced = window.matchMedia("(prefers-reduced-motion: reduce)").matches

animate(el, {
  x: prefersReduced ? 0 : 100,
  opacity: [0, 1],  // opacity is always fine
})
```

---

## Solid.js

Motion has experimental Solid support via `@motionone/solid` (community maintained). For Solid, prefer vanilla `motion` with `onMount`/`onCleanup`:

```jsx
import { onMount, onCleanup } from "solid-js"
import { animate, scroll } from "motion"

function Component() {
  let el

  onMount(() => {
    const anim = animate(el, { opacity: [0, 1] })
    const stopScroll = scroll(/* ... */)

    onCleanup(() => {
      anim.cancel()
      stopScroll()
    })
  })

  return <div ref={el}>...</div>
}
```
