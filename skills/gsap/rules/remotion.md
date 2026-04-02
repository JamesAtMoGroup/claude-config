# GSAP + Remotion Integration

## Overview

Remotion renders video frame-by-frame using React. GSAP's timeline system maps naturally
to this model: create a **paused** GSAP timeline, then `seek()` to `frame / fps` each frame.

GSAP handles complex easing, staggering, SVG morphing, and text splitting that Remotion's
native `interpolate()` / `spring()` cannot easily replicate.

## Core Pattern: useGSAPTimeline Hook

```tsx
import { useRef, useEffect } from 'react';
import { useCurrentFrame, useVideoConfig } from 'remotion';
import { gsap } from 'gsap';

function useGSAPTimeline(
  buildTimeline: (tl: gsap.core.Timeline) => void,
  deps: React.DependencyList = []
) {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();
  const ref = useRef<HTMLDivElement>(null);
  const tlRef = useRef<gsap.core.Timeline | null>(null);

  useEffect(() => {
    if (!ref.current) return;

    const ctx = gsap.context(() => {
      const tl = gsap.timeline({ paused: true });
      buildTimeline(tl);
      tlRef.current = tl;
    }, ref);

    return () => ctx.revert();
  // eslint-disable-next-line react-hooks/exhaustive-deps
  }, deps);

  useEffect(() => {
    if (tlRef.current) {
      tlRef.current.seek(frame / fps);
    }
  }, [frame, fps]);

  return ref;
}
```

## Usage Example

```tsx
import { useCurrentFrame, useVideoConfig, AbsoluteFill } from 'remotion';

function MyScene() {
  const containerRef = useGSAPTimeline((tl) => {
    tl
      .from('.title', { opacity: 0, y: 40, duration: 0.6, ease: 'power3.out' })
      .from('.subtitle', { opacity: 0, y: 20, duration: 0.4 }, '-=0.2')
      .from('.items', {
        opacity: 0,
        x: -30,
        stagger: 0.1,
        duration: 0.4,
        ease: 'power2.out',
      }, '-=0.1');
  });

  return (
    <AbsoluteFill ref={containerRef} style={{ background: '#111' }}>
      <h1 className="title">Hello World</h1>
      <p className="subtitle">A GSAP + Remotion animation</p>
      <div className="items">Item 1</div>
      <div className="items">Item 2</div>
      <div className="items">Item 3</div>
    </AbsoluteFill>
  );
}
```

## Important Constraints

### 1. No ScrollTrigger
Remotion doesn't have a scrollable viewport. ScrollTrigger is useless here.
Use the timeline's time position instead.

### 2. Deterministic Rendering Required
Remotion renders each frame independently (possibly out of order). The GSAP timeline
**must** produce the same output for the same frame number every time.

```tsx
// CORRECT — deterministic
tl.from('.box', { x: -100, opacity: 0, duration: 1 });

// WRONG — random values break determinism
tl.to('.box', { x: 'random(-100, 100)' }); // different each render!
```

### 3. Time Precision
`frame / fps` maps frames to seconds. At 30fps:
- Frame 0 = 0.000s
- Frame 15 = 0.500s
- Frame 30 = 1.000s

So a GSAP duration of `1` = 30 frames at 30fps.

### 4. SplitText + Remotion
SplitText modifies the DOM, which can cause issues with React re-renders.
Create the split inside the effect and revert it in cleanup:

```tsx
useEffect(() => {
  const ctx = gsap.context(() => {
    const split = SplitText.create('.headline', { type: 'chars' });
    const tl = gsap.timeline({ paused: true });

    tl.from(split.chars, {
      opacity: 0,
      y: 30,
      stagger: 0.05,
      duration: 0.4,
    });

    tlRef.current = tl;
    return () => split.revert();
  }, ref);

  return () => ctx.revert();
}, []);
```

### 5. MorphSVG + Remotion
Works well because it's CSS/transform-based:

```tsx
useGSAPTimeline((tl) => {
  tl.to('#star', { morphSVG: '#circle', duration: 1 })
    .to('#circle', { morphSVG: '#star', duration: 1 });
});
```

## Frame-to-Time Conversion Utilities

```tsx
const { fps, durationInFrames } = useVideoConfig();
const frame = useCurrentFrame();

// Convert frames to seconds for GSAP
const currentTime = frame / fps;

// Useful helper
function framesToSeconds(frames: number, fps: number) {
  return frames / fps;
}

// GSAP duration equivalent for N frames
// 30 frames at 30fps = 1 second → duration: 1
// 15 frames at 30fps = 0.5 second → duration: 0.5
```

## Alternative: Direct interpolate() Bridge

For simple cases, map Remotion's `interpolate()` to GSAP-driven values
without using a timeline:

```tsx
import { interpolate, useCurrentFrame, useVideoConfig } from 'remotion';
import { Easing } from 'remotion';

// Remotion's native approach (simpler for basic cases)
const opacity = interpolate(frame, [0, 30], [0, 1], {
  easing: Easing.out(Easing.ease),
  extrapolateRight: 'clamp',
});
```

Use GSAP timeline approach when you need:
- Complex multi-property sequences
- Stagger animations
- GSAP-only plugins (MorphSVG, SplitText, DrawSVG, TextPlugin)
- Advanced easing (CustomEase, elastic, bounce with fine control)
- Nested timelines for modular scene building

## Plugin Registration for Remotion

```tsx
// remotion/register-gsap.ts — import at app root
import { gsap } from 'gsap';
import { SplitText } from 'gsap/SplitText';
import { MorphSVGPlugin } from 'gsap/MorphSVGPlugin';
import { DrawSVGPlugin } from 'gsap/DrawSVGPlugin';
import { TextPlugin } from 'gsap/TextPlugin';
import { MotionPathPlugin } from 'gsap/MotionPathPlugin';

gsap.registerPlugin(SplitText, MorphSVGPlugin, DrawSVGPlugin, TextPlugin, MotionPathPlugin);

// Disable autoSleep for video rendering (prevents GSAP from sleeping between frames)
gsap.config({ autoSleep: 0 });
```

## Complete Scene Example

```tsx
import { AbsoluteFill, useCurrentFrame, useVideoConfig } from 'remotion';
import { useRef, useEffect } from 'react';
import { gsap } from 'gsap';
import { SplitText } from 'gsap/SplitText';

export function IntroScene() {
  const ref = useRef<HTMLDivElement>(null);
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();
  const tlRef = useRef<gsap.core.Timeline | null>(null);

  useEffect(() => {
    if (!ref.current) return;

    const ctx = gsap.context(() => {
      const headlineSplit = SplitText.create('.headline', { type: 'chars' });

      const tl = gsap.timeline({ paused: true });

      // Background fade in
      tl.from(ref.current, { backgroundColor: '#000', duration: 0.5 })

        // Headline chars stagger in
        .from(headlineSplit.chars, {
          opacity: 0,
          y: 30,
          rotationX: -90,
          stagger: 0.04,
          duration: 0.5,
          ease: 'back.out(1.7)',
        }, 0.2)

        // Subtitle slides up
        .from('.subtitle', {
          opacity: 0,
          y: 20,
          duration: 0.4,
          ease: 'power2.out',
        }, '-=0.2')

        // CTA button scales in
        .from('.cta', {
          scale: 0,
          opacity: 0,
          duration: 0.5,
          ease: 'back.out(2)',
        }, '-=0.1');

      tlRef.current = tl;

      return () => headlineSplit.revert();
    }, ref);

    return () => ctx.revert();
  }, []);

  useEffect(() => {
    tlRef.current?.seek(frame / fps);
  }, [frame, fps]);

  return (
    <AbsoluteFill
      ref={ref}
      style={{ backgroundColor: '#0f0f1a', display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center' }}
    >
      <h1 className="headline" style={{ fontSize: 80, color: '#fff' }}>Hello World</h1>
      <p className="subtitle" style={{ fontSize: 36, color: '#aaa' }}>Built with GSAP + Remotion</p>
      <button className="cta" style={{ marginTop: 40, padding: '16px 32px', fontSize: 24 }}>Get Started</button>
    </AbsoluteFill>
  );
}
```
