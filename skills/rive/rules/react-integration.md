# Rive React Integration

## Package Options

```bash
# Standard (recommended — canvas2D renderer)
npm install @rive-app/react-canvas

# Smaller bundle (no advanced renderer features like vector feathering)
npm install @rive-app/react-canvas-lite

# WebGL2 renderer (best quality, larger bundle)
npm install @rive-app/react-webgl2
```

All three expose the same API: `useRive`, `useStateMachineInput`, `RiveComponent`, `Layout`, `Fit`, `Alignment`, `EventType`.

---

## Pattern 1: Simple Drop-In

Use when you just need an animation to play without interaction.

```tsx
import { useRive } from '@rive-app/react-canvas';

export function HeroAnimation() {
  const { RiveComponent } = useRive({
    src: '/animations/hero.riv',
    autoplay: true,
  });

  return <RiveComponent style={{ width: '100%', height: 400 }} />;
}
```

---

## Pattern 2: Isolated Wrapper Component (Required for Artboard Switching)

**Critical:** Always isolate `useRive` into its own component. Rive instanciates on mount and cleans up on unmount. If you inline it in a parent component that re-renders for other reasons, you'll get flickering and broken animation state.

```tsx
// Good: isolated
function RivePlayer({ src, artboard, stateMachine }) {
  const { rive, RiveComponent } = useRive({
    src,
    artboard,
    stateMachines: stateMachine,
    autoplay: true,
  });
  return <RiveComponent style={{ width: 400, height: 400 }} />;
}

// Parent uses `key` for artboard switching
function App() {
  const [scene, setScene] = useState('Intro');

  return (
    <>
      <RivePlayer key={scene} src="/multi.riv" artboard={scene} />
      <button onClick={() => setScene('Outro')}>Switch</button>
    </>
  );
}
```

---

## Pattern 3: Responsive Full-Bleed Canvas

For a Rive animation that fills its container (e.g., hero background):

```tsx
import { useRive, Layout, Fit, Alignment } from '@rive-app/react-canvas';

export function RiveBackground() {
  const { setCanvasRef, setContainerRef } = useRive({
    src: '/animations/bg.riv',
    stateMachines: 'BGState',
    autoplay: true,
    layout: new Layout({ fit: Fit.Cover, alignment: Alignment.Center }),
  });

  return (
    <div
      ref={setContainerRef}
      style={{ position: 'absolute', inset: 0, overflow: 'hidden' }}
    >
      <canvas ref={setCanvasRef} style={{ width: '100%', height: '100%' }} />
    </div>
  );
}
```

**Note:** `setContainerRef` + `setCanvasRef` lets Rive observe container size changes and resize the canvas automatically. Always use this for responsive layouts.

---

## Pattern 4: Mouse-Driven State Machine

```tsx
import { useRive, useStateMachineInput, Layout, Fit, Alignment } from '@rive-app/react-canvas';
import { useEffect } from 'react';

const SM = 'Interactive';

export function MouseFollower() {
  const { rive, setCanvasRef, setContainerRef } = useRive({
    src: '/animations/interactive.riv',
    stateMachines: SM,
    autoplay: true,
    layout: new Layout({ fit: Fit.Cover, alignment: Alignment.Center }),
  });

  const xInput = useStateMachineInput(rive, SM, 'mouseX', 50);
  const yInput = useStateMachineInput(rive, SM, 'mouseY', 50);

  useEffect(() => {
    const handleMove = (e: MouseEvent) => {
      const x = (e.clientX / window.innerWidth) * 100;
      const y = (e.clientY / window.innerHeight) * 100;
      if (xInput) xInput.value = x;
      if (yInput) yInput.value = y;
    };
    window.addEventListener('mousemove', handleMove);
    return () => window.removeEventListener('mousemove', handleMove);
  }, [xInput, yInput]);

  return (
    <div ref={setContainerRef} style={{ width: '100vw', height: '100vh' }}>
      <canvas ref={setCanvasRef} />
    </div>
  );
}
```

---

## Pattern 5: Conditional Rendering / Lazy Load

Prevent Rive from loading until needed (saves bandwidth, avoids WASM parse on initial load):

```tsx
import { useState } from 'react';
import { useInView } from 'react-intersection-observer';

function RiveLazy({ src }) {
  const { ref, inView } = useInView({ triggerOnce: true, threshold: 0.1 });
  return (
    <div ref={ref} style={{ minHeight: 300 }}>
      {inView && <RivePlayer src={src} />}
    </div>
  );
}
```

Or with React.lazy + Suspense:

```tsx
const RivePlayer = React.lazy(() => import('./RivePlayer'));

function App() {
  return (
    <Suspense fallback={<div>Loading...</div>}>
      <RivePlayer src="/animations/hero.riv" />
    </Suspense>
  );
}
```

---

## Pattern 6: Pause When Offscreen

Pause animation when scrolled out of view to save CPU/GPU:

```tsx
import { useRive } from '@rive-app/react-canvas';
import { useInView } from 'react-intersection-observer';
import { useEffect } from 'react';

export function EfficientRive({ src }) {
  const { ref: inViewRef, inView } = useInView({ threshold: 0 });
  const { rive, RiveComponent } = useRive({ src, autoplay: true });

  useEffect(() => {
    if (!rive) return;
    if (inView) rive.play();
    else rive.pause();
  }, [rive, inView]);

  return (
    <div ref={inViewRef}>
      <RiveComponent style={{ width: 400, height: 400 }} />
    </div>
  );
}
```

---

## Next.js Integration

Rive uses WASM which requires special handling in Next.js:

```tsx
// next.config.js — allow WASM
const nextConfig = {
  webpack: (config) => {
    config.experiments = { ...config.experiments, asyncWebAssembly: true };
    return config;
  },
};

// Dynamic import to avoid SSR issues
import dynamic from 'next/dynamic';
const RiveAnimation = dynamic(() => import('./RiveAnimation'), { ssr: false });
```

Place `.riv` files in `public/animations/` and reference as `/animations/hero.riv`.

---

## React Native Integration

Uses a different package with a different API:

```bash
npm install @rive-app/react-native react-native-nitro-modules
```

```tsx
import Rive, { Fit, Alignment } from '@rive-app/react-native';

export function RiveNativeComponent() {
  return (
    <Rive
      resourceName="hero"        // name of the bundled .riv file (without extension)
      // OR:
      url="https://cdn.rive.app/animations/vehicles.riv"
      artboardName="Main"
      stateMachineName="State Machine 1"
      autoplay
      fit={Fit.Contain}
      alignment={Alignment.Center}
      style={{ width: 300, height: 300 }}
    />
  );
}
```

For state machine control in React Native, use a ref:

```tsx
import { useRef } from 'react';
import Rive, { RiveRef } from '@rive-app/react-native';

export function InteractiveRN() {
  const riveRef = useRef<RiveRef>(null);

  const handlePress = () => {
    // Set boolean input
    riveRef.current?.setInputState('State Machine 1', 'isPressed', true);
    // Fire trigger
    riveRef.current?.fireState('State Machine 1', 'tap');
    // Set number input
    riveRef.current?.setInputState('State Machine 1', 'speed', 75);
  };

  return (
    <Rive
      ref={riveRef}
      resourceName="interactive"
      stateMachineName="State Machine 1"
      autoplay
      style={{ width: 300, height: 300 }}
    />
  );
}
```

---

## Common Gotchas

**1. rive is null on first render**
Always null-check before calling rive methods or using inputs from `useStateMachineInput`.

```tsx
// Wrong
rive.play(); // crashes if rive not loaded yet

// Correct
rive?.play();
// or
if (rive) rive.play();
```

**2. Canvas disappears after parent re-render**
Isolate `useRive` in its own child component.

**3. Animation doesn't start**
Ensure `autoplay: true` OR call `rive.play()` inside `onLoad`.

**4. Responsive canvas not filling container**
Use `setContainerRef` + `setCanvasRef` (not `RiveComponent`) for responsive layouts.

**5. State machine name must match exactly**
The name is case-sensitive and must match the name in the Rive editor. Inspect using Rive editor or `rive.stateMachineNames`.

**6. Multiple Rive instances on one page**
Switch to WebGL with `useOffscreenRenderer: true` or use canvas renderer (no WebGL context limit).
