# Fabric.js — Events

Fabric.js has a rich event system. Events fire on both the **object** and the **canvas**, giving you flexibility in where you attach listeners.

## Attaching & Removing Listeners

```ts
// canvas.on(eventName, handler)
canvas.on('mouse:down', (e) => {
  console.log('Canvas clicked', e.pointer);
});

// object.on(eventName, handler)
rect.on('mousedown', (e) => {
  console.log('Rect clicked');
});

// Remove a specific listener
const handler = (e) => { /* ... */ };
canvas.on('object:modified', handler);
canvas.off('object:modified', handler);

// Remove ALL listeners for an event
canvas.off('mouse:down');

// fire() — manually trigger an event
canvas.fire('custom:event', { detail: 'hello' });
```

---

## Mouse Events

| Event | When | Object? | Canvas? |
|-------|------|---------|---------|
| `mouse:down` | Mouse button pressed | — | YES |
| `mouse:up` | Mouse button released | — | YES |
| `mouse:move` | Mouse moves | — | YES |
| `mouse:wheel` | Mouse scroll wheel | — | YES |
| `mouse:dblclick` | Double-click | — | YES |
| `mouse:over` | Cursor enters object bounding box | YES | YES |
| `mouse:out` | Cursor leaves object bounding box | YES | YES |

```ts
canvas.on('mouse:down', ({ e, pointer, target }) => {
  // e         — original MouseEvent
  // pointer   — { x, y } in canvas coordinates
  // target    — the FabricObject clicked (null if canvas background)
  if (target) {
    console.log('Clicked on:', target.type);
  } else {
    console.log('Clicked background at', pointer);
  }
});

canvas.on('mouse:move', ({ e, pointer }) => {
  // Fires continuously — be careful with performance
});

canvas.on('mouse:wheel', ({ e }) => {
  // e.deltaY — scroll amount
  // Commonly used for zoom:
  const delta = e.deltaY;
  let zoom = canvas.getZoom();
  zoom *= 0.999 ** delta;
  zoom = Math.min(Math.max(zoom, 0.1), 20);  // clamp
  canvas.zoomToPoint({ x: e.offsetX, y: e.offsetY }, zoom);
  e.preventDefault();
  e.stopPropagation();
});
```

---

## Object Events

These fire on the **object** itself (and also bubble to canvas as `object:*` events):

| Object event | Canvas event | When |
|---|---|---|
| `mousedown` | `object:mousedown` | Click down on object |
| `mouseup` | `object:mouseup` | Click released on object |
| `mouseover` | `object:over` | Cursor enters object |
| `mouseout` | `object:out` | Cursor leaves object |
| `moving` | `object:moving` | Continuously while dragging |
| `scaling` | `object:scaling` | Continuously while scaling |
| `rotating` | `object:rotating` | Continuously while rotating |
| `skewing` | `object:skewing` | Continuously while skewing |
| `moved` | `object:moved` | After drag ends |
| `scaled` | `object:scaled` | After scale ends |
| `rotated` | `object:rotated` | After rotation ends |
| `modified` | `object:modified` | After any transform completes |
| `added` | `object:added` | Object added to canvas |
| `removed` | `object:removed` | Object removed from canvas |

```ts
// Listen on the object
rect.on('moving', ({ e, transform }) => {
  console.log('Rect position:', rect.left, rect.top);
});

rect.on('modified', () => {
  console.log('Final state:', {
    left: rect.left,
    top: rect.top,
    scaleX: rect.scaleX,
    angle: rect.angle,
  });
});

// Listen on the canvas (catches all objects)
canvas.on('object:modified', ({ target }) => {
  console.log('Object modified:', target?.type, target?.left, target?.top);
});

canvas.on('object:moving', ({ target, e }) => {
  // Constrain movement to canvas bounds
  if (target) {
    target.set({
      left: Math.max(0, Math.min(target.left, canvas.width - target.width * target.scaleX)),
      top: Math.max(0, Math.min(target.top, canvas.height - target.height * target.scaleY)),
    });
  }
});

// Object added / removed
canvas.on('object:added', ({ target }) => {
  console.log('Added:', target.type);
});
canvas.on('object:removed', ({ target }) => {
  console.log('Removed:', target.type);
});
```

---

## Selection Events

| Event | When |
|-------|------|
| `selection:created` | New selection made (first object selected) |
| `selection:updated` | Selection changed (added/removed from multi-select) |
| `selection:cleared` | Selection deselected |
| `before:selection:cleared` | Just before selection is cleared |

```ts
canvas.on('selection:created', ({ selected }) => {
  // selected — array of newly selected objects
  console.log('Selected:', selected.length, 'object(s)');
  const active = canvas.getActiveObject();
  console.log('Active type:', active?.type);  // 'activeselection' for multi
});

canvas.on('selection:updated', ({ selected, deselected }) => {
  console.log('Added to selection:', selected);
  console.log('Removed from selection:', deselected);
});

canvas.on('selection:cleared', ({ deselected }) => {
  console.log('Deselected:', deselected);
});
```

---

## Canvas Lifecycle Events

```ts
canvas.on('canvas:cleared', () => { /* after clear() */ });

// After toDataURL or toSVG operations
canvas.on('before:render', () => { /* before each render frame */ });
canvas.on('after:render', () => { /* after each render frame */ });
```

---

## Path Drawing Events (Drawing Mode)

```ts
canvas.isDrawingMode = true;

canvas.on('path:created', ({ path }) => {
  // path — the newly created Path object
  path.set({ stroke: 'red', strokeWidth: 3 });
  canvas.requestRenderAll();
});
```

---

## Custom Events

```ts
// Fire custom event on canvas
canvas.fire('myapp:save', { timestamp: Date.now() });

// Listen
canvas.on('myapp:save', ({ timestamp }) => {
  console.log('Save at', timestamp);
});

// Fire on object
rect.fire('myapp:highlight');
rect.on('myapp:highlight', () => {
  rect.set('stroke', 'yellow');
  canvas.requestRenderAll();
});
```

---

## Selection & Controls Configuration

### Controlling What's Selectable

```ts
// Globally — change default for all new objects
import { FabricObject } from 'fabric';
FabricObject.prototype.selectable = false;     // make all objects non-selectable
FabricObject.prototype.hasControls = false;    // hide resize/rotate handles globally

// Per object
rect.selectable = false;
rect.evented = false;        // completely invisible to events
rect.hasControls = false;    // can select but can't transform
rect.hasBorders = false;     // can select but no border shown
```

### Locking Transforms

```ts
rect.set({
  lockMovementX: true,     // can't drag horizontally
  lockMovementY: true,     // can't drag vertically
  lockRotation: true,      // can't rotate
  lockScalingX: true,      // can't scale horizontally
  lockScalingY: true,      // can't scale vertically
  lockScalingFlip: true,   // prevent negative scale (mirror)
});
```

### Custom Controls

```ts
import { Control } from 'fabric';

// Add a custom delete button to every object
FabricObject.prototype.controls.deleteControl = new Control({
  x: 0.5,                   // position: right edge of bounding box
  y: -0.5,                  // position: top edge
  offsetX: 16,              // additional pixel offset
  offsetY: -16,
  cursorStyle: 'pointer',
  
  // Custom render — draw an icon/shape
  render(ctx, left, top, styleOverride, fabricObject) {
    ctx.save();
    ctx.translate(left, top);
    ctx.fillStyle = '#ef4444';
    ctx.beginPath();
    ctx.arc(0, 0, 10, 0, Math.PI * 2);
    ctx.fill();
    // Draw X
    ctx.strokeStyle = 'white';
    ctx.lineWidth = 2;
    ctx.beginPath();
    ctx.moveTo(-5, -5); ctx.lineTo(5, 5);
    ctx.moveTo(5, -5);  ctx.lineTo(-5, 5);
    ctx.stroke();
    ctx.restore();
  },

  // Action on click
  mouseUpHandler(eventData, transform) {
    const target = transform.target;
    const canvas = target.canvas;
    canvas?.remove(target);
    canvas?.requestRenderAll();
    return true;
  },

  // Click area size
  sizeX: 20,
  sizeY: 20,
  touchSizeX: 30,
  touchSizeY: 30,
});

// Add custom scale-by-width control
FabricObject.prototype.controls.mtr.offsetY = -40;  // move rotate handle up
```

### Hiding Specific Handles

```ts
// Hide individual corner handles
rect.setControlsVisibility({
  tl: false,    // top-left
  tr: false,    // top-right
  br: false,    // bottom-right
  bl: false,    // bottom-left
  ml: false,    // middle-left
  mr: false,    // middle-right
  mt: false,    // middle-top
  mb: false,    // middle-bottom
  mtr: false,   // rotate handle
});
```

---

## Keyboard Events

Fabric doesn't natively handle keyboard events — wire them up yourself:

```ts
document.addEventListener('keydown', (e) => {
  const active = canvas.getActiveObjects();
  if (active.length === 0) return;

  switch (e.key) {
    case 'Delete':
    case 'Backspace':
      active.forEach((obj) => canvas.remove(obj));
      canvas.discardActiveObject();
      canvas.requestRenderAll();
      break;

    case 'ArrowLeft':
      active.forEach((obj) => obj.set('left', obj.left - (e.shiftKey ? 10 : 1)));
      canvas.requestRenderAll();
      break;

    case 'ArrowRight':
      active.forEach((obj) => obj.set('left', obj.left + (e.shiftKey ? 10 : 1)));
      canvas.requestRenderAll();
      break;

    case 'ArrowUp':
      active.forEach((obj) => obj.set('top', obj.top - (e.shiftKey ? 10 : 1)));
      canvas.requestRenderAll();
      break;

    case 'ArrowDown':
      active.forEach((obj) => obj.set('top', obj.top + (e.shiftKey ? 10 : 1)));
      canvas.requestRenderAll();
      break;
  }
});
```
