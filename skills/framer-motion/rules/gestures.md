# Gestures — Framer Motion

Motion detects hover, tap, pan, drag, focus, and inView gestures. Each gesture has:
- **while- props**: Animation state while gesture is active
- **event handlers**: Callbacks for fine-grained control

---

## whileHover

Animates when pointer hovers the element.

```tsx
<motion.button
  whileHover={{ scale: 1.05, backgroundColor: "#6d28d9" }}
  transition={{ type: "spring", stiffness: 400, damping: 20 }}
>
  Hover me
</motion.button>

// With variant
const buttonVariants = {
  rest: { scale: 1 },
  hover: { scale: 1.05, rotate: 2 },
}

<motion.div variants={buttonVariants} initial="rest" whileHover="hover" />
```

### Hover Event Handlers

```tsx
<motion.div
  onHoverStart={(event, info) => console.log("Hover start", event)}
  onHoverEnd={(event, info) => console.log("Hover end", event)}
/>
```

---

## whileTap (Press)

Animates while pointer is pressed down. Also triggers on Enter key for keyboard accessibility.

```tsx
<motion.button
  whileHover={{ scale: 1.05 }}
  whileTap={{ scale: 0.95 }}
>
  Click me
</motion.button>

// Tap events
<motion.div
  onTapStart={(event, info) => console.log("Tap start")}
  onTap={(event, info) => console.log("Tapped")}
  onTapCancel={(event, info) => console.log("Tap cancelled")}
/>
```

---

## whileFocus

Animates when element receives keyboard focus.

```tsx
<motion.input
  whileFocus={{ scale: 1.02, borderColor: "#6d28d9" }}
/>
```

---

## Drag

Enable dragging with `drag` prop.

```tsx
// Free drag (x and y)
<motion.div drag />

// Axis-locked drag
<motion.div drag="x" />
<motion.div drag="y" />

// Constrained drag within parent
<motion.div drag dragConstraints={{ top: 0, left: 0, right: 300, bottom: 300 }} />

// Constrain to parent element using ref
import { useRef } from "react"
function ConstrainedDrag() {
  const constrainRef = useRef(null)
  return (
    <div ref={constrainRef} style={{ width: 300, height: 300, overflow: "hidden" }}>
      <motion.div drag dragConstraints={constrainRef} />
    </div>
  )
}

// Elastic drag (snap back)
<motion.div drag dragElastic={0.5} dragConstraints={{ left: 0, right: 0, top: 0, bottom: 0 }} />
// dragElastic: 0 = no elasticity, 1 = full elasticity (default: 0.5)

// Momentum on release
<motion.div drag dragMomentum={true} />   // default true

// whileDrag
<motion.div drag whileDrag={{ scale: 1.1, opacity: 0.8 }} />
```

### Drag Event Handlers

```tsx
<motion.div
  drag
  onDragStart={(event, info) => {
    console.log("Started at", info.point)
  }}
  onDrag={(event, info) => {
    // info.point: current position
    // info.delta: delta since last event
    // info.offset: total offset from start
    // info.velocity: current velocity
    console.log("Dragging", info.offset)
  }}
  onDragEnd={(event, info) => {
    console.log("Ended. Velocity:", info.velocity)
  }}
/>
```

### Drag Transition (Snap)

```tsx
// Snap back to origin on release
<motion.div
  drag
  dragConstraints={{ left: 0, right: 0, top: 0, bottom: 0 }}
  dragTransition={{ bounceStiffness: 600, bounceDamping: 20 }}
/>
```

---

## Pan

Pan detects when a pointer presses and moves more than 3px. Unlike drag, it doesn't apply transforms.

```tsx
<motion.div
  onPanStart={(event, info) => console.log("Pan start")}
  onPan={(event, info) => {
    // info.point, info.delta, info.offset, info.velocity
  }}
  onPanEnd={(event, info) => console.log("Pan end")}
/>
```

---

## Combined Gesture Example — Draggable Card

```tsx
import { motion, useMotionValue, useTransform } from "motion/react"

function SwipeCard() {
  const x = useMotionValue(0)
  const rotate = useTransform(x, [-200, 200], [-20, 20])
  const opacity = useTransform(x, [-200, 0, 200], [0, 1, 0])

  return (
    <motion.div
      style={{ x, rotate, opacity }}
      drag="x"
      dragConstraints={{ left: 0, right: 0 }}
      dragElastic={0.8}
      whileDrag={{ scale: 1.05 }}
      onDragEnd={(_, info) => {
        if (Math.abs(info.offset.x) > 100) {
          // Swiped far enough — do something
          console.log(info.offset.x > 0 ? "Swiped right" : "Swiped left")
        }
      }}
    >
      Card content
    </motion.div>
  )
}
```

---

## Slider / Knob Example

```tsx
function Slider({ min = 0, max = 100 }) {
  const constrainRef = useRef(null)
  const x = useMotionValue(0)
  const trackWidth = 200
  const value = useTransform(x, [0, trackWidth], [min, max])

  return (
    <div ref={constrainRef} style={{ width: trackWidth, height: 8, background: "#e5e7eb", borderRadius: 4 }}>
      <motion.div
        drag="x"
        dragConstraints={constrainRef}
        dragElastic={0}
        dragMomentum={false}
        style={{ x, width: 24, height: 24, background: "#6d28d9", borderRadius: "50%", y: -8 }}
        whileHover={{ scale: 1.2 }}
        whileDrag={{ scale: 1.1 }}
      />
    </div>
  )
}
```

---

## Pointer Events Passthrough

```tsx
// Disable gesture detection (for nested drag scenarios)
<motion.div drag>
  <motion.button
    whileTap={{ scale: 0.9 }}
    onPointerDownCapture={(e) => e.stopPropagation()}  // prevent parent drag
  >
    Button inside draggable
  </motion.button>
</motion.div>
```

---

## Accessibility: prefers-reduced-motion

```tsx
import { useReducedMotion } from "motion/react"

function AnimatedCard() {
  const shouldReduce = useReducedMotion()

  return (
    <motion.div
      whileHover={shouldReduce ? {} : { scale: 1.05 }}
      whileTap={shouldReduce ? {} : { scale: 0.95 }}
    />
  )
}
```
