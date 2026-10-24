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

`build` runs `astro build --force`, which clears Astro's content cache. Without
it, a post removed from `src/content/blog/` stays cached and the build fails
looking for its deleted images.

## Blog

The blog is at https://chimesapp.com/blog/, with an RSS feed at `/blog/rss.xml`.
Every page is listed in `/sitemap-index.xml`.

Posts are **written in the app repo**, not here:
`docs/marketing/blog/posts/<slug>/` in
[richstimson/locapp-23](https://github.com/richstimson/locapp-23), where
`docs/marketing/blog/README.md` describes the post format. `./sync-blog.sh`
copies them into `src/content/blog/`. Never edit that copy; change the post in
locapp-23 and re-sync.

```
./sync-blog.sh            # from ~/src/locapp-23-main, or pass a checkout path
npm run build             # fails if a post's frontmatter or cover image is wrong
git add src/content/blog && git commit
npm run smart-deploy      # see docs/deploy.md
```

The script copies only posts marked `draft: false`, because this repo is public.
It copies only `index.md` and image files from each post folder, and strips HTML
comments, which hold internal notes in locapp-23. It stops, changing nothing, if
a published post still has an unclosed `<!--`, `TODO` or `OWNER:`. It refuses to
run unless the locapp-23 checkout is on `main`, clean, and level with
`origin/main`. `src/content/blog/SYNCED-FROM.txt` records the commit the posts
came from.

Pages: `src/pages/blog/index.astro` (the list), `src/pages/blog/[slug].astro`
(a post), `src/pages/blog/rss.xml.ts`. The schema is in `src/content.config.ts`.
Index cards crop the cover to 16:9, so use a landscape cover.

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
