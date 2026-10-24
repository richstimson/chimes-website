#!/usr/bin/env bash
# Copy published blog posts from the app repo into this site.
#
# The posts are written in locapp-23 (docs/marketing/blog/posts/<slug>/index.md
# plus images). This copies them, one way, into src/content/blog/. Never edit
# the copy: edit the post in locapp-23, merge it to main, and re-run this.
#
#   ./sync-blog.sh [path-to-locapp-23-checkout]
#
# The checkout defaults to $LOCAPP_REPO, then ~/src/locapp-23-main. It must be
# on main, clean under the blog folder, and level with origin/main.
#
# Only posts with an explicit `draft: false` are copied: this repo is public,
# so drafts stay in locapp-23. HTML comments (<!-- ... -->, used there for
# internal notes such as claim sources) are stripped from the copy.
#
# Then: review `git status`, commit, and deploy as usual (docs/deploy.md).

set -euo pipefail

SRC_REPO="${1:-${LOCAPP_REPO:-$HOME/src/locapp-23-main}}"
POSTS_REL="docs/marketing/blog/posts"
SITE_ROOT="$(cd "$(dirname "$0")" && pwd)"
DEST="$SITE_ROOT/src/content/blog"

die() { echo "sync-blog: $*" >&2; exit 1; }

[ -d "$SRC_REPO/.git" ] || [ -f "$SRC_REPO/.git" ] || die "not a git checkout: $SRC_REPO"
SRC="$SRC_REPO/$POSTS_REL"
[ -d "$SRC" ] || die "no $POSTS_REL in $SRC_REPO"

branch="$(git -C "$SRC_REPO" rev-parse --abbrev-ref HEAD)"
[ "$branch" = "main" ] || die "$SRC_REPO is on '$branch', not main"

[ -z "$(git -C "$SRC_REPO" status --porcelain -- "$POSTS_REL")" ] \
  || die "uncommitted changes under $POSTS_REL in $SRC_REPO; commit and push them first"

git -C "$SRC_REPO" fetch --quiet origin main || die "could not fetch origin/main in $SRC_REPO"
local_sha="$(git -C "$SRC_REPO" rev-parse HEAD)"
remote_sha="$(git -C "$SRC_REPO" rev-parse origin/main)"
[ "$local_sha" = "$remote_sha" ] \
  || die "$SRC_REPO main ($local_sha) is not level with origin/main ($remote_sha); pull or push first"

# Read `draft:` from the frontmatter block only.
draft_value() {
  awk '{sub(/\r$/, "")} NR==1 && $0!="---" {exit} NR>1 && $0=="---" {exit} NR>1 && /^draft:/ {sub(/^draft:[ \t]*/, ""); sub(/[ \t]*#.*$/, ""); print; exit}' "$1"
}

STAGE="$(mktemp -d)"
trap 'rm -rf "$STAGE"' EXIT
chmod 755 "$STAGE"  # rsync -a copies this onto $DEST; mktemp makes it 700

published=0
skipped=0
for post in "$SRC"/*/; do
  slug="$(basename "$post")"
  index="$post/index.md"
  [ -f "$index" ] || { echo "  skip $slug (no index.md)"; skipped=$((skipped + 1)); continue; }
  draft="$(draft_value "$index")"
  if [ "$draft" != "false" ]; then
    echo "  skip $slug (draft: ${draft:-not set})"
    skipped=$((skipped + 1))
    continue
  fi
  # Copy only the post and its images: any other working file in the folder
  # (notes, sources, .psd) would otherwise land in this public repo.
  mkdir -p "$STAGE/$slug"
  cp "$index" "$STAGE/$slug/index.md"
  find "$post" -maxdepth 1 -type f \( -iname '*.png' -o -iname '*.jpg' -o -iname '*.jpeg' \
    -o -iname '*.webp' -o -iname '*.gif' -o -iname '*.avif' -o -iname '*.svg' \) \
    -exec cp {} "$STAGE/$slug/" \;
  # Strip HTML comments, including multi-line ones.
  perl -0pi -e 's/<!--.*?-->\n?//gs' "$STAGE/$slug/index.md"
  # An unclosed comment, or a placeholder left in a published post, stops the sync.
  if grep -n '<!--' "$STAGE/$slug/index.md" >&2; then
    die "$slug: unclosed <!-- comment (line above); fix it in locapp-23"
  fi
  if grep -nE 'TODO|OWNER:' "$STAGE/$slug/index.md" >&2; then
    die "$slug: placeholder text in a post marked draft: false (line above); fix it in locapp-23"
  fi
  echo "  copy $slug"
  published=$((published + 1))
done

printf 'Synced from locapp-23 %s (%s)\n' "$local_sha" "$POSTS_REL" > "$STAGE/SYNCED-FROM.txt"

mkdir -p "$DEST"
rsync -a --delete "$STAGE/" "$DEST/"

echo "sync-blog: $published published, $skipped skipped, from ${local_sha:0:8}"
echo "Next: npm run build, check the pages, commit src/content/blog/, deploy (docs/deploy.md)."
