# Open questions

Where uncertainty is recorded instead of guessed silently. Each entry: the question,
the current best guess, and what would settle it.

1. **Does FLTK 1.4 buy us anything worth the churn?** Guess: not yet; the
   experimental flag exists upstream and should stay experimental. Settled by: a
   build and a measurement on the same fixture set.
2. **Can `dpid` own the cache instead of `src/cache.c`?** Guess: no, keep the cache
   in the UI process; the daemon should own sockets only. Settled by: a prototype
   measuring IPC traffic on the saved-page corpus.
3. **Is HTTP/2 worth it before connection reuse is done?** Guess: no. Reuse first,
   measure, then decide. Settled by: the W5 measurements.
4. **How much of the 8-tab budget does tab suspension actually recover?** Guess:
   most of it, since images dominate. Settled by: W4 implementation.
