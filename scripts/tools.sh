#!/bin/bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd -P)"
node -e 'if (Number(process.versions.node.split(".")[0]) < 22) process.exit(1)' || { echo "Node 22+ is required" >&2; exit 1; }
mkdir -p "$ROOT/.tools/node"
cp "$ROOT/tooling/package.json" "$ROOT/tooling/package-lock.json" "$ROOT/.tools/node/"
npm ci --prefix "$ROOT/.tools/node" --ignore-scripts --no-audit --no-fund
uv venv --allow-existing --python 3.14.6 "$ROOT/.tools/python"
uv pip sync --python "$ROOT/.tools/python/bin/python" "$ROOT/tooling/python.lock"
# Official prebuilt JS debug adapter, verified before extraction.
url="$(node -p "require(process.argv[1]).url" "$ROOT/tooling/js-debug.json")"
hash="$(node -p "require(process.argv[1]).sha256" "$ROOT/tooling/js-debug.json")"
archive="$ROOT/.tools/js-debug.tar.gz"
curl -fsSL "$url" -o "$archive"
printf '%s  %s\n' "$hash" "$archive" | shasum -a 256 -c -
mkdir -p "$ROOT/.tools/debugger"
tar -xzf "$archive" -C "$ROOT/.tools/debugger"
