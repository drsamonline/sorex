# AGENTS.md

Working rules for coding agents in this repository. Humans should read
`START_PROMPT.md`, which is the long form of this file.

## Read order

`docs/UPSTREAM-FIRST.md` first — this tree is a fork, so the answer to "how should
this work" is already on disk. Read the vendored source before designing anything,
and read `Libraries/LibWeb` (Ladybird) for anything interaction-shaped.

`FAMILY.md` -> `SOURCES.md` -> `PLAN.md` -> `DESIGN.md` -> `INNOVATIONS.md` ->
`ROADMAP.md` -> `PATCHES.md`.

## Non-negotiables

1. No JavaScript engine. Ever.
2. RSS ceilings: 18 MB for one tab, 30 MB for eight.
3. One process plus `dpid`.
4. GPL-3.0-or-later tree: never copy code from Nodus or Volumen (GPL-2.0-only).
5. Vendored-file edits are logged in `PATCHES.md` in the same commit.
6. New dependency requires an ADR in `docs/adr/`.
7. `./tools/build.sh` must pass at every commit.

## Commit style

Conventional commits, scoped by workstream or module:
`feat(ipc):`, `fix(layout):`, `perf(cache):`, `docs(adr):`, `build(musl):`.

## Before you claim success

Run the command. Paste the output. A claim without a command is folklore.

## Where things live

| Need | Path |
|------|------|
| Browser window, cache, cookies, UI glue | `src/` |
| Layout engine | `lout/` |
| FLTK widgets, tabs, dialogs | `dw/` |
| Network daemon and protocol plugins | `dpid/`, `dpi/` |
| Browser-to-daemon wire protocol | `dpip/` |
| Small utility library | `dlib/` |
| Tests and fixtures | `test/` |
| Our documentation | `docs/` |
| Shared family specs (do not diverge) | `shared/vinculum/` |
