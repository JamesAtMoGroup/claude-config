# GSAP + React Integration

## Setup

```bash
npm install gsap @gsap/react
```

```js
// In your app entry point or a shared setup file
import { gsap } from 'gsap';
import { useGSAP } from '@gsap/react';
import { ScrollTrigger } from 'gsap/ScrollTrigger';

gsap.registerPlugin(useGSAP, ScrollTrigger);
```

## useGSAP Hook

`useGSAP()` is a drop-in replacement for `useEffect` / `useLayoutEffect` that:
- Automatically handles cleanup via `gsap.context()`
- Reverts all animations on unmount
- Handles React 18 Strict Mode double-invocation correctly
- Is SSR-safe (falls back to `useEffect` when `window` is undefined)

### Basic Pattern

```jsx
import { useRef } from 'react';
import { gsap } from 'gsap';
import { useGSAP } from '@gsap/react';

gsap.registerPlugin(useGSAP);

function MyComponent() {
  const container = useRef(null);

  useGSAP(() => {
    // All GSAP code here is automatically cleaned up on unmount
    gsap.to('.box', { x: 100, duration: 1 });
  }, { scope: container }); // scope: scopes all selector text to container

  return (
    <div ref={container}>
      <div className="box" />
    </div>
  );
}
```

### Configuration Options

```js
// Option 1: Dependency array (like useEffect)
useGSAP(() => {
  gsap.to('.box', { x: value });
}, [value]); // re-runs when value changes

// Option 2: Config object
useGSAP(() => {
  gsap.to('.box', { x: 100 });
}, {
  scope: container,          // scope selector text to this element
  dependencies: [value],     // re-run when these change
  revertOnUpdate: true,      // revert animations before re-running (default: false)
});
```

### revertOnUpdate

```js
// Without revertOnUpdate (default false):
// Old animations persist; new ones are added on top
// Use when animations don't conflict with each other

// With revertOnUpdate: true:
// All animations are reverted before re-running
// Use when prop changes should restart the entire animation sequence
useGSAP(() => {
  gsap.from('.items', { opacity: 0, stagger: 0.1 });
}, {
  scope: container,
  dependencies: [items],
  revertOnUpdate: true, // clean slate each time items changes
});
```

## contextSafe — For Delayed / Event-Driven Animations

Animations created AFTER the hook runs (in event handlers, setTimeout, etc.) won't be tracked for cleanup. Wrap them with `contextSafe()`.

```jsx
function MyComponent() {
  const container = useRef(null);

  // Get contextSafe from the hook's return value
  const { contextSafe } = useGSAP({ scope: container });

  // Wrap event handlers with contextSafe
  const handleClick = contextSafe(() => {
    gsap.to('.box', { rotation: '+=90', duration: 0.5 });
  });

  const handleHover = contextSafe((e) => {
    gsap.to(e.currentTarget, { scale: 1.1, duration: 0.3 });
  });

  return (
    <div ref={container}>
      <div className="box" onClick={handleClick} onMouseEnter={handleHover} />
    </div>
  );
}
```

### contextSafe as Second Argument (inside hook)

```jsx
useGSAP((context, contextSafe) => {
  gsap.from('.box', { opacity: 0 }); // tracked automatically

  // Wrap delayed callbacks
  const safeCallback = contextSafe(() => {
    gsap.to('.box', { x: 100 }); // now tracked for cleanup
  });

  setTimeout(safeCallback, 1000);
}, { scope: container });
```

## Animating with Refs

```jsx
function MyComponent() {
  const boxRef = useRef(null);
  const container = useRef(null);

  useGSAP(() => {
    // Prefer refs over selector strings for specific elements
    gsap.to(boxRef.current, { x: 200, duration: 1 });

    // Selector strings work when scoped to container
    gsap.from('.inner', { opacity: 0, stagger: 0.1 });
  }, { scope: container });

  return (
    <div ref={container}>
      <div ref={boxRef} className="box">
        <span className="inner">A</span>
        <span className="inner">B</span>
        <span className="inner">C</span>
      </div>
    </div>
  );
}
```

## ScrollTrigger in React

```jsx
function ScrollSection() {
  const container = useRef(null);

  useGSAP(() => {
    gsap.from('.card', {
      opacity: 0,
      y: 50,
      stagger: 0.1,
      scrollTrigger: {
        trigger: container.current,
        start: 'top 80%',
        toggleActions: 'play none none reverse',
      }
    });
  }, { scope: container });

  return (
    <section ref={container}>
      <div className="card" />
      <div className="card" />
      <div className="card" />
    </section>
  );
}
```

## SplitText in React

```jsx
function AnimatedHeading({ text }) {
  const container = useRef(null);

  useGSAP(() => {
    const split = SplitText.create(container.current, { type: 'chars' });

    gsap.from(split.chars, {
      opacity: 0,
      y: 20,
      stagger: 0.03,
      duration: 0.5,
    });

    // SplitText is automatically reverted on unmount via context
    return () => split.revert(); // optional explicit cleanup
  }, { scope: container, dependencies: [text] });

  return <h1 ref={container}>{text}</h1>;
}
```

## Timeline with Playback Control

```jsx
function AnimatedCard() {
  const container = useRef(null);
  const tl = useRef(null);

  const { contextSafe } = useGSAP(() => {
    tl.current = gsap.timeline({ paused: true })
      .from('.card', { scale: 0.8, opacity: 0, duration: 0.4 })
      .from('.title', { y: 20, opacity: 0, duration: 0.3 })
      .from('.body', { y: 10, opacity: 0, duration: 0.3 });
  }, { scope: container });

  const playForward = contextSafe(() => tl.current.play());
  const playReverse = contextSafe(() => tl.current.reverse());

  return (
    <div ref={container}>
      <div className="card">
        <h2 className="title">Title</h2>
        <p className="body">Content</p>
      </div>
      <button onClick={playForward}>Show</button>
      <button onClick={playReverse}>Hide</button>
    </div>
  );
}
```

## Next.js Setup

For Next.js, add `"use client"` to components using GSAP:

```jsx
'use client'; // required for Next.js App Router

import { useRef } from 'react';
import { gsap } from 'gsap';
import { useGSAP } from '@gsap/react';

gsap.registerPlugin(useGSAP);
```

For global plugin registration (Next.js):

```js
// lib/gsap-setup.ts
'use client';
import { gsap } from 'gsap';
import { ScrollTrigger } from 'gsap/ScrollTrigger';
import { SplitText } from 'gsap/SplitText';
import { useGSAP } from '@gsap/react';

gsap.registerPlugin(useGSAP, ScrollTrigger, SplitText);
export { gsap, ScrollTrigger, SplitText, useGSAP };
```

## Common Pitfalls in React

```jsx
// WRONG — using useEffect without cleanup
useEffect(() => {
  gsap.to('.box', { x: 100 }); // leaks animations, breaks in Strict Mode
}, []);

// CORRECT — use useGSAP
useGSAP(() => {
  gsap.to('.box', { x: 100 });
});

// WRONG — creating animation in event handler without contextSafe
const handleClick = () => {
  gsap.to('.box', { x: 100 }); // not tracked for cleanup!
};

// CORRECT
const handleClick = contextSafe(() => {
  gsap.to('.box', { x: 100 });
});

// WRONG — selector without scope (may target wrong components)
useGSAP(() => {
  gsap.to('.box', { x: 100 }); // all .box on page!
});

// CORRECT — always use scope
useGSAP(() => {
  gsap.to('.box', { x: 100 }); // only .box inside container
}, { scope: container });
```

## gsap.context() — Manual Alternative to useGSAP

If not using the hook, manage context manually:

```js
useEffect(() => {
  const ctx = gsap.context(() => {
    gsap.to('.box', { x: 100 });
    ScrollTrigger.create({ ... });
  }, containerRef); // scope to container

  return () => ctx.revert(); // cleanup on unmount
}, []);
```
