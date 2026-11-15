#!/bin/sh
# Measure the numbers this project is judged on. Nothing here is a benchmark for
# its own sake: every figure maps to a row in PLAN.md's success criteria.
set -eu

TABS=1
MODE=
while [ $# -gt 0 ]; do
  case "$1" in
    --tabs) TABS="$2"; shift 2 ;;
    --ceiling) MODE=ceiling; shift ;;
    --help) echo "usage: tools/measure.sh [--tabs N] [--ceiling]"; exit 0 ;;
    *) shift ;;
  esac
done

BIN=${SOREX_BIN:-./src/dillo}
[ -x "$BIN" ] || { echo "no binary at $BIN - build first (tools/build.sh)" >&2; exit 1; }

rss_kb() { # rss of a pid in kB, portable-ish
  ps -o rss= -p "$1" 2>/dev/null | tr -d ' '
}

echo "== binary =="
ls -l "$BIN" | awk '{print "size_bytes: "$5}'
if command -v ldd >/dev/null 2>&1; then
  echo -n "dynamic: "; ldd "$BIN" 2>&1 | head -1
fi

echo "== idle, $TABS tab(s) =="
# A headless display keeps this reproducible in CI.
if command -v xvfb-run >/dev/null 2>&1; then
  xvfb-run -a "$BIN" --geometry=800x600 about:blank >/dev/null 2>&1 &
else
  "$BIN" about:blank >/dev/null 2>&1 &
fi
PID=$!
sleep 3
if [ -n "$MODE" ]; then
  echo "ceiling mode: open $TABS tabs and watch for OOM kill"
  echo "  (drive tabs through the control socket once W3 lands)"
fi
echo "rss_kb: $(rss_kb "$PID")"
kill "$PID" 2>/dev/null || true
wait "$PID" 2>/dev/null || true

echo
echo "Record these in PERFORMANCE.md with the date and the machine."
echo "Compare against the budgets in PLAN.md, never against a feeling."
