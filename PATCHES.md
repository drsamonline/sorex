# Patches

Every change to a file that came from upstream Dillo is recorded here, in the same
commit that makes the change. This file exists so that an upstream merge is a
review, not an archaeology project.

## Format

```
### <path> - <one-line summary>
- Commit: <sha>
- Why: <the reason, in one sentence>
- Upstream: <issue or PR link if one exists, else "not filed">
- Revert risk: <what breaks if upstream changes this area>
```

## Log

Nothing yet. This tree is a clean import of Dillo `6856c50`. The first entry will be
added by the first task that has to touch vendored code.

## Policy

1. **Prefer new files.** A new file never conflicts on merge.
2. **Prefer wrappers.** If a behaviour needs changing, wrap the upstream function
   rather than editing it where the call sites allow.
3. **Keep hunks small.** A patch should be readable in a diff without scrolling.
4. **File it upstream when it is a bug.** Dillo is actively maintained again; a fix
   that belongs upstream should go there and come back on the next sync.
