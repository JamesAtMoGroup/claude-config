# Fabric.js — React Integration

Fabric.js manages its own DOM (the `<canvas>` element). React should not try to control the canvas content declaratively — instead, treat it as an **uncontrolled component** and use `useRef` + `useEffect` to wire it up.

---

## Core Pattern: useRef + useEffect

```tsx
import { useEffect, useRef, useState } from 'react';
import { Canvas, Rect, Circle, FabricText, type Canvas as FabricCanvas } from 'fabric';

function FabricEditor() {
  const canvasElRef = useRef<HTMLCanvasElement>(null);
  const canvasRef = useRef<FabricCanvas | null>(null);

  useEffect(() => {
    if (!canvasElRef.current) return;

    // Initialize Fabric canvas
    const canvas = new Canvas(canvasElRef.current, {
      width: 800,
      height: 600,
      backgroundColor: '#f8fafc',
    });
    canvasRef.current = canvas;

    // Add initial objects
    const rect = new Rect({
      left: 100, top: 100,
      width: 200, height: 150,
      fill: '#4f46e5',
      rx: 8, ry: 8,
    });
    canvas.add(rect);
    canvas.renderAll();

    // Cleanup: MUST await dispose in v6
    return () => {
      canvas.dispose();  // dispose() returns Promise in v6 — OK to not await in cleanup
    };
  }, []);   // empty deps — run once on mount

  return <canvas ref={canvasElRef} />;
}
```

---

## React 18 Strict Mode: Double Mount

React 18 Strict Mode mounts components twice in development. Fabric canvas must be fully disposed before re-creating:

```tsx
useEffect(() => {
  if (!canvasElRef.current) return;

  // Guard: only init if not already initialized
  if (canvasRef.current) return;

  const canvas = new Canvas(canvasElRef.current, { width: 800, height: 600 });
  canvasRef.current = canvas;

  return () => {
    canvas.dispose().then(() => {
      canvasRef.current = null;
    });
  };
}, []);
```

---

## Custom Hook: useFabricCanvas

Encapsulate canvas initialization in a reusable hook:

```tsx
import { useEffect, useRef, useCallback } from 'react';
import { Canvas, type Canvas as FabricCanvas } from 'fabric';

interface UseFabricCanvasOptions {
  width?: number;
  height?: number;
  backgroundColor?: string;
}

export function useFabricCanvas(options: UseFabricCanvasOptions = {}) {
  const { width = 800, height = 600, backgroundColor = '#ffffff' } = options;
  const canvasElRef = useRef<HTMLCanvasElement>(null);
  const canvasRef = useRef<FabricCanvas | null>(null);

  useEffect(() => {
    const el = canvasElRef.current;
    if (!el || canvasRef.current) return;

    const canvas = new Canvas(el, { width, height, backgroundColor });
    canvasRef.current = canvas;

    return () => {
      canvas.dispose().then(() => {
        canvasRef.current = null;
      });
    };
  }, [width, height, backgroundColor]);

  const getCanvas = useCallback(() => canvasRef.current, []);

  return { canvasElRef, canvasRef, getCanvas };
}

// Usage
function MyEditor() {
  const { canvasElRef, canvasRef } = useFabricCanvas({ width: 1200, height: 800 });

  const addRect = () => {
    const canvas = canvasRef.current;
    if (!canvas) return;
    canvas.add(new Rect({ left: 50, top: 50, width: 100, height: 100, fill: 'red' }));
    canvas.requestRenderAll();
  };

  return (
    <div>
      <canvas ref={canvasElRef} />
      <button onClick={addRect}>Add Rectangle</button>
    </div>
  );
}
```

---

## Syncing Fabric State to React State

React state should only reflect **metadata** about canvas objects, not the objects themselves. Use canvas events to sync:

```tsx
import { useEffect, useRef, useState } from 'react';
import { Canvas, type FabricObject } from 'fabric';

interface ObjectMeta {
  id: string;
  type: string;
  left: number;
  top: number;
}

function EditorWithSidebar() {
  const canvasElRef = useRef<HTMLCanvasElement>(null);
  const canvasRef = useRef<Canvas | null>(null);
  const [selectedObject, setSelectedObject] = useState<ObjectMeta | null>(null);
  const [objectCount, setObjectCount] = useState(0);

  useEffect(() => {
    if (!canvasElRef.current) return;

    const canvas = new Canvas(canvasElRef.current, { width: 800, height: 600 });
    canvasRef.current = canvas;

    // Sync selection to React state
    canvas.on('selection:created', ({ selected }) => {
      const obj = selected[0];
      setSelectedObject({
        id: (obj as any).id ?? 'no-id',
        type: obj.type ?? 'unknown',
        left: obj.left,
        top: obj.top,
      });
    });

    canvas.on('selection:cleared', () => {
      setSelectedObject(null);
    });

    canvas.on('object:modified', ({ target }) => {
      if (!target) return;
      setSelectedObject({
        id: (target as any).id ?? 'no-id',
        type: target.type ?? 'unknown',
        left: Math.round(target.left),
        top: Math.round(target.top),
      });
    });

    // Track object count
    const updateCount = () => setObjectCount(canvas.getObjects().length);
    canvas.on('object:added', updateCount);
    canvas.on('object:removed', updateCount);

    return () => { canvas.dispose(); };
  }, []);

  // Update object property FROM React (e.g., from a form input)
  const updateLeft = (value: number) => {
    const active = canvasRef.current?.getActiveObject();
    if (active) {
      active.set('left', value);
      active.setCoords();
      canvasRef.current?.requestRenderAll();
      setSelectedObject((prev) => prev ? { ...prev, left: value } : null);
    }
  };

  return (
    <div style={{ display: 'flex', gap: 16 }}>
      <canvas ref={canvasElRef} />

      <aside>
        <p>Objects: {objectCount}</p>
        {selectedObject && (
          <div>
            <p>Type: {selectedObject.type}</p>
            <label>
              Left:
              <input
                type="number"
                value={selectedObject.left}
                onChange={(e) => updateLeft(Number(e.target.value))}
              />
            </label>
          </div>
        )}
      </aside>
    </div>
  );
}
```

---

## Handling Canvas Resize

```tsx
useEffect(() => {
  if (!canvasElRef.current || !canvasRef.current) return;

  const resizeObserver = new ResizeObserver(([entry]) => {
    const { width, height } = entry.contentRect;
    canvasRef.current?.setDimensions({ width, height });
    canvasRef.current?.requestRenderAll();
  });

  const wrapper = canvasElRef.current.parentElement;
  if (wrapper) resizeObserver.observe(wrapper);

  return () => resizeObserver.disconnect();
}, []);
```

---

## Responsive Canvas with CSS Scaling

```tsx
// Make canvas visually responsive without changing its coordinate space
// (preserves object positions at 1:1)

function ResponsiveCanvas() {
  const canvasElRef = useRef<HTMLCanvasElement>(null);
  const wrapperRef = useRef<HTMLDivElement>(null);
  const canvasRef = useRef<Canvas | null>(null);

  const CANVAS_WIDTH = 1920;
  const CANVAS_HEIGHT = 1080;

  useEffect(() => {
    if (!canvasElRef.current) return;
    const canvas = new Canvas(canvasElRef.current, {
      width: CANVAS_WIDTH,
      height: CANVAS_HEIGHT,
    });
    canvasRef.current = canvas;
    return () => { canvas.dispose(); };
  }, []);

  return (
    <div
      ref={wrapperRef}
      style={{
        width: '100%',
        aspectRatio: `${CANVAS_WIDTH} / ${CANVAS_HEIGHT}`,
        overflow: 'hidden',
      }}
    >
      <canvas
        ref={canvasElRef}
        style={{
          width: '100%',
          height: '100%',
        }}
      />
    </div>
  );
}
```

---

## Event Cleanup

Always remove Fabric event listeners that reference React state, to avoid stale closures:

```tsx
useEffect(() => {
  const canvas = canvasRef.current;
  if (!canvas) return;

  const handleModified = ({ target }: { target: FabricObject }) => {
    setLastModified(target.type);
  };

  canvas.on('object:modified', handleModified);

  return () => {
    canvas.off('object:modified', handleModified);  // clean up specific handler
  };
}, []);  // runs once — stable reference
```

---

## Next.js: Avoid SSR

Fabric.js requires `window` and `document` — do not render on server:

```tsx
// Option 1: dynamic import with ssr: false
import dynamic from 'next/dynamic';

const FabricEditor = dynamic(() => import('./FabricEditor'), { ssr: false });

// Option 2: Check window in useEffect (always client-safe)
useEffect(() => {
  // This only runs on client — safe to use Fabric here
  const { Canvas } = await import('fabric');
  // ...
}, []);

// Option 3: 'use client' directive + typeof window guard
'use client';
// import { Canvas } from 'fabric' is fine here
```

---

## Third-Party React Libraries

| Library | Notes |
|---------|-------|
| `fabricjs-react` | Thin React wrapper; hooks-based; check version compatibility |
| `react-fabric` | Declarative components; simpler API; less flexible |
| **Custom hook** | Recommended — full control, no dependency overhead |

Most production apps implement a custom `useFabricCanvas` hook rather than using third-party wrappers, which often lag behind Fabric.js version updates.

---

## TypeScript: Extending FabricObject

```ts
// types/fabric.d.ts
import 'fabric';

declare module 'fabric' {
  interface FabricObject {
    id?: string;
    name?: string;
    locked?: boolean;
    layerIndex?: number;
  }
}

// Register custom properties for serialization
import { FabricObject } from 'fabric';
FabricObject.customProperties = ['id', 'name', 'locked', 'layerIndex'];
```
