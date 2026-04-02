# Fabric.js — Serialization & Export

---

## JSON Serialization

### Save Canvas State

```ts
// Get JSON object
const json = canvas.toJSON();
// json = {
//   version: "6.x.x",
//   objects: [ { type, left, top, fill, ... }, ... ],
//   background: "#ffffff",
// }

// Get as JSON string
const jsonString = JSON.stringify(canvas.toJSON());

// Save with additional custom properties
const json = canvas.toJSON(['myCustomProp', 'id', 'name']);
// Objects will include these custom properties in export

// Persist to localStorage
localStorage.setItem('canvas-state', jsonString);

// Or send to server
await fetch('/api/save', {
  method: 'POST',
  body: jsonString,
  headers: { 'Content-Type': 'application/json' },
});
```

### Load Canvas State

```ts
// v6: loadFromJSON is async
const json = JSON.parse(localStorage.getItem('canvas-state') ?? '{}');
await canvas.loadFromJSON(json);
canvas.requestRenderAll();

// With a callback (v5 style — still works in v6)
canvas.loadFromJSON(json, () => {
  canvas.renderAll();
});

// Load with image revival (for cross-origin images)
await canvas.loadFromJSON(json, undefined, (o, fabricObj) => {
  // o         — raw JSON object being revived
  // fabricObj — the FabricObject being created
  // return fabricObj to keep, return null to skip
  return fabricObj;
});
```

### toObject vs toJSON

`toObject()` returns a plain JS object (same data as toJSON but as an object, not stringified):

```ts
// Single object serialization
const rectData = rect.toObject();
// rectData = { type: 'Rect', version: '6.x', left: 100, top: 100, ... }

// Include extra properties
const rectData = rect.toObject(['id', 'locked']);
```

---

## Custom Property Serialization

To persist custom properties, pass them to `toJSON/toObject`:

```ts
// Attach custom props to object
rect.id = 'slide-bg-001';
rect.layerName = 'Background';
rect.locked = false;

// Serialize including custom props
const json = canvas.toJSON(['id', 'layerName', 'locked']);

// On load, custom props are automatically restored
await canvas.loadFromJSON(json);
const bg = canvas.getObjects().find((o) => o.id === 'slide-bg-001');
```

### Extending the serialized class

For TypeScript, declare the custom properties:

```ts
declare module 'fabric' {
  interface FabricObject {
    id?: string;
    layerName?: string;
    locked?: boolean;
  }
}

// Register so Fabric knows to serialize them
import { FabricObject } from 'fabric';
FabricObject.customProperties = ['id', 'layerName', 'locked'];
```

---

## Undo / Redo with JSON

```ts
const history: string[] = [];
let currentIndex = -1;

function saveState() {
  // Trim redo history when a new action happens
  history.splice(currentIndex + 1);
  history.push(JSON.stringify(canvas.toJSON()));
  currentIndex = history.length - 1;
}

async function undo() {
  if (currentIndex <= 0) return;
  currentIndex--;
  await canvas.loadFromJSON(JSON.parse(history[currentIndex]));
  canvas.requestRenderAll();
}

async function redo() {
  if (currentIndex >= history.length - 1) return;
  currentIndex++;
  await canvas.loadFromJSON(JSON.parse(history[currentIndex]));
  canvas.requestRenderAll();
}

// Wire up
canvas.on('object:modified', saveState);
canvas.on('object:added', saveState);
canvas.on('object:removed', saveState);
saveState(); // capture initial state
```

---

## SVG Export & Import

### Export to SVG

```ts
// Get SVG string
const svg = canvas.toSVG();

// With options
const svg = canvas.toSVG({
  suppressPreamble: false,      // include <?xml ...> header
  viewBox: {                    // custom viewBox
    x: 0,
    y: 0,
    width: 1920,
    height: 1080,
  },
  encoding: 'UTF-8',
  width: '100%',                // override width attribute
  height: '100%',
  reviver: (markup, obj) => {   // transform SVG markup per object
    return markup;
  },
});

// Download as .svg file
function downloadSVG() {
  const svg = canvas.toSVG();
  const blob = new Blob([svg], { type: 'image/svg+xml' });
  const url = URL.createObjectURL(blob);
  const a = document.createElement('a');
  a.href = url;
  a.download = 'canvas.svg';
  a.click();
  URL.revokeObjectURL(url);
}
```

### Import from SVG

```ts
import { loadSVGFromString, loadSVGFromURL, util } from 'fabric';

// From string
const { objects, options } = await loadSVGFromString(svgString);
const group = util.groupSVGElements(objects, options);
canvas.add(group);
canvas.requestRenderAll();

// From URL
const { objects, options } = await loadSVGFromURL('https://example.com/icon.svg');
const group = util.groupSVGElements(objects, options);
group.set({ left: 100, top: 100, scaleX: 0.5, scaleY: 0.5 });
canvas.add(group);
canvas.requestRenderAll();
```

---

## Image Export (toDataURL)

```ts
// Get data URL as PNG (default)
const dataURL = canvas.toDataURL({
  format: 'png',        // 'png' | 'jpeg' | 'webp'
  quality: 1,           // 0–1 (for jpeg/webp)
  multiplier: 2,        // scale factor — 2 = 2x resolution (for HiDPI/export)
  left: 0,              // export region (optional)
  top: 0,
  width: canvas.width,
  height: canvas.height,
  enableRetinaScaling: false,  // use canvas's retina scale
});

// dataURL = "data:image/png;base64,iVBOR..."

// Download as PNG
function downloadPNG() {
  const dataURL = canvas.toDataURL({ format: 'png', multiplier: 2 });
  const a = document.createElement('a');
  a.href = dataURL;
  a.download = 'export.png';
  a.click();
}

// Upload to server
async function uploadCanvas() {
  const dataURL = canvas.toDataURL({ format: 'jpeg', quality: 0.9 });
  const blob = await (await fetch(dataURL)).blob();
  const formData = new FormData();
  formData.append('image', blob, 'canvas.jpg');
  await fetch('/api/upload', { method: 'POST', body: formData });
}
```

### Export Single Object

```ts
// Temporarily isolate and export one object
function exportObject(obj: FabricObject) {
  const tempCanvas = new StaticCanvas(undefined, {
    width: obj.width * obj.scaleX,
    height: obj.height * obj.scaleY,
  });
  const clone = await obj.clone();
  clone.set({ left: 0, top: 0, originX: 'left', originY: 'top' });
  tempCanvas.add(clone);
  tempCanvas.renderAll();
  const dataURL = tempCanvas.toDataURL({ format: 'png', multiplier: 2 });
  await tempCanvas.dispose();
  return dataURL;
}
```

### Export Region (Crop)

```ts
const regionDataURL = canvas.toDataURL({
  format: 'png',
  left: 100,
  top: 50,
  width: 400,
  height: 300,
  multiplier: 2,
});
```

---

## Node.js / Server-Side Export

```ts
// Use fabric/node — ships with node-canvas support
import { StaticCanvas, Rect } from 'fabric/node';
import * as fs from 'fs';

const canvas = new StaticCanvas(undefined, { width: 800, height: 600 });

const rect = new Rect({ left: 100, top: 100, width: 200, height: 150, fill: '#4f46e5' });
canvas.add(rect);
canvas.renderAll();

// Export to PNG buffer
const stream = canvas.createPNGStream();
const out = fs.createWriteStream('output.png');
stream.pipe(out);
out.on('finish', () => console.log('PNG saved'));

// Or as data URL
const dataURL = canvas.toDataURL();
```

---

## Type Compatibility: v5 vs v6 JSON

JSON saved with v5 generally loads in v6, BUT:
- `fabric.Text` in v5 JSON serializes as `type: "text"` — in v6 it becomes `FabricText`, type is still `"text"` so it revives correctly.
- `fabric.IText` → `type: "i-text"` — still works.
- `fabric.Group` → Group rewrite in v6 means complex nested groups may differ.
- Always test cross-version loading in your app.
