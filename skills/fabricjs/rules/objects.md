# Fabric.js — Shape Objects

All shapes extend `FabricObject` and share the same base properties (left, top, fill, stroke, angle, opacity, etc.). See `core-api.md` for the full property list.

## Import (v6+)

```ts
import {
  Rect, Circle, Triangle, Ellipse,
  Line, Polyline, Polygon, Path,
  FabricImage, Group, ActiveSelection,
} from 'fabric';
```

---

## Basic Shapes

### Rect

```ts
const rect = new Rect({
  left: 100,
  top: 100,
  width: 200,
  height: 100,
  fill: '#4f46e5',
  stroke: '#312e81',
  strokeWidth: 2,
  rx: 12,           // horizontal corner radius
  ry: 12,           // vertical corner radius
  angle: 15,        // degrees, clockwise
  opacity: 0.9,
});
canvas.add(rect);
```

### Circle

```ts
const circle = new Circle({
  left: 300,
  top: 200,
  radius: 60,       // radius in px (width = height = radius * 2)
  fill: '#10b981',
  stroke: '#065f46',
  strokeWidth: 3,
  startAngle: 0,    // arc start (degrees)
  endAngle: 360,    // arc end — set < 360 for pie slice
});
canvas.add(circle);
```

### Triangle

```ts
const triangle = new Triangle({
  left: 200,
  top: 200,
  width: 100,        // base width
  height: 120,       // height
  fill: '#f59e0b',
  stroke: '#92400e',
  strokeWidth: 2,
});
canvas.add(triangle);
```

### Ellipse

```ts
const ellipse = new Ellipse({
  left: 150,
  top: 150,
  rx: 100,           // horizontal radius
  ry: 60,            // vertical radius
  fill: 'rgba(239, 68, 68, 0.7)',
  stroke: '#991b1b',
  strokeWidth: 2,
});
canvas.add(ellipse);
```

---

## Line-based Shapes

### Line

```ts
// Points: [x1, y1, x2, y2]
const line = new Line([50, 100, 300, 200], {
  stroke: '#1e293b',
  strokeWidth: 3,
  strokeLineCap: 'round',
});
canvas.add(line);
```

### Polyline

```ts
// Array of { x, y } points — OPEN shape (no auto-close)
const polyline = new Polyline([
  { x: 10, y: 10 },
  { x: 100, y: 50 },
  { x: 200, y: 10 },
  { x: 250, y: 100 },
], {
  stroke: '#7c3aed',
  strokeWidth: 2,
  fill: 'transparent',     // fill: '' or 'transparent' for no fill
});
canvas.add(polyline);
```

### Polygon

```ts
// Array of { x, y } points — CLOSED shape (auto-connects last to first)
const polygon = new Polygon([
  { x: 100, y: 10 },
  { x: 180, y: 80 },
  { x: 150, y: 180 },
  { x: 50, y: 180 },
  { x: 20, y: 80 },
], {
  fill: '#0ea5e9',
  stroke: '#0369a1',
  strokeWidth: 2,
});
canvas.add(polygon);
```

### Path

```ts
// SVG path string — the most powerful shape type
const path = new Path('M 100 0 L 200 200 L 0 200 Z', {
  fill: '#f97316',
  stroke: '#9a3412',
  strokeWidth: 2,
  left: 50,
  top: 50,
});
canvas.add(path);

// Complex path with curves
const heartPath = new Path(
  'M 272.70141,238.71731 C 206.46141,238.71731 152.70146,292.4773 152.70146,358.71731 ...',
  { fill: '#ef4444', stroke: 'none' }
);
```

---

## Images

### Loading with fromURL

```ts
// v6: FabricImage.fromURL returns a Promise
import { FabricImage } from 'fabric';

const img = await FabricImage.fromURL('https://example.com/photo.jpg', {
  crossOrigin: 'anonymous',   // required for images from other origins
});
img.set({ left: 100, top: 100, scaleX: 0.5, scaleY: 0.5 });
canvas.add(img);
canvas.requestRenderAll();
```

### Loading from existing HTMLImageElement

```ts
const imgEl = document.getElementById('my-img') as HTMLImageElement;
const fabricImg = new FabricImage(imgEl, {
  left: 200,
  top: 100,
  angle: 10,
  opacity: 0.8,
});
canvas.add(fabricImg);
```

### Cropping with clipPath

```ts
import { Rect, FabricImage } from 'fabric';

const img = await FabricImage.fromURL('/photo.jpg');
img.set({ left: 100, top: 100 });

// Create a clip region
const clipRect = new Rect({
  left: 120, top: 120,
  width: 200, height: 150,
  absolutePositioned: true,   // clip in canvas coords, not object-relative
});

img.clipPath = clipRect;
canvas.add(img);
```

### Image Filters

```ts
import { FabricImage, filters } from 'fabric';

const img = await FabricImage.fromURL('/photo.jpg');

// Single filter
img.filters = [new filters.Grayscale()];

// Multiple filters (applied in order)
img.filters = [
  new filters.Brightness({ brightness: 0.2 }),    // -1 to 1
  new filters.Contrast({ contrast: 0.3 }),         // -1 to 1
  new filters.Saturation({ saturation: -0.5 }),    // -1 to 1
  new filters.Blur({ blur: 0.05 }),                // 0 to 1
  new filters.Noise({ noise: 50 }),                // 0 to 1000
  new filters.Pixelate({ blocksize: 8 }),          // integer
  new filters.Sepia(),                             // no config
  new filters.Invert(),                            // no config
  new filters.HueRotation({ rotation: 0.5 }),      // -1 to 1 (fraction of 2π)
  new filters.Gamma({ gamma: [1.5, 1, 0.8] }),    // [R, G, B] each 0.01–2.2
];

img.applyFilters();           // apply to the image (must call before renderAll)
canvas.requestRenderAll();

// Update a filter value
img.filters[0].brightness = 0.5;
img.applyFilters();
canvas.requestRenderAll();

// Remove all filters
img.filters = [];
img.applyFilters();
canvas.requestRenderAll();
```

### Available Filter Types

| Filter | Key Options |
|--------|-------------|
| `Grayscale` | `mode: 'average' \| 'lightness' \| 'luminosity'` |
| `Brightness` | `brightness: -1..1` |
| `Contrast` | `contrast: -1..1` |
| `Saturation` | `saturation: -1..1` |
| `Blur` | `blur: 0..1` |
| `Noise` | `noise: 0..1000` |
| `Pixelate` | `blocksize: integer` |
| `Sepia` | — |
| `Invert` | — |
| `HueRotation` | `rotation: -1..1` |
| `Gamma` | `gamma: [r, g, b]` each 0.01–2.2 |
| `Vibrance` | `vibrance: -1..1` |
| `ColorMatrix` | `matrix: number[20]` |
| `BlendColor` | `color, mode, alpha` |
| `BlendImage` | `image, mode, alpha` |

---

## Groups

### Creating a Group

```ts
import { Group, Rect, Circle } from 'fabric';

const rect = new Rect({ left: 0, top: 0, width: 100, height: 100, fill: '#4f46e5' });
const circle = new Circle({ left: 30, top: 30, radius: 30, fill: '#10b981' });

// Group positions objects relative to group center
const group = new Group([rect, circle], {
  left: 200,
  top: 150,
  angle: 10,
});

canvas.add(group);
```

### v6 Group: LayoutManager

In v6, groups use `LayoutManager` to compute bounding box. By default it's **fit-content** — the group bounds update when objects are added/removed/modified.

```ts
import { Group, LayoutManager, Rect } from 'fabric';

// Custom layout manager (e.g., fixed-size group)
const group = new Group([rect, circle], {
  layoutManager: new LayoutManager(),  // default
  subTargetCheck: true,                // allow clicking child objects
  interactive: true,                   // allow editing children when group selected
});
```

### Modifying Groups

```ts
// Add to group
group.add(newObj);

// Remove from group
group.remove(existingObj);

// Get children
group.getObjects();

// v5 addWithUpdate is GONE — use add() directly in v6
// group.addWithUpdate(obj);  // OLD — do NOT use

// Destroy group but keep objects on canvas
const items = group.getObjects();
canvas.remove(group);
items.forEach((item) => {
  item.set({ left: group.left + item.left, top: group.top + item.top });
  canvas.add(item);
});
```

### Entering Group to Edit Children

```ts
// Double-click enters the group (built-in behavior with interactive: true)
// Or programmatically:
canvas.setActiveObject(group);

// subTargetCheck allows events to reach children
group.subTargetCheck = true;
```

---

## ActiveSelection (Multi-select)

```ts
import { ActiveSelection } from 'fabric';

// Programmatic multi-select
const selection = new ActiveSelection([rect, circle, text], { canvas });
canvas.setActiveObject(selection);
canvas.requestRenderAll();

// User-driven — listen to selection events
canvas.on('selection:created', ({ selected }) => {
  console.log('Selected:', selected);
});

// Convert selection to group
canvas.on('selection:created', (e) => {
  const activeObj = canvas.getActiveObject();
  if (activeObj?.type === 'activeselection') {
    activeObj.toGroup();  // converts ActiveSelection to Group
  }
});
```

---

## ClipPath

Any FabricObject can serve as a clip path for another:

```ts
import { Circle, Rect } from 'fabric';

const clipCircle = new Circle({
  radius: 80,
  originX: 'center',
  originY: 'center',
});

rect.clipPath = clipCircle;
canvas.add(rect);
canvas.requestRenderAll();
```

---

## Object Cloning

```ts
// clone() is async in v6
const cloned = await obj.clone();
cloned.set({ left: obj.left + 20, top: obj.top + 20 });
canvas.add(cloned);
```
