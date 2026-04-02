# Fabric.js — Animation

Fabric.js provides its own animation system via `util.animate` and the object-level `.animate()` method. For complex sequences, you can also combine with GSAP or anime.js.

## Import (v6+)

```ts
import { util } from 'fabric';
// util.animate, util.ease
```

---

## Object.animate() — Property Animation

The simplest way to animate a single object property:

```ts
// Animate a property to a target value
rect.animate('left', 400, {
  duration: 800,         // ms (default: 500)
  onChange: () => canvas.requestRenderAll(),
  onComplete: () => console.log('Done!'),
});

// Animate from a custom starting value
rect.animate('opacity', 0, {
  from: 1,
  duration: 600,
  onChange: () => canvas.requestRenderAll(),
});

// Animate multiple properties simultaneously
rect.animate({ left: 400, top: 200, angle: 45 }, {
  duration: 1000,
  onChange: () => canvas.requestRenderAll(),
  onComplete: () => console.log('Multi-prop done'),
});

// Animate by relative amount (string prefix +/-)
rect.animate('left', '+=100', {        // add 100 to current left
  duration: 500,
  onChange: () => canvas.requestRenderAll(),
});

rect.animate('angle', '-=90', {        // subtract 90 from current angle
  duration: 600,
  onChange: () => canvas.requestRenderAll(),
});
```

---

## util.animate() — Low-level Animation

More control: animates any numeric value, not tied to an object property.

```ts
import { util } from 'fabric';

util.animate({
  startValue: 0,
  endValue: 1,
  duration: 1000,
  easing: util.ease.easeInOutQuad,   // easing function
  onChange: (value) => {
    rect.set('opacity', value);
    canvas.requestRenderAll();
  },
  onComplete: () => {
    console.log('Animation complete');
  },
  abort: () => {
    // Return true to stop the animation early
    return someCondition;
  },
});
```

### Animating Multiple Values

```ts
// Color interpolation
util.animate({
  startValue: 0,
  endValue: 1,
  duration: 1500,
  easing: util.ease.easeInOutSine,
  onChange: (t) => {
    // Interpolate between two colors manually
    const r = Math.round(79 + (239 - 79) * t);    // 4f46e5 -> ef4444
    const g = Math.round(70 + (68 - 70) * t);
    const b = Math.round(229 + (68 - 229) * t);
    rect.set('fill', `rgb(${r},${g},${b})`);
    canvas.requestRenderAll();
  },
});
```

---

## Easing Functions

Available via `util.ease`:

```ts
import { util } from 'fabric';
const ease = util.ease;

// Linear
ease.linear

// Quad
ease.easeInQuad
ease.easeOutQuad
ease.easeInOutQuad

// Cubic
ease.easeInCubic
ease.easeOutCubic
ease.easeInOutCubic

// Quart / Quint
ease.easeInQuart
ease.easeOutQuart
ease.easeInOutQuart
ease.easeInQuint
ease.easeOutQuint
ease.easeInOutQuint

// Sine
ease.easeInSine       // default for object.animate()
ease.easeOutSine
ease.easeInOutSine

// Expo
ease.easeInExpo
ease.easeOutExpo
ease.easeInOutExpo

// Circ
ease.easeInCirc
ease.easeOutCirc
ease.easeInOutCirc

// Elastic
ease.easeInElastic
ease.easeOutElastic
ease.easeInOutElastic

// Back (overshoot)
ease.easeInBack
ease.easeOutBack
ease.easeInOutBack

// Bounce
ease.easeInBounce
ease.easeOutBounce
ease.easeInOutBounce
```

Usage:
```ts
rect.animate('left', 400, {
  duration: 800,
  easing: util.ease.easeOutBounce,
  onChange: () => canvas.requestRenderAll(),
});
```

---

## Managing Running Animations

```ts
import { runningAnimations } from 'fabric';

// See all currently running animations
console.log(runningAnimations);

// Cancel all animations on a specific object
runningAnimations.cancelByTarget(rect);

// Cancel all animations
runningAnimations.cancelAll();

// v6: animations auto-cancel when object is disposed
// Attach animations via target property so they clean up:
util.animate({
  target: rect,    // animation auto-cancels if rect is disposed
  startValue: 0,
  endValue: 1,
  // ...
});
```

---

## Looping / Repeating Animations

Fabric doesn't have built-in loop support — chain in `onComplete`:

```ts
function animateLoop(obj: FabricObject) {
  let running = true;

  function step() {
    if (!running) return;
    obj.animate('angle', '+=360', {
      duration: 3000,
      easing: util.ease.linear,
      onChange: () => canvas.requestRenderAll(),
      onComplete: () => step(),  // loop by calling self
    });
  }

  step();
  return () => { running = false; };   // returns stop function
}

const stopRotation = animateLoop(rect);
// Later: stopRotation();
```

### Ping-pong (back-and-forth)

```ts
let goingRight = true;

function pingPong() {
  rect.animate('left', goingRight ? 600 : 100, {
    duration: 1200,
    easing: util.ease.easeInOutSine,
    onChange: () => canvas.requestRenderAll(),
    onComplete: () => {
      goingRight = !goingRight;
      pingPong();
    },
  });
}

pingPong();
```

---

## Sequencing Animations

Chain animations using `onComplete`:

```ts
// 1. Fade in
rect.animate('opacity', 1, {
  from: 0,
  duration: 400,
  onChange: () => canvas.requestRenderAll(),
  onComplete: () => {
    // 2. Move right
    rect.animate('left', 400, {
      duration: 600,
      easing: util.ease.easeOutCubic,
      onChange: () => canvas.requestRenderAll(),
      onComplete: () => {
        // 3. Scale down
        rect.animate({ scaleX: 0.5, scaleY: 0.5 }, {
          duration: 400,
          easing: util.ease.easeInBack,
          onChange: () => canvas.requestRenderAll(),
        });
      },
    });
  },
});
```

### Promise wrapper for cleaner sequencing

```ts
function animate(obj: FabricObject, props: Record<string, number | string>, options: Partial<AnimationOptions> = {}): Promise<void> {
  return new Promise((resolve) => {
    obj.animate(props, {
      ...options,
      onChange: () => canvas.requestRenderAll(),
      onComplete: resolve,
    });
  });
}

// Now use async/await
await animate(rect, { opacity: 1 }, { from: 0, duration: 400 });
await animate(rect, { left: 400 }, { duration: 600, easing: util.ease.easeOutCubic });
await animate(rect, { scaleX: 0.5, scaleY: 0.5 }, { duration: 400 });
console.log('Sequence complete!');
```

---

## Integrating with GSAP (External Animation Library)

For complex sequences with GSAP:

```ts
import gsap from 'gsap';

// GSAP to/from works on Fabric objects directly since they're plain objects
gsap.to(rect, {
  left: 400,
  top: 200,
  angle: 45,
  opacity: 0.5,
  duration: 1,
  ease: 'power2.out',
  onUpdate: () => {
    rect.setCoords();           // update selection box
    canvas.requestRenderAll();
  },
});

// GSAP timeline
const tl = gsap.timeline();
tl.to(rect, { left: 400, duration: 0.8, onUpdate: () => canvas.requestRenderAll() })
  .to(circle, { top: 200, duration: 0.6 }, '-=0.3')   // overlap
  .to(text, { opacity: 1, duration: 0.4 });
```

---

## Transition on Object Add (Fade-in)

```ts
canvas.on('object:added', ({ target }) => {
  target.set('opacity', 0);
  target.animate('opacity', 1, {
    duration: 300,
    easing: util.ease.easeOutQuad,
    onChange: () => canvas.requestRenderAll(),
  });
});
```

---

## Animate Background Color

```ts
// util.animate works on any value — use for background
util.animate({
  startValue: 0,
  endValue: 100,
  duration: 2000,
  onChange: (value) => {
    const hue = Math.round(value * 3.6);  // 0-360
    canvas.set('backgroundColor', `hsl(${hue}, 70%, 95%)`);
    canvas.requestRenderAll();
  },
});
```
