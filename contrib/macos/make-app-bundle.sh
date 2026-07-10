#!/bin/bash
#
# Build a self-contained, relocatable PulseView.app for macOS (Apple Silicon).
#
# Bundles Qt (via macdeployqt), the libsigrok/glib/boost dylib graph, an
# embedded Python 3.12 runtime, and the protocol decoders. A tiny launcher
# stub redirects SIGROKDECODE_DIR / SIGROK_FIRMWARE_DIR / PYTHONHOME into the
# bundle so it runs from anywhere. Produces an ad-hoc signed .app; sign with a
# Developer ID + notarize separately for distribution (see README).
#
# Prereqs: a built ./pulseview binary, and libsigrok + libsigrokdecode (git)
# installed into $SIGROK_PREFIX. Homebrew deps: qt, python@3.12, glibmm, boost,
# libusb, libftdi, libserialport, libzip, etc.
#
set -euo pipefail

PVDIR="${PVDIR:-$(pwd)}"                                   # pulseview source/build dir (has ./pulseview)
SIGROK_PREFIX="${SIGROK_PREFIX:-$HOME/dwnl/sigrok-prefix}" # where git libsigrok(decode) is installed
BREW="${BREW:-/opt/homebrew}"
QT_PREFIX="${QT_PREFIX:-$BREW/opt/qt}"
PYVER="${PYVER:-3.12}"
PYFW="${PYFW:-$BREW/opt/python@$PYVER/Frameworks/Python.framework}"
APP="${APP:-$PVDIR/PulseView.app}"

C="$APP/Contents"; FW="$C/Frameworks"; RES="$C/Resources"; MAC="$C/MacOS"
echo ">> building $APP"
rm -rf "$APP"; mkdir -p "$MAC" "$FW" "$RES" "$C/PlugIns"

cp "$PVDIR/pulseview" "$MAC/pulseview"

# ---- icon ----
ISET="$(mktemp -d)/pulseview.iconset"; mkdir -p "$ISET"
for s in 16 32 64 128 256 512; do
  sips -z $s $s "$PVDIR/icons/pulseview.png" --out "$ISET/icon_${s}x${s}.png" >/dev/null
  d=$((s*2)); sips -z $d $d "$PVDIR/icons/pulseview.png" --out "$ISET/icon_${s}x${s}@2x.png" >/dev/null
done
iconutil -c icns "$ISET" -o "$RES/pulseview.icns"

# ---- Info.plist ----
cat > "$C/Info.plist" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0"><dict>
	<key>CFBundleName</key><string>PulseView</string>
	<key>CFBundleDisplayName</key><string>PulseView</string>
	<key>CFBundleExecutable</key><string>pulseview</string>
	<key>CFBundleIdentifier</key><string>org.sigrok.PulseView</string>
	<key>CFBundleVersion</key><string>0.5.0</string>
	<key>CFBundleShortVersionString</key><string>0.5.0-git</string>
	<key>CFBundlePackageType</key><string>APPL</string>
	<key>CFBundleIconFile</key><string>pulseview.icns</string>
	<key>NSHighResolutionCapable</key><true/>
	<key>NSPrincipalClass</key><string>NSApplication</string>
	<key>LSMinimumSystemVersion</key><string>11.0</string>
	<key>NSHumanReadableCopyright</key><string>GNU GPL v3+</string>
</dict></plist>
PLIST

# ---- Qt ----
"$QT_PREFIX/bin/macdeployqt" "$APP" -verbose=1 || true   # errors on python/optional plugins are expected
rm -rf "$C/PlugIns/platforminputcontexts" "$FW/QtVirtualKeyboard"*.framework "$FW/QtPdf"*.framework

# ---- embedded Python framework + stdlib ----
PYDST="$FW/Python.framework/Versions/$PYVER"
mkdir -p "$PYDST/Resources"
cp "$PYFW/Versions/$PYVER/Python" "$PYDST/Python"; chmod u+w "$PYDST/Python"
cp "$PYFW/Versions/$PYVER/Resources/Info.plist" "$PYDST/Resources/Info.plist" 2>/dev/null || true
rsync -a --exclude test --exclude tests --exclude __pycache__ --exclude site-packages \
  --exclude 'config-*' --exclude idlelib --exclude turtledemo --exclude tkinter \
  "$PYFW/Versions/$PYVER/lib/python$PYVER/" "$PYDST/lib/python$PYVER/"
ln -sfn "$PYVER" "$FW/Python.framework/Versions/Current"
ln -sfn Versions/Current/Python "$FW/Python.framework/Python"
ln -sfn Versions/Current/Resources "$FW/Python.framework/Resources"
install_name_tool -id "@rpath/Python.framework/Versions/$PYVER/Python" "$PYDST/Python"
install_name_tool -change \
  "$PYFW/Versions/$PYVER/Python" "@rpath/Python.framework/Versions/$PYVER/Python" \
  "$FW/libsigrokdecode.4.dylib" 2>/dev/null || true

# ---- pull in any remaining absolute (non-system) deps, rewrite to @rpath ----
RE="^($BREW|$SIGROK_PREFIX|/usr/local)"
for pass in 1 2 3 4 5 6; do changed=0
  while IFS= read -r f; do
    file "$f" | grep -q Mach-O || continue
    while IFS= read -r dep; do
      [ -z "$dep" ] && continue
      case "$dep" in *Python.framework*) continue;; esac
      b=$(basename "$dep")
      if [ ! -f "$FW/$b" ]; then
        s=$(readlink -f "$dep" 2>/dev/null || echo "$dep"); [ -f "$s" ] || continue
        cp -f "$s" "$FW/$b"; chmod u+w "$FW/$b"; install_name_tool -id "@rpath/$b" "$FW/$b"; changed=1
      fi
      install_name_tool -change "$dep" "@rpath/$b" "$f" 2>/dev/null && changed=1 || true
    done < <(otool -L "$f" | tail -n +2 | awk '{print $1}' | grep -E "$RE" || true)
  done < <(find "$C" -type f \( -name '*.dylib' -o -name '*.so' -o -perm -u+x \))
  [ "$changed" -eq 0 ] && break
done

# ---- normalise rpaths: every Mach-O searches only the bundle ----
while IFS= read -r f; do
  file "$f" | grep -q Mach-O || continue
  has=0
  while IFS= read -r r; do
    [ -z "$r" ] && continue
    case "$r" in
      @executable_path/../Frameworks) has=1;;
      "$BREW"*|"$SIGROK_PREFIX"*|/usr/local*|@loader_path*) install_name_tool -delete_rpath "$r" "$f" 2>/dev/null || true;;
    esac
  done < <(otool -l "$f" | awk '/LC_RPATH/{getline;getline;print $2}')
  [ "$has" -eq 0 ] && install_name_tool -add_rpath "@executable_path/../Frameworks" "$f" 2>/dev/null || true
done < <(find "$C" -type f \( -name '*.dylib' -o -name '*.so' -o -perm -u+x \))

# ---- decoders + firmware ----
mkdir -p "$RES/share/libsigrokdecode" "$RES/share/sigrok-firmware"
rsync -a --exclude __pycache__ "$SIGROK_PREFIX/share/libsigrokdecode/decoders" "$RES/share/libsigrokdecode/"
# fx2lafw firmware (fx2-based logic analyzers/scopes). Prefer prefix copy; else fetch release.
if ls "$SIGROK_PREFIX/share/sigrok-firmware/"*.fw >/dev/null 2>&1; then
  cp "$SIGROK_PREFIX/share/sigrok-firmware/"*.fw "$RES/share/sigrok-firmware/"
else
  FWVER="${FWVER:-0.1.7}"; TMP="$(mktemp -d)"
  curl -fsSL "https://sigrok.org/download/binary/sigrok-firmware-fx2lafw/sigrok-firmware-fx2lafw-bin-$FWVER.tar.gz" \
    | tar xz -C "$TMP" --strip-components=1 && cp "$TMP"/*.fw "$RES/share/sigrok-firmware/"
fi

# ---- relocatable launcher stub ----
cat > "$MAC/../../launcher.c" <<'C'
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <limits.h>
#include <unistd.h>
#include <libgen.h>
#include <mach-o/dyld.h>
int main(int argc, char **argv){
	char ep[PATH_MAX], real[PATH_MAX], buf[PATH_MAX], macos[PATH_MAX], contents[PATH_MAX], croot[PATH_MAX];
	uint32_t sz=sizeof(ep);
	if(_NSGetExecutablePath(ep,&sz)!=0) return 127;
	if(!realpath(ep,real)) return 127;
	strncpy(macos,real,sizeof(macos)-1); macos[sizeof(macos)-1]=0;
	char *md=dirname(macos);
	snprintf(contents,sizeof(contents),"%s/..",md);
	if(!realpath(contents,croot)) return 127;
	snprintf(buf,sizeof(buf),"%s/Resources/share/libsigrokdecode/decoders",croot); setenv("SIGROKDECODE_DIR",buf,1);
	snprintf(buf,sizeof(buf),"%s/Resources/share/sigrok-firmware",croot); setenv("SIGROK_FIRMWARE_DIR",buf,1);
	snprintf(buf,sizeof(buf),"%s/Frameworks/Python.framework/Versions/3.12",croot); setenv("PYTHONHOME",buf,1);
	snprintf(buf,sizeof(buf),"%s/pulseview.bin",md); argv[0]=buf;
	execv(buf,argv); perror("execv"); return 127;
}
C
clang -arch arm64 -O2 -o "$C/launcher.tmp" "$C/../launcher.c"; rm -f "$C/../launcher.c"
mv "$MAC/pulseview" "$MAC/pulseview.bin"
mv "$C/launcher.tmp" "$MAC/pulseview"; chmod +x "$MAC/pulseview"

# ---- ad-hoc sign (replace '-' with your Developer ID for distribution) ----
IDENTITY="${IDENTITY:--}"
find "$FW" "$C/PlugIns" -type f \( -name '*.dylib' -o -name '*.so' \) | while read f; do codesign --force -s "$IDENTITY" -o runtime "$f" 2>/dev/null || codesign --force -s "$IDENTITY" "$f"; done
find "$FW" -maxdepth 1 -name '*.framework' | while read w; do codesign --force -s "$IDENTITY" "$w"; done
codesign --force -s "$IDENTITY" "$MAC/pulseview.bin"
codesign --force -s "$IDENTITY" "$MAC/pulseview"
codesign --force --deep -s "$IDENTITY" "$APP"
echo ">> done: $APP"
