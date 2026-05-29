# Meen — Style Guide

The Meen brand is built around its logo: a hand-drawn ink feather filled with soft
watercolor petals in blue, periwinkle, lavender, and teal. The visual language is
**colorful but calm** — playful watercolor warmth held together by clean typography and
generous space. Think "friendly stationery," not "loud gamified app."

This guide defines the palette, type system, and component conventions. Colors are given
as CSS custom properties and mapped to Bootstrap 5 via SCSS variable overrides.

---

## Brand colors (sampled from the logo)

The core palette is taken directly from the logo's watercolor petals.

| Token            | Hex       | Use                                              |
|------------------|-----------|--------------------------------------------------|
| `--meen-lavender`| `#9C87B1` | Primary brand color. Buttons, links, active nav. |
| `--meen-periwinkle`| `#6E75A3`| Primary-dark / hover states, headings.          |
| `--meen-sky`     | `#79AAC8` | Secondary. Info states, highlights.              |
| `--meen-teal`    | `#66A0C1` | Accent. Listening exercise, audio cues.          |
| `--meen-mist`    | `#B1B1CC` | Soft fills, disabled states, muted borders.      |
| `--meen-haze`    | `#CDD4E3` | Backgrounds, cards, subtle dividers.             |
| `--meen-ink`     | `#25233E` | Text, the feather outline, near-black.           |

### Extended / functional colors
Derived to harmonise with the watercolor palette rather than default Bootstrap colors.

| Token             | Hex       | Use                          |
|-------------------|-----------|------------------------------|
| `--meen-success`  | `#5BA38C` | Correct answers, streak kept.|
| `--meen-warning`  | `#D6A85B` | Gentle nudges, due-soon.     |
| `--meen-danger`   | `#C4708A` | Errors, lost streak. (Soft rose, not harsh red — stays on-brand.) |
| `--meen-white`    | `#FDFDFF` | Page background (warm white).|

### Per-companion accent
Each language companion gets one palette color as its signature, used in companion chat
bubbles and that language's accents.

- **Greta** (German fox) -> `--meen-lavender`
- **Fabien** (French cat) -> `--meen-teal`

---

## Typography

**Inter** throughout — it's exceptionally legible at small sizes and handles German
umlauts, French accents, and long compound words cleanly, which matters for a language
app. Personality comes from the palette and watercolor textures, not the typeface.

Load via Google Fonts or self-host (self-hosting preferred for the iOS shell to avoid a
network dependency on first paint):

```html
<link rel="preconnect" href="https://fonts.googleapis.com">
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
```

### Type scale
A modular scale (~1.25 ratio). Use `rem`; base is 16px.

| Token            | Size      | Weight | Use                              |
|------------------|-----------|--------|----------------------------------|
| `--fs-display`   | 2.75rem   | 700    | Onboarding splash, big numbers (streak count). |
| `--fs-h1`        | 2.0rem    | 700    | Page titles.                     |
| `--fs-h2`        | 1.5rem    | 600    | Section headers.                 |
| `--fs-h3`        | 1.25rem   | 600    | Card titles, exercise prompts.   |
| `--fs-body`      | 1.0rem    | 400    | Body text.                       |
| `--fs-small`     | 0.875rem  | 400    | Captions, helper text.           |
| `--fs-micro`     | 0.75rem   | 500    | Labels, tags, pill text.         |

- **Foreign-language target text** (the German/French word being learned) renders one step
  larger than surrounding UI text and in weight 600, so the learner's eye lands on it
  first.
- **Translations / base-language glosses** render in `--meen-periwinkle` at `--fs-small`,
  visually subordinate to the target word.
- Line height: 1.5 for body, 1.2 for headings.
- Letter-spacing: default everywhere except `--fs-micro` labels, which get `0.04em` and
  uppercase.

---

## CSS custom properties

Define once on `:root`. These are the single source of truth; the Bootstrap SCSS overrides
below simply point at them.

```css
:root {
  /* Brand */
  --meen-lavender:   #9C87B1;
  --meen-periwinkle: #6E75A3;
  --meen-sky:        #79AAC8;
  --meen-teal:       #66A0C1;
  --meen-mist:       #B1B1CC;
  --meen-haze:       #CDD4E3;
  --meen-ink:        #25233E;

  /* Functional */
  --meen-success: #5BA38C;
  --meen-warning: #D6A85B;
  --meen-danger:  #C4708A;
  --meen-white:   #FDFDFF;

  /* Type */
  --font-base: 'Inter', system-ui, sans-serif;
  --fs-display: 2.75rem;
  --fs-h1: 2rem;
  --fs-h2: 1.5rem;
  --fs-h3: 1.25rem;
  --fs-body: 1rem;
  --fs-small: 0.875rem;
  --fs-micro: 0.75rem;

  /* Spacing scale (4px base) */
  --space-1: 0.25rem;
  --space-2: 0.5rem;
  --space-3: 0.75rem;
  --space-4: 1rem;
  --space-6: 1.5rem;
  --space-8: 2rem;
  --space-12: 3rem;

  /* Radius — soft, rounded, friendly */
  --radius-sm: 8px;
  --radius-md: 14px;
  --radius-lg: 22px;
  --radius-pill: 999px;

  /* Shadows — soft and diffuse, like watercolor bleed */
  --shadow-sm: 0 1px 3px rgba(37, 35, 62, 0.08);
  --shadow-md: 0 4px 16px rgba(37, 35, 62, 0.10);
  --shadow-lg: 0 12px 32px rgba(37, 35, 62, 0.14);
}
```

---

## Bootstrap 5 integration

Override Bootstrap's SCSS variables before importing Bootstrap so the framework's own
components inherit the Meen palette. In `app/assets/stylesheets/`:

```scss
// _meen_variables.scss — import BEFORE bootstrap

$primary:   #9C87B1;  // lavender
$secondary: #79AAC8;  // sky
$info:      #66A0C1;  // teal
$success:   #5BA38C;
$warning:   #D6A85B;
$danger:    #C4708A;
$light:     #CDD4E3;  // haze
$dark:      #25233E;  // ink

$body-bg:    #FDFDFF;
$body-color: #25233E;

$font-family-sans-serif: 'Inter', system-ui, -apple-system, sans-serif;

$border-radius:    14px;
$border-radius-sm: 8px;
$border-radius-lg: 22px;

$box-shadow-sm: 0 1px 3px rgba(37, 35, 62, 0.08);
$box-shadow:    0 4px 16px rgba(37, 35, 62, 0.10);
$box-shadow-lg: 0 12px 32px rgba(37, 35, 62, 0.14);

// Then:
// @import "bootstrap/scss/bootstrap";
```

---

## Components

### Buttons
- **Primary**: lavender fill, white text, `--radius-pill`, no border. Hover -> periwinkle.
- **Secondary**: transparent fill, lavender text + 1.5px lavender border. Hover -> haze fill.
- **Audio / listening**: teal fill (ties to the listening exercise accent).
- Generous padding: `--space-3` vertical, `--space-6` horizontal. Buttons should feel
  tappable on mobile — minimum 44px tall (iOS touch target).

### Cards
- Background `--meen-white`, `--radius-lg`, `--shadow-md`.
- Flashcards specifically: slightly larger radius and a subtle watercolor-tint top border
  (a 4px bar in the word's theme color) to bring color in without overwhelming.
- Padding `--space-6`.

### Flashcards
- The card face is calm: white, lots of space, the target word centered at `--fs-h1`.
- Flip animation on reveal (CSS 3D transform, ~0.4s ease).
- The reveal side shows the translation, article (color-coded by gender — see below), and
  example forms.

### Gender color-coding (German)
A learning aid: tint the article chip by grammatical gender so users build the association.
- der (m) -> `--meen-sky`
- die (f) -> `--meen-danger` (soft rose)
- das (n) -> `--meen-success` (green)
These are chips/pills, not full backgrounds — small dots of color.

### Companion chat
- Companion messages: left-aligned bubble in the companion's signature color at low opacity
  (~12% fill), ink text, with a small companion avatar.
- User messages: right-aligned, lavender fill, white text.
- Bubbles use `--radius-lg` with one corner squared toward the speaker.

### Progress & streaks
- Streak count uses `--fs-display` in periwinkle with a small flame/feather icon.
- Progress rings/bars use a lavender-to-teal gradient (echoes the logo's color sweep).
- Daily-session progress: a 6-segment bar (introduce + 4 exercises + done), each segment
  filling with watercolor color as completed.

### Pills / tags (themes, CEFR levels)
- `--radius-pill`, `--fs-micro` uppercase, `0.04em` tracking.
- Theme pills tinted with `--meen-haze`; CEFR pills tinted by level.

---

## Visual texture & motion

- **Watercolor accents**: use soft radial-gradient "petal" shapes from the logo palette as
  subtle background decoration on empty states and the onboarding/splash — low opacity,
  never behind body text.
- **Backgrounds**: warm white (`--meen-white`) as default; occasional `--meen-haze` for
  grouped sections. Avoid flat gray.
- **Motion**: gentle. Page transitions via Turbo should feel smooth. Use one well-staggered
  reveal on the daily-session start rather than scattered micro-animations. Flashcard flips
  and the streak count-up are the two "delight" moments worth investing in.
- **Shadows** are soft and diffuse (defined above) to echo watercolor bleed — never hard or
  high-contrast.

---

## Accessibility

- Body text (`--meen-ink` on `--meen-white`) passes WCAG AAA.
- Never rely on color alone — the gender color-coding always pairs with the written article
  (der/die/das), and correct/incorrect states pair color with an icon.
- Minimum touch target 44x44px (iOS).
- Respect `prefers-reduced-motion`: disable the flashcard flip and count-up animations.
- Maintain a visible focus ring (lavender, 2px offset) for keyboard nav.

---

## Logo usage
- `meen_logo.png` is the feather. Keep clear space around it equal to the width of the
  feather's notch.
- On dark backgrounds use the logo as-is (the watercolor reads well); on busy backgrounds
  place it on a white or haze card.
- Don't recolor the feather — the watercolor fill is the brand.
