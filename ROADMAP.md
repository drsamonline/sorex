# Roadmap

Dates are targets, not promises. Each phase has an exit criterion that is a command,
not a feeling: if the command does not pass, the phase is not done and the next one
does not start.

Phases are deliberately short. A phase that cannot be finished in six to ten weeks of
evenings is a phase that will be abandoned, so scope is cut before dates move.

## P0 - Scaffold (November 2026)

Upstream imported at `6856c50`, documentation written, build script exists, shared
Vinculum contract in place.

**Exit:** `./tools/build.sh` produces a working `src/dillo` on a machine with the
dependencies installed. `./tools/measure.sh` runs and prints something, even if the
something is embarrassing.

## P1 - Measured baseline and the control socket (December 2026 - January 2027)

Two things at once, because they are independent: the baseline numbers (idle RSS, RSS
with eight tabs, first text paint, binary size) published in `PERFORMANCE.md`, and the
control socket documented as it behaves today in `docs/IPC.md`.

**Exit:** `PERFORMANCE.md` has a dated baseline; `docs/IPC.md` covers every existing
verb including the ugly ones; `tools/test-ipc.sh` passes for the verbs that exist.

**Cut if late:** the socket verbs that need new UI (tab list, PNG capture). Keep open,
close, text.

## P2 - Bounded memory (February - March 2027)

The memory ceiling (I1) and tab suspension (I2). These two together are the difference
between "a small browser" and "a browser that stays small".

**Exit:** `tools/measure.sh --ceiling --tabs 20` keeps RSS under the configured value
with no OOM kill; eight tabs of the saved corpus under 30 MB.

**Cut if late:** suspension for background tabs only; the ceiling ships alone.

## P3 - Fast paint and the automation API (April - May 2027)

Text-first paint with a layout budget (I4), the full control-socket API (I3), and the
command palette (I9).

**Exit:** first text paint under 120 ms on the fixture corpus with no total-layout
regression; every IPC verb documented and tested.

## P4 - Network and family integration (June - July 2027)

Connection reuse and brotli (I5), then HTTP/2 behind a flag (I6) only if the
measurements justify it. The handoff protocol working in both directions.

**Exit:** under 10 connections per saved page; `tools/test-handoff.sh` passes; HTTP/2
is either on by default with evidence, or documented as rejected with the numbers.

## P5 - Hardening and v1.0 (August - September 2027)

Fuzzing (I11), hardened build flags, the arena allocator (I10), static musl artifacts
for x86_64, aarch64 and riscv64, packaging for Alpine and Debian, and the soak test.

**Exit:** all eight success criteria in `PLAN.md` pass; the release artifact runs on a
clean Alpine container and on a 512 MB machine.

## What is explicitly not on this roadmap

- JavaScript, ever (see `docs/adr/0001-no-javascript-ever.md`).
- A second frontend.
- Windows or macOS ports.
- HTTP/3, WebRTC, WebGL, DRM, extensions.

## How this roadmap changes

A phase can be cut, but the order cannot be reversed: measurement before optimisation,
ceiling before features, hardening before release. If a new idea arrives, it goes into
`INNOVATIONS.md` with a measurement attached, and waits for a phase.

## Deferred by decision (2026-11-16)

**The family landing page.** Once all four browsers are finished, one page listing the
ladder, the licences and the honest state of each project goes in the hub repo
(`drsamonline.github.io`) - not in a fifth repository, and not before. A landing page
that advertises four unfinished browsers is worse than no landing page.

The trigger is concrete, not a date: Aetheris, Nodus, Sorex and Volumen all at v1.0, or
the point where one of them is good enough that a stranger would actually try it. Until
then, `FAMILY.md` in each repo is the family's front door and it is enough.

**No fifth repo.** The family is four browsers and a shared contract. Anything that
wants to be a fifth repository has to justify itself against that.
