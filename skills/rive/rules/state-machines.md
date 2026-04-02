# Rive State Machines

## What Is a State Machine?

A State Machine in Rive is a graph of states (each playing one or more animations) connected by transitions. Transitions fire when input conditions are met. This drives interactive/reactive animations at runtime without writing playback logic.

**Anatomy:**
- **States** — Each state plays an animation timeline (or blend tree)
- **Transitions** — Directed edges between states, fire when conditions are true
- **Inputs** — Named variables that conditions check

---

## Input Types

| Type | Class | Set How | Read How |
|---|---|---|---|
| Boolean | `StateMachineInputType.Boolean` | `input.value = true/false` | `input.value` |
| Number | `StateMachineInputType.Number` | `input.value = 42` | `input.value` |
| Trigger | `StateMachineInputType.Trigger` | `input.fire()` | n/a (stateless) |

---

## useStateMachineInput

The recommended React hook to grab a reference to a state machine input.

```tsx
import { useRive, useStateMachineInput } from '@rive-app/react-canvas';

function MyComponent() {
  const STATE_MACHINE = 'State Machine 1';

  const { rive, RiveComponent } = useRive({
    src: '/animations/interactive.riv',
    stateMachines: STATE_MACHINE,
    autoplay: true,
  });

  // Signature: useStateMachineInput(rive, stateMachineName, inputName, initialValue?)
  const isHoveredInput = useStateMachineInput(rive, STATE_MACHINE, 'isHovered');
  const speedInput     = useStateMachineInput(rive, STATE_MACHINE, 'speed');
  const tapTrigger     = useStateMachineInput(rive, STATE_MACHINE, 'tap');

  return (
    <RiveComponent
      style={{ width: 400, height: 400 }}
      onMouseEnter={() => { if (isHoveredInput) isHoveredInput.value = true; }}
      onMouseLeave={() => { if (isHoveredInput) isHoveredInput.value = false; }}
      onClick={() => tapTrigger?.fire()}
    />
  );
}
```

**Important:** `useStateMachineInput` returns `null` until the `.riv` file loads and the input is found. Always null-check before using.

---

## Boolean Input

```tsx
const isActiveInput = useStateMachineInput(rive, 'SM', 'isActive');

// Set to true
isActiveInput.value = true;

// Set to false
isActiveInput.value = false;

// Toggle
if (isActiveInput) isActiveInput.value = !isActiveInput.value;
```

---

## Number Input

```tsx
const speedInput = useStateMachineInput(rive, 'SM', 'speed', 0); // initialValue = 0

// Set a value
if (speedInput) speedInput.value = 75;

// Drive from mouse position
const handleMouseMove = (e: MouseEvent) => {
  const { innerWidth } = window;
  if (speedInput) speedInput.value = (e.clientX / innerWidth) * 100;
};
```

---

## Trigger Input

Triggers are fire-and-forget — they don't hold state.

```tsx
const tapTrigger = useStateMachineInput(rive, 'SM', 'tap');

// Fire on click
const handleClick = () => {
  tapTrigger?.fire();
};
```

---

## Full Interactive Example

```tsx
import { useRive, useStateMachineInput, Layout, Fit, Alignment } from '@rive-app/react-canvas';

const STATE_MACHINE = 'ButtonSM';

export function AnimatedButton() {
  const { rive, RiveComponent } = useRive({
    src: '/animations/button.riv',
    stateMachines: STATE_MACHINE,
    autoplay: true,
    layout: new Layout({ fit: Fit.Contain, alignment: Alignment.Center }),
  });

  const hoverInput   = useStateMachineInput(rive, STATE_MACHINE, 'isHovered');
  const pressInput   = useStateMachineInput(rive, STATE_MACHINE, 'isPressed');
  const clickTrigger = useStateMachineInput(rive, STATE_MACHINE, 'onClick');

  return (
    <RiveComponent
      style={{ width: 200, height: 60, cursor: 'pointer' }}
      onMouseEnter={() => { if (hoverInput) hoverInput.value = true; }}
      onMouseLeave={() => {
        if (hoverInput) hoverInput.value = false;
        if (pressInput) pressInput.value = false;
      }}
      onMouseDown={() => { if (pressInput) pressInput.value = true; }}
      onMouseUp={() => {
        if (pressInput) pressInput.value = false;
        clickTrigger?.fire();
      }}
    />
  );
}
```

---

## Listening to State Machine Events

Rive supports named "Events" — set in the editor on transitions. Listen at runtime:

### Via useRive callback

```tsx
const { rive, RiveComponent } = useRive({
  src: '/animations/hero.riv',
  stateMachines: 'SM',
  autoplay: true,
  onStateChange: (event) => {
    // event.data is an array of state names that became active
    console.log('Active state:', event.data[0]);
  },
});
```

### Via rive.on() — Rive Events (named events from editor)

```tsx
import { EventType } from '@rive-app/react-canvas';

useEffect(() => {
  if (!rive) return;

  const handler = (event) => {
    // event.data is the RiveEvent object
    // event.data.name — the event name set in editor
    // event.data.properties — custom key/value pairs added in editor
    console.log('Rive event fired:', event.data.name, event.data.properties);
  };

  rive.on(EventType.RiveEvent, handler);
  return () => rive.off(EventType.RiveEvent, handler);
}, [rive]);
```

### EventType values

```tsx
import { EventType } from '@rive-app/react-canvas';

EventType.Play           // animation started playing
EventType.Pause          // animation paused
EventType.Stop           // animation stopped
EventType.Loop           // animation looped
EventType.StateChange    // state machine changed state
EventType.RiveEvent      // named event fired from state machine
```

---

## State Change Callback Detail

`onStateChange` fires whenever the active state changes in any running state machine.

```tsx
onStateChange: (event) => {
  // event.data = array of state name strings
  const stateName = event.data[0];
  if (stateName === 'Success') {
    // transition to success UI
  }
}
```

---

## Multiple State Machines

A single artboard can have multiple state machines. Play them all simultaneously:

```tsx
const { rive, RiveComponent } = useRive({
  src: '/animations/complex.riv',
  stateMachines: ['BodySM', 'EyesSM', 'MouthSM'],  // all play concurrently
  autoplay: true,
});

const eyeBlinkTrigger = useStateMachineInput(rive, 'EyesSM', 'blink');
const mouthTalkInput  = useStateMachineInput(rive, 'MouthSM', 'isTalking');
```

---

## Data Binding (Rive 2024+ — Modern Approach)

Rive now supports **Data Binding** — a higher-level system for connecting runtime data to animations. It reduces complexity compared to manually setting inputs. Check [rive.app/docs](https://rive.app/docs) for latest Data Binding API, as it is the preferred approach for new projects.

```tsx
// Data Binding is accessed via the rive instance's viewModel API
// (available in @rive-app/canvas 2.x+)
// useStateMachineInput remains fully supported for legacy/existing files
```
