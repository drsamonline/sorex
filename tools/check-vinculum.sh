#!/bin/sh
# The shared specs must be byte-identical across the family. Drift is the failure
# mode this check exists to catch.
set -eu
CANON="${VINCULUM_CANON:-}"
if [ -z "$CANON" ]; then
  echo "VINCULUM_CANON not set - skipping cross-repo check."
  echo "Local self-check only:"
  ls -1 shared/vinculum/
  exit 0
fi
rc=0
for f in "$CANON"/*; do
  name=$(basename "$f")
  if ! cmp -s "$f" "shared/vinculum/$name"; then
    echo "DRIFT: shared/vinculum/$name differs from $CANON/$name"
    rc=1
  fi
done
[ "$rc" -eq 0 ] && echo "vinculum: identical to canonical copy"
exit "$rc"
