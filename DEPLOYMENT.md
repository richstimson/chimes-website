# Chimes Website Deployment Guide

This document explains the two main deployment methods for the Chimes website: **smart-deploy** and **full-deploy**.

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
     - Only uploads changed files to the FTP server using `lftp`.
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

- **Purpose:** Force a complete upload of the entire site, deleting any files on the server that no longer exist locally.
- **How it works:**
  1. Runs a production build (`npm run build`).
  2. Executes `full-sync` (defined in `package.json`), which:
     - Uses `lftp` to mirror the entire `dist/` directory to the FTP server.
     - Deletes any files on the server that are not present locally.
     - Ensures the server is a perfect match to your local build.
- **When to use:**
  - After major refactors, renames, or deletions.
  - If you suspect the server and local files are out of sync.

---

## Summary Table

| Command                | What it does                                 | When to use                |
|------------------------|----------------------------------------------|----------------------------|
| `npm run smart-deploy` | Build and upload only changed files          | Most updates (fast, safe)  |
| `npm run full-deploy`  | Build and upload everything, delete old files| Major changes, full reset  |

---

For questions or troubleshooting, see the scripts in the project root or contact the project maintainer.
