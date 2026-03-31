#!/bin/bash

set -euo pipefail

SITE_URL="${SITE_URL:-https://chimesapp.com}"

if [ ! -d "dist/_astro" ]; then
  echo "❌ dist/_astro not found"
  echo "Run npm run build before verifying deployment"
  exit 1
fi

echo "🔎 Verifying deployment for $SITE_URL"

HTML_HEADERS=$(curl -fsSI "$SITE_URL")

echo "$HTML_HEADERS" | grep -qi '^cache-control: no-cache, max-age=0, must-revalidate' || {
  echo "❌ Homepage HTML is missing the expected no-cache header"
  echo "$HTML_HEADERS"
  exit 1
}

echo "✅ Homepage HTML cache header looks correct"

ASSET_COUNT=0

while IFS= read -r asset_path; do
  [ -n "$asset_path" ] || continue
  ASSET_COUNT=$((ASSET_COUNT + 1))
  asset_url="$SITE_URL/${asset_path#dist/}"

  echo "Checking $asset_url"
  ASSET_HEADERS=$(curl -fsSI "$asset_url") || {
    echo "❌ Asset request failed: $asset_url"
    exit 1
  }

  echo "$ASSET_HEADERS" | grep -qi '^http/.* 200' || {
    echo "❌ Asset did not return 200: $asset_url"
    echo "$ASSET_HEADERS"
    exit 1
  }

  echo "$ASSET_HEADERS" | grep -qi '^cache-control: public, max-age=31536000, immutable' || {
    echo "❌ Asset is missing the expected immutable cache header: $asset_url"
    echo "$ASSET_HEADERS"
    exit 1
  }
done < <(find dist/_astro -maxdepth 1 -type f | sort)

if [ "$ASSET_COUNT" -eq 0 ]; then
  echo "❌ No Astro assets found in dist/_astro"
  exit 1
fi

echo "✅ Verified $ASSET_COUNT Astro asset(s) on production"