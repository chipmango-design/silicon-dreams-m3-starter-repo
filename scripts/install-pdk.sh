#!/usr/bin/env bash
# Silicon Dreams · Module 3 · First-run PDK installer.
set -euo pipefail

PIN_VERSION="2025.04"
PDK_ROOT="${PDK_ROOT:-$HOME/.volare/pdks}"

echo "==> Installing sky130A PDK for LibreLane $PIN_VERSION into $PDK_ROOT"

docker run --rm -v "$PDK_ROOT":/pdk \
  "efabless/librelane:$PIN_VERSION" \
  volare enable sky130A --pdk-root /pdk

echo "==> Done. PDK_ROOT=$PDK_ROOT"
echo "Add this to your shell rc:"
echo "  export PDK_ROOT=$PDK_ROOT"
