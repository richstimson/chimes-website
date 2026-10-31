# Site design

[`CHIMES_DESIGN.md`](CHIMES_DESIGN.md) is the design pack as delivered (2026-10-31, "Pink Gradient"
theme D) and the source of truth for colours, gradients, type and components. Its tokens are in
`src/styles/app.css`. The pack's `chimes-theme.css` and `homepage-reference.html` were not added to
the repo: the first is the plain-CSS copy of the same tokens, the second a static mock-up.

## How this site applies it

| Pack says | This site | Why |
| --- | --- | --- |
| Apollo theme | The site uses daisyUI 5 on Tailwind 4.1, not Apollo | The pack assumed a theme the site does not use. daisyUI's `primary` is action blue and `secondary` raspberry, so older pages follow rule 1 too |
| `.btn-vendor`, `.btn-secondary`, … | `.ch-btn` plus `.ch-btn-vendor`, `.ch-btn-secondary`, … | daisyUI already defines `.btn` and `.btn-secondary`; the `ch-` prefix stops the two merging |
| `bg-night` utility | `bg-vendor-band` | `bg-night` is already the plain night colour (`--color-night`), used by the footer |
| `blue-50` / `blue-100` tints | `sky-tint-50` / `sky-tint-100` | As in the pack's `chimes-tailwind.css`: Tailwind's own `blue-50` would be shadowed |
| Google Fonts link | Fredoka and DM Sans self-hosted from `public/fonts/` | No visitor request goes to Google (privacy) |
| Customer section: `.btn-customer` "Get the app" | App Store and Google Play badges + `.ch-btn-secondary-blue` "See every feature" | The badges are the customer's action, and there are two stores |
| Vendor band "Register your business" | Links to the App Store, with "Settings → Register your business" beside it | Registration happens in the iPhone app; there is no web sign-up |
| Ticks copy ("you disappear from the map") | Feed-backed copy from the feature pages | An Offline van can still show, faded (MAP-013); live tracking starts in demo mode (VDM-001) |

Screenshots: real app captures in `public/images/app/`, in phone frames that peek from tinted panels.
