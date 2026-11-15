# ADR 0001 - No JavaScript engine, ever

- Status: accepted
- Date: 2026-11-16

## Context

Every lightweight browser eventually faces the same request: "just a small JS
engine for the sites people actually use". Duktape and QuickJS both fit in a few
hundred kilobytes, so the request sounds cheap.

It is not cheap. Script support is not a feature that sits beside rendering; it
changes the rendering model. A page becomes a program that mutates its own DOM, so
layout must be re-entrant, timers must run, the event loop must be trustworthy, and
every DOM API a site touches becomes a compatibility surface that never shrinks.
The 30 MB ceiling in this project is not a coincidence - it is what is left when you
decide not to run programs from strangers.

## Decision

Sorex will never embed a JavaScript engine, and will never grow a scripting
language of its own in the render path.

Pages that need script are handed to a higher tier via the handoff protocol
(`shared/vinculum/handoff-protocol.md`), with a visible message telling the user
which browser took over and why.

Site shims (I7) are data only: URL patterns plus CSS. A shim that needs a condition
does not ship.

## Consequences

- The memory and speed budgets are achievable, and stay achievable.
- Some sites will not work here. That is the product, not a defect.
- The family needs a working escalation path, so Nodus and Aetheris are load-bearing
  for Sorex's usability.
- Saying no becomes an architectural fact rather than a maintainer's opinion, which
  is the only way it survives contact with a persuasive bug report.
