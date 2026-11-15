# Sources

Where this tree came from, exactly, and what may be pulled into it later.

## Upstream

| Field | Value |
|-------|-------|
| Project | Dillo |
| Repository | https://github.com/dillo-browser/dillo |
| Website | https://dillo-browser.org/ |
| Commit | `6856c50` (2026-04-19) |
| Version at that commit | 3.3.0-rc1 (master, post-3.3.0) |
| Licence | GPL-3.0-or-later (verified in `src/dilloc.c`: "either version 3 ... or any later version") |
| Size / files | 6.6 MB, 524 tracked files |
| Language | C, plus C++ for the CSS parser (`src/css.cc`, `src/cssparser.cc`) |
| Code lines | ~40,500 (`.c` + `.h`) |

The whole upstream tree is present at the commit above. This is a vendored fork,
not a GitHub network fork: there is no fork badge, because the GitHub App used to
build this repo cannot create forks. Upstream is tracked as a git remote instead,
which is more useful anyway.

## How to sync upstream

```sh
./tools/sync-upstream.sh            # fetch and show what changed
./tools/sync-upstream.sh --merge    # merge upstream/master into the current branch
```

The script adds `upstream` as a read-only remote the first time it runs. Merging
upstream is expected to be boring: local changes live in new files where possible,
and in `PATCHES.md`-documented hunks where not.

## Upstream layout, and what each part is for

| Path | What it is | Will Sorex change it? |
|------|------------|-----------------------|
| `src/` | UI, browser window, cache, cookies, actions, `dilloc.c` control client | yes, heavily |
| `lout/` | layout engine | yes, for the layout budget |
| `dw/` | FLTK widget layer (tabs, status bar, dialogs) | yes, for vertical tabs |
| `dlib/` | small utility library (lists, strings, dstrings) | no, keep stable |
| `dpi/` | protocol plugins (http, https, ftp, file, data) | yes, for HTTP/2 and cache |
| `dpid/` | plugin daemon, the process that owns the network | yes, for connection reuse |
| `dpip/` | the wire protocol between browser and dpid | yes, additively |
| `doc/` | user documentation | yes, ours goes in `docs/` |
| `test/` | upstream test scripts | yes, extended |

## Dependencies

| Dependency | Needed for | Notes |
|------------|-----------|-------|
| FLTK 1.3 (or 1.4 with `--enable-experimental-fltk`) | the GUI | the reason the binary is small |
| zlib, libpng, libjpeg, libwebp | images and compression | brotli optional since 3.3.0 |
| OpenSSL, LibreSSL or mbedTLS | TLS | pick exactly one; three backends is three attack surfaces |
| POSIX threads, sockets | everything | no other runtime |

## Licences of things we may vendor

- **MIT, from the NetSurf project:** `libcss`, `libdom`, `libhubbub`,
  `libparserutils`, `libwapcaplet`, `libnsgif`, `libnsbmp`, `libsvgtiny`. These may
  be vendored into this GPL-3.0 tree without any licence interaction. See
  `FAMILY.md` for why this matters to the whole family.
- **Not permitted:** anything from Nodus or Volumen. Both are GPL-2.0-only, and
  GPL-2.0-only code cannot be combined with GPL-3.0-or-later. Ideas, specs and
  data may cross; source lines may not.

## Ideas taken from elsewhere

Ideas are not copyrightable and this section records where the good ones came
from, so that credit is not lost:

- The control-socket approach to automation: upstream Dillo 3.3 (`dilloc`).
- The "hand off what you cannot render" ladder: the Aetheris family contract.
- Content-addressed caching: Nodus (see `FAMILY.md`), reimplemented here.
- The Lite Rendering Profile and its corpus: `shared/vinculum/lite-profile.md`.
