# Old `/` vs `/homepage`: what would be lost (D2 check, 2026-10-31)

**Done 2026-11-01 (owner said yes to D2):** `/homepage` is now `/`, `/homepage` redirects there, and the
old-only components are deleted (`DownloadApp` stays: `/download` uses it); the old page is kept at `/oldhomepage` (noindex). Kept as the record of what the
old page had.

Before `/homepage` replaces `/` (owner decision D2), this lists everything on the old home page
(`src/pages/index.astro` and its components) and where, if anywhere, it is on the new one. Checked
against `feat/register-form`, which adds the "Register your interest" box and `/register`.

**Gone, and needs your call** is the part to read.

## Gone, and needs your call

| Old `/` has | Where | On `/homepage`? | Recommendation |
| --- | --- | --- | --- |
| **Vendor pricing**: Essentials £0, Track & Notify £20/month (£240/year) and Fully Customizable £45/month (£540/year), each with a Stripe payment link. "No setup fees • Cancel anytime • 30-day money-back guarantee" | `VendorPricing.astro` (`#pricing`) | **No.** `#pricing` now lands on the vendor band, which says "free" and "free trial" with no prices | **Decided (owner, D11, 2026-10-31): no prices on the new homepage** while Chimes is in trials; the Stripe links stay off it |
| **"Grow the Chimes network"**: no vans on the map? Find vans online, tell them in person, use Share Chimes in the app, tell us about a van | `Features.astro` | **No.** The map card now says "Even ones not on Chimes yet" (listed shops and vans), which answers "no vans on the map" differently | Add one customer line, e.g. "Know a van that isn't on Chimes? Tell us" linking to `#contact`, if you want customers recruiting vans |
| "Join thousands of ice cream lovers…" | `Hero.astro`, `HowItWorks.astro` | No | Leave out unless the number is true |

## Carried over (same point, new words)

| Old `/` | On `/homepage` |
| --- | --- |
| Customer headline: notifications when the van is in your area | Customer section "Know when the van's coming" and the "Pick your area" card; hero is now vendor-first (positioning brief) |
| "I'm looking for ice cream" / "I'm a vendor" switch | Hero is for vans; the customer section and the blue "Get the app" in the header are for customers |
| Vendor "Register interest" email box | Hero, under "Put my van on the map" (this branch). Same PHP, same welcome email, which now links to `/register` |
| Features: real-time tracking, chime alerts, search a wider area, postcode + radius setup | How it works steps 2–3, customer cards, `/features/*` pages |
| Vendor privacy ("you control when your location is visible") | Vendor band tick "Your call", `/features/live-van-tracking` |
| Free to get started (customers always free; vendors free listing, then trial) | "Free. No account." in the customer section; "Free listing" and "start free in demo mode" in the vendor band |
| App showcase: following a favourite van | "Keep your favourites" card, `/features/favourites` |
| How it works (customer: set location, get a chime, enjoy) | "Pick your area" card; the new How it works is the vendor's three steps |
| Vendor info: reach more customers, more sales, simple setup; sign up → share location → serve | Hero subhead and body, How it works, vendor band |
| "Get Started Free" → `/vendor-getting-started` | "Register your business" → `/register` (this branch also points the old page's button there) |
| Download: App Store and Google Play badges | Customer section badges (`#download`) |
| Contact form, footer | Same components |

## Links that must still land

The header uses `/#features`, `/#how-it-works`, `/#pricing`, `/#download`, `/#contact`. All five ids
exist on `/homepage` (`features` and `pricing` are on the vendor band). The old hero's `#vendor`
(singular) is only used inside the old page.

## If D2 is yes

Move `src/pages/homepage.astro` to `index.astro`, drop `noindex`, redirect `/homepage` to `/` in
`public/.htaccess`, then delete the old-only components (`Hero`, `Features`, `AppShowcase`,
`HowItWorks`, `VendorInfo`, `VendorPricing`, `DownloadApp`) once nothing imports them.
