# PulseView for macOS (Apple Silicon) — unofficial build

This is an **unofficial, community-built** native **arm64** package of
[PulseView](https://sigrok.org/wiki/PulseView), the sigrok signal-analysis GUI,
for Apple Silicon Macs. It is self-contained: Qt, the libsigrok/libsigrokdecode
stack, an embedded Python runtime, all protocol decoders, and fx2lafw firmware
are bundled inside `PulseView.app`, so no Homebrew or other install is required.

> ⚠️ **Unofficial & unaffiliated.** This build is **not** produced, endorsed,
> supported, or reviewed by the sigrok project. Do not report issues with this
> package to the sigrok developers. It is provided **as-is, with no warranty**
> (see [DISCLAIMER.md](DISCLAIMER.md)).

## Install

1. Download `PulseView-arm64.zip` from the [Releases](../../releases) page.
2. Unzip and drag `PulseView.app` to `/Applications`.
3. Open it. (If macOS blocks it, right-click the app → **Open** → **Open**.)

Requires macOS 11 (Big Sur) or later on an Apple Silicon Mac.

## What's inside

- PulseView `0.5.0-git` (commit `af02198`)
- libsigrok / libsigrokcxx `0.6.0-git`, libsigrokdecode `0.6.0-git`
- Qt `6.11.1`, Python `3.12`
- 131 protocol decoders, fx2lafw firmware `0.1.7`
- Native `arm64` only (no Rosetta / x86_64)

## Corresponding source (GPL compliance)

PulseView, libsigrok and libsigrokdecode are licensed under the **GNU GPL v3**.
The corresponding source is the exact upstream commits this build was made from:

- PulseView — https://github.com/sigrokproject/pulseview commit `af02198`
- libsigrok — https://github.com/sigrokproject/libsigrok (git master, `0.6.0-git`)
- libsigrokdecode — https://github.com/sigrokproject/libsigrokdecode (git master, `0.6.0-git`)
- fx2lafw firmware — https://sigrok.org/wiki/Fx2lafw (`0.1.7`)

Full third-party license texts and versions are in
[`THIRD-PARTY-LICENSES/`](THIRD-PARTY-LICENSES/).

## How it was built

Everything is reproducible via the scripts in
[`contrib/macos/`](contrib/macos/):

```bash
# 1. Build git libsigrok + libsigrokdecode into a prefix (~/dwnl/sigrok-prefix)
# 2. Build PulseView against them (Qt6, native arm64):
PKG_CONFIG_PATH=~/dwnl/sigrok-prefix/lib/pkgconfig:/opt/homebrew/lib/pkgconfig \
  cmake -DCMAKE_BUILD_TYPE=Release . && make -j

# 3. Assemble the self-contained, relocatable .app:
./contrib/macos/make-app-bundle.sh

# 4. (maintainer) Developer-ID sign + notarize + staple:
IDENTITY="Developer ID Application: ... (TEAMID)" NOTARY_PROFILE="pv-notary" \
  ./contrib/macos/sign-and-notarize.sh PulseView.app
```

See the script comments for prerequisites (Homebrew deps, doxygen, etc.).
