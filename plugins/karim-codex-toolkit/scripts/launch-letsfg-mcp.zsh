#!/usr/bin/env zsh
set -euo pipefail

if ! command -v npx >/dev/null 2>&1; then
  print -u2 "Required command not found: npx"
  exit 69
fi

if [[ -z "${LETSFG_BEARER_TOKEN:-}" && -z "${LETSFG_API_KEY:-}" ]]; then
  if command -v python3 >/dev/null 2>&1; then
    saved_token="$(python3 -c '
import json, time
from pathlib import Path
p = Path.home() / ".letsfg" / "config.json"
try:
    auth = json.loads(p.read_text()).get("pfs_auth") or {}
    token = auth.get("token") or ""
    expires = float(auth.get("expires_at") or 0)
    if token and time.time() < expires - 3600:
        print(token)
except Exception:
    pass
' 2>/dev/null || true)"
    if [[ -n "$saved_token" ]]; then
      export LETSFG_BEARER_TOKEN="$saved_token"
      unset saved_token
    fi
  fi
fi

exec npx -y letsfg-mcp@2026.5.70
