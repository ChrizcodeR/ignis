#!/bin/bash
# Railway boot: Caddy takes $PORT (the public port) and enforces basic auth,
# then upstream's entrypoint runs Ignis on a loopback-only port behind it.
set -euo pipefail

if [ -z "${BASIC_AUTH_PASSWORD:-}" ]; then
  echo "[railway] FATAL: BASIC_AUTH_PASSWORD is required; refusing to expose Ignis without auth" >&2
  exit 1
fi

export BASIC_AUTH_USER="${BASIC_AUTH_USER:-admin}"
export CADDY_PORT="${PORT:-8080}"
export IGNIS_PORT="${IGNIS_PORT:-3000}"
BASIC_AUTH_HASH="$(caddy hash-password --plaintext "$BASIC_AUTH_PASSWORD")"
export BASIC_AUTH_HASH

caddy run --config /app/apps/ignis-server/railway/Caddyfile --adapter caddyfile &

export PORT="$IGNIS_PORT"
exec /app/apps/ignis-server/scripts/entrypoint.sh "$@"
