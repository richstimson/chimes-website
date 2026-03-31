# Chimes Website Deployment Guide

This document explains the two main deployment methods for the Chimes website: **smart-deploy** and **full-deploy**.

It also includes a verification command to confirm the live site is serving the expected HTML and asset cache headers after deployment.

## Required Environment Variables

Before running any deployment command, set your FTP password in the shell:

```bash
export CHIMES_FTP_PASSWORD="<your-ftp-password>"
```

Or store it locally on macOS Keychain once (recommended):

```bash
npm run set-ftp-password
```

After that, deploy commands will read the password from Keychain automatically.

To print the currently configured password locally:

```bash
npm run show-ftp-password
```

Optional local file (not committed): create `.env.local` with:

```bash
CHIMES_FTP_PASSWORD=<your-ftp-password>
CHIMES_FTP_USER=STIMSONS@chimesapp.com
CHIMES_FTP_HOST=ftp.chimesapp.com
```

Optional overrides:

```bash
export CHIMES_FTP_USER="STIMSONS@chimesapp.com"
export CHIMES_FTP_HOST="ftp.chimesapp.com"
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
     - Only uploads changed files to the FTP server using `lftp`.
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
     - Uses `lftp` to mirror the site to the FTP server.
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
