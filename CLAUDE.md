# chimesapp.com

Astro marketing site for the Chimes app. `src/` and `public/` are the source;
`npm run build` writes `dist/`, which is what gets deployed.

- **Deploying:** read [`docs/deploy.md`](docs/deploy.md) first. Deploys use
  SFTP with an SSH key. FTP is retired and must not be used.
- **Privacy policy:** `src/pages/privacy.astro` is served at `/privacy` and
  linked from Google Play and the App Store. It must never disappear. See
  "Privacy policy" in `README.md`.
- This repo is public. Never commit or print credentials.
