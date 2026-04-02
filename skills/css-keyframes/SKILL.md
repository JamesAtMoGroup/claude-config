---
name: css-keyframes
description: CSS @keyframes animations — syntax, timing functions, scroll-driven animations, Tailwind integration, common patterns. Use when implementing pure CSS animations without JS libraries.
---

# CSS @keyframes Animations

Pure CSS animation system. No JS required. Covers everything from basic keyframes to scroll-driven timelines.

## Quick Reference

```css
/* Minimal viable animation */
@keyframes fadeIn {
  from { opacity: 0; }
  to   { opacity: 1; }
}

.el {
  animation: fadeIn 0.3s ease forwards;
}
```

## Sub-files

| File | Covers |
|------|--------|
| `rules/syntax.md` | `@keyframes` syntax + all `animation-*` sub-properties |
| `rules/timing-functions.md` | Easing — `cubic-bezier`, `steps()`, `linear()`, named keywords |
| `rules/scroll-driven.md` | `animation-timeline`, scroll/view progress timelines |
| `rules/tailwind-integration.md` | Tailwind v3 + v4 animation utilities and config |
| `rules/patterns.md` | Copy-paste patterns: fade, slide, scale, shake, bounce, spin, pulse, skeleton |
| `rules/performance.md` | `will-change`, transform vs positional props, `contain`, compositor thread |

## When to Use CSS Animations vs JS

- **Use CSS** — single-shot transitions, hover effects, loading states, decorative loops, scroll reveals
- **Use GSAP/Framer Motion** — sequenced timelines, drag interactions, physics, JS-driven state, complex choreography

## ZH-TW 資源

- [MDN 繁體中文 — 使用 CSS 動畫](https://developer.mozilla.org/zh-TW/docs/Web/CSS/Guides/Animations/Using)
- [CSS 動畫教學 — STEAM 教育學習網](https://steam.oxxostudio.tw/category/css/content/animation.html)
- [完整解析 CSS 動畫 — OXXO.STUDIO](https://www.oxxostudio.tw/articles/201803/css-animation.html)
- [CSS 關鍵影格動畫教學 — RealNewbie](https://realnewbie.com/coding/css/css-keyframes/)
- [一個工具帶你認識 CSS Animation — Casper](https://www.casper.tw/development/2021/10/04/css-animation/)
