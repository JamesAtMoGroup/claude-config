# GSAP Core API

## Installation & Setup

```bash
npm install gsap
```

```js
import { gsap } from 'gsap';
// Always register plugins at app entry point (once)
import { ScrollTrigger } from 'gsap/ScrollTrigger';
gsap.registerPlugin(ScrollTrigger);
```

## gsap.to()

Animate from current state TO specified values. Most common method.

```js
// Basic
gsap.to('.box', { x: 100, duration: 1 });

// Full options
gsap.to('.box', {
  // Transform shorthands (avoids matrix conflicts)
  x: 100,           // translateX in px
  y: 50,            // translateY in px
  xPercent: -50,    // translateX in %
  yPercent: -50,    // translateY in %
  rotation: 360,    // degrees
  rotationX: 45,
  rotationY: 45,
  scale: 1.5,
  scaleX: 2,
  scaleY: 0.5,
  skewX: 10,
  skewY: 10,

  // CSS properties (camelCase)
  opacity: 0,
  backgroundColor: '#ff0000',
  width: '200px',
  borderRadius: '50%',

  // Timing
  duration: 1,          // seconds (default: 0.5)
  delay: 0.5,           // seconds before start
  ease: 'power2.out',   // easing function (default: 'power1.out')

  // Repeat
  repeat: -1,           // -1 = infinite
  yoyo: true,           // reverse on alternate repeats
  repeatDelay: 1,       // seconds between repeats

  // Playback
  paused: true,         // don't autoplay
  reversed: false,

  // Overwrite
  overwrite: 'auto',    // 'auto' | true | false
                        // 'auto' kills only conflicting properties
                        // true kills ALL tweens on same targets

  // Callbacks
  onStart: () => {},
  onUpdate: () => {},
  onComplete: () => {},
  onRepeat: () => {},
  onReverseComplete: () => {},

  // Stagger (for multiple targets)
  stagger: 0.1,         // see stagger.md for advanced options
});
```

## gsap.from()

Animate FROM specified values TO current state.

```js
// Element fades in from below
gsap.from('.box', { y: 50, opacity: 0, duration: 0.8, ease: 'power2.out' });

// Useful for entrance animations
gsap.from('.card', { scale: 0, rotation: -10, opacity: 0, duration: 0.5 });
```

## gsap.fromTo()

Define explicit start AND end values. Use when you need deterministic start state.

```js
gsap.fromTo('.box',
  // FROM (start values)
  { x: -100, opacity: 0 },
  // TO (end values) — duration/ease go here
  { x: 0, opacity: 1, duration: 1, ease: 'power2.out' }
);
```

**When to prefer fromTo:**
- Animations triggered multiple times (prevents state accumulation)
- When re-running after partial completion
- When start state may be unpredictable

## gsap.set()

Immediately set properties with no animation (duration: 0).

```js
gsap.set('.box', { x: 100, opacity: 0 });
gsap.set(['.a', '.b', '.c'], { transformOrigin: '50% 50%' });

// Useful for initial state setup before animating
gsap.set('.menu', { display: 'none', y: -20 });
```

## gsap.timeline()

Container for sequencing multiple tweens. Preferred over chaining delays.

```js
const tl = gsap.timeline({
  // Timeline-level options
  repeat: 2,
  repeatDelay: 0.5,
  yoyo: false,
  paused: false,
  delay: 0,
  defaults: { duration: 0.5, ease: 'power2.out' }, // inherited by children
  onComplete: () => console.log('done'),
  onUpdate: () => {},
  onStart: () => {},
});

// Methods chain — each runs sequentially by default
tl.from('.title', { y: 30, opacity: 0 })
  .from('.subtitle', { y: 20, opacity: 0 })
  .to('.button', { scale: 1.1 });
```

### Position Parameter (critical feature)

Controls WHERE in the timeline an animation inserts:

```js
tl.to('.a', { x: 100 })                 // after previous ends (default)
  .to('.b', { y: 100 }, '+=0.5')        // 0.5s AFTER previous ends
  .to('.c', { opacity: 0 }, '-=0.3')    // 0.3s BEFORE previous ends (overlap)
  .to('.d', { scale: 2 }, 1.5)          // at absolute 1.5s mark
  .to('.e', { x: 50 }, '<')             // same START time as previous
  .to('.f', { y: 50 }, '>')             // same END time as previous
  .to('.g', { x: 0 }, '<0.2')           // 0.2s after previous START
  .to('.h', { y: 0 }, '>0.2')           // 0.2s after previous END
  .to('.i', { opacity: 1 }, 'myLabel')  // at label position
  .addLabel('myLabel', 2);              // add label at 2s
```

### Timeline Control Methods

```js
const tl = gsap.timeline({ paused: true });

tl.play();
tl.pause();
tl.reverse();
tl.restart();
tl.seek(2);           // jump to 2 seconds
tl.progress(0.5);     // jump to 50% through
tl.timeScale(2);      // play at 2x speed
tl.kill();            // destroy
tl.duration();        // get total duration
tl.time();            // get current time
```

### Nested Timelines

```js
function buildCardAnim(card) {
  return gsap.timeline()
    .from(card.querySelector('.img'), { scale: 1.2, duration: 0.6 })
    .from(card.querySelector('.text'), { y: 20, opacity: 0 }, '-=0.3');
}

const master = gsap.timeline();
document.querySelectorAll('.card').forEach((card, i) => {
  master.add(buildCardAnim(card), i * 0.2); // offset each card
});
```

## Special Property Values

```js
// Relative values
gsap.to('.box', { x: '+=50' });   // add 50 to current x
gsap.to('.box', { x: '-=50' });   // subtract 50

// Random values (string syntax)
gsap.to('.box', { x: 'random(-200, 200)' });
gsap.to('.box', { x: 'random(-200, 200, 10)' }); // snapped to nearest 10

// Function-based (called per target)
gsap.to('.box', {
  x: (index, target, targets) => index * 100,
  y: (index) => Math.sin(index) * 50,
});

// Keyframes
gsap.to('.box', {
  keyframes: [
    { x: 100, duration: 0.5 },
    { y: 50, duration: 0.3 },
    { rotation: 180, duration: 0.8, ease: 'bounce.out' },
  ]
});
```

## Global Configuration

```js
// gsap.defaults() — inherited by all tweens
gsap.defaults({
  duration: 0.5,
  ease: 'power2.out',
  overwrite: 'auto',
});

// gsap.config() — global engine settings
gsap.config({
  force3D: false,       // 'auto' | true | false (default: 'auto')
  nullTargetWarn: false, // suppress missing-element warnings
  units: { left: '%' }, // default CSS units per property
  autoSleep: 60,        // frames before engine sleeps (default: 120)
});
```

## Control Methods on Tweens

```js
const tween = gsap.to('.box', { x: 200, duration: 2 });

tween.pause();
tween.play();
tween.reverse();
tween.restart();
tween.kill();
tween.progress(0.5);      // 0-1
tween.seek(1);            // jump to 1 second
tween.timeScale(0.5);     // half speed
tween.duration();         // get duration
tween.isActive();         // boolean
```

## Targets

```js
// All these are valid targets:
gsap.to('.box', {})                          // CSS selector string
gsap.to(document.getElementById('box'), {}) // DOM element
gsap.to([el1, el2, el3], {})               // array of elements
gsap.to(document.querySelectorAll('li'), {}) // NodeList
gsap.to({ value: 0 }, {                     // plain object (useful for counters)
  value: 100,
  onUpdate() { el.textContent = Math.round(this.targets()[0].value); }
});
```
