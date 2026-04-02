# Fabric.js — Core API

## Installation

```bash
npm install fabric          # v6+ (current stable)
```

## Import Patterns

```ts
// v6+ — named exports, tree-shakeable (PREFERRED)
import { Canvas, StaticCanvas, Rect, Circle, FabricText } from 'fabric';

// Node.js (SSR / server-side export)
import { StaticCanvas, Rect } from 'fabric/node';

// Old v5 pattern — DO NOT use in v6+
import * as fabric from 'fabric';  // works but no tree-shaking
const canvas = new fabric.Canvas('id');  // still works but legacy
```

---

## Canvas vs StaticCanvas

| | `Canvas` | `StaticCanvas` |
|---|---|---|
| Interactive | YES — click, drag, resize, rotate | NO — read-only rendering |
| Use case | Editors, whiteboards, annotation tools | Server rendering, export, background |
| Selection | Built-in multi-select | None |
| Events | Full mouse/keyboard events | None |

```ts
// Interactive canvas (most common)
const canvas = new Canvas('myCanvas', {
  width: 1200,
  height: 800,
  backgroundColor: '#f8f8f8',
  selection: true,             // enable multi-select (default: true)
  preserveObjectStacking: true, // selected objects don't jump to top
});

// Static canvas (render-only)
const staticCanvas = new StaticCanvas('exportCanvas', {
  width: 1920,
  height: 1080,
});
```

---

## Canvas Constructor Options

```ts
new Canvas('id', {
  width: 800,
  height: 600,
  backgroundColor: '#ffffff',       // or gradient/pattern
  backgroundImage: null,            // FabricImage as background
  overlayImage: null,               // FabricImage rendered on top
  selection: true,                  // multi-select mode
  preserveObjectStacking: false,    // selected obj moves to top if false
  allowTouchScrolling: false,       // prevent page scroll while drawing
  isDrawingMode: false,             // free-hand drawing mode
  skipOffscreen: true,              // skip rendering off-screen objects
  stopContextMenu: true,            // prevent right-click menu
  fireRightClick: false,            // emit right-click as mouse:down
  renderOnAddRemove: true,          // auto re-render on add/remove
  controlsAboveOverlay: false,      // controls render above overlay
  defaultCursor: 'default',
  hoverCursor: 'move',
  moveCursor: 'move',
  freeDrawingCursor: 'crosshair',
  notAllowedCursor: 'not-allowed',
  perPixelTargetFind: false,        // click detection on actual pixels (perf cost)
  targetFindTolerance: 0,           // px padding for click hit area
  uniformScaling: true,             // scale proportionally by default
  uniScaleKey: 'shiftKey',         // hold this key to break uniform scale
  centeredScaling: false,           // scale from center
  centeredRotation: true,
  altActionKey: 'altKey',          // key for alternative action
});
```

---

## Core Canvas Methods

### Adding & Removing Objects

```ts
canvas.add(rect);                   // add one or more objects
canvas.add(rect, circle, text);     // add multiple at once

canvas.remove(rect);                // remove from canvas

canvas.clear();                     // remove all objects (keeps background)

canvas.dispose();                   // ASYNC in v6 — destroys canvas, removes listeners
await canvas.dispose();             // always await in cleanup!
```

### Object Retrieval

```ts
canvas.getObjects();                      // all objects
canvas.getObjects('rect');                // filter by type string
canvas.getActiveObject();                 // currently selected single object
canvas.getActiveObjects();                // array (multi-select)
canvas.item(index);                       // by z-order index

canvas.forEachObject((obj) => {          // iterate all objects
  obj.set('opacity', 0.5);
});
```

### Rendering

```ts
canvas.renderAll();            // synchronous — re-render everything
canvas.requestRenderAll();     // RAF-batched — preferred during animations

// Render only specific region (advanced perf optimization)
canvas.renderCanvas(ctx, objects);
```

### Selection

```ts
canvas.setActiveObject(obj);          // programmatically select
canvas.discardActiveObject();         // deselect all
canvas.getActiveObject();             // currently selected

// Select multiple programmatically
import { ActiveSelection } from 'fabric';
const sel = new ActiveSelection([rect, circle], { canvas });
canvas.setActiveObject(sel);
canvas.requestRenderAll();
```

### Z-order (Layering)

```ts
canvas.bringObjectToFront(obj);    // move to top
canvas.sendObjectToBack(obj);      // move to bottom
canvas.bringObjectForward(obj);    // move up one layer
canvas.sendObjectBackwards(obj);   // move down one layer

// v6: also works as methods on the object
obj.bringToFront();
obj.sendToBack();
```

### Zoom & Pan

```ts
canvas.setZoom(2);                    // 2x zoom
canvas.getZoom();                     // current zoom

// Zoom toward a point
canvas.zoomToPoint({ x: 400, y: 300 }, 1.5);

// Pan (translate viewport)
canvas.relativePan({ x: 50, y: 0 });   // pan by delta
canvas.absolutePan({ x: 100, y: 0 });  // pan to absolute position

// Get viewport transform
canvas.viewportTransform;             // [scaleX, 0, 0, scaleY, translateX, translateY]
canvas.setViewportTransform([1, 0, 0, 1, 0, 0]);  // reset
```

---

## Object Properties (Shared by All Objects)

All `FabricObject` subclasses share these properties. Set at creation or via `.set()`.

### Position & Size

```ts
{
  left: 100,          // x position (canvas coords, from left of canvas)
  top: 100,           // y position (canvas coords, from top of canvas)
  width: 200,         // intrinsic width (before scale)
  height: 150,        // intrinsic height (before scale)
  scaleX: 1,          // horizontal scale multiplier
  scaleY: 1,          // vertical scale multiplier
  flipX: false,       // mirror horizontally
  flipY: false,       // mirror vertically
}
```

### Visual Style

```ts
{
  fill: '#4f46e5',         // fill color, gradient, or pattern
  stroke: '#1e1b4b',       // stroke (border) color
  strokeWidth: 2,          // stroke thickness in px
  strokeDashArray: [5, 3], // dashed border [dash, gap]
  strokeLineCap: 'round',  // 'butt' | 'round' | 'square'
  strokeLineJoin: 'round', // 'miter' | 'round' | 'bevel'
  opacity: 1,              // 0–1
  shadow: null,            // fabric.Shadow or null
  backgroundColor: '',     // background fill (text/itext only)
  visible: true,           // hide without removing
  globalCompositeOperation: 'source-over', // canvas blend mode
}
```

### Transform

```ts
{
  angle: 0,               // rotation in degrees (clockwise)
  originX: 'left',        // 'left' | 'center' | 'right'
  originY: 'top',         // 'top' | 'center' | 'bottom'
  centeredScaling: false,
  centeredRotation: true,
  skewX: 0,               // horizontal skew in degrees
  skewY: 0,               // vertical skew in degrees
}
```

### Interaction

```ts
{
  selectable: true,         // can be selected
  evented: true,            // fires/receives events
  hasControls: true,        // show transform handles
  hasBorders: true,         // show selection border
  lockMovementX: false,     // prevent horizontal drag
  lockMovementY: false,     // prevent vertical drag
  lockRotation: false,
  lockScalingX: false,
  lockScalingY: false,
  lockScalingFlip: false,   // prevent scale going negative
  hoverCursor: null,        // override canvas hoverCursor
  moveCursor: null,
  perPixelTargetFind: false,
}
```

### Setting Properties

```ts
// Set single property
obj.set('left', 200);

// Set multiple properties
obj.set({ left: 200, top: 150, fill: 'red' });

// Get a property
obj.get('left');  // or obj.left directly

// After changing position/transform, call setCoords to update selection box
obj.setCoords();
canvas.requestRenderAll();
```

---

## Gradients & Patterns

```ts
import { Gradient, Pattern } from 'fabric';

// Linear gradient fill
const gradient = new Gradient({
  type: 'linear',
  gradientUnits: 'percentage',  // 'pixel' or 'percentage'
  coords: { x1: 0, y1: 0, x2: 1, y2: 0 },
  colorStops: [
    { offset: 0, color: '#4f46e5' },
    { offset: 1, color: '#7c3aed' },
  ],
});
rect.set('fill', gradient);

// Radial gradient
const radial = new Gradient({
  type: 'radial',
  coords: { x1: 0.5, y1: 0.5, r1: 0, x2: 0.5, y2: 0.5, r2: 0.5 },
  colorStops: [
    { offset: 0, color: 'white' },
    { offset: 1, color: 'black' },
  ],
});

// Pattern fill from image element
const imgEl = document.createElement('img');
imgEl.src = '/texture.png';
imgEl.onload = () => {
  const pattern = new Pattern({ source: imgEl, repeat: 'repeat' });
  rect.set('fill', pattern);
  canvas.requestRenderAll();
};
```

---

## Shadow

```ts
import { Shadow } from 'fabric';

obj.set('shadow', new Shadow({
  color: 'rgba(0,0,0,0.4)',
  blur: 10,
  offsetX: 4,
  offsetY: 4,
}));
```

---

## Drawing Mode (Free-hand)

```ts
import { PencilBrush } from 'fabric';

canvas.isDrawingMode = true;
canvas.freeDrawingBrush = new PencilBrush(canvas);
canvas.freeDrawingBrush.color = '#ef4444';
canvas.freeDrawingBrush.width = 4;

// When user finishes drawing, 'path:created' event fires
canvas.on('path:created', ({ path }) => {
  console.log('New path:', path);
});

// Turn off drawing mode
canvas.isDrawingMode = false;
```
