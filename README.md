# Sorex

**sorex, sorecis** *(m.) - shrew.* The smallest mammal with a real bite: a
metabolism fast enough to starve overnight, eyesight poor enough to work in the
dark. That is the brief.

Sorex is a featherweight graphical web browser for machines the modern web forgot
- 2 GB netbooks, Pentium M ThinkPads, Raspberry Pis with 512 MB, VMs on a
metered connection. It is a fork of [Dillo](https://dillo-browser.org/) at commit
`6856c50`, hardened for speed, made scriptable, and given the parts a browser needs
in 2026 without giving it a JavaScript engine.

Part of the [Aetheris browser family](FAMILY.md) - tier 2, the everyday GUI.

```
T0 Aetheris   full fidelity, 200 MB+
T1 Nodus      shared core, 25-70 MB
T2 Sorex      THIS REPO, 15-30 MB
T3 Volumen    text only, 5-8 MB
```

## What Sorex is

- A **no-JavaScript browser, by policy and by architecture.** Not a setting that
  can be flipped; there is no engine to flip. Pages that need script are handed to
  a higher tier (see `shared/vinculum/handoff-protocol.md`) instead of failing
  quietly.
- A **scriptable browser.** Dillo 3.3 grew a UNIX control socket and `dilloc`; this
  fork makes that the primary automation surface, so the browser can be driven
  from a shell the way a text browser can.
- A **memory-bounded browser.** The resident set has a ceiling that is enforced by
  evicting image and page caches before the allocator fails, and the ceiling is
  configurable in one shared config file.
- A **reproducibly built browser.** Static musl builds, cross-compiled to aarch64
  and riscv64, one binary, no runtime surprises.

## What Sorex is not

- Not a Chromium replacement and never will be. If you need a web app, use tier 0.
- Not a Dillo patch set. This tree diverges; `PATCHES.md` records every change made
  to vendored upstream code and why.
- Not finished. See `ROADMAP.md`; the tree is at v0.1, which means "imports and
  builds, nothing improved yet".

## Build

```sh
./tools/build.sh            # configure + make, native, tuned
./tools/build.sh --static   # static musl build, if musl-gcc is present
./tools/build.sh --debug    # -O0 -g3, assertions on, for gdb
```

The upstream build needs FLTK, zlib, libpng, libjpeg, libwebp and one TLS library
(OpenSSL, LibreSSL or mbedTLS). `./configure --help` in the tree is authoritative;
`tools/build.sh` passes flags and tells you what is missing.

## Run

```sh
./src/dillo https://example.org
./src/dillo --help
./src/dilloc status            # talk to a running instance over the control socket
```

## Budget

These numbers are the contract with the user, and they are measured, not asserted.
`tools/measure.sh` is how.

| Metric | Target | Where it is enforced |
|--------|--------|----------------------|
| Resident set, 1 tab | <= 18 MB | `memory.max_rss_mb` |
| Resident set, 8 tabs | <= 30 MB | cache eviction policy |
| First text paint, local fixture | <= 120 ms | layout budget per frame |
| Stripped static binary | <= 1.4 MB | build flags, no NLS |
| Clean build | <= 90 s on 2 cores | no C++ in hot paths beyond the CSS parser |

## Documentation

| File | Read it when |
|------|--------------|
| [FAMILY.md](FAMILY.md) | you want to know how the four browsers relate, and what may legally be shared |
| [SOURCES.md](SOURCES.md) | you need to know exactly which upstream this came from |
| [PLAN.md](PLAN.md) | you want scope, workstreams, success criteria |
| [DESIGN.md](DESIGN.md) | you are changing code and need the module map |
| [INNOVATIONS.md](INNOVATIONS.md) | you want the enhancement backlog with measurements attached |
| [ROADMAP.md](ROADMAP.md) | you want the release sequence and exit criteria |
| [START_PROMPT.md](START_PROMPT.md) | you are an AI agent or a new contributor starting work |
| [AGENTS.md](AGENTS.md) | you are an agent and need the working rules only |
| [PATCHES.md](PATCHES.md) | you are touching vendored upstream code |

## Provenance and licence

Derived from Dillo `6856c50` (2026-04-19), version 3.3.0-rc1 (master, post-3.3.0),
`dillo-browser/dillo`, which is GPL-3.0-or-later. Sorex is therefore
**GPL-3.0-or-later**; see `COPYING`. The upstream copyright holders are named in
each source file and in `AUTHORS`; this fork adds no relicensing claim and does not
pretend the engine is its own work.

Shared specs in `shared/vinculum/` are CC0-1.0 and may be used by anyone.

Author: Dr Sohil Momin.
