#!/usr/bin/env bash
# Start a headless Orca runtime (orca serve).
set -euo pipefail

PORT="${ORCA_PORT:-6768}"
PAIRING_ADDRESS="${ORCA_PAIRING_ADDRESS:-127.0.0.1}"
APPIMAGE="${ORCA_APPIMAGE:-/opt/orca/orca-linux.AppImage}"

if [[ ! -x "${APPIMAGE}" ]]; then
  echo "Missing AppImage at ${APPIMAGE}. Run ./scripts/install-orca-linux.sh first." >&2
  exit 1
fi

# Prefer Orca-managed Xvfb when no usable display exists.
unset DISPLAY || true
export LIBGL_ALWAYS_SOFTWARE="${LIBGL_ALWAYS_SOFTWARE:-1}"

EXTRA=()
# Containers / restricted environments often need Chromium --no-sandbox.
if [[ "$(id -u)" -eq 0 ]] || [[ -f /.dockerenv ]] || [[ -n "${CURSOR_AGENT:-}" ]]; then
  EXTRA+=(--no-sandbox)
fi

echo "Starting orca serve on port ${PORT} (pairing-address=${PAIRING_ADDRESS})…"
exec "${APPIMAGE}" "${EXTRA[@]}" serve \
  --port "${PORT}" \
  --pairing-address "${PAIRING_ADDRESS}" \
  --json
