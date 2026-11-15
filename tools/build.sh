#!/bin/sh
# Sorex build driver. One script, so that "how do I build this" has one answer.
set -eu

MODE=native
TARGET=
JOBS=$( (getconf _NPROCESSORS_ONLN 2>/dev/null || echo 2) )

for arg in "$@"; do
  case "$arg" in
    --static) MODE=static ;;
    --debug)  MODE=debug ;;
    --target=*) TARGET="${arg#--target=}" ;;
    -h|--help)
      cat <<'EOF'
usage: tools/build.sh [--static] [--debug] [--target=<triplet>] [--help]

  --static           static musl build (needs musl-gcc)
  --debug            -O0 -g3, assertions on
  --target=<triplet> cross-compile, e.g. aarch64-linux-musl
EOF
      exit 0 ;;
    *) echo "unknown option: $arg" >&2; exit 64 ;;
  esac
done

case "$MODE" in
  native)
    CFLAGS="-O2 -flto -fomit-frame-pointer -DNDEBUG -fstack-protector-strong -D_FORTIFY_SOURCE=2"
    LDFLAGS="-Wl,-O1 -Wl,--as-needed -s" ;;
  static)
    CFLAGS="-O2 -flto -fomit-frame-pointer -DNDEBUG -fstack-protector-strong -D_FORTIFY_SOURCE=2 -static"
    LDFLAGS="-static -s"
    CC=musl-gcc
    export CC ;;
  debug)
    CFLAGS="-O0 -g3 -fno-omit-frame-pointer"
    LDFLAGS="" ;;
esac

if [ -n "$TARGET" ]; then
  export CC="${TARGET}-gcc"
fi

export CFLAGS LDFLAGS

if [ ! -x ./configure ]; then
  if [ -x ./autogen.sh ]; then
    echo "== autogen =="
    ./autogen.sh
  else
    echo "== autoreconf =="
    autoreconf -fi
  fi
fi

echo "== configure =="
# --help is authoritative for the exact flag set in this tree; these are the ones
# that matter for size and speed and are stable across Dillo 3.x.
./configure \
  --disable-dependency-tracking \
  --disable-debug \
  --enable-ssl \
  --disable-nls \
  || { echo "configure failed. Missing deps are usually: FLTK, zlib, libpng, libjpeg, libwebp, OpenSSL." >&2; exit 1; }

echo "== make -j$JOBS =="
make -j"$JOBS"

echo "== done =="
ls -la src/dillo 2>/dev/null || true
if command -v size >/dev/null 2>&1; then size src/dillo 2>/dev/null || true; fi
