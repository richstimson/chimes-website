#!/bin/bash

# Pre-upload checks shared by every script that pushes dist/ to the live site.
#
# Google Play and the App Store both link to https://chimesapp.com/privacy, and
# Play removes the app if that URL stops loading. A mirror with --delete from a
# checkout that lacks the page deletes it from the server, so refuse to upload
# unless this checkout is current and the build contains the policy.
#
# Usage: source this file, then call `require_deploy_guards || exit 1` before
# connecting to the server.

require_deploy_guards() {
    echo "🛡️  Running deploy guards..."

    if ! git fetch --quiet origin main; then
        echo "❌ Refusing to deploy: git fetch failed, so this checkout cannot be confirmed up to date."
        return 1
    fi

    local behind
    behind=$(git rev-list --count HEAD..origin/main)
    if [ "$behind" -gt 0 ]; then
        echo "❌ Refusing to deploy: this checkout is $behind commit(s) behind origin/main."
        echo "   Deploying it would remove pages that exist only on origin/main, such as /privacy."
        echo "   Run: git pull --rebase"
        return 1
    fi

    local dirty
    dirty=$(git status --porcelain -- ':!.deploy-cache' ':!dist')
    if [ -n "$dirty" ]; then
        echo "❌ Refusing to deploy: uncommitted changes outside .deploy-cache/ and dist/:"
        echo "$dirty" | sed 's/^/     /'
        echo "   Commit or stash them, then rebuild."
        return 1
    fi

    if [ ! -f dist/privacy/index.html ]; then
        echo "❌ Refusing to deploy: dist/privacy/index.html is missing."
        echo "   The privacy policy (src/pages/privacy.astro) must be in every deploy. Run: npm run build"
        return 1
    fi

    if ! grep -qE 'RedirectMatch.*ios-privacy-policy.*/privacy' dist/.htaccess 2>/dev/null; then
        echo "❌ Refusing to deploy: dist/.htaccess lacks the /ios-privacy-policy/ -> /privacy redirect."
        echo "   The App Store listing still uses the old URL. Check public/.htaccess, then run: npm run build"
        return 1
    fi

    echo "✅ Deploy guards passed"
}
