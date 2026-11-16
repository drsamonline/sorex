# Innovations

Twelve enhancements, each with the reason it is worth doing, where it lands, and
how it will be measured. Ordered by value per unit of risk, not by glamour.

Nothing here is speculative engineering for its own sake: each item exists because
a real page or a real machine failed without it.

---

## I1 - An enforced memory ceiling

**Why.** A 30 MB browser that dies at 34 MB is a toy. A 30 MB browser that evicts
and tells you why is a tool. Dillo's caches grow with the tab count and nothing
stops them.

**What.** `memory.max_rss_mb` in the shared config; cache and image cache budgeted
as fractions of it; an eviction pass that runs before any allocation above a
threshold; and a user-visible status line when eviction happens.

**Where.** `src/cache.c`, `src/bw.c`, `src/prefs.c`.

**Measured by.** `tools/measure.sh --ceiling --tabs 20`: RSS must stay under the
configured value, and the process must not be killed.

**Risk.** Low. The interesting part is policy, not plumbing.

---

## I2 - Tab suspension

**Why.** Eight tabs of real pages will not fit in 30 MB unless idle tabs give their
memory back. This is the single biggest win available and it unblocks criterion 1.

**What.** An idle tab serialises its box tree and scroll position to the cache,
drops its widget tree, and rebuilds on focus. Because there is no JavaScript, a
suspended tab is genuinely inert: no timers, no state to lose beyond the DOM the
server sent.

**Where.** `src/bw.c`, `src/cache.c`, `dw/`.

**Measured by.** RSS with 8 tabs, all visited, 7 idle; and time-to-focus for a
suspended tab (target under 150 ms).

**Risk.** Medium. Widget-tree teardown is where crashes hide; it needs the soak
test.

---

## I3 - The control socket as a supported API

**Why.** A browser you can script is a browser you can put in a cron job, a test
harness, a kiosk, or a research pipeline. Upstream's `dilloc` is a good start and
is currently under-documented.

**What.** A documented request/response protocol over the existing UNIX socket:
`open`, `close`, `list`, `text`, `png`, `zoom`, `history`, `find`, `handoff`.
Line-delimited JSON in, JSON out. A shell test suite that needs no display.

**Where.** `src/dilloc.c`, `src/actions.c`, `src/uicmd.cc`.

**Measured by.** `tools/test-ipc.sh` covering every verb, plus a published protocol
document in `docs/IPC.md`.

**Risk.** Low, and it composes with the family's handoff protocol.

---

## I4 - Text-first paint with a layout budget

**Why.** On a slow machine the perceived speed of a page is when text appears, not
when the last image is decoded. Dillo streams, which helps, but layout and image
work still compete for the same frame.

**What.** Split layout into structure and decoration. Paint the text of the first
screen as soon as the box tree for that region exists; defer images and complex
backgrounds to an idle slice with a per-frame budget (default 8 ms).

**Where.** `lout/`, `dw/`.

**Measured by.** First-text-paint time on the fixture corpus, target 120 ms
locally; and no increase in total layout time.

**Risk.** Medium. Two-phase layout invites stale-state bugs; fixtures with
late-arriving images are the test.

---

## I5 - Connection reuse in the daemon

**Why.** A page with 60 subresources opens a connection per resource today. On a
high-latency link that is the entire load time.

**What.** A keep-alive pool in `dpid` keyed by host, port and TLS session, with
HTTP/1.1 pipelining off and parallel connections capped per host.

**Where.** `dpid/`, `dpi/http.c`.

**Measured by.** Connection count for the saved-page corpus, target under 10 per
page; and wall time to load over a 200 ms RTT link.

**Risk.** Low. Well-trodden ground.

---

## I6 - HTTP/2, behind a flag

**Why.** Most of the web now prefers HTTP/2, and its header compression is worth
more on a slow link than pipelining ever was. But it is a real protocol with a real
state machine.

**What.** A minimal HTTP/2 client (HPACK plus the framing layer, no push, no
priority tree) vendored or linked from nghttp2, enabled per-site once it proves
stable.

**Where.** `dpi/`, new module `dpi/h2/`.

**Measured by.** Byte count and time on the saved-page corpus over a simulated
slow link; must be a win on 80% of pages or it stays off by default.

**Risk.** Medium-high. This is the most ambitious item here and it is deliberately
late in the roadmap.

---

## I7 - Site shims as data, not code

**Why.** Some sites are unreadable without JavaScript, but many are merely ugly
without it: a sticky header covering the text, a paywall overlay, a consent dialog
that will never load. Those can be fixed with CSS.

**What.** A user-editable rules file: URL pattern, plus CSS injected into the page,
plus optional element removal. No conditions, no expressions, no scripting. Shipped
as a small default set covering the worst offenders, with an audit trail.

**Where.** A rules loader in `src/` feeding the existing CSS path.

**Measured by.** Before/after text dump for each shimmed site; and a hard rule that
the file is data (a shim that needs logic is rejected in review).

**Risk.** Low technically, medium politically: shims rot as sites change, so they
need a maintainer or they get deleted.

---

## I8 - Vertical tabs and a keyboard-first UI

**Why.** On a 1024x600 netbook, horizontal tabs waste the scarcest resource:
vertical space. And this browser's users are keyboard people.

**What.** A vertical tab strip drawn in `dw/`, collapsible, with the shared Vinculum
keymap honoured end to end, plus a command palette that searches the existing action
table.

**Where.** `dw/`, `src/actions.c`.

**Measured by.** Usability, not throughput: the acceptance test is opening,
switching and closing 8 tabs without touching the mouse, in under 20 seconds.

**Risk.** Low. Pure widget work, easy to review.

---

## I9 - A "what this page wanted to run" log

**Why.** Sorex refuses JavaScript. Users deserve to see what that cost them, site by
site, rather than guessing why a page looks odd.

**What.** A per-tab counter of blocked script tags, blocked iframes and blocked
`on*` handlers, surfaced in the status bar and in `dilloc list`. No engine, no
execution, just evidence.

**Where.** `src/` (the HTML path already sees these tags).

**Measured by.** Counts correct on the fixture set; zero performance cost in the
render path.

**Risk.** Very low, and it makes the handoff ladder's advice actionable.

---

## I10 - An arena allocator for layout

**Why.** Layout allocates thousands of small boxes per page and frees them on every
reflow. That is the hot path on old hardware.

**What.** A per-page arena: bump-allocate boxes, free the whole arena on reflow.
`dlib` keeps the malloc wrappers so accounting still works.

**Where.** `lout/`, `dlib/`.

**Measured by.** Layout time on the largest fixtures; target 15% improvement, and
RSS must not grow.

**Risk.** Low-medium. Use-after-free is the failure mode; run under ASan.

---

## I11 - Hardened decoders

**Why.** Image and CSS parsers are where a no-JavaScript browser still gets
attacked: they are the only complex parsing of untrusted bytes left.

**What.** Build the browser with `-D_FORTIFY_SOURCE=3`, stack protector strong, and
`-fstack-clash-protection`; add libFuzzer harnesses for the CSS parser and each
image decoder; consider running decoders in the existing `dpi` process boundary
rather than the UI process where that is possible.

**Where.** `dpi/`, image code, build flags.

**Measured by.** Fuzzing hours without a crash; and a written threat model.

**Risk.** Low. Mostly discipline.

---

## I12 - Reproducible static builds and cross-compilation

**Why.** The users of this browser cannot compile it. They need an artifact that
runs on a machine from 2008, and we need to be able to reproduce that artifact
exactly.

**What.** `tools/build.sh --static` with musl, `--target aarch64-musl` and
`--target riscv64-musl`, a pinned dependency set, and a CI job that builds all
three and reports the binary size against the 1.4 MB budget.

**Where.** `tools/`, CI.

**Measured by.** Binary size, `ldd` output (must be "not a dynamic executable"),
and a run inside an empty Alpine container.

**Risk.** Low. Unglamorous, and it is what makes the project usable.

## Prior art in this tree

Every item below already has a home upstream. Read it before designing the
replacement — the shape is usually right and only the policy is new.

| Innovation | Where upstream already does part of this |
| --- | --- |
| I1 memory ceiling | `src/cache.c` (the caches that grow), `src/bw.c` (per-tab state) |
| I2 tab suspension | `src/bw.c` (the widget tree a tab owns) |
| I3 control socket as API | `src/dilloc.c` (client), `src/actions.c` (the actions it drives) |
| I4 text-first paint | `lout/` (layout produces the box tree before `dw/` draws it) |
| I5 connection reuse | `dpid/`, `dpi/http.c` (the daemon already owns the sockets) |
| I6 HTTP/2 | `dpi/http.c`, `dpip/` (the wire protocol to extend) |
| I7 site shims as data | `src/css.cc`, `src/cssparser.cc` (the CSS path the shims feed) |
| I8 vertical tabs | `dw/` (the widget layer) |
| I9 command palette | `src/actions.c`, `src/uicmd.cc` (the existing action table) |
| I10 arena allocator | `lout/` (box allocation), `dlib/` (the malloc wrappers to keep) |
| I11 hardened decoders | `dpi/` (already a separate process from the UI) |
| I12 static builds | `configure.ac` (the flags that already exist) |

Two boundaries upstream draws, and this fork keeps: the network lives in `dpid`
with `dpi/` plugins, and layout (`lout/`) is separate from widgets (`dw/`). A change
that crosses either needs a reason in `DESIGN.md` first.
