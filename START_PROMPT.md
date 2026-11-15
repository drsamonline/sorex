# Start prompt

Paste this whole file into a coding agent (Claude Code, Codex, Cursor, or a
reviewer's brain) at the start of a work session in this repository. It is written
to be self-contained: the agent should need nothing else except the files it names.

---

You are working in **Sorex**, a fork of the Dillo web browser, at
`https://github.com/drsamonline/sorex`. You are one of four browsers in the
Aetheris family; Sorex is tier 2.

## Read before you type

In this order, and do not skip:

1. `FAMILY.md` - the four tiers, the Vinculum contract, and the licence firewall.
2. `SOURCES.md` - the exact upstream commit this tree is derived from.
3. `PLAN.md` - mission, non-goals, workstreams, success criteria.
4. `DESIGN.md` - the module map and the six binding decisions (D1-D6).
5. `INNOVATIONS.md` - the twelve-item backlog with measurements attached.
6. `ROADMAP.md` - which of those items belongs to the release you are in.
7. `PATCHES.md` - every local change to vendored upstream code.

If a file contradicts this prompt, the file wins and this prompt gets fixed.

## What this project is

A ~30 MB graphical browser, no JavaScript ever, drivable over a UNIX socket, built
from Dillo's engine, for machines where a modern browser is impossible. It is
GPL-3.0-or-later. It is not a Chromium competitor and must never try to become one.

## Hard constraints

These are not preferences. A change that violates one is rejected regardless of how
well it works.

1. **No JavaScript engine, ever.** Not Duktape, not QuickJS, not a small interpreter
   for forms. Pages that need script are handed to a higher tier via
   `shared/vinculum/handoff-protocol.md`.
2. **Resident set ceilings hold.** 18 MB for one tab, 30 MB for eight. If a feature
   breaks the ceiling, the feature loses.
3. **One process plus `dpid`.** No new daemons, no renderer processes.
4. **One TLS backend per build.** Do not link two.
5. **Licence hygiene.** This is a GPL-3.0-or-later tree. Code from Nodus or Volumen
   is GPL-2.0-only and must not be copied in, not even a function. Specs and data
   from `shared/vinculum/` (CC0) are fine. The NetSurf MIT libraries are fine.
6. **Upstream edits are logged.** Any change inside a file that came from Dillo goes
   in `PATCHES.md` in the same commit.
7. **No new dependency without an ADR.** One paragraph in `docs/adr/NNNN-*.md`
   saying what it costs in bytes and in attack surface.

## How to work

- **Small commits, conventional messages.** `feat(ipc): add tab list verb`,
  `fix(layout): do not reflow on image arrival`, `perf(cache): evict by age`.
- **One workstream per branch.** W1 build, W2 memory, W3 IPC, W4 UI, W5 network,
  W6 layout, W7 privacy, W8 packaging. Do not mix.
- **Fixture first.** Any rendering or layout change starts with a page in
  `test/corpus/fixtures/` that fails today.
- **Measure, do not assert.** Every performance claim needs the output of
  `tools/measure.sh` pasted into the pull request. Numbers without a command are
  folklore.
- **Ask before redesigning.** If a task seems to need a change to D1-D6, stop and
  write an ADR proposing it. Do not quietly reinterpret a decision.
- **Leave the tree buildable.** `./tools/build.sh` must pass at every commit. If it
  does not, that is the only thing you work on.

## Your first three tasks

In this order. Do not start the second until the first is green.

**Task 1 - Prove the build.** Run `./tools/build.sh`, fix whatever breaks on this
machine, and record the exact dependency versions and the resulting binary size in
`PERFORMANCE.md`. If a dependency is missing, add the install line to
`tools/build.sh`'s error message rather than to a wiki.

**Task 2 - Baseline the numbers.** Implement `tools/measure.sh` well enough to
report: idle RSS with 1 tab, RSS with 8 tabs of the saved-page corpus, first
text paint time, and binary size. Publish the baseline in `PERFORMANCE.md` with the
date. Do not optimise anything yet. You cannot improve what you have not measured,
and a baseline taken after the first optimisation is worthless.

**Task 3 - Start W3 (the control socket).** Read `src/dilloc.c` and
`src/actions.c`, then document the existing socket protocol in `docs/IPC.md` as it
actually behaves today, including the parts that are ugly. Do not change behaviour
in this task. The document is the deliverable, and it will show which verbs are
missing.

## Definition of done

A task is done when all of these are true:

- `./tools/build.sh` passes from clean.
- New behaviour has a fixture or a shell test, and the test fails without the change.
- `tools/measure.sh` output is in the pull request if any performance claim is made.
- `PATCHES.md` is updated if a vendored file changed.
- Docs are updated in the same commit, not a follow-up.
- The commit message says *why*, not just what.

## Anti-goals, restated because they keep coming back

- Do not add a JavaScript engine.
- Do not add a second frontend. That is Nodus's job.
- Do not add HTTP/3, WebRTC, WebGL, DRM, or extensions.
- Do not rewrite the layout engine "properly". It works; it needs a budget, not a
  replacement.
- Do not turn the shim file into a scripting language.
- Do not optimise without a baseline.

## When you are unsure

Write the question into `docs/questions.md` with your best guess and the reason, and
pick the guess that keeps the memory ceiling and the licence intact. Those two
constraints are never the wrong answer.
