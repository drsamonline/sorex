# Plan

## Mission

Build the best browser that fits in 30 MB, for people whose machine is the reason
they cannot use the web. Concretely: a GUI browser that renders the text-first web
correctly, never runs JavaScript, is drivable from a shell, and cannot grow past a
memory ceiling the user set.

## Position in the family

Tier 2. Above Volumen because it draws images and applies CSS; below Nodus because
it has one frontend and no JavaScript; below Aetheris because it cannot run an
application. When Sorex meets a page it cannot render, it promotes the URL rather
than growing.

## Users, in priority order

1. **The constrained user.** 1-2 GB RAM, spinning disk, integrated GPU, often on a
   metered or slow link. Everything is optimised for this person.
2. **The reader.** Wants documentation, mailing lists, forums, Wikipedia, blogs.
   Does not want a video site and knows it.
3. **The scripter.** Wants `dilloc` to drive a real renderer from a shell or a cron
   job, with images, without a display server in the loop.
4. **The embedder.** Wants a small renderer inside a kiosk, a dashboard, a
   single-purpose appliance.

## Non-goals

Stated so they can be refused politely, in writing, forever:

- No JavaScript engine. Not Duktape, not QuickJS, not "just for forms".
- No WebExtensions, no DRM, no WebRTC, no WebGL, no service workers.
- No multi-process architecture. One process, one event loop; the `dpid` daemon is
  the only extra process and it exists for network isolation.
- No GPU acceleration. Software blitting to an X or framebuffer surface.
- No Windows or macOS frontend. Linux and the BSDs, plus anything that can run
  FLTK.

## Success criteria for v1.0

| # | Criterion | Measured by |
|---|-----------|-------------|
| 1 | 8 tabs of real pages under 30 MB RSS | `tools/measure.sh --tabs 8` |
| 2 | 100% of `fixtures/` conform at Lite Profile v0 | `tools/check-corpus.sh` |
| 3 | 40 saved real pages: no layout regression versus upstream Dillo 3.3.0 | pixel diff in `tools/check-corpus.sh` |
| 4 | Full control-socket API, documented, with a shell test suite | `tools/test-ipc.sh` |
| 5 | Handoff to Sorex/Nodus/Aetheris works both ways | `tools/test-handoff.sh` |
| 6 | Static musl build under 1.4 MB, runs on a 512 MB machine | release artifact |
| 7 | Hard RSS ceiling honoured under 20 tabs | `tools/measure.sh --ceiling` |
| 8 | Zero crashes on the 4-hour soak test | `tools/soak.sh` |

## Workstreams

Each workstream is independently mergeable and has one owner-shaped sentence.

**W1 - Build and reproducibility.** Autotools stays, but the build becomes boring:
one script, pinned dependencies, static option, cross-compilation to aarch64 and
riscv64, and a CI job that builds all three. Exit: `tools/build.sh --static`
produces a binary that runs on a clean Alpine container.

**W2 - Memory ceiling.** Instrument RSS, add an eviction policy that runs before
allocation failure, expose `memory.max_rss_mb`, and prove it holds under 20 tabs.
Exit: criterion 1 and 7.

**W3 - Control socket as the API.** Promote `dilloc` from a convenience to the
supported automation surface: open, close, list tabs, get text, get a PNG, set
zoom, navigate history. Document it as a protocol. Exit: criterion 4.

**W4 - Tabs and keyboard.** Vertical tabs in `dw/`, tab suspension (serialise a tab
to the cache and drop its widget tree), a command palette over the existing
actions, and the shared Vinculum keymap. Exit: 8 tabs in 30 MB is only possible
with suspension, so this unblocks criterion 1.

**W5 - Network.** Connection reuse in `dpid`, HTTP/2 via a minimal client, brotli,
TLS session resumption, and a strict TLS policy with no downgrade path. Exit: a
page with 60 subresources issues fewer than 10 connections.

**W6 - Layout budget.** A per-frame layout time budget with a text-first paint: if
layout exceeds the budget, paint text and defer images to the next idle slice.
Exit: criterion on first text paint.

**W7 - Privacy and security.** RAM-only cookies by default, no referrer, no
history unless asked, `display:none` respected for tracking pixels, a per-site
script-block log so the user can see what a page wanted to run, and a hardened
build (fortify, stack protector, seccomp around image decoders if it proves
cheap). Exit: threat model written in `docs/adr/`.

**W8 - Packaging.** A release artifact per target, a `sorex` package for Alpine and
Debian, and a one-page "install on a 2008 laptop" guide.

## Milestones

| Milestone | Contains | Gate |
|-----------|----------|------|
| v0.1 scaffold | upstream imported, builds, docs, tools, shared specs | `tools/build.sh` green |
| v0.2 measured | RSS and paint instrumentation, baseline numbers published | numbers in `PERFORMANCE.md` |
| v0.3 scriptable | full control-socket API + tests | criterion 4 |
| v0.4 bounded | eviction policy + tab suspension | criteria 1, 7 |
| v0.5 fast | layout budget, network reuse | criterion 3 no regressions |
| v0.6 family | handoff both directions | criterion 5 |
| v1.0 release | static builds, packaging, soak clean | all criteria |

## Risks

| Risk | Likelihood | Response |
|------|-----------|----------|
| Upstream goes quiet again (it was dormant 2017-2023) | medium | the tree is vendored; we are the maintainer now, and `SOURCES.md` keeps the lineage honest |
| FLTK blocks vertical tabs or a modern look | medium | fall back to a tab strip in `dw/` drawn by ourselves; FLTK is only a surface and an event loop |
| Users demand JavaScript | certain | that is the handoff ladder's job, and saying no is the product |
| Memory work fights the cache hit rate | medium | measure both; the ceiling is a hard limit, the cache is best-effort |
| GPL-3.0 discourages embedders | low | noted; the alternative is a licence that contradicts the upstream we build on |
