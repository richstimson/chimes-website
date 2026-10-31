# Chimes website design guide — "Pink Gradient" theme (D)

Hand this file to whoever builds the site. It is the source of truth for colours,
gradients, type and component rules. Tokens live in `chimes-theme.css` (plain CSS)
and `chimes-tailwind.css` (Tailwind v4 `@theme`). `homepage-reference.html` is a
static reference build of the homepage — match its look, not necessarily its markup.

**The site is an Astro (v5) build using the Apollo theme with Tailwind CSS v4.1.**
Use `chimes-tailwind.css`: import it in the theme's main stylesheet right after
`@import "tailwindcss";` and replace the theme's existing colour/font tokens with
these. Ignore `chimes-theme.css` (it's the plain-CSS equivalent, kept for reference
and for `homepage-reference.html`). Restyle the Apollo components to these rules
rather than adding a second styling system.

---

## 1. The one big rule: colour tells the visitor who a button is for

The homepage speaks to two audiences. Colour separates them.

| Audience | Colour | Used for |
|---|---|---|
| **Vendors** (ice cream vans, shops) | **Raspberry `#C81E54`** | "Put my van on Chimes", "Register your business", step numbers, vendor highlights |
| **Customers** (people wanting ice cream) | **Action blue `#2563EB`** | "Get the app", "Pick your area", customer links |

- Never use raspberry for a customer action or blue for a vendor action.
- **One filled raspberry button per screen-height.** Everything else nearby is a secondary (outline) button.
- The nav's main button is a customer action ("Get the app"), so it is blue.

---

## 2. Palette

### Core colours

| Token | Hex | Role |
|---|---|---|
| `--chimes-raspberry` | `#C81E54` | Vendor primary buttons, step badges start |
| `--chimes-raspberry-dark` | `#A3173F` | Raspberry text on light/pink backgrounds, hover state |
| `--chimes-raspberry-deeper` | `#7A1130` | Pressed state, text on pale pink |
| `--chimes-candy` | `#FF8FB0` | Ticks/icons **on navy only** |
| `--chimes-plum` | `#8B2FA8` | Step badge gradient end only |
| `--chimes-logo-blue` | `#1D4ED8` | "Chimes" wordmark and "Chimes:" in headline, small blue labels |
| `--chimes-action-blue` | `#2563EB` | Customer primary buttons |
| `--chimes-action-blue-dark` | `#1E3A8A` | Blue button hover, blue text on white |
| `--chimes-night` | `#0B1D3A` | Vendor band start, footer |
| `--chimes-ink` | `#1B2333` | All headings and body text |
| `--chimes-ink-muted` | `#4A5468` | Secondary text on white |
| `--chimes-ink-muted-pink` | `#44394A` | Secondary text on the pink hero |
| `--chimes-ink-muted-blue` | `#3E4A63` | Secondary text on blue/lilac sections |
| `--chimes-on-night` | `#D6DEF0` | Secondary text on navy |
| `--chimes-white` | `#FFFFFF` | Page background, cards |

### Tints (backgrounds, borders)

| Token | Hex | Role |
|---|---|---|
| `--chimes-pink-50` | `#FFF4F7` | Card background (pink) |
| `--chimes-pink-100` | `#F8D6E0` | Card border (pink) |
| `--chimes-lilac-50` | `#FBF4FF` | Card background (lilac) |
| `--chimes-lilac-100` | `#EBD9F7` | Card border (lilac) |
| `--chimes-blue-50` | `#F4F7FF` | Card background (blue) |
| `--chimes-blue-100` | `#DCE5FA` | Card border (blue) |
| `--chimes-outline-pink` | `#E2B6D6` | Secondary button border on pink hero |
| `--chimes-outline-blue` | `#9CBDF5` | Secondary button border in customer section |

The page background is **white**. No cream.

---

## 3. Gradients

There are exactly four. Don't invent others.

1. **Hero ("sundae")** — top of the homepage only.
   ```css
   background:
     linear-gradient(180deg, rgba(255,255,255,0) 72%, #FFFFFF 100%),
     linear-gradient(120deg, #FFC9DA 0%, #FDDDEE 38%, #EEDDFF 72%, #DCE8FF 100%);
   ```
   Strawberry pink → lilac → soft blue, fading to white at the bottom so it melts into the page.

2. **Vendor band ("night")** — the "Get your van on Chimes" sign-up block.
   ```css
   background: linear-gradient(135deg, #0B1D3A 0%, #1B2D5A 60%, #2A3F7A 100%);
   ```

3. **Customer section ("lilac wash")**
   ```css
   background: linear-gradient(120deg, #F1E6FF 0%, #E3EEFF 100%);
   ```

4. **Step badge** — small numbered circles only.
   ```css
   background: linear-gradient(135deg, #C81E54 0%, #8B2FA8 100%);
   ```

Rules:
- Buttons are always **solid**, never gradient.
- Text sits on gradients 1–3 as specified below; don't put white text on the hero gradient.

---

## 4. Typography

| Use | Font | Weight | Size (desktop) |
|---|---|---|---|
| H1 (hero) | Fredoka | 700 | 60px / line-height 1.05 |
| H2 (section) | Fredoka | 700 | 40px / 1.1 |
| Wordmark | Fredoka | 700 | 28px |
| H3 (card title) | DM Sans | 700 | 20px |
| Hero subhead | DM Sans | 700 | 22px, raspberry-dark |
| Body large | DM Sans | 400 | 18px / 1.55 |
| Body | DM Sans | 400 | 16px / 1.5 |
| Eyebrow label | DM Sans | 700 | 12–13px, uppercase, letter-spacing 1px |
| Buttons | DM Sans | 700 | 17px (15px in nav) |

Google Fonts:
```html
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Fredoka:wght@500;600;700&family=DM+Sans:wght@400;500;700&display=swap" rel="stylesheet">
```

On mobile (<640px): H1 40px, H2 30px.

In the headline, "Chimes:" is logo blue and the rest is ink.

---

## 5. Components

### Buttons
All buttons: min-height 52px (44px in nav), padding 0 26px, radius 14px (12px in nav), bold 17px, no gradient.

| Class | Background | Text | Border | Hover |
|---|---|---|---|---|
| `.btn-vendor` | `#C81E54` | white | none | `#A3173F` |
| `.btn-customer` | `#2563EB` | white | none | `#1E3A8A` |
| `.btn-secondary` (on pink/white) | white | ink | 1.5px `#E2B6D6` | border → raspberry |
| `.btn-secondary-blue` (customer section) | white | `#1E3A8A` | 1.5px `#9CBDF5` | border → action blue |
| `.btn-ghost-light` (on navy) | transparent | white | 1.5px white | bg white 10% |

Always show a visible focus ring: `outline: 3px solid #2563EB; outline-offset: 2px;` (use white outline on navy).

### Cards
- Radius 20px, padding 28px, 1px border.
- "How it works" step cards shift across the row: pink-50/pink-100 → lilac-50/lilac-100 → blue-50/blue-100.
- Customer section cards: white, no border.

### Step badge
44px circle, gradient 4, white bold 18px number.

### Eyebrow pill
White background, raspberry-dark text, 12px bold uppercase, radius 999px, padding 6px 12px.

### Ticks on navy
`✓` (or an icon) in candy `#FF8FB0`, bold.

### Radius scale
12px (small buttons) · 14px (buttons) · 20px (cards) · 28px (big panels, vendor band, screenshot frame) · 999px (pills, badges).

### Layout
- Content max-width 1120px, side padding 24px.
- Section vertical padding 80px (48px on mobile).
- Flex/grid gaps: 12px between buttons, 20px between cards, 48px between hero columns.

---

## 6. Homepage structure (top to bottom)

1. **Header + hero** on the sundae gradient. Nav links in ink; "Get the app" = `.btn-customer`. Left column: eyebrow pill "For ice cream vans", H1, raspberry-dark subhead, body, `.btn-vendor` "Put my van on Chimes" + `.btn-secondary` "See how it works". Right column: app screenshots.
2. **How it works** on white: H2 + three step cards (pink → lilac → blue) with gradient badges.
3. **Vendor band** (night gradient, radius 28px, inset with page padding): H2 white, body `#D6DEF0`, `.btn-vendor` "Register your business" + `.btn-ghost-light`, candy ticks list.
4. **Customer section** (lilac wash, full width): blue eyebrow "Looking for ice cream?", H2, three white cards, `.btn-customer` "Get the app" + `.btn-secondary-blue`.
5. **Footer** on `#0B1D3A`, text `#D6DEF0`, wordmark white.

On mobile, every multi-column row stacks to one column; the nav collapses to a menu button.

---

## 7. Accessibility rules (already checked for these pairings)

All text/background pairings above meet WCAG AA (4.5:1 for normal text). Keep to them:

- White text: OK on raspberry `#C81E54`, action blue `#2563EB`, night and the vendor band gradient.
- **Don't** use the old `#E0245E` raspberry or `#3B82F6` blue behind white button text — both fall just short.
- Candy pink `#FF8FB0` is for navy backgrounds only, never on white or pink.
- Logo blue `#1D4ED8` passes as text on white, the pink hero and the lilac wash.
- Raspberry text on pink: use `#A3173F`, not `#C81E54`.
- Touch targets at least 44px.

---

## 8. Don'ts

- No cream backgrounds.
- No gradient buttons, no new gradients.
- No emoji as icons — use a line icon set (e.g. Lucide) at 2px stroke.
- Don't let pink take over below the hero; the page body is white with tinted cards.
- Don't use raspberry for anything customer-facing.
