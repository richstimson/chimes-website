# App screenshot originals

Full-size captures behind the 600 px WebPs in `public/images/app/`. This folder is not under `public/`, so it
is never deployed. To rebuild a WebP, scale to 600 px wide and convert.

| Original | Published | Source |
| --- | --- | --- |
| `23-map-area-1km.png` | `23-map-area-1km.webp` | iPhone 17 Pro sim, 1206×2622, 2026-10-31 (PR #21) |
| `24-vendor-card-socials.png` | `24-vendor-card-socials.webp` | iPhone 17 Pro sim, 1206×2622, 2026-10-31 (PR #21) |
| `25-vendor-card-full.png` | `25-vendor-card-full.webp` | iPhone 17 Pro sim, 1206×2622, 2026-11-01 (PR #22) |
| `27-map-clusters-frosty.png` | `27-map-clusters-frosty.webp` | Owner's iPhone capture, 1170×2532, 2026-11-01 (PR #23) |

The older WebPs were made from captures already in git in the app repo (`richstimson/locapp-23`), so they
are not copied here. Each pairing checked on 2026-11-01 (original scaled to the WebP's size, RMSE ≤ 0.034):

| Published | Original in `locapp-23` |
| --- | --- |
| `01`, `02`, `04`, `11`, `13`, `15`–`18`, `20`, `21-…-card`, `22-…-card` | `assets/images/stores/app-store/2026-10/raw/<same name>.png` |
| `notification-ios.webp` | `assets/images/app-assets/ios-notification.png` |
| `notification-android.webp` | `assets/images/app-assets/Android-notification.png` |
