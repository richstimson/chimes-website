# Chimesapp-com

## Get started

```
npm install
```

## Build

```
npm run build
```

Output is in the `/dist` directory. This is what you want to host

## Privacy policy

This repo is the single source of truth for the Chimes privacy policy, served at
https://chimesapp.com/privacy from `src/pages/privacy.astro`.

- It is linked from Google Play Console (App content → Privacy policy) and from
  App Store Connect (App Information → Privacy Policy URL). Its URL must never
  change or disappear: Google Play removed the app on 2026-09-14 when the URL it
  had on file stopped loading.
- The App Store listing still uses the old URL `/ios-privacy-policy/`, which
  `public/.htaccess` redirects to `/privacy`. Keep that redirect.
- Update the policy whenever the Chimes app changes what data it collects. The
  app lives in [richstimson/locapp-23](https://github.com/richstimson/locapp-23).
  Keep the `lastUpdated` date at the top of `privacy.astro` current.

The deploy scripts refuse to upload unless this checkout is up to date with
`origin/main` and the build contains both the policy and the redirect; see
`deploy-guards.sh`.
