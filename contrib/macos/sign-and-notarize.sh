#!/bin/bash
#
# Sign (Developer ID + hardened runtime), notarize, and staple PulseView.app,
# then produce a distributable zip for GitHub Releases.
#
# Usage:
#   IDENTITY="Developer ID Application: NjiaPay Group B.V (XS6R3WDUYY)" \
#   NOTARY_PROFILE="pv-notary" \
#   ./contrib/macos/sign-and-notarize.sh [PulseView.app]
#
set -euo pipefail

APP="${1:-PulseView.app}"
IDENTITY="${IDENTITY:?set IDENTITY to your 'Developer ID Application: ... (TEAMID)' string}"
NOTARY_PROFILE="${NOTARY_PROFILE:-pv-notary}"   # created via: xcrun notarytool store-credentials
OUT="${OUT:-${APP%.app}-arm64.zip}"

[ -d "$APP" ] || { echo "no such app: $APP"; exit 1; }

echo ">> signing nested code inside-out (hardened runtime)"
find "$APP/Contents/Frameworks" "$APP/Contents/PlugIns" -type f \( -name '*.dylib' -o -name '*.so' \) \
  -exec codesign --force --options runtime --timestamp -s "$IDENTITY" {} \;
find "$APP/Contents/Frameworks" -maxdepth 1 -name '*.framework' \
  -exec codesign --force --options runtime --timestamp -s "$IDENTITY" {} \;
codesign --force --options runtime --timestamp -s "$IDENTITY" "$APP/Contents/MacOS/pulseview.bin"
codesign --force --options runtime --timestamp -s "$IDENTITY" "$APP/Contents/MacOS/pulseview"

echo ">> signing the app bundle"
codesign --force --options runtime --timestamp -s "$IDENTITY" "$APP"

echo ">> verifying signature"
codesign --verify --deep --strict --verbose=2 "$APP"

echo ">> submitting for notarization (this can take a few minutes)"
NZIP="$(mktemp -d)/notarize.zip"
ditto -c -k --keepParent "$APP" "$NZIP"
xcrun notarytool submit "$NZIP" --keychain-profile "$NOTARY_PROFILE" --wait

echo ">> stapling ticket into the app"
xcrun stapler staple "$APP"
xcrun stapler validate "$APP"
spctl -a -t exec -vv "$APP" || true   # expect: accepted, source=Notarized Developer ID

echo ">> building distributable: $OUT"
rm -f "$OUT"
ditto -c -k --keepParent "$APP" "$OUT"
echo ">> done. Upload $OUT to GitHub Releases."
