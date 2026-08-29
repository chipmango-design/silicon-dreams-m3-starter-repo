#!/usr/bin/env bash
# Silicon Dreams · Module 3 · LibreLane wrapper.
# Pins the image version, handles headless X for Magic, and names runs by tag.
set -euo pipefail

PIN_VERSION="2025.04"
CONFIG_JSON="$(pwd)/librelane/config.json"

TAG=""
VERSION_CHECK_ONLY=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --tag)            TAG="$2"; shift 2 ;;
    --version-check)  VERSION_CHECK_ONLY=1; shift ;;
    *) echo "Unknown arg: $1" >&2; exit 2 ;;
  esac
done

if [[ ! -f "$CONFIG_JSON" ]]; then
  echo "Error: librelane/config.json not found. Run from the repo root." >&2
  exit 1
fi

PINNED_META="$(python3 - <<'PY'
import json, sys
print(json.load(open("librelane/config.json"))["meta.version"])
PY
)"

if [[ "$PINNED_META" != "$PIN_VERSION" ]]; then
  echo "Error: config.json pins LibreLane $PINNED_META but course expects $PIN_VERSION." >&2
  echo "Do not edit the pin — grader will reject." >&2
  exit 1
fi

if [[ "$VERSION_CHECK_ONLY" -eq 1 ]]; then
  echo "OK: LibreLane $PIN_VERSION correctly pinned."
  exit 0
fi

if [[ -z "$TAG" ]]; then
  TAG="run-$(date +%Y%m%d-%H%M%S)"
fi

echo "==> LibreLane $PIN_VERSION  ·  tag=$TAG"

xvfb-run -a -s "-screen 0 1920x1080x24" \
  docker run --rm -v "$(pwd)":/work -w /work \
    "efabless/librelane:$PIN_VERSION" \
    librelane run \
      --config "$CONFIG_JSON" \
      --pdk sky130A \
      --scl sky130_fd_sc_hd \
      --tag "$TAG"

echo "==> Done. Reports under runs/$TAG/reports/"
