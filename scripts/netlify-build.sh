#!/usr/bin/env bash
# Injects CKEditor license key from environment into index.html before publish.
# Set CKEDITOR_LICENSE_KEY in Netlify: Site settings → Environment variables (do not commit secrets).
# For local preview with a key: CKEDITOR_LICENSE_KEY='your-jwt' bash scripts/netlify-build.sh
# Without a key, falls back to GPL (development / open-source build).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

PLACEHOLDER="__CKEDITOR_LICENSE_KEY__"
KEY="${CKEDITOR_LICENSE_KEY:-GPL}"

if [[ ! -f index.html ]]; then
  echo "error: index.html not found" >&2
  exit 1
fi

python3 - <<'PY' "$ROOT" "$PLACEHOLDER" "$KEY"
import pathlib, sys
root = pathlib.Path(sys.argv[1])
ph = sys.argv[2]
key = sys.argv[3]
path = root / "index.html"
text = path.read_text(encoding="utf-8")
if ph not in text:
    print("error: placeholder not found in index.html", file=__import__("sys").stderr)
    exit(1)
escaped = key.replace("\\", "\\\\").replace('"', '\\"')
# Single replacement to avoid duplicate runs corrupting content
text = text.replace(
    f'licenseKey: "{ph}"',
    f'licenseKey: "{escaped}"',
    1,
)
path.write_text(text, encoding="utf-8")
print("CKEditor license key wiring OK (value length:", len(key), ")")
PY
