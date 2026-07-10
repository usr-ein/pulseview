# Disclaimer

This repository and the `PulseView.app` package it produces are an
**unofficial, community build** of PulseView for macOS on Apple Silicon.

## No affiliation / no endorsement

- This is **not** an official sigrok project release. It is not produced,
  endorsed, supported, reviewed, or maintained by the sigrok project or its
  contributors. The names "sigrok" and "PulseView" belong to their respective
  owners and are used here only to identify the software.
- Please direct any problems with **this package** to this repository's issue
  tracker — **not** to the upstream sigrok developers.

## No warranty

This software is provided **"AS IS", without warranty of any kind**, express or
implied, including but not limited to the warranties of merchantability,
fitness for a particular purpose, and non-infringement. In no event shall the
maintainer(s) of this repository be liable for any claim, damages, or other
liability arising from, out of, or in connection with the software or its use.
See the GNU General Public License v3 for the full warranty disclaimer.

## Bundled dependencies & security

This build bundles third-party libraries (Qt, Python, OpenSSL, glib, and
others — see [`THIRD-PARTY-LICENSES/`](THIRD-PARTY-LICENSES/)) pinned to the
versions available when it was built. **These versions may become outdated and
contain unpatched security vulnerabilities.** This is a point-in-time snapshot,
not a continuously-maintained, security-updated distribution. Use at your own
risk, and prefer rebuilding from current sources for anything sensitive.

## Licensing

PulseView, libsigrok, and libsigrokdecode are licensed under the **GNU General
Public License v3**. This package as a whole is distributed under the GPLv3.
Corresponding source and all third-party license texts are provided — see
[`README.macOS.md`](README.macOS.md) and [`THIRD-PARTY-LICENSES/`](THIRD-PARTY-LICENSES/).
