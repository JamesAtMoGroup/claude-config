# GSAP Callbacks

## Core Callback Properties

All callbacks can be set on both tweens and timelines:

```js
gsap.to('.box', {
  x: 200,
  duration: 1,

  onStart: function() {
    // Fires once when animation begins playing
    console.log('started');
  },

  onUpdate: function() {
    // Fires on EVERY frame while animation is active
    const progress = this.progress(); // 0 to 1
    console.log('progress:', progress);
  },

  onComplete: function() {
    // Fires when animation reaches its end
    console.log('complete');
  },

  onRepeat: function() {
    // Fires at the START of each repeat cycle
    console.log('repeating');
  },

  onReverseComplete: function() {
    // Fires when reversed animation reaches beginning
    console.log('reversed to start');
  },

  onInterrupt: function() {
    // Fires if tween is killed before completing
    console.log('interrupted');
  },
});
```

## Callback Arguments

Use `*Params` properties to pass arguments. Without params, `this` inside callback is the tween.

```js
gsap.to('.box', {
  x: 200,
  onComplete: handleComplete,
  onCompleteParams: ['.box', 42, 'hello'],  // passed as arguments

  onUpdate: handleUpdate,
  onUpdateParams: ['{self}'],  // {self} is a special token = the tween itself
});

function handleComplete(selector, num, str) {
  console.log(selector, num, str);  // '.box', 42, 'hello'
}

function handleUpdate(self) {
  console.log(self.progress()); // current progress 0-1
}
```

## `this` Context in Callbacks

```js
gsap.to('.box', {
  x: 100,
  onUpdate() {
    // `this` = the Tween instance
    console.log(this.progress());       // 0-1
    console.log(this.time());          // current time in seconds
    console.log(this.duration());      // total duration
    console.log(this.targets());       // array of animated elements
    console.log(this.vars.x);         // access vars
  },
  onComplete() {
    this.targets()[0].style.outline = '2px solid green';
  },
});
```

## Timeline Callbacks

```js
const tl = gsap.timeline({
  onStart: () => console.log('timeline started'),
  onUpdate: () => console.log('progress:', tl.progress()),
  onComplete: () => console.log('timeline done'),
  onRepeat: () => console.log('repeat cycle'),
  onReverseComplete: () => console.log('reversed to start'),
});
```

## Adding Callbacks to Timeline at Specific Times

```js
tl.add(() => console.log('at 1s mark'), 1);
tl.call(myFunction, ['arg1', 'arg2'], 2.5);  // call() is equivalent
```

## `onUpdate` — Frame-by-frame Control

```js
// Driving a counter display
const obj = { value: 0 };
const display = document.getElementById('counter');

gsap.to(obj, {
  value: 1000,
  duration: 2,
  ease: 'none',
  onUpdate() {
    display.textContent = Math.round(obj.value).toLocaleString();
  },
  onComplete() {
    display.textContent = '1,000';
  },
});

// Sync custom logic with animation
gsap.to('.ball', {
  x: 500,
  duration: 2,
  onUpdate() {
    const progress = this.progress();
    // Update shadow, trail, or other effects based on progress
    updateTrail(progress);
  },
});
```

## `onComplete` — Common Patterns

```js
// Chain sequential operations after animation
gsap.to('.modal', {
  opacity: 0,
  y: -20,
  duration: 0.3,
  onComplete() {
    document.querySelector('.modal').style.display = 'none';
    // Trigger next state
    loadNextContent();
  },
});

// Using promises instead of onComplete
await gsap.to('.box', { x: 200 });
// Code here runs after animation finishes

// or with .then()
gsap.to('.box', { x: 200 }).then(() => {
  console.log('done');
});
```

## `callbackScope`

Set `this` context for all callbacks:

```js
class MyComponent {
  animate() {
    gsap.to('.box', {
      x: 200,
      callbackScope: this,  // `this` in callbacks = MyComponent instance
      onComplete() {
        this.handleComplete(); // works!
      },
    });
  }

  handleComplete() { /* ... */ }
}
```

## Per-Element Callbacks in Stagger

```js
gsap.to('.box', {
  x: 100,
  stagger: {
    each: 0.1,
    onStart() {
      // fires for each element as it starts
      const el = this.targets()[0];
      el.classList.add('active');
    },
    onComplete() {
      const el = this.targets()[0];
      el.classList.remove('active');
    },
  },
});
```

## ScrollTrigger Callbacks

```js
ScrollTrigger.create({
  trigger: '.section',
  onEnter: (self) => console.log('entered'),           // scroll down INTO
  onLeave: (self) => console.log('left going down'),   // scroll past end
  onEnterBack: (self) => console.log('entered back'),  // scroll back into
  onLeaveBack: (self) => console.log('left going up'), // scroll above start
  onUpdate: (self) => console.log('progress:', self.progress),
  onToggle: (self) => console.log('isActive:', self.isActive),
  onRefresh: (self) => console.log('recalculated'),
});
```
