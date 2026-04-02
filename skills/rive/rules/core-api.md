# Rive Core API

## useRive Hook

The primary hook for integrating Rive into React. Returns `{ rive, RiveComponent }` plus refs for manual canvas management.

```tsx
import { useRive, Layout, Fit, Alignment } from '@rive-app/react-canvas';

const { rive, RiveComponent } = useRive({
  // --- Required ---
  src: '/animations/hero.riv',          // Path to .riv file (string or URL)

  // --- Artboard ---
  artboard: 'MyArtboard',              // string (name) or number (index); default = first artboard

  // --- Animations (timeline, not state machine) ---
  animations: 'idle',                   // string | string[] — timeline animation name(s)

  // --- State Machines ---
  stateMachines: 'State Machine 1',     // string | string[] — state machine name(s)

  // --- Playback ---
  autoplay: true,                       // boolean, default false

  // --- Layout ---
  layout: new Layout({
    fit: Fit.Contain,                   // see Fit enum below
    alignment: Alignment.Center,        // see Alignment enum below
  }),

  // --- Lifecycle callbacks ---
  onLoad: () => console.log('loaded'),
  onPlay: (e) => console.log('play', e.data),
  onPause: (e) => console.log('pause', e.data),
  onStop: (e) => console.log('stop', e.data),
  onLoop: (e) => console.log('loop', e.data),
  onStateChange: (e) => console.log('state changed', e.data[0]),

  // --- Asset CDN ---
  enableRiveAssetCDN: true,             // allow loading assets from Rive CDN (default true)

  // --- Device pixel ratio ---
  useDevicePixelRatio: true,            // scale canvas for retina (default true)

  // --- Canvas sizing ---
  fitCanvasToArtboardHeight: false,     // resize canvas height to match artboard (default false)
});
```

### Return Values

```tsx
const {
  rive,           // Rive instance — null until loaded; use for imperative control
  RiveComponent,  // React component wrapping the canvas element
  setCanvasRef,   // ref callback for manual canvas (use with setContainerRef for responsive)
  setContainerRef // ref callback for container div
} = useRive(params);
```

### Rendering RiveComponent

```tsx
// Simple — fixed size
<RiveComponent style={{ width: 400, height: 400 }} />

// Responsive full-bleed (use setContainerRef + setCanvasRef)
<div ref={setContainerRef} style={{ width: '100%', height: '100vh' }}>
  <canvas ref={setCanvasRef} />
</div>
```

---

## Fit Enum

Controls how the artboard scales within the canvas:

| Value | Behavior |
|---|---|
| `Fit.Contain` | Scale to fit fully visible; preserve aspect ratio (may leave empty space) |
| `Fit.Cover` | Scale to fill canvas; preserve aspect ratio (may clip edges) |
| `Fit.Fill` | Stretch to fill canvas; does NOT preserve aspect ratio |
| `Fit.FitWidth` | Scale to match container width; preserve aspect ratio (may clip vertically) |
| `Fit.FitHeight` | Scale to match container height; preserve aspect ratio (may clip horizontally) |
| `Fit.None` | Render at artboard's native size (may clip or leave space) |
| `Fit.ScaleDown` | Like Contain when artboard > canvas; otherwise native size |
| `Fit.Layout` | Use Rive's built-in Layout system (Rive 2024+ feature) |

## Alignment Enum

Controls where the artboard is positioned within the canvas:

`TopLeft`, `TopCenter`, `TopRight`, `CenterLeft`, `Center`, `CenterRight`, `BottomLeft`, `BottomCenter`, `BottomRight`

```tsx
import { Layout, Fit, Alignment } from '@rive-app/react-canvas';

const layout = new Layout({
  fit: Fit.Cover,
  alignment: Alignment.Center,
  // Optional: minX, minY, maxX, maxY for clipping/offsetting
});
```

---

## Layout Object (Advanced)

```tsx
new Layout({
  fit: Fit.Cover,
  alignment: Alignment.TopLeft,
  minX: 0,     // crop/offset from left
  minY: 0,     // crop/offset from top
  maxX: 1920,  // crop/offset from right
  maxY: 1080,  // crop/offset from bottom
})
```

---

## Imperative Rive Instance API

Once `rive` is non-null (after load), you can call:

```tsx
// Playback
rive.play();                        // play all animations
rive.play('idle');                  // play named animation
rive.play(['idle', 'blink']);       // mix multiple animations
rive.pause();                       // pause all
rive.pause('idle');                 // pause specific animation
rive.stop();                        // stop all
rive.reset();                       // reset to initial state

// State queries
rive.isPlaying;                     // boolean
rive.isPaused;                      // boolean

// Artboard switching (requires new Rive instance or re-mount)
// Note: switching artboard at runtime requires re-instantiating or
// using a keyed component — see react-integration.md

// Layout update at runtime
rive.layout = new Layout({ fit: Fit.Cover });

// Canvas resize (important for responsive)
rive.resizeDrawingSurfaceToCanvas();

// Event subscription
rive.on('statechange', (event) => { console.log(event.data[0]); });
rive.on('play', (event) => { console.log(event.data); });
rive.off('statechange', myHandler);  // unsubscribe
```

---

## .riv File Structure

A `.riv` binary file contains:

```
file.riv
  └── Artboard "Main"         ← default artboard (used if artboard not specified)
        ├── Animations
        │     ├── "idle"      ← timeline animation
        │     └── "walk"
        └── State Machines
              └── "State Machine 1"
                    ├── Inputs
                    │     ├── isHovered (Boolean)
                    │     ├── speed     (Number)
                    │     └── tap       (Trigger)
                    └── States + Transitions
  └── Artboard "Alt"          ← second artboard
```

### Exporting from Rive Editor

1. Open your file in the Rive editor (rive.app)
2. Right-click file in browser → **Export**
3. Choose **Rive (.riv)** format
4. Place `.riv` in your `public/` folder (for Create React App / Vite / Next.js)
5. For Next.js: use `next/static` path or place in `/public/animations/`

### Loading Options

```tsx
// From public folder
src: '/animations/hero.riv'

// From CDN (Rive community files)
src: 'https://cdn.rive.app/animations/vehicles.riv'

// From Remotion staticFile
import { staticFile } from 'remotion';
src: staticFile('hero.riv')
```

---

## Artboard Switching

To switch artboards, remount the component with a different `artboard` prop using React `key`:

```tsx
function RiveScene({ artboardName }) {
  return (
    <RiveWrapper key={artboardName} artboard={artboardName} />
  );
}

// Wrap useRive in its own component to get proper cleanup
function RiveWrapper({ artboard }) {
  const { RiveComponent } = useRive({
    src: '/animations/multi.riv',
    artboard,
    autoplay: true,
  });
  return <RiveComponent style={{ width: 400, height: 400 }} />;
}
```

**Why key matters:** React needs to unmount/remount the Rive component to switch artboards cleanly. Without `key`, the old canvas persists and the new artboard may not load.

---

## Animation Playback — Mixing Multiple Timelines

```tsx
const { rive, RiveComponent } = useRive({
  src: '/animations/character.riv',
  animations: ['idle', 'blink'],  // both play simultaneously
  autoplay: true,
});

// Later — add/remove animations dynamically
rive?.play('run');           // mix in 'run' with existing animations
rive?.pause('idle');         // pause only 'idle', keep 'blink' running
rive?.stop('blink');         // stop 'blink'
```

> For coordinating complex animation sequences, prefer using a State Machine over manually mixing timelines.
