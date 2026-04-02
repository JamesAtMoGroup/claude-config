# Animation Object — Control, Promises, State

## Overview

`element.animate()` returns an `Animation` object. Think of it as a **DVD player**: it controls the playback of a `KeyframeEffect` (the "DVD").

```js
const anim = el.animate(keyframes, options);
// anim is an Animation object — already playing
```

## Playback Control Methods

### play() / pause()

```js
anim.pause();   // Suspend playback; currentTime freezes
anim.play();    // Resume from current position (or restart if finished)
```

### finish()

```js
anim.finish();
// Instantly jumps to end of animation (or beginning if reversed)
// Triggers 'finish' event and resolves anim.finished promise
```

### cancel()

```js
anim.cancel();
// Aborts animation, removes its visual effects
// Rejects anim.finished promise
// Fires 'cancel' event
```

### reverse()

```js
anim.reverse();
// Flips playback direction (positive ↔ negative playbackRate)
// If already finished: plays from the end backward
```

### updatePlaybackRate(rate)

```js
anim.updatePlaybackRate(0.5);   // Slow to half speed, smooth transition
anim.updatePlaybackRate(2);     // Double speed
anim.updatePlaybackRate(-1);    // Play in reverse at normal speed

// Slow all page animations (e.g., for accessibility debugging)
document.getAnimations().forEach(a => a.updatePlaybackRate(a.playbackRate * 0.5));
```

**Note:** Prefer `updatePlaybackRate()` over directly setting `anim.playbackRate` — the async version synchronizes timing first to prevent jumps.

### commitStyles()

Writes the animation's current computed styles into the element's `style` attribute as inline styles, then the animation can be cancelled safely.

```js
const anim = el.animate(
  [{ transform: 'translateX(0)' }, { transform: 'translateX(200px)' }],
  { duration: 500, fill: 'forwards' }
);

await anim.finished;

// Persist the final position as inline style, then clean up
anim.commitStyles();
anim.cancel();   // Safe to cancel — styles are now inline
```

**Why use this instead of `fill: 'forwards'`:**
- `fill: 'forwards'` keeps the animation alive indefinitely (memory overhead)
- `fill: 'forwards'` can cause specificity conflicts (animation styles override inline styles)
- `commitStyles()` writes to `style` attribute — normal CSS cascade applies after

### persist()

Prevent the browser from auto-removing a finished/replaced animation:

```js
anim.persist();
console.log(anim.replaceState); // "persisted"
```

## Instance Properties

### currentTime

```js
anim.currentTime;           // ms — current playhead position, or null
anim.currentTime = 250;     // Seek to 250ms (scrubbing)
```

### playbackRate

```js
anim.playbackRate;          // 1 = normal, 0.5 = half speed, -1 = reverse
anim.playbackRate = 2;      // Direct assignment (may cause timing jump — prefer updatePlaybackRate)
```

### playState

```js
anim.playState;
// 'idle'    — not started or cancelled
// 'running' — actively playing
// 'paused'  — paused
// 'finished'— reached end (or beginning if reversed)
```

### pending

```js
anim.pending;
// true if waiting for async operation (e.g., play() called but not yet composited)
// false when ready
```

### overallProgress

```js
anim.overallProgress;
// 0.0–1.0 — fraction of total animation completed
// Useful for progress bars, scrubbers
```

### replaceState

```js
anim.replaceState;
// 'active'    — currently running
// 'persisted' — manually persisted via .persist()
// 'removed'   — auto-removed by browser (replaced by newer animation)
```

### effect

```js
anim.effect;                          // KeyframeEffect object
anim.effect.getKeyframes();           // Get current keyframes array
anim.effect.setKeyframes(newKeyframes); // Replace keyframes mid-animation
anim.effect.getComputedTiming();      // Full timing info
anim.effect.getComputedTiming().duration;       // e.g., 500
anim.effect.getComputedTiming().activeDuration; // accounts for iterations
```

### timeline

```js
anim.timeline;              // Current AnimationTimeline (document.timeline by default)
anim.timeline = newTimeline; // Swap to a ScrollTimeline at runtime
```

### id

```js
anim.id = 'fade-in';
// Then find it later:
el.getAnimations().find(a => a.id === 'fade-in');
```

## Promises

### animation.ready

Resolves when the animation is ready to play (browser has started compositing it). Use this to sync with other animations or read layout after the animation has started.

```js
await anim.ready;
console.log('Animation has started compositing');
```

**Important:** `ready` resolves on the *first* frame — the animation may not be visually different yet.

### animation.finished

Resolves when the animation reaches its end state. Rejects if `cancel()` is called.

```js
// Promise style
anim.finished
  .then(() => console.log('Done'))
  .catch(() => console.log('Cancelled'));

// Async/await
try {
  await anim.finished;
  doNextThing();
} catch {
  console.log('Animation was cancelled before finishing');
}
```

**Important:** Every time the animation leaves `finished` state (e.g., `play()` is called again), a new Promise is created. Cache the reference if needed:

```js
const finishedPromise = anim.finished;
anim.play(); // anim.finished is now a NEW promise
await finishedPromise; // this still resolves correctly
```

## Events

```js
anim.onfinish = (e) => console.log('finished', e);
anim.oncancel = (e) => console.log('cancelled', e);
anim.onremove = (e) => console.log('removed', e); // auto-removed by browser

// Or addEventListener:
anim.addEventListener('finish', handler);
anim.addEventListener('cancel', handler);
anim.addEventListener('remove', handler);
```

## Auto-Removal Behavior

When `fill: 'forwards'` (or `both`) is used and the animation finishes, the browser may auto-remove it if:
1. The animation is filling and finished
2. The timeline is monotonically increasing (i.e., not scroll-driven)
3. The animation is entirely replaced by a newer animation on the same element+property

```js
// Prevent auto-removal:
anim.persist();

// Check if it was removed:
if (anim.replaceState === 'removed') {
  // Styles are gone — need to re-apply or use commitStyles() before this
}
```

## Full Workflow Pattern

```js
async function animateIn(el) {
  const anim = el.animate(
    [
      { opacity: 0, transform: 'translateY(16px)' },
      { opacity: 1, transform: 'translateY(0)' }
    ],
    {
      duration: 400,
      easing: 'cubic-bezier(0.25, 0.46, 0.45, 0.94)',
      fill: 'forwards'
    }
  );

  await anim.finished;
  anim.commitStyles();
  anim.cancel();

  return anim;
}

// Usage
const animation = await animateIn(document.querySelector('.card'));
```

## ZH-TW 速查表

| 方法/屬性 | 說明 |
|----------|------|
| `.play()` | 開始或繼續播放 |
| `.pause()` | 暫停在當前位置 |
| `.finish()` | 跳到結尾（立即完成） |
| `.cancel()` | 中止並移除視覺效果 |
| `.reverse()` | 反向播放 |
| `.commitStyles()` | 把當前樣式寫入 inline style，讓效果持久 |
| `.persist()` | 防止動畫被自動移除 |
| `.currentTime` | 當前播放位置（毫秒），可設定以 scrub |
| `.playbackRate` | 播放速率，負數代表倒播 |
| `.playState` | 'idle' / 'running' / 'paused' / 'finished' |
| `.ready` | Promise，動畫開始合成時 resolve |
| `.finished` | Promise，動畫結束時 resolve，cancel 時 reject |
| `.overallProgress` | 0–1 的整體進度，適合進度條 |
