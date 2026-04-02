# Variants — Framer Motion

Variants are named animation states defined outside your JSX. They make complex, orchestrated animations readable and reusable.

## Basic Variants

```tsx
import { motion } from "motion/react"

const boxVariants = {
  hidden: { opacity: 0, scale: 0.8 },
  visible: { opacity: 1, scale: 1 },
  exit: { opacity: 0, scale: 0.8 },
}

function Box() {
  return (
    <motion.div
      variants={boxVariants}
      initial="hidden"
      animate="visible"
      exit="exit"
      transition={{ duration: 0.3 }}
    />
  )
}
```

## Variant Labels as Strings vs Objects

```tsx
// String label — references the variant definition
animate="visible"

// Inline object — direct values (no variants needed)
animate={{ opacity: 1, scale: 1 }}

// Conditional
animate={isActive ? "active" : "inactive"}
```

---

## Variant Inheritance (Parent → Child Propagation)

Variants **automatically propagate** from parent to children. When the parent's `animate` changes to `"visible"`, all children with a `"visible"` variant also animate — no extra props needed on children.

```tsx
const containerVariants = {
  hidden: { opacity: 0 },
  visible: { opacity: 1 },
}

const itemVariants = {
  hidden: { opacity: 0, y: 20 },
  visible: { opacity: 1, y: 0 },
}

function List() {
  return (
    <motion.ul
      variants={containerVariants}
      initial="hidden"
      animate="visible"
    >
      {items.map((item) => (
        // No initial/animate needed — inherits from parent
        <motion.li key={item} variants={itemVariants}>
          {item}
        </motion.li>
      ))}
    </motion.ul>
  )
}
```

---

## Orchestration — staggerChildren & delayChildren

Control timing between parent and children via `transition` inside variants.

```tsx
const containerVariants = {
  hidden: { opacity: 0 },
  visible: {
    opacity: 1,
    transition: {
      // Delay before children start
      delayChildren: 0.3,
      // Gap between each child's start time
      staggerChildren: 0.1,
    },
  },
}

const itemVariants = {
  hidden: { opacity: 0, x: -20 },
  visible: { opacity: 1, x: 0 },
}

function AnimatedList({ items }) {
  return (
    <motion.ul variants={containerVariants} initial="hidden" animate="visible">
      {items.map((item, i) => (
        <motion.li key={i} variants={itemVariants}>
          {item}
        </motion.li>
      ))}
    </motion.ul>
  )
}
```

### Stagger Direction

```tsx
transition: {
  staggerChildren: 0.08,
  staggerDirection: 1,   // 1 = first to last (default), -1 = last to first
}
```

---

## Dynamic Variants (Function Syntax)

Pass a function as a variant to receive a `custom` prop for dynamic values per child.

```tsx
const itemVariants = {
  hidden: { opacity: 0 },
  visible: (i: number) => ({
    opacity: 1,
    transition: { delay: i * 0.1 },
  }),
}

function List({ items }) {
  return (
    <motion.ul initial="hidden" animate="visible">
      {items.map((item, i) => (
        <motion.li key={i} custom={i} variants={itemVariants}>
          {item}
        </motion.li>
      ))}
    </motion.ul>
  )
}
```

---

## Gesture Variants

Variants work with gesture props too:

```tsx
const cardVariants = {
  rest: { scale: 1, boxShadow: "0px 4px 10px rgba(0,0,0,0.1)" },
  hover: { scale: 1.03, boxShadow: "0px 10px 30px rgba(0,0,0,0.2)" },
  tap: { scale: 0.97 },
}

<motion.div
  variants={cardVariants}
  initial="rest"
  whileHover="hover"
  whileTap="tap"
/>
```

---

## Switching Variants at Runtime

```tsx
const [state, setState] = useState<"open" | "closed">("closed")

<motion.div variants={menuVariants} animate={state}>
  ...
</motion.div>

<button onClick={() => setState(s => s === "open" ? "closed" : "open")}>
  Toggle
</button>
```

---

## useAnimation — Programmatic Variant Control

```tsx
import { motion, useAnimation } from "motion/react"
import { useEffect } from "react"

function PulseBox() {
  const controls = useAnimation()

  const pulse = async () => {
    await controls.start("big")
    await controls.start("normal")
  }

  return (
    <motion.div
      animate={controls}
      variants={{
        normal: { scale: 1 },
        big: { scale: 1.3 },
      }}
      onClick={pulse}
    />
  )
}
```

---

## Per-Property Transition in Variants

```tsx
const variants = {
  visible: {
    opacity: 1,
    x: 0,
    transition: {
      opacity: { duration: 0.2 },   // opacity animates fast
      x: { type: "spring", stiffness: 200 },  // x uses spring
    },
  },
}
```

---

## Common Patterns

### Fade + Slide Up List
```tsx
const container = {
  hidden: {},
  visible: { transition: { staggerChildren: 0.07 } },
}

const item = {
  hidden: { opacity: 0, y: 24 },
  visible: { opacity: 1, y: 0, transition: { duration: 0.4 } },
}
```

### Page Transition
```tsx
const pageVariants = {
  initial: { opacity: 0, x: "-100vw" },
  in: { opacity: 1, x: 0 },
  out: { opacity: 0, x: "100vw" },
}

const pageTransition = {
  type: "tween",
  ease: "anticipate",
  duration: 0.5,
}

<motion.div variants={pageVariants} initial="initial" animate="in" exit="out" transition={pageTransition}>
  {children}
</motion.div>
```
