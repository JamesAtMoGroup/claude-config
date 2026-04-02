# GSAP Easing

## Built-in Ease Types

Default ease: `"power1.out"`

All built-in eases support `.in`, `.out`, `.inOut` modifiers:

```js
ease: 'power1.in'     // accelerate
ease: 'power1.out'    // decelerate (most natural for UI)
ease: 'power1.inOut'  // accelerate then decelerate
```

### Standard Eases

| Ease | Description |
|------|-------------|
| `none` / `linear` | Constant speed |
| `power1` | Gentle quadratic |
| `power2` | Cubic — good default for UI |
| `power3` | Quartic — snappier |
| `power4` | Quintic — very snappy |
| `back` | Overshoots slightly before settling |
| `bounce` | Bounces at end (like a ball) |
| `circ` | Circular arc |
| `elastic` | Spring/rubber-band effect |
| `expo` | Exponential — very fast then slow |
| `sine` | Gentle sine wave curve |
| `steps(n)` | Stepped/staircase motion |

### Common Ease Patterns for UI

```js
// UI entrances — element enters from off-screen
ease: 'power2.out'       // good default
ease: 'expo.out'         // very quick start, elegant settle
ease: 'circ.out'         // smooth and crisp

// UI exits — disappear quickly
ease: 'power2.in'        // accelerate into exit
ease: 'expo.in'          // very quick exit

// Interactive feedback — button press, toggle
ease: 'back.out(1.7)'    // slight overshoot (feels alive)

// Spring-like
ease: 'elastic.out(1, 0.3)'  // (amplitude, period)
                              // amplitude: strength of bounce
                              // period: bounciness (lower = more bouncy)

// Bounce landing
ease: 'bounce.out'

// Loading indicators, infinite loops
ease: 'none'             // linear for progress bars
```

### Back Ease Parameters

```js
ease: 'back.out(1.7)'   // default overshoot amount is 1.7
ease: 'back.in(2.5)'    // larger = more overshoot
ease: 'back.inOut(1)'   // both sides
```

### Elastic Ease Parameters

```js
ease: 'elastic.out(1, 0.3)'
// param1: amplitude (1 = normal, 2 = double height)
// param2: period (0.1 = very bouncy, 0.5 = few bounces)
```

### Steps Ease

```js
ease: 'steps(5)'        // 5 discrete steps
ease: 'steps(12, start)' // start | end | none | both
```

## EasePack (Premium — now free)

Additional eases requiring registration:

```js
import { EasePack } from 'gsap/EasePack';
gsap.registerPlugin(EasePack);

ease: 'rough({...})'       // jagged, hand-drawn feel
ease: 'slow(0.7, 0.7)'    // slow in middle, fast at ends
ease: 'expoScale(1, 2)'   // scale with expo
```

## CustomEase

Draw any easing curve using a cubic bezier string (SVG path syntax).

```js
import { CustomEase } from 'gsap/CustomEase';
gsap.registerPlugin(CustomEase);

// Create once, reference by name everywhere
CustomEase.create('myEase', 'M0,0 C0.126,0.382 0.282,0.674 0.44,0.822 0.632,1.0 0.818,1.001 1,1');

gsap.to('.box', { x: 200, ease: 'myEase', duration: 1 });

// Common custom eases
CustomEase.create('smoothBounce', '0.175, 0.885, 0.32, 1');
CustomEase.create('snapIn', '0.23, 1, 0.32, 1');         // iOS-like
CustomEase.create('materialStandard', '0.4, 0, 0.2, 1'); // Material Design
```

## CustomBounce & CustomWiggle

```js
import { CustomBounce } from 'gsap/CustomBounce';
import { CustomWiggle } from 'gsap/CustomWiggle';
gsap.registerPlugin(CustomBounce, CustomWiggle);

CustomBounce.create('myBounce', {
  strength: 0.6,        // 0-1, bounciness
  squash: 3,            // squash/stretch amount
  endAtStart: false,
});

CustomWiggle.create('myWiggle', {
  wiggles: 6,           // number of oscillations
  type: 'easeOut',      // easeIn | easeOut | easeInOut | anticipate | uniform
});

gsap.to('.box', { y: -100, ease: 'myBounce', duration: 1 });
gsap.to('.box', { rotation: 10, ease: 'myWiggle', duration: 1 });
```

## Global Default Ease

```js
gsap.defaults({ ease: 'power2.out' });
```

## Ease Visualizer

Interactive tool: https://gsap.com/docs/v3/Eases/
