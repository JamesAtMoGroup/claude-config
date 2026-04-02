# Fabric.js — Text Objects

Three text classes with increasing interactivity:

| Class | Editable | Word Wrap | Per-char Styles |
|-------|----------|-----------|-----------------|
| `FabricText` | No | No | Yes |
| `IText` | Yes (click to edit) | No | Yes |
| `Textbox` | Yes + auto-wrap | Yes | Yes |

## Import (v6+)

```ts
import { FabricText, IText, Textbox } from 'fabric';
// Note: in v6 it's FabricText, NOT fabric.Text
// Some builds still export as Text — check your version
```

---

## FabricText (Static Text)

Non-editable. Use for labels, watermarks, decorative text.

```ts
const text = new FabricText('Hello, Fabric!', {
  left: 100,
  top: 100,

  // Font
  fontFamily: 'Arial',
  fontSize: 32,           // px
  fontWeight: 'bold',     // 'normal' | 'bold' | number
  fontStyle: 'italic',    // 'normal' | 'italic' | 'oblique'
  underline: false,
  overline: false,
  linethrough: false,

  // Color
  fill: '#1e293b',
  stroke: 'transparent',
  strokeWidth: 0,

  // Alignment
  textAlign: 'left',      // 'left' | 'center' | 'right' | 'justify'

  // Line spacing
  lineHeight: 1.16,       // multiplier

  // Background
  backgroundColor: '',    // color behind the text bounding box
  textBackgroundColor: '', // color behind each individual character

  // Shadow
  shadow: null,

  // Transform
  angle: 0,
  opacity: 1,
  charSpacing: 0,         // character spacing in 1/1000 em units
  direction: 'ltr',       // 'ltr' | 'rtl'
});

canvas.add(text);
```

---

## IText (Interactive / Editable Text)

Extends `FabricText`. Users can double-click to enter edit mode and type.

```ts
const itext = new IText('Click me to edit', {
  left: 100,
  top: 200,
  fontSize: 24,
  fontFamily: 'Georgia',
  fill: '#0f172a',
  editable: true,           // default: true
  cursorColor: '#4f46e5',   // cursor color in edit mode
  cursorWidth: 2,
  cursorDelay: 1000,        // ms before cursor blinks
  cursorDuration: 600,      // blink duration ms
  selectionColor: 'rgba(79, 70, 229, 0.3)',  // text selection highlight
  selectionStart: 0,        // programmatic cursor start
  selectionEnd: 0,          // programmatic cursor end
});

canvas.add(itext);

// Programmatically enter edit mode
itext.enterEditing();
itext.selectAll();           // select all text

// Exit edit mode
itext.exitEditing();

// Listen to editing events
itext.on('editing:entered', () => console.log('Edit mode started'));
itext.on('editing:exited', () => console.log('Edit mode ended'));
itext.on('changed', () => console.log('Text changed:', itext.text));
```

### Per-Character Styles on IText

You can style individual characters, words, or lines:

```ts
// styles object: { [lineIndex]: { [charIndex]: styleObject } }
const itext = new IText('Hello World', {
  styles: {
    0: {              // line 0
      0: { fill: '#ef4444', fontSize: 40, fontWeight: 'bold' },   // 'H'
      1: { fill: '#f97316', fontSize: 36 },                        // 'e'
      2: { fill: '#eab308', fontSize: 32 },                        // 'l'
      3: { fill: '#22c55e', fontSize: 32 },                        // 'l'
      4: { fill: '#06b6d4', fontSize: 32 },                        // 'o'
    },
  },
});

// Set style on a range programmatically
itext.setSelectionStart(0);
itext.setSelectionEnd(5);
itext.setSelectionStyles({ fill: '#7c3aed', fontSize: 48 });
canvas.requestRenderAll();

// Get style at position
const style = itext.getSelectionStyles(0, 5);
```

---

## Textbox (Auto-wrapping Editable Text)

Extends `IText`. Width is fixed; height grows automatically as text wraps.

```ts
const textbox = new Textbox('This is a long text that will wrap automatically when it reaches the width limit.', {
  left: 100,
  top: 150,
  width: 300,               // fixed width — text wraps at this boundary
  // Height is auto-calculated — do NOT set height manually
  fontSize: 18,
  fontFamily: 'Inter',
  fill: '#0f172a',
  lineHeight: 1.4,
  textAlign: 'justify',
  editable: true,
  splitByGrapheme: false,   // true = wrap on every char (CJK friendly)
  dynamicMinWidth: 20,      // minimum width when resizing
  minWidth: 20,
});

canvas.add(textbox);

// Textbox locks Y-scale (only X resize is allowed by default)
// Height adjusts automatically

// Detect when lines change
textbox.on('changed', () => {
  const lines = textbox._splitTextIntoLines(textbox.text);
  console.log('Line count:', lines.graphemeLines.length);
});
```

---

## Text Common Patterns

### Centering Text on Canvas

```ts
const text = new FabricText('Centered', {
  fontSize: 40,
  fontFamily: 'Arial Black',
  fill: '#1e293b',
  originX: 'center',
  originY: 'center',
  left: canvas.width / 2,
  top: canvas.height / 2,
});
canvas.add(text);
```

### Updating Text Content

```ts
text.set('text', 'Updated text content');
canvas.requestRenderAll();
```

### Rich Multiline Text

```ts
const multiline = new FabricText('Line one\nLine two\nLine three', {
  left: 100,
  top: 100,
  fontSize: 24,
  lineHeight: 1.5,
  textAlign: 'center',
});
```

### Text with Stroke Outline

```ts
const outlined = new FabricText('OUTLINE', {
  left: 200,
  top: 200,
  fontSize: 72,
  fontWeight: 'bold',
  fill: 'white',
  stroke: '#1e293b',
  strokeWidth: 3,
  paintFirst: 'stroke',   // draw stroke BEFORE fill (prevents fill covering stroke)
});
```

### Measuring Text Width

```ts
// Use canvas 2D context to measure text width before adding
const ctx = canvas.getContext('2d');
ctx.font = `${text.fontStyle} ${text.fontWeight} ${text.fontSize}px ${text.fontFamily}`;
const metrics = ctx.measureText(text.text);
console.log('Width:', metrics.width);

// Or use Fabric's built-in after the object exists
console.log('Object width:', text.width);
```

### Preventing Editing (Read-only IText)

```ts
// Allow selection but not editing
itext.editable = false;

// Allow neither selection nor editing
itext.selectable = false;
itext.evented = false;
```

---

## Font Loading (Custom Web Fonts)

Load fonts before creating text objects to avoid FOUT on canvas:

```ts
// Use FontFace API
const font = new FontFace('Pretendard', 'url(/fonts/Pretendard-Bold.woff2)');
await font.load();
document.fonts.add(font);

// Now safe to create text with this font
const text = new FabricText('안녕하세요', {
  fontFamily: 'Pretendard',
  fontSize: 32,
});
canvas.add(text);
```

---

## Text Events

```ts
itext.on('editing:entered', () => { /* user entered edit mode */ });
itext.on('editing:exited', () => { /* user left edit mode */ });
itext.on('changed', () => { /* text content changed (during edit) */ });
itext.on('selection:changed', () => { /* cursor or selection changed */ });

// Canvas-level text events
canvas.on('text:selection:changed', ({ target }) => {});
canvas.on('text:editing:entered', ({ target }) => {});
canvas.on('text:editing:exited', ({ target }) => {});
canvas.on('text:changed', ({ target }) => {});
```
