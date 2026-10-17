#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."

if [[ -z "${MONGO_URI:-}" ]]; then
  echo "Add MONGO_URI in Replit Secrets before starting LibreChat." >&2
  exit 1
fi

if [[ "$MONGO_URI" != mongodb://* && "$MONGO_URI" != mongodb+srv://* ]]; then
  echo "MONGO_URI must start with mongodb:// or mongodb+srv://. Enter the URI without surrounding quotes." >&2
  exit 1
fi

if [[ ! -x node_modules/.bin/cross-env ]]; then
  echo "Dependencies are missing. Install the root npm workspace dependencies first." >&2
  exit 1
fi

export HOST=0.0.0.0
export PORT="${PORT:-5000}"
export SEARCH="${SEARCH:-false}"

if [[ -n "${REPLIT_DEV_DOMAIN:-}" ]]; then
  export DOMAIN_CLIENT="https://${REPLIT_DEV_DOMAIN}"
  export DOMAIN_SERVER="$DOMAIN_CLIENT"
fi

if [[ ! -f client/dist/index.html ||
      ! -f packages/api/dist/index.cjs ||
      ! -f packages/data-provider/dist/index.js ||
      ! -f packages/data-schemas/dist/index.cjs ||
      ! -f packages/client/dist/index.cjs ||
      ! -f packages/chat/dist/index.cjs ]]; then
  npm run frontend
fi

exec npm run backend
