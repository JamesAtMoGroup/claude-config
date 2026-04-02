# GSAP Stagger Animations

Staggers create offset start times for animations targeting multiple elements.

## Simple Stagger

```js
// 0.1s delay between each element's animation start
gsap.to('.box', { y: 100, stagger: 0.1 });
gsap.from('.card', { opacity: 0, y: 30, stagger: 0.15, duration: 0.6 });

// Negative stagger — last element starts first
gsap.to('.box', { x: 100, stagger: -0.1 });
```

## Advanced Stagger Object

```js
gsap.to('.box', {
  y: 100,
  stagger: {
    // Timing
    each: 0.1,      // seconds between each sub-tween's START
    amount: 1,      // total stagger time split among ALL elements
                    // (use either each OR amount, not both)

    // Direction/origin
    from: 'center',   // 'start' | 'center' | 'edges' | 'random' | 'end'
                      // OR a number index
                      // OR [x, y] coordinate for grid origin

    // Grid layout (for 2D staggers)
    grid: 'auto',     // auto-detect grid | [rows, cols] e.g. [5, 10]
    axis: null,       // null | 'x' | 'y' (focus stagger on one axis)

    // Ease across staggers (not the animation ease)
    ease: 'power2',   // controls TIME distribution of staggers

    // Repeat per element
    repeat: -1,       // elements repeat independently
    yoyo: true,
  }
});
```

### `each` vs `amount`

```js
// each: fixed delay between elements regardless of count
gsap.to('.box', { y: 100, stagger: { each: 0.2 } });
// With 5 elements: starts at 0, 0.2, 0.4, 0.6, 0.8

// amount: total time divided among elements
gsap.to('.box', { y: 100, stagger: { amount: 1 } });
// With 5 elements: starts at 0, 0.25, 0.5, 0.75, 1.0
// With 10 elements: same 1s spread, each gets 0.1s apart
// Use amount when you want the same total visual rhythm regardless of element count
```

### Grid Staggers

```js
// Animate grid items radiating from center
gsap.to('.grid-item', {
  scale: 0,
  opacity: 0,
  stagger: {
    grid: [5, 10],   // 5 rows, 10 columns
    from: 'center',  // ripple outward from center
    each: 0.05,
  }
});

// Ripple from a specific cell
gsap.to('.grid-item', {
  y: -20,
  stagger: {
    grid: 'auto',
    from: [0.5, 0.2],  // [x%, y%] from top-left corner
    each: 0.03,
  }
});
```

### Stagger from `"random"` (shuffled order)

```js
gsap.from('.particle', {
  opacity: 0,
  scale: 0,
  stagger: {
    from: 'random',
    each: 0.02,
  }
});
```

## Function-Based Stagger

```js
// Return total delay from animation start (not inter-element delay)
gsap.to('.box', {
  x: 100,
  stagger: (index, target, targets) => {
    return index * 0.1;  // same as stagger: 0.1
  }
});

// Complex formula
gsap.to('.box', {
  y: 50,
  stagger: (index, target, targets) => {
    const total = targets.length;
    return Math.sin((index / total) * Math.PI) * 0.5;
  }
});
```

## Stagger Callbacks (per-element)

```js
// onStart/onComplete fire for EACH element
gsap.to('.box', {
  x: 100,
  stagger: {
    each: 0.1,
    onStart() {
      // `this` refers to the current tween
      console.log('element started:', this.targets()[0]);
    },
    onComplete() {
      console.log('element done');
    },
  }
});
```

## Stagger in Timeline

```js
const tl = gsap.timeline();
tl.from('.items', {
  opacity: 0,
  y: 20,
  stagger: 0.1,
  duration: 0.5,
});
// All staggered animations are treated as one "unit" in the timeline
// Timeline moves on after the LAST staggered item completes
```

## Common Patterns

```js
// Card list entrance
gsap.from('.card', {
  opacity: 0,
  y: 40,
  duration: 0.6,
  ease: 'power2.out',
  stagger: 0.08,
});

// Text word by word
const split = SplitText.create('.headline', { type: 'words' });
gsap.from(split.words, {
  opacity: 0,
  y: 20,
  stagger: 0.05,
  duration: 0.4,
  ease: 'power2.out',
});

// Particle explosion from center
gsap.to('.particle', {
  x: () => gsap.utils.random(-300, 300),
  y: () => gsap.utils.random(-300, 300),
  opacity: 0,
  stagger: { from: 'center', each: 0.02 },
  duration: 0.8,
  ease: 'power2.out',
});
```
