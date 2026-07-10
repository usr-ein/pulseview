# Third-Party Licenses

`PulseView.app` (macOS, Apple Silicon) is a self-contained bundle that
redistributes the following third-party components. Each subdirectory here
contains the corresponding license text / copyright notice.

This build is licensed as a whole under the **GNU GPL v3** (PulseView itself),
with bundled dependencies under their respective licenses listed below.

## Core (sigrok project) — GPL

| Component | Version | License | Source |
|---|---|---|---|
| PulseView | 0.5.0-git (commit af02198) | GPL-3.0-or-later | https://sigrok.org/wiki/PulseView |
| libsigrok / libsigrokcxx | 0.6.0-git | GPL-3.0-or-later | https://sigrok.org/wiki/Libsigrok |
| libsigrokdecode + decoders | 0.6.0-git | GPL-3.0-or-later | https://sigrok.org/wiki/Libsigrokdecode |
| sigrok-firmware-fx2lafw | 0.1.7 | GPL-2.0-or-later | https://sigrok.org/wiki/Fx2lafw |

## GUI toolkit & language runtime

| Component | Version | License | Source |
|---|---|---|---|
| Qt | 6.11.1 | LGPL-3.0-only (+BSD/GFDL/GPL-exc) | https://www.qt.io/ |
| Python | 3.12.13 | Python-2.0 (PSF) | https://www.python.org/ |

## Libraries (Homebrew)

| Component | Version | License | Source |
|---|---|---|---|
| boost | 1.90.0 | BSL-1.0 | https://www.boost.org/ |
| brotli | 1.2.0 | MIT | https://github.com/google/brotli |
| openssl@3 | 3.6.3 | Apache-2.0 | https://www.openssl.org/ |
| dbus | 1.16.2 | AFL-2.1 OR GPL-2.0-or-later | https://www.freedesktop.org/wiki/Software/dbus/ |
| double-conversion | 3.4.0 | BSD-3-Clause | https://github.com/google/double-conversion |
| freetype | 2.14.3 | FTL | https://freetype.org/ |
| libftdi | 1.5 | LGPL-2.1-only | https://www.intra2net.com/en/developer/libftdi/ |
| glib | 2.88.0 | LGPL-2.1-or-later | https://gitlab.gnome.org/GNOME/glib |
| glibmm | 2.66.9 | LGPL-2.1-or-later | https://gitlab.gnome.org/GNOME/glibmm |
| graphite2 | 1.3.15 | MIT OR MPL-2.0 OR LGPL-2.1+ | https://github.com/silnrsi/graphite |
| harfbuzz | 14.2.1 | MIT | https://harfbuzz.github.io/ |
| hidapi | 0.15.0 | BSD-3-Clause (or GPL-3.0 / HIDAPI) | https://github.com/libusb/hidapi |
| icu4c | 78.3 | Unicode-3.0 | https://icu.unicode.org/ |
| gettext (libintl) | latest | LGPL-2.1-or-later | https://www.gnu.org/software/gettext/ |
| jasper | 4.2.9 | JasPer-2.0 | https://github.com/jasper-software/jasper |
| jpeg-turbo | 3.1.4 | IJG AND Zlib AND BSD-3-Clause | https://libjpeg-turbo.org/ |
| little-cms2 | 2.19 | MIT | https://www.littlecms.com/ |
| xz (liblzma) | 5.8.3 | 0BSD | https://tukaani.org/xz/ |
| md4c | 0.5.2 | MIT | https://github.com/mity/md4c |
| libmng | 2.0.3 | Zlib | https://www.libmng.com/ |
| mpdecimal | 4.0.1 | BSD-2-Clause | https://www.bytereef.org/mpdecimal/ |
| nettle | 4.0 | LGPL-3.0-or-later (or GPL-2.0) | https://www.lysator.liu.se/~nisse/nettle/ |
| pcre2 | 10.47 | BSD-3-Clause | https://www.pcre.org/ |
| libpng | 1.6.58 | libpng-2.0 | http://www.libpng.org/ |
| libserialport | 0.1.2 | LGPL-3.0-or-later | https://sigrok.org/wiki/Libserialport |
| webp | 1.6.0 | BSD-3-Clause | https://developers.google.com/speed/webp |
| libsigc++ | 2.12.2 | LGPL-2.1-or-later | https://libsigcplusplus.github.io/libsigcplusplus/ |
| sqlite | 3.53.3 | Public Domain (blessing) | https://www.sqlite.org/ |
| libtiff | 4.7.1 | libtiff (BSD-like) | http://www.libtiff.org/ |
| libusb | 1.0.30 | LGPL-2.1-or-later | https://libusb.info/ |
| libzip | 1.11.4 | BSD-3-Clause | https://libzip.org/ |
| zstd | 1.5.7 | BSD-3-Clause AND ... | https://facebook.github.io/zstd/ |
| libb2 | 0.98.1 | CC0-1.0 | https://github.com/BLAKE2/libb2 |

## Notes on copyleft compliance

- **GPL (PulseView, libsigrok*, fx2lafw):** corresponding source is the exact
  commits listed above. See the repository README for source links.
- **LGPL (Qt, glib, glibmm, libsigc++, libusb, libftdi, libserialport,
  nettle):** these are linked **dynamically** as separate `.dylib`/`.framework`
  files under `Contents/Frameworks/`, and can be replaced/relinked by the user.
