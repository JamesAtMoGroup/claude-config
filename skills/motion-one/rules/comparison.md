# Motion vs GSAP vs Framer Motion — When to Use Which

## TL;DR Decision Matrix

| Scenario | Best Choice |
|----------|-------------|
| React UI with declarative animations | Motion (motion/react) |
| Scroll parallax + reveals, bundle size matters | Motion (vanilla) |
| Complex creative timelines, SVG morphing, 3D | GSAP |
| GSAP but it's React | GSAP + useGSAP |
| Legacy Framer Motion codebase | Motion (drop-in compatible) |
| Vue app | Motion (motion-v) |
| Maximum browser compatibility, IE11 | GSAP |
| SplitText, Draggable, Flip, ScrollSmoother | GSAP (plugins) |
| Canvas / Three.js / non-DOM | Motion hybrid or GSAP |

---

## Bundle Size

| Library | Core (gzip) | With scroll/extras |
|---------|-------------|-------------------|
| Motion mini | ~2.3kb | N/A |
| Motion hybrid | ~17kb | ~17kb (tree-shakeable) |
| GSAP core | ~23kb | ~30kb+ with plugins |
| Framer Motion full | ~32kb | ~32kb |

Motion's modular architecture means tree-shaking is meaningful — only functions you import are included. GSAP's older architecture means importing any piece pulls in more than expected.

---

## Performance

### WAAPI Hardware Acceleration
Motion runs `transform`, `opacity`, and `filter` on the **compositor thread** via WAAPI — zero main-thread cost. GSAP always runs on the main thread via `requestAnimationFrame`.

Measured benchmarks:
- Motion is **2.5x faster** than GSAP at animating from unknown values
- Motion is **6x faster** at animating between different value types
- For `will-change: transform` animations: effectively the same (both hit GPU)

### Where GSAP Still Wins on Performance
- Complex `requestAnimationFrame` logic (reading values every frame)
- Animating many non-GPU properties (e.g., `width`, `height`, `top`)
- On old browsers where WAAPI support is partial

---

## Feature Comparison

### Core Animation

| Feature | Motion | GSAP |
|---------|--------|------|
| Hardware acceleration (WAAPI) | Yes (automatic) | No (rAF only) |
| Keyframes | Yes | Yes |
| Spring physics | Yes | Yes (with plugin) |
| Per-property options | Yes | Yes |
| Independent transforms | Yes (hybrid) | Yes |
| CSS variables | Yes | Yes |
| SVG path drawing | Yes | Yes |
| Morph SVG | No | Yes (MorphSVG plugin) |
| Canvas / Three.js | Yes (hybrid) | Yes |

### Scroll

| Feature | Motion | GSAP |
|---------|--------|------|
| Scroll-linked (bind to progress) | scroll() | ScrollTrigger scrub |
| ScrollTimeline API (native) | Yes | No |
| Intersection-based triggers | inView() | ScrollTrigger |
| Pinning elements | No | Yes (ScrollTrigger) |
| Horizontal scroll panels | scroll() | ScrollTrigger |
| ScrollSmoother | No | Yes (plugin) |

### Sequencing

| Feature | Motion | GSAP |
|---------|--------|------|
| Timeline | animate() sequences | gsap.timeline() |
| Labeled positions | Yes (string in array) | Yes (.addLabel) |
| Nested timelines | No | Yes |
| Per-tween control | Limited | Full |
| Callbacks (onStart, onUpdate) | Limited | Extensive |

### React / Framework

| Feature | Motion (React) | GSAP + useGSAP | Framer Motion |
|---------|---------------|----------------|---------------|
| Declarative motion component | Yes | No | Yes |
| Variants / propagation | Yes | No | Yes |
| AnimatePresence / exit | Yes | Manual | Yes |
| Layout animations (FLIP) | Yes | Via Flip plugin | Yes |
| Gesture props (hover, drag) | Yes | Manual | Yes |
| useScroll motion values | Yes | Via ScrollTrigger | Yes |

---

## Motion vs Framer Motion

Motion for React IS Framer Motion — Matt Perry's team rebranded and merged both libraries under the `motion` package. Key facts:

- `framer-motion` package now re-exports from `motion`
- `motion/react` is the current canonical import (previously `framer-motion`)
- All Framer Motion APIs work in Motion (fully backward compatible)
- Motion adds vanilla JS + Vue support alongside React

**Migration is zero-effort:**
```js
// Old
import { motion } from "framer-motion"
// New (identical API)
import { motion } from "motion/react"
```

---

## What Motion Cannot Do (GSAP Wins)

1. **Read animated values every frame** — WAAPI runs off-thread; you can't sample the current transform value at 60fps the way GSAP's `onUpdate` can.
2. **MorphSVG** — complex path morphing between arbitrary shapes
3. **SplitText** — automatic text splitting into chars/words/lines
4. **Draggable with Inertia** — momentum-based drag-throw
5. **ScrollSmoother** — virtual scroll with momentum and lag effects
6. **Nested timeline control** — deeply nested, independently pauseable timelines
7. **IE11 / old browser support** — WAAPI requires modern browsers

---

## What Motion Does Better

1. **Bundle size** — 2.3kb mini vs 23kb GSAP core
2. **React DX** — declarative `<motion.div>` component, AnimatePresence, layout animations
3. **Hardware acceleration** — compositor-thread animations for free
4. **inView** — 0.5kb native IntersectionObserver (no plugin needed)
5. **scroll()** — uses ScrollTimeline API natively (off main thread)
6. **Spring generation for CSS** — `spring().toString()` for CSS transitions
7. **Vue support** — first-class with `motion-v`
8. **Active development** — GSAP reached v3 and is in maintenance mode

---

## 中文技術說明 (ZH-TW)

### Motion 是什麼

Motion（前身為 Motion One，作者 Matt Perry）是一個基於瀏覽器原生 Web Animations API（WAAPI）的現代動畫庫。它分為兩個引擎：
- **Mini 引擎**（~2.3kb）：純 WAAPI，硬體加速，適合 transforms 和 opacity
- **Hybrid 引擎**（~17kb）：Mini + JS 動畫，支援序列、Canvas、Three.js

### 與 GSAP 的核心差異

| 面向 | Motion | GSAP |
|------|--------|------|
| 執行執行緒 | Compositor（硬體加速） | 主執行緒 rAF |
| Bundle size | 2.3–17kb | 23–30kb+ |
| React 支援 | 原生（motion/react） | 需 useGSAP hook |
| 複雜 timeline | 較簡單 | 功能完整 |
| 插件生態 | 較少 | 豐富（ScrollSmoother, SplitText...） |

### 何時選 Motion

- 要最小 bundle size 的專案
- React / Vue 應用，需要 `<motion.div>` 聲明式語法
- Scroll parallax + inView 動畫（不需要 pinning）
- 不需要 MorphSVG / SplitText / Draggable 等進階功能

### 何時選 GSAP

- 需要複雜 timeline 巢狀與細粒度控制
- 需要 ScrollTrigger pinning（固定元素）
- SVG morphing 動畫
- 需要 SplitText / ScrollSmoother 等付費插件
- 不是 React/Vue 生態（純 vanilla JS 複雜動畫）

---

## Official Documentation

- Motion docs: https://motion.dev/docs
- GSAP vs Motion: https://motion.dev/docs/gsap-vs-motion
- Migrate from GSAP: https://motion.dev/docs/migrate-from-gsap-to-motion
- Examples: https://examples.motion.dev
