#!/bin/sh
# Keep this fork honest about where it came from.
set -eu

UPSTREAM_URL="https://github.com/dillo-browser/dillo.git"
UPSTREAM_BRANCH="master"

if ! git remote get-url upstream >/dev/null 2>&1; then
  echo "adding upstream remote: $UPSTREAM_URL"
  git remote add upstream "$UPSTREAM_URL"
fi

git fetch --tags upstream
echo
echo "== commits upstream has that we do not =="
git log --oneline HEAD..upstream/$UPSTREAM_BRANCH | head -40 || true
echo
echo "== commits we have that upstream does not =="
git log --oneline upstream/$UPSTREAM_BRANCH..HEAD | head -40 || true
echo

if [ "${1:-}" = "--merge" ]; then
  echo "merging upstream/$UPSTREAM_BRANCH"
  git merge "upstream/$UPSTREAM_BRANCH" || {
    echo
    echo "conflict. Resolve it, then update PATCHES.md - the conflicting hunk is"
    echo "almost certainly a change that should have been recorded there."
    exit 1
  }
  echo "merged. Now: run tools/build.sh, then tools/measure.sh, then update PATCHES.md."
else
  echo "dry run only. Re-run with --merge to merge."
fi
