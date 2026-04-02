---
name: rive
description: Rive runtime animations and state machines for web/React. Use when integrating interactive .riv animation files, controlling state machine inputs, or embedding Rive animations in React apps.
---

# Rive Skill

Rive is a real-time interactive animation tool. Designers create animations in the Rive editor and export `.riv` files. At runtime, these files are played back using platform-specific runtimes (Web, React, React Native, Flutter, etc.).

## Key Concepts

- **Artboard** — The root canvas of a Rive file. A single `.riv` file can contain multiple artboards. Each artboard has its own dimensions, animations, and state machines.
- **Animation (Timeline)** — A keyframe-based animation clip within an artboard. Multiple animations can be mixed and layered simultaneously.
- **State Machine** — A graph of states and transitions driven by inputs (boolean, number, trigger). This is the primary mechanism for interactive/reactive animations at runtime.
- **Inputs** — Named variables that drive state machine transitions. Three types: Boolean, Number, Trigger.

## Rules

- Always read `rules/core-api.md` for useRive, RiveComponent, Layout, Fit, Alignment details.
- Always read `rules/state-machines.md` for input types, events, callbacks.
- Always read `rules/react-integration.md` for React-specific patterns and gotchas.
- Always read `rules/performance.md` for canvas vs WebGL, caching, lazy loading.

## Package Reference

| Package | Use Case |
|---|---|
| `@rive-app/react-canvas` | Recommended for most React apps |
| `@rive-app/react-canvas-lite` | Smaller bundle, no advanced renderer features |
| `@rive-app/react-webgl2` | Best rendering quality, heavier bundle |
| `@rive-app/canvas` | Vanilla JS with canvas renderer |
| `@rive-app/webgl2` | Vanilla JS with WebGL2 renderer |
| `@rive-app/react-native` | React Native (uses Nitro Modules) |
| `@remotion/rive` | Remotion video rendering integration |

## Installation

```bash
# React (recommended)
npm install @rive-app/react-canvas

# React Native
npm install @rive-app/react-native react-native-nitro-modules
```

## Quick Start

```tsx
import { useRive } from '@rive-app/react-canvas';

export default function MyAnimation() {
  const { RiveComponent } = useRive({
    src: '/animations/hero.riv',
    autoplay: true,
  });

  return <RiveComponent style={{ width: 400, height: 400 }} />;
}
```

## Traditional Chinese (ZH-TW) Resources

- Medium 繁體中文教學 (Flutter Rive): https://medium.com/flutter-formosa/教你製作強大的-rive-動畫
- Rive 官方文件無繁體中文版，建議搭配 Chrome 翻譯閱讀官方英文文件
- 官方文件: https://rive.app/docs / https://help.rive.app
- 社群: https://community.rive.app
