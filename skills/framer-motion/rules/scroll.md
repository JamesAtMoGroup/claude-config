# Scroll Animations — Framer Motion

## useScroll

Returns four MotionValues tracking scroll position.

```tsx
import { useScroll, useTransform, motion } from "motion/react"

function ScrollPage() {
  const { scrollY, scrollX, scrollYProgress, scrollXProgress } = useScroll()
  // scrollY / scrollX: absolute pixels scrolled
  // scrollYProgress / scrollXProgress: 0–1 relative progress
}
```

### Page-Level Scroll Progress Bar

```tsx
function ProgressBar() {
  const { scrollYProgress } = useScroll()

  return (
    <motion.div
      style={{
        scaleX: scrollYProgress,  // GPU-accelerated (scale transform)
        transformOrigin: "left",
        position: "fixed",
        top: 0, left: 0, right: 0,
        height: 4,
        background: "#6d28d9",
      }}
    />
  )
}
```

### Element-Scoped Scroll

Track scroll within a specific element, or track when an element scrolls through the viewport.

```tsx
import { useRef } from "react"

function HeroParallax() {
  const ref = useRef(null)

  // Track this element's scroll position through the viewport
  const { scrollYProgress } = useScroll({
    target: ref,
    offset: ["start end", "end start"],  // [when element enters, when it exits]
  })

  const y = useTransform(scrollYProgress, [0, 1], [-100, 100])
  const opacity = useTransform(scrollYProgress, [0, 0.5, 1], [0, 1, 0])

  return (
    <div ref={ref} style={{ height: 400 }}>
      <motion.div style={{ y, opacity }}>
        Parallax content
      </motion.div>
    </div>
  )
}
```

### offset Option

Controls when scroll progress is 0 and when it's 1.

```tsx
// Format: [startPoint, endPoint]
// Each point is [elementEdge viewportEdge]
// elementEdge: "start" | "end" | "center" | 0–1
// viewportEdge: "start" | "end" | "center" | 0–1

{ offset: ["start end", "end start"] }
// Progress 0 when element's top hits viewport bottom
// Progress 1 when element's bottom hits viewport top

{ offset: ["start start", "end end"] }
// Progress 0 when element's top hits viewport top
// Progress 1 when element's bottom hits viewport bottom

{ offset: ["center center", "center start"] }
// Progress 0 when centers align
```

---

## useScroll + useSpring (Smooth Scrolling)

Apply spring physics to the scroll progress for a smooth feel:

```tsx
function SmoothProgress() {
  const { scrollYProgress } = useScroll()
  const smoothProgress = useSpring(scrollYProgress, { stiffness: 100, damping: 30 })

  return (
    <motion.div style={{ scaleX: smoothProgress, transformOrigin: "left" }} />
  )
}
```

---

## whileInView

Animate a `motion` element when it enters the viewport. Simple and declarative.

```tsx
// Fade in when scrolled into view
<motion.div
  initial={{ opacity: 0, y: 40 }}
  whileInView={{ opacity: 1, y: 0 }}
  transition={{ duration: 0.5 }}
>
  Reveal on scroll
</motion.div>

// Only animate once (don't reverse when scrolling back up)
<motion.div
  initial={{ opacity: 0 }}
  whileInView={{ opacity: 1 }}
  viewport={{ once: true }}
/>

// Trigger when 25% of element is visible (default: any part visible)
<motion.div
  whileInView={{ opacity: 1 }}
  viewport={{ once: true, amount: 0.25 }}
/>
// amount: 0–1 (fraction visible) or "some" | "all"

// Use specific root element as viewport
<motion.div
  whileInView={{ opacity: 1 }}
  viewport={{ root: scrollContainerRef }}
/>
```

---

## useInView Hook

More control than `whileInView` — use it when you need the inView boolean for logic.

```tsx
import { useInView } from "motion/react"
import { useRef, useEffect } from "react"

function Section() {
  const ref = useRef(null)
  const isInView = useInView(ref, {
    once: true,        // only trigger once
    amount: 0.3,       // 30% visible
    margin: "0px 0px -100px 0px",  // root margin (like IntersectionObserver)
  })

  return (
    <div ref={ref}>
      <motion.h2
        animate={{ opacity: isInView ? 1 : 0, y: isInView ? 0 : 30 }}
        transition={{ duration: 0.5 }}
      >
        Section Title
      </motion.h2>
    </div>
  )
}
```

---

## Scroll-Linked Parallax

```tsx
function ParallaxSection() {
  const ref = useRef(null)
  const { scrollYProgress } = useScroll({
    target: ref,
    offset: ["start end", "end start"],
  })

  const backgroundY = useTransform(scrollYProgress, [0, 1], ["-20%", "20%"])
  const textY = useTransform(scrollYProgress, [0, 1], ["30%", "-30%"])

  return (
    <section ref={ref} style={{ position: "relative", height: "100vh", overflow: "hidden" }}>
      {/* Background moves slower */}
      <motion.div
        style={{
          position: "absolute", inset: "-20%",
          backgroundImage: "url('/hero.jpg')",
          backgroundSize: "cover",
          y: backgroundY,
        }}
      />

      {/* Text moves faster */}
      <motion.h1 style={{ y: textY, position: "relative", zIndex: 1 }}>
        Parallax Hero
      </motion.h1>
    </section>
  )
}
```

---

## Scroll-Triggered Stagger

```tsx
const container = {
  hidden: {},
  visible: { transition: { staggerChildren: 0.1 } },
}

const item = {
  hidden: { opacity: 0, y: 20 },
  visible: { opacity: 1, y: 0 },
}

function StaggeredGrid({ cards }) {
  return (
    <motion.div
      variants={container}
      initial="hidden"
      whileInView="visible"
      viewport={{ once: true, amount: 0.2 }}
    >
      {cards.map((card) => (
        <motion.div key={card.id} variants={item}>
          <Card {...card} />
        </motion.div>
      ))}
    </motion.div>
  )
}
```

---

## Horizontal Scroll

```tsx
function HorizontalScroll() {
  const ref = useRef(null)
  const { scrollXProgress } = useScroll({ container: ref })

  return (
    <div ref={ref} style={{ overflowX: "scroll", display: "flex" }}>
      {items.map((item) => (
        <div key={item} style={{ minWidth: 300, height: 400 }}>{item}</div>
      ))}
    </div>
  )
}
```

---

## Hardware-Accelerated Scroll Effects

For maximum performance, pipe `scrollYProgress` directly to a transform style (no `useTransform` needed — Motion detects it and runs on the compositor thread):

```tsx
const { scrollYProgress } = useScroll()

// Direct style binding — runs on GPU compositor thread
<motion.div style={{ opacity: scrollYProgress }} />
<motion.div style={{ scaleX: scrollYProgress }} />
```
