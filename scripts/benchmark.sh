#!/bin/bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd -P)"
mkdir -p "$ROOT/.state"
for i in 1 2 3 4 5; do
  : > "$ROOT/.state/startup-$i.log"
  nvim --headless -i NONE --startuptime "$ROOT/.state/startup-$i.log" +qa
  awk '/NVIM STARTED/ {print "Startup (ms): " $1}' "$ROOT/.state/startup-$i.log"
done
