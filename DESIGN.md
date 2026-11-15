# Design

## The upstream architecture, in one page

Dillo is a single-process, single-threaded browser with a separate network
daemon. Understanding four boundaries is enough to change almost anything:

```
  user input (FLTK)
        |
        v
   src/  actions.c, bw.c, capi.c          <- browser window, cache, cookies, UI glue
        |
        |  dpip wire protocol (dpip/)
        v
   dpid/  plugin daemon                    <- one process, owns DNS, TCP, TLS, cache
        |
        v
   dpi/  http.c, https.c, file.c, ftp.c    <- protocol plugins, one .so each
        |
        v
   src/cache.c  ->  lout/  layout  ->  dw/  widgets  ->  FLTK  ->  X or framebuffer
```

Two things about this are worth protecting:

1. **The network is already out of process.** `dpid` means a hostile page cannot
   reach the socket code, and a crashing protocol plugin does not take the window
   with it. Sorex leans on this and does not add more processes.
2. **Layout is already separate from widgets.** `lout/` produces a box tree, `dw/`
   turns it into FLTK widgets. This is why a text-first paint is cheap to add: the
   box tree exists before anything is drawn.

## Where each innovation lands

| Innovation (see INNOVATIONS.md) | Module | Kind of change |
|---------------------------------|--------|----------------|
| I1 hard memory ceiling | `src/cache.c`, `src/bw.c` | new policy, no new subsystem |
| I2 tab suspension | `src/bw.c`, `src/cache.c` | serialise widget tree, restore lazily |
| I3 control socket as API | `src/dilloc.c`, `src/actions.c`, `src/uicmd.cc` | extend an existing protocol |
| I4 text-first paint | `lout/`, `dw/` | split layout into two phases |
| I5 connection reuse | `dpid/`, `dpi/http.c` | pool in the daemon |
| I6 HTTP/2 | `dpi/http.c` + a vendored minimal client | new module, behind a flag |
| I7 site shims as data | `src/` + a rules file | data, not code, in the render path |
| I8 vertical tabs | `dw/` | widget work |
| I9 command palette | `src/actions.c` | UI over existing action table |
| I10 script-wanted log | `src/` | log, not an engine |
| I11 arena allocator for layout | `lout/`, `dlib/` | allocator swap, measurable |
| I12 decoder hardening | `dpi/`, image code | build flags plus seccomp |

## Decisions

Recorded here because they constrain everything downstream. Each gets an ADR in
`docs/adr/` when it is revisited.

### D1 - The control socket is the automation API

Dillo 3.3 added a UNIX-socket remote control and the `dilloc` client. Rather than
invent a second IPC mechanism, Sorex extends that one and documents it as the
public surface. Consequences: the socket must be stable, authenticated by file
permissions alone (which is correct for a per-user browser), and testable without a
display.

### D2 - No JavaScript, and no shims that become a JavaScript engine

The tempting middle ground - "a tiny declarative language for the sites people use"
- is how small browsers become bad large browsers. Shims (I7) are therefore *data*:
a list of URL patterns and CSS rules to inject, applied by the existing CSS
machinery. If a shim needs a condition, it does not ship.

### D3 - The memory ceiling is enforced, not advised

`memory.max_rss_mb` is read at startup. The cache and image cache are budgeted as
fractions of it. Before a large allocation, the eviction path runs; if it cannot
free enough, the page is dropped with a visible message rather than the process
being killed by the kernel. Users must never see an OOM kill from this browser.

### D4 - Static musl builds are a first-class target

The point of this browser is to run where nothing else does. A dynamically linked
binary against a 2010 glibc is a bug. musl static is the reference target; glibc
dynamic is the convenience target.

### D5 - One TLS backend per build

OpenSSL, LibreSSL and mbedTLS are all supported upstream. Sorex builds exactly one,
selected at configure time, and refuses to link two. Smaller binary, smaller attack
surface, simpler bug reports.

### D6 - Upstream changes are patches, not silent edits

Every modification to a vendored file is logged in `PATCHES.md` with the reason and
the upstream issue number if one exists. A merge conflict with upstream is
information; an undocumented edit is a future conflict nobody can explain.

## Data flow for a page load (target behaviour)

```
URL -> actions.c -> dpip -> dpid -> dpi/http.c -> cache.c (content-addressed)
     -> lout/ (parse + style + layout, budgeted)
     -> first paint: text only            [I4]
     -> idle slice: images, if budget allows and images are on
     -> dw/ widgets, then FLTK surface
```

## Threading and memory

Single-threaded event loop; no locks in the render path. Allocation goes through
`dlib`'s wrappers so that peak and current usage are observable in one place; the
layout engine gets an arena allocator (I11) that is freed wholesale when a page is
re-laid out, which removes the per-box free() traffic that dominates layout time on
large documents.

## Testing strategy

- **Fixtures first.** Every layout change lands with a fixture in `test/corpus/`.
- **Dumps before pixels.** Structural diffs are cheap and stable; PNG diffs are the
  second line of defence, used for the 40 saved real pages.
- **Soak.** A four-hour run over the corpus with tabs opening and closing; RSS must
  be flat, not merely bounded.
- **Fuzz.** The CSS parser and image decoders get libFuzzer harnesses before v0.5.
