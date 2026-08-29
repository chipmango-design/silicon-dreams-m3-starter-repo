#!/usr/bin/env bash
# Silicon Dreams · Module 3 · Build a ChipFoundry shuttle submission tarball.
# Produces submission/silicon-dreams-<discord>-m3.tar.gz with a COURSE_HASH.
set -euo pipefail

FINAL_RUN="${1:-runs/final}"

if [[ ! -d "$FINAL_RUN" ]]; then
  echo "Error: $FINAL_RUN not found. Run ./scripts/run-librelane.sh --tag final first." >&2
  exit 1
fi

DISCORD="$(python3 - <<'PY'
import yaml; d = yaml.safe_load(open("info.yaml"))
h = d["project"]["discord"]
if h.startswith("YOUR-") or not h:
    print("__UNFILLED__")
else:
    print(h.replace("/", "_").replace(" ", "_"))
PY
)"

if [[ "$DISCORD" == "__UNFILLED__" ]]; then
  echo "Error: info.yaml project.discord is still the template value." >&2
  echo "Fill in both 'author' and 'discord' before building the submission." >&2
  exit 1
fi

SUBMISSION_DIR="submission"
TAR="$SUBMISSION_DIR/silicon-dreams-$DISCORD-m3.tar.gz"
STAGE="$SUBMISSION_DIR/_stage"

rm -rf "$STAGE"
mkdir -p "$STAGE/runs/final/final/gds" "$STAGE/runs/final/final/lef" "$STAGE/runs/final"

cp -v "$FINAL_RUN/final/gds/"*.gds   "$STAGE/runs/final/final/gds/"
cp -v "$FINAL_RUN/final/lef/"*.lef   "$STAGE/runs/final/final/lef/"
cp -v "$FINAL_RUN/metrics.csv"       "$STAGE/runs/final/"
cp -v info.yaml                      "$STAGE/"

git rev-parse --verify HEAD > "$STAGE/GIT_COMMIT"
( cd "$STAGE" && find . -type f ! -name COURSE_HASH -print0 | sort -z | xargs -0 sha256sum ) \
  | sha256sum | awk '{print $1}' > "$STAGE/COURSE_HASH"

mkdir -p "$SUBMISSION_DIR"
tar -czf "$TAR" -C "$STAGE" .
rm -rf "$STAGE"

echo ""
echo "==> Submission built:  $TAR"
echo "    COURSE_HASH:       $(tar -xOzf "$TAR" ./COURSE_HASH)"
echo "    GIT_COMMIT:        $(tar -xOzf "$TAR" ./GIT_COMMIT)"
echo ""
echo "Upload via:"
echo "  gh release create v1.0.0-final $TAR --title 'M3 tape-out submission'"
echo "or the ChipFoundry portal: https://portal.chipfoundry.io/silicon-dreams/submit"
