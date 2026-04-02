# GSAP Plugins

All plugins are 100% free since Webflow's 2024 acquisition (including commercial use).

## Plugin Registration (required)

Always register plugins ONCE at app entry point, before any animation code runs:

```js
import { gsap } from 'gsap';
import { ScrollTrigger } from 'gsap/ScrollTrigger';
import { Draggable } from 'gsap/Draggable';
import { SplitText } from 'gsap/SplitText';
import { MorphSVGPlugin } from 'gsap/MorphSVGPlugin';
import { MotionPathPlugin } from 'gsap/MotionPathPlugin';
import { TextPlugin } from 'gsap/TextPlugin';
import { DrawSVGPlugin } from 'gsap/DrawSVGPlugin';
import { CustomEase } from 'gsap/CustomEase';

gsap.registerPlugin(
  ScrollTrigger,
  Draggable,
  SplitText,
  MorphSVGPlugin,
  MotionPathPlugin,
  TextPlugin,
  DrawSVGPlugin,
  CustomEase
);
```

---

## ScrollTrigger

Links animations to scroll position. Most powerful GSAP plugin.

### Basic Usage

```js
import { ScrollTrigger } from 'gsap/ScrollTrigger';
gsap.registerPlugin(ScrollTrigger);

// Inline shorthand (trigger element = animated element)
gsap.to('.box', {
  scrollTrigger: '.box',  // string shorthand
  x: 500,
});

// Full config object
gsap.to('.box', {
  x: 500,
  scrollTrigger: {
    trigger: '.box',         // element that triggers the animation
    start: 'top 80%',        // 'triggerEdge scrollerEdge'
    end: 'bottom 20%',       // default: 'bottom top'
    toggleActions: 'play pause resume reset',
    // 4 actions for: onEnter onLeave onEnterBack onLeaveBack
    // values: play | pause | resume | reset | restart | complete | reverse | none
    markers: true,           // show debug markers (remove for production!)
  }
});
```

### start / end Syntax

```js
// Format: 'triggerEdge scrollerEdge'
// Trigger edges: 'top' | 'center' | 'bottom' | px | %
// Scroller edges: 'top' | 'center' | 'bottom' | px | %

start: 'top bottom'      // trigger top reaches scroller bottom (default)
start: 'top center'      // trigger top at screen center
start: 'top top'         // trigger top at screen top
start: 'center center'   // trigger center at screen center
start: '+=200'           // 200px after default
start: 'top 80%'         // trigger top when 80% down viewport
end: '+=300'             // 300px after start
end: 'bottom top'        // trigger bottom reaches top of screen
```

### Scrub — Link to Scrollbar

```js
gsap.to('.parallax', {
  y: -200,
  scrollTrigger: {
    trigger: '.section',
    scrub: true,    // animation plays in sync with scroll position
    scrub: 1,       // 1 second catch-up delay (smoother)
    scrub: 0.5,     // shorter delay = more responsive
  }
});
```

### Pin — Stick Element During Scroll

```js
gsap.timeline({
  scrollTrigger: {
    trigger: '.section',
    pin: true,               // pin the trigger element
    pin: '#hero',            // pin a different element
    pinSpacing: true,        // (default) adds space to prevent layout collapse
    start: 'top top',
    end: '+=500',            // stays pinned for 500px of scroll
    scrub: 1,
  }
})
.from('.title', { y: 50, opacity: 0 })
.from('.subtitle', { y: 30, opacity: 0 });
```

### Standalone ScrollTrigger (no animation)

```js
ScrollTrigger.create({
  trigger: '#section',
  start: 'top center',
  end: 'bottom center',

  onEnter: (self) => {
    console.log('direction:', self.direction);   // 1 or -1
    console.log('progress:', self.progress);     // 0-1
    console.log('velocity:', self.getVelocity()); // px/second
  },
  onLeave: (self) => {},
  onEnterBack: (self) => {},
  onLeaveBack: (self) => {},
  onUpdate: (self) => {
    progressBar.style.width = (self.progress * 100) + '%';
  },
  onToggle: (self) => {
    console.log('isActive:', self.isActive);
  },

  toggleClass: 'is-active',  // add/remove class while active
  once: true,                // kill after first trigger
});
```

### Snap

```js
scrollTrigger: {
  trigger: '.container',
  snap: 0.25,                    // snap to every 25%
  snap: [0, 0.33, 0.66, 1],     // snap to specific progress values
  snap: 'labels',                // snap to timeline labels
  snap: {
    snapTo: [0, 0.5, 1],
    duration: { min: 0.2, max: 3 },  // snap animation duration range
    delay: 0.1,
    ease: 'power1.inOut',
  }
}
```

### Batch (coordinated multi-element)

```js
ScrollTrigger.batch('.card', {
  interval: 0.1,    // seconds between each card's trigger
  onEnter: (batch) => {
    gsap.from(batch, { opacity: 0, y: 30, stagger: 0.05 });
  },
  onLeave: (batch) => {
    gsap.to(batch, { opacity: 0, y: -30, stagger: 0.05 });
  },
  onEnterBack: (batch) => {
    gsap.from(batch, { opacity: 0, y: -30, stagger: 0.05 });
  },
});
```

### Responsive with matchMedia

```js
const mm = gsap.matchMedia();

mm.add('(min-width: 768px)', () => {
  // desktop animations
  gsap.to('.box', {
    x: 500,
    scrollTrigger: { trigger: '.box', scrub: true }
  });

  return () => {
    // cleanup on breakpoint exit
  };
});

mm.add('(max-width: 767px)', () => {
  // mobile animations
  gsap.to('.box', {
    y: 100,
    scrollTrigger: { trigger: '.box', scrub: true }
  });
});
```

### Static Methods

```js
ScrollTrigger.refresh();          // recalculate all positions (call after layout changes)
ScrollTrigger.getAll();           // array of all ScrollTrigger instances
ScrollTrigger.getById('myId');    // find by id
ScrollTrigger.kill();             // kill all instances
ScrollTrigger.isScrolling();      // boolean
ScrollTrigger.maxScroll(element); // max scroll distance
ScrollTrigger.normalizeScroll();  // smooth mobile scroll
```

---

## Draggable

Makes DOM elements draggable with touch support and inertia.

```js
import { Draggable } from 'gsap/Draggable';
import { InertiaPlugin } from 'gsap/InertiaPlugin'; // needed for inertia
gsap.registerPlugin(Draggable, InertiaPlugin);

// Basic
Draggable.create('.box');

// Full options
Draggable.create('.box', {
  type: 'x,y',          // 'x' | 'y' | 'x,y' | 'rotation' | 'top,left' | 'scroll'
  bounds: '#container', // constrain to element bounds
  bounds: { minX: 0, maxX: 500, minY: 0, maxY: 300 },

  inertia: true,        // momentum-based release (requires InertiaPlugin)
  lockAxis: true,       // lock to detected axis on drag start

  // Snapping
  snap: [0, 100, 200],  // snap to these pixel values after release
  liveSnap: true,       // snap during drag
  snap: { x: [0, 100], y: [0, 50] },  // per-axis snap values
  snap: (endValue) => Math.round(endValue / 50) * 50,  // function

  // Callbacks
  onPress: (e) => {},
  onDragStart: (e) => {},
  onDrag: function() {
    console.log('x:', this.x, 'y:', this.y);
  },
  onDragEnd: function() {
    console.log('final x:', this.x);
  },
  onRelease: (e) => {},
  onClick: (e) => {},
  onLockAxis: (e) => {},
});

// Get instance
const draggable = Draggable.get('.box');

// Control methods
draggable.enable();
draggable.disable();
draggable.kill();
draggable.startDrag(event);
draggable.endDrag(event);
draggable.applyBounds('#container');

// Hit testing
Draggable.hitTest(dragEl, '#target', '50%'); // true if 50% overlap

// Instance properties (read-only during drag)
draggable.x, draggable.y
draggable.rotation
draggable.isDragging
draggable.isPressed
draggable.isThrowing
```

---

## MotionPathPlugin

Animate elements along SVG paths or coordinate arrays.

```js
import { MotionPathPlugin } from 'gsap/MotionPathPlugin';
gsap.registerPlugin(MotionPathPlugin);

// Along an SVG path element
gsap.to('#rocket', {
  motionPath: {
    path: '#myPath',         // SVG <path> selector or element
    align: '#myPath',        // align coordinate space to path element
    alignOrigin: [0.5, 0.5], // [x%, y%] — center of element
    autoRotate: true,        // rotate to follow path direction
    autoRotate: 90,          // rotate + 90 degrees offset
    start: 0,                // 0-1, where on path to start
    end: 1,                  // 0-1, where to end
  },
  duration: 5,
  ease: 'none',
});

// Along a coordinate array
gsap.to('#ball', {
  motionPath: {
    path: [
      { x: 0, y: 0 },
      { x: 100, y: -80 },
      { x: 200, y: 0 },
      { x: 300, y: 80 },
    ],
    curviness: 1,    // 0=straight lines, 1=default, 2+=very curved
  },
  duration: 3,
});

// Utility: convert SVG path to coordinates
const points = MotionPathPlugin.getGlobalMatrix(el);
```

---

## TextPlugin

Animates text character by character (or word by word).

```js
import { TextPlugin } from 'gsap/TextPlugin';
gsap.registerPlugin(TextPlugin);

// Simple (character by character)
gsap.to('#el', {
  text: 'New text content',
  duration: 2,
  ease: 'none',
});

// Advanced options
gsap.to('#el', {
  text: {
    value: 'Hello, world!',
    delimiter: ' ',          // '' = char, ' ' = word
    newClass: 'new-text',    // CSS class for newly added text
    oldClass: 'old-text',    // CSS class for old text
    padSpace: true,          // prevent space collapse
    rtl: false,              // right-to-left
    type: 'diff',            // only animate changed characters
    speed: 1,                // auto-adjust duration (1=slow, 20=fast)
  },
  duration: 2,
  ease: 'none',
});
```

---

## MorphSVGPlugin

Morphs one SVG shape into another.

```js
import { MorphSVGPlugin } from 'gsap/MorphSVGPlugin';
gsap.registerPlugin(MorphSVGPlugin);

// Morph between two SVG paths
gsap.to('#shape1', {
  morphSVG: '#shape2',    // selector, element, or raw path data string
  duration: 1,
  ease: 'power2.inOut',
});

// Advanced options
gsap.to('#star', {
  duration: 1,
  morphSVG: {
    shape: '#circle',
    type: 'rotational',     // 'linear' (default) or 'rotational'
    shapeIndex: 3,          // point mapping offset (0-based)
    map: 'size',            // 'size' | 'position' | 'complexity'
    origin: '50% 50%',      // transform origin for rotational type
  },
});

// Convert primitive shapes to <path> so they can morph
MorphSVGPlugin.convertToPath('circle, rect, ellipse, polygon');

// Find optimal shapeIndex (interactive UI in browser console)
MorphSVGPlugin.findShapeIndex('#start', '#end');
```

---

## SplitText

Splits text into animatable characters, words, or lines.

```js
import { SplitText } from 'gsap/SplitText';
gsap.registerPlugin(SplitText);

// Create and animate
const split = SplitText.create('.headline', {
  type: 'chars,words,lines',  // what to split into
  // type: 'chars'            // just characters
  // type: 'words'            // just words
  // type: 'lines'            // just lines
  linesClass: 'line',         // class added to line wrappers
  wordsClass: 'word',
  charsClass: 'char',
  mask: 'lines',              // wrap in clipping container (for slide-in effects)
  autoSplit: true,            // re-split on resize
  aria: 'auto',              // 'auto' | 'hidden' | 'none'
});

// Access split elements
split.chars    // array of char elements
split.words    // array of word elements
split.lines    // array of line elements

// Animate the pieces
gsap.from(split.chars, {
  opacity: 0,
  y: 20,
  stagger: 0.03,
  duration: 0.5,
  ease: 'power2.out',
});

// Slide up through mask (requires mask: 'lines')
gsap.from(split.lines, {
  yPercent: 100,
  opacity: 0,
  stagger: 0.1,
  duration: 0.6,
  ease: 'power3.out',
});

// Revert to original HTML
split.revert();

// onSplit callback (fires after splitting)
SplitText.create('.headline', {
  type: 'words,chars',
  onSplit(self) {
    return gsap.from(self.chars, {
      opacity: 0,
      y: 20,
      stagger: 0.03,
    });
  }
});
```

---

## DrawSVGPlugin

Animates SVG stroke drawing (the "draw on" effect).

```js
import { DrawSVGPlugin } from 'gsap/DrawSVGPlugin';
gsap.registerPlugin(DrawSVGPlugin);

// Draw a path from 0% to 100%
gsap.from('#path', {
  drawSVG: 0,      // start at 0%
  duration: 2,
  ease: 'power2.inOut',
});

// Animate from 25% to 75%
gsap.to('#path', {
  drawSVG: '25% 75%',
  duration: 1,
});

// Reverse draw (erase)
gsap.to('#path', {
  drawSVG: '100% 100%',
  duration: 1,
});
```

---

## gsap.utils — Utility Functions

```js
// Clamp a value
gsap.utils.clamp(0, 100, 150); // 100

// Map one range to another
gsap.utils.mapRange(0, 100, 0, 1, 50); // 0.5

// Snap to nearest value
gsap.utils.snap(10, 23);          // 20 (nearest multiple of 10)
gsap.utils.snap([0, 25, 50], 30); // 25 (nearest in array)

// Random
gsap.utils.random(0, 100);        // float
gsap.utils.random(0, 100, 5);     // snapped to 5

// Wrap
gsap.utils.wrap(0, 5, 6);         // 1 (wraps around)

// Interpolate
const lerp = gsap.utils.interpolate(0, 100);
lerp(0.5); // 50

// Get/set CSS values
gsap.getProperty('.box', 'x');    // returns current x value
gsap.getProperty('.box', 'backgroundColor');

// Distribute values (for stagger grid math)
gsap.utils.distribute({ base: 0.5, amount: 1, from: 'center' });

// Convert selectors to array
gsap.utils.toArray('.items');     // proper Array (not NodeList)
```
