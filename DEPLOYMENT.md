# Chimes Website Deployment Guide

> Start with [`docs/deploy.md`](docs/deploy.md): current setup, known quirks,
> and why FTP is retired.

This document explains the two main deployment methods for the Chimes website: **smart-deploy** and **full-deploy**.

It also includes a verification command to confirm the live site is serving the expected HTML and asset cache headers after deployment.

## Deploy access

Deploys use SFTP with an SSH key; there is no password. The Bluehost account
allows SFTP but not shell access, so `lftp` mirrors over SFTP rather than
`rsync`. Connection settings are in `deploy-target.sh`:

| Setting | Default |
|---|---|
| `CHIMES_SSH_HOST` | `box2276.bluehost.com` |
| `CHIMES_SSH_USER` | `stimsons` |
| `CHIMES_SSH_KEY` | `~/.ssh/chimes_deploy_ed25519` |
| `CHIMES_REMOTE_ROOT` | `/home1/stimsons/public_html/chimesapp` |

To deploy from a new machine:

1. Generate a key there: `ssh-keygen -t ed25519 -f ~/.ssh/chimes_deploy_ed25519`
2. In cPanel → SSH Access → Manage SSH Keys → Import Key, paste the contents
   of `~/.ssh/chimes_deploy_ed25519.pub`. Then click **Manage → Authorize**;
   imported keys start unauthorized.
3. Test: `sftp -i ~/.ssh/chimes_deploy_ed25519 stimsons@box2276.bluehost.com`

Generate the key locally rather than with cPanel's "Generate a New Key", so the
private key never leaves your machine.

Before uploading, every deploy script runs `deploy-guards.sh`, which refuses to
deploy a checkout that is behind `origin/main`, has uncommitted changes, or
whose build lacks the privacy policy. See "Privacy policy" in `README.md`.

To preview a deploy without changing anything:

```bash
npm run build && DRY_RUN=1 ./sync-smart.sh
```

---


## 1. Smart Deploy (`npm run smart-deploy`)

**How it's defined in `package.json`:**

```json
  "smart-deploy": "npm run build && ./sync-smart.sh"
```

- **Purpose:** Efficiently uploads only files that have actually changed since the last deployment.
- **How it works:**
  1. Runs a production build (`npm run build`) to generate the latest site in `dist/`.
  2. Executes `sync-smart.sh`, which:
     - Calculates checksums for all files in `dist/`.
    - Compares with previous deployment to detect changes.
    - Tracks hashed Astro assets in `dist/_astro` separately.
     - Only uploads changed files to the server using `lftp` over SFTP.
    - Deletes removed top-level site files, but preserves older hashed files in `/_astro` so browsers with cached HTML do not lose their CSS or JS bundles mid-rollout.
     - Skips upload if nothing changed.
     - Updates cache/checksum files for next run.
- **When to use:**
  - For most day-to-day updates and deployments.
  - Saves bandwidth and time by avoiding unnecessary uploads.

---


## 2. Full Deploy (`npm run full-deploy`)

**How it's defined in `package.json`:**

```json
  "full-deploy": "npm run build && npm run full-sync",
  "full-sync": "./full-sync.sh"
```

- **Purpose:** Force a complete upload of the entire site, while preserving older hashed Astro assets for cache safety.
- **How it works:**
  1. Runs a production build (`npm run build`).
  2. Executes `full-sync` (defined in `package.json`), which:
     - Uses `lftp` over SFTP to mirror the site to the server.
     - Deletes files outside `/_astro` that are not present locally.
     - Uploads the current `/_astro` directory without deleting older hashed bundles.
     - Keeps stale cached HTML from breaking when it references a previous hashed CSS or JS filename.
- **When to use:**
  - After major refactors, renames, or deletions.
  - If you suspect the server and local files are out of sync.

---

## 3. Verify Deploy (`npm run verify-deploy`)

- **Purpose:** Validate that the live site is serving cache-safe HTML and that every current Astro asset from the local build is available on production.
- **How it works:**
  1. Checks the homepage headers and confirms HTML is served with `no-cache, max-age=0, must-revalidate`.
  2. Reads the current files in `dist/_astro`.
  3. Requests each asset from production and confirms it returns `200`.
  4. Confirms the asset responses include long-lived cache headers.
- **When to use:**
  - Immediately after any production deploy.
  - When debugging reports of unstyled or partially styled pages.

---

## Summary Table

| Command                | What it does                                 | When to use                |
|------------------------|----------------------------------------------|----------------------------|
| `npm run smart-deploy` | Build and upload only changed files          | Most updates (fast, safe)  |
| `npm run full-deploy`  | Build and upload everything, preserve old `/_astro` bundles | Major changes, safe full sync |
| `npm run verify-deploy` | Verify live HTML and current `/_astro` assets | After each deploy |

---

## Cache Safety

This site uses hashed Astro assets in `/_astro`.

- Browsers can temporarily cache older HTML documents.
- If deployment deletes the older hashed CSS or JS files immediately, those browsers will render an unstyled or broken page until they refresh HTML.
- To avoid that, deployment preserves older `/_astro` files and only replaces the HTML and current assets.

For Bluehost/Apache hosting, a `.htaccess` file is also published from `public/.htaccess` so HTML revalidates quickly while static assets can stay cached longer.

---

For questions or troubleshooting, see the scripts in the project root or contact the project maintainer.
