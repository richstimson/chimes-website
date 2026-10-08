# Deploying chimesapp.com

Last updated: 2026-10-08

This is the reference for anyone, human or AI agent, deploying this site. For
the command-by-command description see [`DEPLOYMENT.md`](../DEPLOYMENT.md).

## FTP is retired

**Do not use FTP.** No script in this repo uses it, and it must not be
reintroduced. FTP sent the password in plaintext, and lftp printed it in its
output, which leaked it into a session transcript. The FTP password helpers
(`load-ftp-secrets.sh`, `save-ftp-password.sh`, `show-ftp-password.sh`) were
deleted on 2026-10-08.

Done on 2026-10-08:

- The FTP account `STIMSONS@chimesapp.com` was deleted in cPanel, which
  disables the leaked password. The site files were unaffected.
- The `chimes-ftp-password` item was deleted from macOS Keychain. There was no
  `.env.local`.

Still outstanding as of 2026-10-08:

- Delete the old `chimes-ssh-rsa` key (public and private) in cPanel → SSH
  Access. It has been replaced by `chimes-deploy-ssh`.
- Delete Chrome's saved passwords for `STIMSONS@chimesapp.com` and
  `chimes-ssh-rsa`.

## How deploys work

Deploys use **SFTP with an SSH key**. `lftp` mirrors `dist/` to the server.

| | |
|---|---|
| Host | `box2276.bluehost.com` (IP 50.87.176.132) |
| User | `stimsons` |
| Key | `~/.ssh/chimes_deploy_ed25519` on the owner's MacBook. No passphrase. |
| Key name in cPanel | `chimes-deploy-ssh`, public half only (cPanel → SSH Access → Manage SSH Keys) |
| Passwords | None needed to deploy. The key file has no passphrase, and cPanel key management uses the normal cPanel login. cPanel's Import Key form insists on a passphrase even for a public-only import; the value entered is in the owner's LastPass entry `chimes-deploy-ssh`. It's never used to log in. |
| Document root | `/home1/stimsons/public_html/chimesapp` |
| Settings file | `deploy-target.sh`. Each setting can be overridden from the environment. |

The account allows **SFTP but not shell access**: `ssh` logs in, then prints
"Shell access is not enabled on your account". So `rsync` and remote commands
are not possible. Use SFTP, `lftp`, or `scp`-style transfers only.

If the key is lost, nothing is locked out. Generate a new key and import its
public half in cPanel (about five minutes). The same applies to deploying from
another machine; see "Deploy access" in `DEPLOYMENT.md`. Don't use cPanel's "Generate a
New Key": it requires a passphrase, and the private key is created on the
server.

### Commands

Run these from an up-to-date `main`:

| Command | What it does |
|---|---|
| `npm run smart-deploy` | Build, then upload only what changed. Removes files deleted from the build. **Use this by default.** |
| `npm run full-deploy` | Build, then re-send every file and remove anything not in the build. |
| `npm run deploy` | Build, then upload everything. Never deletes anything. |
| `npm run build && DRY_RUN=1 ./sync-smart.sh` | Show what a deploy would upload and delete, without changing anything. |
| `npm run verify-deploy` | Check the privacy URLs after a deploy (see "Verifying a deploy"). |

### Deploy guards

Every upload script runs `deploy-guards.sh` first. It refuses to deploy when:

- the checkout is behind `origin/main`;
- there are uncommitted changes outside `dist/` and `.deploy-cache/`;
- the build lacks `dist/privacy/index.html`;
- the build lacks the `/ios-privacy-policy/` redirect in `dist/.htaccess`.

Don't bypass these. They exist because of the incident described below.

## The privacy policy must stay up

`https://chimesapp.com/privacy` is linked from Google Play and the App Store.
Google Play removed the Android app on 2026-09-14 because its privacy URL was
dead. The App Store still uses `/ios-privacy-policy/`, which `.htaccess`
redirects to `/privacy`. See "Privacy policy" in [`README.md`](../README.md).

On 2026-10-07 a deploy from a checkout 5 commits behind `origin/main` ran
`mirror --delete` and removed `/privacy` from the server. The deploy guards
were added to stop that happening again.

## Verifying a deploy

**Cloudflare serves curl a bot challenge (HTTP 403)** on chimesapp.com, so a
plain `curl` proves nothing. `verify-deploy.sh` reports "could not verify" in
that case. Either:

- open the page in a browser; or
- go straight to the origin server, bypassing Cloudflare:

  ```bash
  curl -sL --resolve chimesapp.com:443:50.87.176.132 \
    -o /dev/null -w '%{http_code} %{url_effective}\n' https://chimesapp.com/privacy
  ```

  Expect `200 https://chimesapp.com/privacy/`. (Apache adds the trailing
  slash.)

To list or back up the files on the server:

```bash
source deploy-target.sh
lftp -c "$CHIMES_LFTP_OPEN; cd $CHIMES_REMOTE_ROOT; find -l ."   # list
lftp -c "$CHIMES_LFTP_OPEN; mirror $CHIMES_REMOTE_ROOT ./backup"  # back up
```

## Known quirks

- **Bluehost throttles SSH connections.** After a burst of attempts, especially
  failed logins, the server resets or refuses connections on port 22
  ("Connection reset by peer", "Connection refused") for several minutes.
  Wait; don't retry in a loop, or you may extend the block, which can also
  lock out cPanel.
- **A missing page returns HTTP 500, not 404.** Treat a 500 on a page that
  should exist as "the file is missing".
- **`lftp --exclude-glob` needs a trailing slash to match a directory.**
  `.well-known/` protects the directory; `.well-known` doesn't, and an earlier
  version of the scripts deleted `/.well-known/` (used for SSL certificate
  validation) on every deploy.
- **`/.well-known/` was missing from the server as of 2026-10-08.** cPanel's
  AutoSSL normally recreates it at certificate renewal.
- **`/_astro/` on the server holds old hashed CSS files, plus a stray copy of
  the site** left by an old script bug. Deploys never delete from `/_astro/`
  on purpose, so browsers with cached HTML keep their CSS. The stray copy is
  harmless.
- **`public_html/chimesapp.old` and `chimesapp.old2`** on the server are earlier
  versions of the site. They may hold the WordPress-era privacy policy.
- **The rest of `public_html/`** is the primary domain, just-iot.com (a
  WordPress install). Deploys only touch `public_html/chimesapp`.

## Rules for agents

- Deploy only when the owner asks. Deploying changes the live site.
- Never print credentials or private keys, and never paste a URL containing
  them. The SSH key file stays on the owner's machine.
- Don't reintroduce FTP, or any upload path that skips `deploy-guards.sh`.
- Before an unusual deploy, run `DRY_RUN=1 ./sync-smart.sh` and read every
  `rm` line.
