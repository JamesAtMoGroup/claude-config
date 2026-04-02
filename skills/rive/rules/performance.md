# Rive Performance

## Canvas vs WebGL — Which Renderer to Choose

| Factor | Canvas (`@rive-app/react-canvas`) | WebGL2 (`@rive-app/react-webgl2`) |
|---|---|---|
| Bundle size | Smaller | Larger (~50% more) |
| Rendering quality | Good | Best (matches editor) |
| Vector feathering | No | Yes |
| Advanced Rive features | Limited | Full |
| Multiple instances on page | No context limit | Context limit (~8-16 per browser) |
| Performance (simple graphics) | Good enough | Overkill |
| Performance (complex graphics) | May degrade | Better |
| Recommendation | Most React apps | When visual fidelity matters most |

**Rule of thumb:** Use `@rive-app/react-canvas` unless:
- Your animation uses vector feathering or advanced renderer features
- You need the highest visual fidelity
- You have very complex graphics with many paths

---

## WebGL Multiple Instances — Offscreen Renderer

Browsers limit WebGL contexts to ~8-16 per page. If you render many Rive WebGL instances (e.g., list items), use the offscreen renderer:

```tsx
import Rive from '@rive-app/webgl2';

const r = new Rive({
  src: '/animations/card.riv',
  canvas: canvasEl,
  useOffscreenRenderer: true,  // share a single WebGL context offscreen
  autoplay: true,
});
```

For React WebGL2:

```tsx
import { useRive } from '@rive-app/react-webgl2';

const { RiveComponent } = useRive({
  src: '/animations/item.riv',
  autoplay: true,
  // useOffscreenRenderer is enabled automatically in react-webgl2 for lists
});
```

With canvas renderer, there is no context limit — it's safe to render dozens simultaneously.

---

## Preloading .riv Files (Hero Animations)

Preload both the `.riv` file and the WASM runtime before the component mounts. This eliminates the load delay.

```html
<!-- In your HTML <head> or Next.js _document.tsx -->
<link rel="preload" href="/animations/hero.riv" as="fetch" crossorigin="anonymous" />
<link rel="preload" href="https://unpkg.com/@rive-app/canvas/rive.wasm" as="fetch" crossorigin="anonymous" />
```

Or in Next.js:

```tsx
// pages/_document.tsx or app/layout.tsx
import Head from 'next/head';

export default function RootLayout({ children }) {
  return (
    <html>
      <head>
        <link rel="preload" href="/animations/hero.riv" as="fetch" crossOrigin="anonymous" />
      </head>
      <body>{children}</body>
    </html>
  );
}
```

---

## Self-Hosting the WASM Runtime

By default, Rive loads the WASM runtime from `unpkg.com`, causing an extra HTTP connection. Self-host to avoid it:

```bash
# Copy WASM to your public folder
cp node_modules/@rive-app/canvas/rive.wasm public/rive.wasm
```

```tsx
import { RuntimeLoader } from '@rive-app/react-canvas';

// Set this ONCE at app startup (before any Rive components mount)
RuntimeLoader.setWasmUrl('/rive.wasm');
```

---

## Caching .riv Files for Reuse

If the same `.riv` file is used in multiple places, parse it once and create artboard instances from the cached file:

```tsx
// Using vanilla JS runtime directly
import { RuntimeLoader, RiveFile } from '@rive-app/canvas';

let cachedFile: RiveFile | null = null;

async function getOrLoadRiveFile(src: string): Promise<RiveFile> {
  if (cachedFile) return cachedFile;
  const response = await fetch(src);
  const arrayBuffer = await response.arrayBuffer();
  const file = await RuntimeLoader.getInstance().then((runtime) =>
    runtime.load(new Uint8Array(arrayBuffer))
  );
  cachedFile = file;
  return file;
}
```

The `@rive-app/react-canvas` hook handles file loading internally; for shared caching across multiple components, use a React context or module-level singleton.

---

## Lazy Loading with Intersection Observer

Only mount the Rive component when it enters the viewport:

```tsx
import { useRef, useState, useEffect } from 'react';

function LazyRive({ src, stateMachine }) {
  const containerRef = useRef<HTMLDivElement>(null);
  const [shouldRender, setShouldRender] = useState(false);

  useEffect(() => {
    const observer = new IntersectionObserver(
      ([entry]) => {
        if (entry.isIntersecting) {
          setShouldRender(true);
          observer.disconnect();
        }
      },
      { threshold: 0.1 }
    );

    if (containerRef.current) observer.observe(containerRef.current);
    return () => observer.disconnect();
  }, []);

  return (
    <div ref={containerRef} style={{ minHeight: 300 }}>
      {shouldRender && <RivePlayer src={src} stateMachine={stateMachine} />}
    </div>
  );
}
```

Or use the `react-intersection-observer` library:

```bash
npm install react-intersection-observer
```

```tsx
import { useInView } from 'react-intersection-observer';

function LazyRive({ src }) {
  const { ref, inView } = useInView({ triggerOnce: true, threshold: 0.1 });
  return (
    <div ref={ref} style={{ minHeight: 300 }}>
      {inView && <RivePlayer src={src} />}
    </div>
  );
}
```

---

## Pause When Not Visible

Pausing a Rive animation when scrolled offscreen reduces CPU/GPU usage significantly.

```tsx
import { useRive } from '@rive-app/react-canvas';
import { useInView } from 'react-intersection-observer';
import { useEffect } from 'react';

export function PauseAwareRive({ src }) {
  const { ref: inViewRef, inView } = useInView({ threshold: 0 });
  const { rive, RiveComponent } = useRive({ src, autoplay: true });

  useEffect(() => {
    if (!rive) return;
    inView ? rive.play() : rive.pause();
  }, [rive, inView]);

  return (
    <div ref={inViewRef}>
      <RiveComponent style={{ width: 400, height: 400 }} />
    </div>
  );
}
```

---

## Remotion Integration (`@remotion/rive`)

Rive animations can be embedded in Remotion videos using the official `@remotion/rive` package.

```bash
npm install @remotion/rive
```

```tsx
import { RemotionRiveCanvas } from '@remotion/rive';
import { staticFile } from 'remotion';

export function RiveScene() {
  return (
    <RemotionRiveCanvas
      src={staticFile('animations/hero.riv')}
      // OR: src="https://cdn.rive.app/animations/vehicles.riv"
      artboard="Main"            // optional: artboard name or index
      animation="idle"           // optional: animation name or index
      onLoad={(riveFile) => {
        // riveFile is the RiveFile instance from Rive runtime
        console.log('Loaded:', riveFile);
      }}
    />
  );
}
```

**Important limitations:**
- `@remotion/rive` uses the Rive low-level JS runtime, not `@rive-app/react-canvas`
- State machine inputs are NOT directly exposed via props in `RemotionRiveCanvas`
- For state machine control in Remotion, use the `onLoad` callback to get the `RiveFile` and manually create a state machine controller
- Use `getAnimationInstance()` and `getArtboard()` via ref for imperative access

```tsx
import { useRef } from 'react';
import { RemotionRiveCanvas, RemotionRiveCanvasRef } from '@remotion/rive';
import { staticFile, useCurrentFrame } from 'remotion';

export function AnimatedRiveScene() {
  const ref = useRef<RemotionRiveCanvasRef>(null);
  const frame = useCurrentFrame();

  return (
    <RemotionRiveCanvas
      ref={ref}
      src={staticFile('scene.riv')}
      onLoad={(riveFile) => {
        // Access Rive runtime instance for manual control
        const artboard = ref.current?.getArtboard();
        // Drive animations based on frame time
      }}
    />
  );
}
```

**Note on state machines in Remotion:** As of early 2026, full state machine input control from Remotion is a known limitation. For frame-accurate animation in Remotion, prefer timeline animations (not state machines) when embedding Rive in video renders. Track https://github.com/remotion-dev/remotion/issues/5147 for state machine support updates.

---

## General Performance Checklist

- [ ] Use `@rive-app/react-canvas` unless WebGL quality is needed
- [ ] Isolate `useRive` in a dedicated child component to prevent unnecessary re-renders
- [ ] Preload `.riv` + WASM for above-the-fold animations
- [ ] Self-host `rive.wasm` to eliminate the `unpkg.com` request
- [ ] Cache `.riv` files if reused across multiple component instances
- [ ] Lazy load Rive components below the fold (Intersection Observer)
- [ ] Pause animations when scrolled offscreen
- [ ] For WebGL with many instances, use `useOffscreenRenderer: true`
- [ ] Use `Fit.Cover` or `Fit.Contain` with `setContainerRef` + `setCanvasRef` for responsive layouts (avoids constant canvas resize)
- [ ] Call `rive.resizeDrawingSurfaceToCanvas()` after dynamic container size changes
