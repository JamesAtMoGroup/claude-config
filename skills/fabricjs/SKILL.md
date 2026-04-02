---
name: fabricjs
description: Fabric.js canvas library — interactive object model for HTML5 Canvas. Shapes, text, images, groups, events, serialization, export. Use when building canvas-based editors, whiteboards, or image manipulation tools.
---

# Fabric.js Skill

Fabric.js is a powerful, open-source JavaScript canvas library that wraps the HTML5 `<canvas>` element with an interactive **object model**. Every shape, image, and text you add becomes a first-class object with properties, events, and controls (drag, scale, rotate, skew) — without managing raw canvas pixel operations yourself.

**Current stable: v6.x (named exports, TypeScript, async APIs)**
**v7** is in development with further cleanup.

---

## Quick Start

```bash
npm install fabric
```

```ts
// v6+ named imports (tree-shakeable)
import { Canvas, Rect, Circle, FabricText } from 'fabric';

const canvas = new Canvas('c', { width: 800, height: 600 });

const rect = new Rect({
  left: 100, top: 100,
  width: 200, height: 150,
  fill: '#4f46e5',
  rx: 8, ry: 8,         // rounded corners
});

canvas.add(rect);
canvas.renderAll();
```

---

## Skill Files

| File | Contents |
|------|----------|
| `rules/core-api.md` | Canvas, StaticCanvas, object properties, rendering |
| `rules/objects.md` | Rect, Circle, Path, Group, Image — all shape types |
| `rules/text.md` | Text, IText, Textbox — editable & styled text |
| `rules/events.md` | Mouse, object, selection, canvas events |
| `rules/serialization.md` | toJSON, loadFromJSON, toDataURL, toSVG |
| `rules/animation.md` | util.animate, object.animate, easing |
| `rules/react-integration.md` | React hooks pattern, cleanup, state management |

---

## Key Mental Models

1. **Everything is an object** — shapes, images, text all share a common `FabricObject` base with the same property API.
2. **Canvas is the root** — `Canvas` (interactive) vs `StaticCanvas` (read-only, good for rendering).
3. **v6 uses named exports** — `import { Canvas, Rect } from 'fabric'`, NOT `fabric.Canvas`.
4. **Async dispose** — `canvas.dispose()` returns a Promise in v6+. Always await in cleanup.
5. **renderAll() vs requestRenderAll()** — use `requestRenderAll()` for RAF-batched rendering during animations.

---

## ZH-TW Resources

- iT邦幫忙系列教學：https://ithelp.ithome.com.tw/articles/10343461
- DeTools Fabric.js介紹：https://tools.wingzero.tw/article/sn/490
- DeTools 圖片編輯：https://tools.wingzero.tw/article/sn/596
- 中文教學 GitHub：https://github.com/Rookie-Birds/Fabric-Tutorial_zh-CN
