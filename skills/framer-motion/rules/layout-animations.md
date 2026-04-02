# Layout Animations — Framer Motion

Motion can automatically animate changes in an element's size and position using the FLIP technique (First, Last, Invert, Play). This allows animating CSS properties like `justify-content`, `flex-direction`, and grid changes that normally can't be animated.

---

## layout Prop

Add `layout` to any `motion` component to automatically animate layout changes.

```tsx
import { motion } from "motion/react"
import { useState } from "react"

function Toggle() {
  const [isExpanded, setIsExpanded] = useState(false)

  return (
    <motion.div
      layout
      style={{
        width: isExpanded ? 300 : 100,
        height: isExpanded ? 200 : 100,
        background: "#6d28d9",
        borderRadius: 16,
      }}
      onClick={() => setIsExpanded(!isExpanded)}
    />
  )
}
```

### layout Values

| Value | Behavior |
|-------|----------|
| `true` or `layout` | Animate both size and position |
| `"position"` | Animate position only (not size) |
| `"size"` | Animate size only (not position) |
| `"preserve-aspect"` | Animate size while maintaining aspect ratio |

```tsx
// Only animate position (useful for reordering lists)
<motion.div layout="position" />

// Only animate size
<motion.div layout="size" />
```

---

## layout + AnimatePresence (List Reorder)

```tsx
function SortableList({ items }) {
  return (
    <ul>
      <AnimatePresence>
        {items.map((item) => (
          <motion.li
            key={item.id}
            layout                          // smoothly reflow when items removed
            initial={{ opacity: 0, scale: 0.8 }}
            animate={{ opacity: 1, scale: 1 }}
            exit={{ opacity: 0, scale: 0.8 }}
            transition={{ duration: 0.2 }}
          >
            {item.label}
          </motion.li>
        ))}
      </AnimatePresence>
    </ul>
  )
}
```

---

## layoutId — Shared Element Transitions

`layoutId` creates a visual connection between separate component instances. When one unmounts and another with the same `layoutId` mounts, Motion animates between them.

### Tabs with Underline Indicator

```tsx
const tabs = ["Overview", "Features", "Pricing"]

function Tabs() {
  const [activeTab, setActiveTab] = useState(tabs[0])

  return (
    <nav style={{ display: "flex", gap: 24 }}>
      {tabs.map((tab) => (
        <button
          key={tab}
          style={{ position: "relative", paddingBottom: 4, background: "none", border: "none" }}
          onClick={() => setActiveTab(tab)}
        >
          {tab}
          {activeTab === tab && (
            <motion.div
              layoutId="tab-underline"
              style={{
                position: "absolute",
                bottom: 0, left: 0, right: 0,
                height: 2,
                background: "#6d28d9",
                borderRadius: 1,
              }}
            />
          )}
        </button>
      ))}
    </nav>
  )
}
```

### Modal Expand from Card

```tsx
function CardGrid({ cards }) {
  const [selected, setSelected] = useState(null)

  return (
    <>
      {cards.map((card) => (
        <motion.div
          key={card.id}
          layoutId={`card-${card.id}`}
          onClick={() => setSelected(card)}
          style={{ width: 200, height: 120, background: card.color, borderRadius: 12 }}
        />
      ))}

      <AnimatePresence>
        {selected && (
          <>
            {/* Overlay */}
            <motion.div
              initial={{ opacity: 0 }}
              animate={{ opacity: 0.5 }}
              exit={{ opacity: 0 }}
              style={{ position: "fixed", inset: 0, background: "#000" }}
              onClick={() => setSelected(null)}
            />

            {/* Expanded card — shares layoutId with the card */}
            <motion.div
              layoutId={`card-${selected.id}`}
              style={{
                position: "fixed",
                top: "10%", left: "10%",
                width: "80%", height: "80%",
                background: selected.color,
                borderRadius: 24,
                zIndex: 10,
              }}
              onClick={() => setSelected(null)}
            />
          </>
        )}
      </AnimatePresence>
    </>
  )
}
```

---

## LayoutGroup — Scope layoutId Globally

By default, `layoutId` is **globally unique** across the entire page. Use `LayoutGroup` to scope it so multiple instances of the same component don't conflict.

```tsx
import { LayoutGroup } from "motion/react"

function TabRow({ id, tabs }) {
  return (
    <LayoutGroup id={id}>
      <nav>
        {tabs.map((tab) => (
          <Tab key={tab} label={tab} />
        ))}
      </nav>
    </LayoutGroup>
  )
}

// Now you can render multiple TabRow instances without layoutId conflicts
<TabRow id="nav-1" tabs={["A", "B", "C"]} />
<TabRow id="nav-2" tabs={["X", "Y", "Z"]} />
```

---

## Layout Transition

Customize the transition for layout changes specifically (separate from other property transitions).

```tsx
<motion.div
  layout
  animate={{ opacity: 1, color: "#6d28d9" }}
  transition={{
    layout: { type: "spring", stiffness: 300, damping: 30 },  // layout-specific
    opacity: { duration: 0.2 },                                // opacity-specific
  }}
/>
```

---

## layoutScroll — Scroll Container Support

When doing layout animations inside a scrollable container, add `layoutScroll` to the scroll container so Motion accounts for scroll offset.

```tsx
<motion.div layoutScroll style={{ overflow: "auto", height: 400 }}>
  {items.map((item) => (
    <motion.div key={item.id} layout>
      {item.content}
    </motion.div>
  ))}
</motion.div>
```

---

## Common Pitfalls

```tsx
// PITFALL: border-radius doesn't animate correctly with layout
// Fix: wrap in another motion.div, or apply borderRadius on inner element
<motion.div layout style={{ borderRadius: 16 }}>
  {/* May jump — use layoutDependency or restructure */}
</motion.div>

// FIX: use style on a wrapper
<motion.div layout>
  <div style={{ borderRadius: 16 }}>content</div>
</motion.div>
```

### layoutDependency

Force layout animation when external state changes (not just this element's layout):

```tsx
<motion.div layout layoutDependency={someExternalState} />
```

---

## Reorder Component (Drag to Reorder Lists)

```tsx
import { Reorder } from "motion/react"
import { useState } from "react"

function DragList() {
  const [items, setItems] = useState(["Item 1", "Item 2", "Item 3", "Item 4"])

  return (
    <Reorder.Group axis="y" values={items} onReorder={setItems}>
      {items.map((item) => (
        <Reorder.Item key={item} value={item}>
          <motion.div
            whileHover={{ scale: 1.02 }}
            whileDrag={{ scale: 1.05, boxShadow: "0px 8px 20px rgba(0,0,0,0.2)" }}
          >
            {item}
          </motion.div>
        </Reorder.Item>
      ))}
    </Reorder.Group>
  )
}
```
