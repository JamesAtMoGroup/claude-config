---
name: gsap
description: >
  Comprehensive GSAP (GreenSock Animation Platform) knowledge for building web animations,
  scroll-driven effects, interactive draggable elements, SVG morphing, and text animations.
  Use when working with gsap.to/from/fromTo/timeline, ScrollTrigger, Draggable, SplitText,
  MorphSVG, MotionPath, TextPlugin, or integrating GSAP with React / Remotion.
metadata:
  tags: gsap, greensock, animation, scrolltrigger, react, remotion, svg, tween, timeline
---

# GSAP Skill

## Overview

GSAP is a high-performance JavaScript animation library. Since Webflow's 2024 acquisition,
ALL plugins (SplitText, MorphSVG, DrawSVG, etc.) are completely free including commercial use.

Load the relevant rule file for your task:

- [rules/core-api.md](rules/core-api.md) — gsap.to/from/fromTo/set/timeline, all tween props
- [rules/easing.md](rules/easing.md) — Ease types, CustomEase, EasePack
- [rules/stagger.md](rules/stagger.md) — Stagger patterns, grid staggers, callbacks
- [rules/callbacks.md](rules/callbacks.md) — onComplete, onUpdate, onStart, onRepeat
- [rules/plugins.md](rules/plugins.md) — ScrollTrigger, Draggable, MotionPath, TextPlugin, MorphSVG, SplitText
- [rules/react.md](rules/react.md) — useGSAP hook, contextSafe, cleanup, SSR
- [rules/remotion.md](rules/remotion.md) — GSAP + Remotion frame-sync pattern
- [rules/performance.md](rules/performance.md) — force3D, will-change, overwrite, pitfalls
- [rules/chinese-resources.md](rules/chinese-resources.md) — 繁體中文教學資源

## Quick Reference — Installation

```bash
npm install gsap
npm install @gsap/react   # for React useGSAP hook
```

```js
// Always register plugins before use
import { gsap } from 'gsap';
import { ScrollTrigger } from 'gsap/ScrollTrigger';
import { Draggable } from 'gsap/Draggable';
import { SplitText } from 'gsap/SplitText';
import { MorphSVGPlugin } from 'gsap/MorphSVGPlugin';
import { MotionPathPlugin } from 'gsap/MotionPathPlugin';
import { TextPlugin } from 'gsap/TextPlugin';

gsap.registerPlugin(ScrollTrigger, Draggable, SplitText, MorphSVGPlugin, MotionPathPlugin, TextPlugin);
```
