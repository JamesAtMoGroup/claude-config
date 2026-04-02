# Tailwind CSS Animation Integration

## Built-in Utilities

| Class | CSS Generated | Use Case |
|-------|--------------|----------|
| `animate-spin` | `animation: spin 1s linear infinite` | Loading spinners, refresh icons |
| `animate-ping` | `animation: ping 1s cubic-bezier(0, 0, 0.2, 1) infinite` | Notification badges, radar effect |
| `animate-pulse` | `animation: pulse 2s cubic-bezier(0.4, 0, 0.6, 1) infinite` | Skeleton loaders, heartbeat |
| `animate-bounce` | `animation: bounce 1s infinite` | Scroll arrows, attention cues |
| `animate-none` | `animation: none` | Override/reset animations |

### Tailwind-defined keyframes

```css
@keyframes spin  { to { transform: rotate(360deg); } }

@keyframes ping  {
  75%, 100% { transform: scale(2); opacity: 0; }
}

@keyframes pulse {
  0%, 100% { opacity: 1; }
  50%       { opacity: 0.5; }
}

@keyframes bounce {
  0%, 100% {
    transform: translateY(-25%);
    animation-timing-function: cubic-bezier(0.8, 0, 1, 1);
  }
  50% {
    transform: none;
    animation-timing-function: cubic-bezier(0, 0, 0.2, 1);
  }
}
```

---

## Accessibility Variants

Always wrap non-essential animations with `motion-safe:` or disable with `motion-reduce:`:

```html
<!-- Only animate if user has no reduced-motion preference -->
<svg class="motion-safe:animate-spin">...</svg>

<!-- Disable if reduced motion is preferred -->
<div class="animate-pulse motion-reduce:animate-none">...</div>
```

---

## Custom Animations — Tailwind v4 (CSS-first)

In v4, configuration lives in CSS via `@theme`. Define the animation token and keyframes together.

```css
/* globals.css */
@import "tailwindcss";

@theme {
  /* --animate-<name>: <value> → creates animate-<name> utility */
  --animate-wiggle: wiggle 1s ease-in-out infinite;
  --animate-fade-in: fadeIn 0.3s ease forwards;
  --animate-slide-up: slideUp 0.4s cubic-bezier(0.2, 0, 0, 1) forwards;
  --animate-shimmer: shimmer 1.5s linear infinite;

  @keyframes wiggle {
    0%, 100% { transform: rotate(-3deg); }
    50%       { transform: rotate(3deg); }
  }

  @keyframes fadeIn {
    from { opacity: 0; }
    to   { opacity: 1; }
  }

  @keyframes slideUp {
    from { opacity: 0; transform: translateY(1rem); }
    to   { opacity: 1; transform: translateY(0); }
  }

  @keyframes shimmer {
    from { background-position: -200% 0; }
    to   { background-position: 200% 0; }
  }
}
```

Usage in markup:
```html
<button class="animate-wiggle">Click me</button>
<div class="animate-fade-in">Content</div>
<div class="animate-shimmer bg-gradient-to-r from-gray-200 via-white to-gray-200 bg-[length:200%_100%]">
  Loading...
</div>
```

---

## Custom Animations — Tailwind v3 (JS config)

```js
// tailwind.config.js
module.exports = {
  theme: {
    extend: {
      keyframes: {
        wiggle: {
          '0%, 100%': { transform: 'rotate(-3deg)' },
          '50%':       { transform: 'rotate(3deg)' },
        },
        fadeIn: {
          from: { opacity: '0' },
          to:   { opacity: '1' },
        },
        slideUp: {
          from: { opacity: '0', transform: 'translateY(1rem)' },
          to:   { opacity: '1', transform: 'translateY(0)' },
        },
        shimmer: {
          from: { backgroundPosition: '-200% 0' },
          to:   { backgroundPosition: '200% 0' },
        },
        'ping-once': {
          '75%, 100%': { transform: 'scale(2)', opacity: '0' },
        },
      },
      animation: {
        wiggle:     'wiggle 1s ease-in-out infinite',
        'fade-in':  'fadeIn 0.3s ease forwards',
        'slide-up': 'slideUp 0.4s cubic-bezier(0.2, 0, 0, 1) forwards',
        shimmer:    'shimmer 1.5s linear infinite',
        'ping-once':'ping-once 0.5s cubic-bezier(0, 0, 0.2, 1) forwards',
      },
    },
  },
}
```

---

## Arbitrary Value Syntax

For one-off animations without extending config:

```html
<!-- Arbitrary animation value -->
<div class="animate-[wiggle_1s_ease-in-out_infinite]">...</div>

<!-- Arbitrary with delay -->
<div class="animate-[fadeIn_0.3s_ease_0.2s_forwards]">...</div>

<!-- CSS variable shorthand -->
<div class="animate-(--my-custom-animation)">...</div>
```

---

## Responsive + State Variants

```html
<!-- Only animate on md+ screens -->
<div class="animate-none md:animate-spin">...</div>

<!-- Animate on hover -->
<div class="animate-none hover:animate-bounce">...</div>

<!-- Animate only when in a specific group state -->
<div class="group">
  <div class="animate-none group-hover:animate-spin">...</div>
</div>
```

---

## Stagger with CSS Custom Properties in Tailwind

No built-in stagger, but inline style + custom properties work cleanly:

```html
<ul>
  {items.map((item, i) => (
    <li
      key={i}
      style={{ '--delay': `${i * 0.1}s` }}
      class="animate-fade-in [animation-delay:var(--delay)]"
    >
      {item}
    </li>
  ))}
</ul>
```

Or with arbitrary property utilities:

```html
<li class="animate-fade-in [animation-delay:100ms]">Item 1</li>
<li class="animate-fade-in [animation-delay:200ms]">Item 2</li>
<li class="animate-fade-in [animation-delay:300ms]">Item 3</li>
```

---

## Animation Plugins

For enter/exit animations, directional slides, and scroll-triggered reveals:

- **tailwindcss-animate** — enter/exit, fade, slide, zoom, spin with data-state support (used by shadcn/ui)
- **tailwind-animations** — large collection of preset animations

```bash
npm install tailwindcss-animate
```

```js
// tailwind.config.js
module.exports = {
  plugins: [require('tailwindcss-animate')],
}
```

```html
<!-- tailwindcss-animate usage -->
<div class="animate-in fade-in slide-in-from-bottom-4 duration-300">...</div>
<div class="animate-out fade-out slide-out-to-top-4 duration-200">...</div>
```
