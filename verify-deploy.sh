#!/bin/bash

set -euo pipefail

SITE_URL="${SITE_URL:-https://chimesapp.com}"

# The privacy policy is linked from Google Play and the App Store, and Play
# removes the app if it stops loading. Check it first, because Cloudflare often
# serves curl a bot challenge (403) that stops the later checks.
UNVERIFIED=0

check_policy_url() {
    local label="$1" url="$2" expect_path="$3"
    local out result code final

    out=$(curl -sL --max-time 20 -D - -o /dev/null -w '\n__RESULT__ %{http_code} %{url_effective}' "$url" 2>/dev/null || true)
    result=$(echo "$out" | grep '^__RESULT__' | tail -1)
    code=$(echo "$result" | awk '{print $2}')
    final=$(echo "$result" | awk '{print $3}')

    if echo "$out" | grep -qi '^cf-mitigated: *challenge'; then
        echo "⚠️  Could not verify $label: Cloudflare served curl a bot challenge (HTTP $code)."
        echo "   Open $url in a browser and confirm it shows the privacy policy."
        UNVERIFIED=1
        return 0
    fi

    if [ -z "$code" ] || [ "$code" = "000" ]; then
        echo "⚠️  Could not verify $label: no response from $url."
        echo "   Open $url in a browser and confirm it shows the privacy policy."
        UNVERIFIED=1
        return 0
    fi

    if [ "$code" = "200" ] && [ "${final%/}" = "$SITE_URL$expect_path" ]; then
        echo "✅ $label loads ($url -> $final)"
    else
        echo "❌ $label failed: HTTP $code at $final (expected 200 at $SITE_URL$expect_path)"
        echo "   Google Play and the App Store link here. Restore it before anything else."
        exit 1
    fi
}

echo "🔎 Verifying privacy policy URLs on $SITE_URL"
check_policy_url "Privacy policy" "$SITE_URL/privacy" "/privacy"
check_policy_url "Old App Store privacy URL" "$SITE_URL/ios-privacy-policy/" "/privacy"

if [ "$UNVERIFIED" -eq 1 ]; then
    echo "⚠️  Privacy policy URLs NOT verified. Check both in a browser before relying on this deploy."
fi

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