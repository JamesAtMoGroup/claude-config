# AnimatePresence — Exit Animations

`AnimatePresence` enables components to animate out when they're removed from the React tree. React normally unmounts components immediately — `AnimatePresence` keeps them mounted until the `exit` animation completes.

## Basic Usage

```tsx
import { motion, AnimatePresence } from "motion/react"
import { useState } from "react"

function Modal({ isOpen, onClose }) {
  return (
    <AnimatePresence>
      {isOpen && (
        <motion.div
          key="modal"
          initial={{ opacity: 0, y: -20 }}
          animate={{ opacity: 1, y: 0 }}
          exit={{ opacity: 0, y: 20 }}
          transition={{ duration: 0.25 }}
        >
          <button onClick={onClose}>Close</button>
        </motion.div>
      )}
    </AnimatePresence>
  )
}
```

**Rules:**
- Wrap the conditional element — not the component itself
- The child must have a `key` prop so Motion can track it
- The child needs an `exit` prop or variant to animate out

---

## mode Prop

Controls how enter and exit animations interact when the child switches.

| mode | Behavior |
|------|----------|
| `"sync"` | Default. Enter and exit happen simultaneously |
| `"wait"` | Wait for exit to finish before entering |
| `"popLayout"` | Remove exiting element from layout flow immediately; entering element takes its place |

```tsx
// Page transitions: wait for exit before entering
<AnimatePresence mode="wait">
  <motion.div key={routeKey} initial={{ opacity: 0 }} animate={{ opacity: 1 }} exit={{ opacity: 0 }}>
    <Page />
  </motion.div>
</AnimatePresence>

// Carousel: pop the old element out of layout immediately
<AnimatePresence mode="popLayout">
  <motion.div key={currentSlide} ...>
    <Slide />
  </motion.div>
</AnimatePresence>
```

---

## Page Transitions (Next.js App Router)

```tsx
// app/template.tsx — use template.tsx, not layout.tsx
"use client"
import { motion } from "motion/react"

export default function Template({ children }: { children: React.ReactNode }) {
  return (
    <motion.div
      initial={{ opacity: 0, y: 8 }}
      animate={{ opacity: 1, y: 0 }}
      exit={{ opacity: 0, y: -8 }}
      transition={{ duration: 0.3 }}
    >
      {children}
    </motion.div>
  )
}
```

---

## List with AnimatePresence

```tsx
const items = ["Apple", "Banana", "Cherry"]

function AnimatedList() {
  const [list, setList] = useState(items)

  const remove = (item: string) => {
    setList((prev) => prev.filter((i) => i !== item))
  }

  return (
    <ul>
      <AnimatePresence>
        {list.map((item) => (
          <motion.li
            key={item}
            layout                        // animate position changes
            initial={{ opacity: 0, height: 0 }}
            animate={{ opacity: 1, height: "auto" }}
            exit={{ opacity: 0, height: 0 }}
            transition={{ duration: 0.2 }}
            onClick={() => remove(item)}
          >
            {item}
          </motion.li>
        ))}
      </AnimatePresence>
    </ul>
  )
}
```

---

## Notification Stack

```tsx
function NotificationStack({ notifications }) {
  return (
    <div style={{ position: "fixed", bottom: 16, right: 16 }}>
      <AnimatePresence>
        {notifications.map((n) => (
          <motion.div
            key={n.id}
            layout
            initial={{ opacity: 0, x: 50, scale: 0.9 }}
            animate={{ opacity: 1, x: 0, scale: 1 }}
            exit={{ opacity: 0, x: 50, scale: 0.9 }}
            transition={{ type: "spring", stiffness: 300, damping: 25 }}
          >
            {n.message}
          </motion.div>
        ))}
      </AnimatePresence>
    </div>
  )
}
```

---

## Tabs / Content Switching

```tsx
const tabs = ["Home", "About", "Contact"]

function Tabs() {
  const [active, setActive] = useState("Home")

  return (
    <>
      <nav>
        {tabs.map((tab) => (
          <button key={tab} onClick={() => setActive(tab)}>{tab}</button>
        ))}
      </nav>

      <AnimatePresence mode="wait">
        <motion.div
          key={active}
          initial={{ opacity: 0, x: 20 }}
          animate={{ opacity: 1, x: 0 }}
          exit={{ opacity: 0, x: -20 }}
          transition={{ duration: 0.2 }}
        >
          <Content tab={active} />
        </motion.div>
      </AnimatePresence>
    </>
  )
}
```

---

## initial={false} — Skip First Animation

When rendering server-side or on page load, you may not want the initial animation to run.

```tsx
// Children animate in only after first render — not on initial mount
<AnimatePresence initial={false}>
  {isVisible && <motion.div exit={{ opacity: 0 }} />}
</AnimatePresence>
```

---

## onExitComplete

Callback fired when all exit animations finish.

```tsx
<AnimatePresence onExitComplete={() => console.log("All exits done")}>
  {isVisible && <motion.div exit={{ opacity: 0 }} />}
</AnimatePresence>
```

---

## Common Pitfalls

```tsx
// WRONG — AnimatePresence wraps the conditional component, but key is missing
<AnimatePresence>
  {isOpen && <motion.div exit={{ opacity: 0 }}>...</motion.div>}
</AnimatePresence>
// Fix: add key="modal" to the motion.div

// WRONG — Animating a component that doesn't pass props through
function MyModal() {
  return <div>Modal</div>  // motion props won't work
}
<AnimatePresence>
  {isOpen && <MyModal />}  // exit won't animate
</AnimatePresence>
// Fix: use motion.div inside MyModal, or use motion() HOC:
const MotionModal = motion(MyModal)
```
