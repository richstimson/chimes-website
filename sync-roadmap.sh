#!/usr/bin/env bash
# Copy the public roadmap from the app repo into this site.
#
# The list is generated in locapp-23 (docs/features/roadmap-public.json).
# This copies it, one way, to src/data/roadmap-public.json, which
# src/pages/roadmap.astro renders. Never edit the copy: change the source in
# locapp-23, merge it to main, and re-run this. Run it whenever roadmap.yaml changes and at each store release.
#
#   ./sync-roadmap.sh [path-to-locapp-23-checkout]
#
# The checkout defaults to $LOCAPP_REPO, then ~/src/locapp-23-main. It must be
# on main, clean under docs/features, and level with origin/main.
#
# Then: review `git status`, commit, and deploy as usual (docs/deploy.md).

set -euo pipefail

SRC_REPO="${1:-${LOCAPP_REPO:-$HOME/src/locapp-23-main}}"
FILE_REL="docs/features/roadmap-public.json"
DIR_REL="docs/features"
SITE_ROOT="$(cd "$(dirname "$0")" && pwd)"
DEST_DIR="$SITE_ROOT/src/data"
DEST="$DEST_DIR/roadmap-public.json"

die() { echo "sync-roadmap: $*" >&2; exit 1; }

[ -d "$SRC_REPO/.git" ] || [ -f "$SRC_REPO/.git" ] || die "not a git checkout: $SRC_REPO"
SRC="$SRC_REPO/$FILE_REL"
[ -f "$SRC" ] || die "no $FILE_REL in $SRC_REPO"

branch="$(git -C "$SRC_REPO" rev-parse --abbrev-ref HEAD)"
[ "$branch" = "main" ] || die "$SRC_REPO is on '$branch', not main"

[ -z "$(git -C "$SRC_REPO" status --porcelain -- "$DIR_REL")" ] \
  || die "uncommitted changes under $DIR_REL in $SRC_REPO; commit and push them first"

git -C "$SRC_REPO" fetch --quiet origin main || die "could not fetch origin/main in $SRC_REPO"
local_sha="$(git -C "$SRC_REPO" rev-parse HEAD)"
remote_sha="$(git -C "$SRC_REPO" rev-parse origin/main)"
[ "$local_sha" = "$remote_sha" ] \
  || die "$SRC_REPO main ($local_sha) is not level with origin/main ($remote_sha); pull or push first"

# The JSON must parse and carry a non-empty items array.
node -e '
const d = JSON.parse(require("fs").readFileSync(process.argv[1], "utf8"));
if (!Array.isArray(d.items) || d.items.length === 0) process.exit(1);
' "$SRC" || die "$FILE_REL is not valid JSON with a non-empty \"items\" array"

mkdir -p "$DEST_DIR"
PREV="$(mktemp)"
trap 'rm -f "$PREV"' EXIT
if [ -f "$DEST" ]; then cp "$DEST" "$PREV"; else echo '{"items":[]}' > "$PREV"; fi

cp "$SRC" "$DEST"
printf 'Synced from locapp-23 %s (%s)\n' "$local_sha" "$FILE_REL" > "$DEST_DIR/SYNCED-FROM-ROADMAP.txt"

# Entries added/removed/changed versus the previous copy, by id.
node -e '
const fs = require("fs");
const load = (p) => new Map(JSON.parse(fs.readFileSync(p, "utf8")).items.map((f) => [f.id, f]));
const [prev, next] = [load(process.argv[1]), load(process.argv[2])];
let a = 0, r = 0, c = 0;
for (const [id, f] of next) {
  if (!prev.has(id)) { console.log("  added   " + id + "  " + f.title); a++; }
  else if (JSON.stringify(prev.get(id)) !== JSON.stringify(f)) { console.log("  changed " + id + "  " + f.title); c++; }
}
for (const [id, f] of prev) if (!next.has(id)) { console.log("  removed " + id + "  " + f.title); r++; }
console.log("sync-roadmap: " + next.size + " items (" + a + " added, " + r + " removed, " + c + " changed)");
' "$PREV" "$DEST"

echo "sync-roadmap: from ${local_sha:0:8}"
echo "Next: npm run build, check /roadmap/, commit src/data/, deploy (docs/deploy.md)."
