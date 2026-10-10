#!/usr/bin/env bash
# Install Orca (stablyai/orca) Linux AppImage into /opt/orca and PATH wrappers.
set -euo pipefail

ORCA_VERSION="${ORCA_VERSION:-latest}"
INSTALL_DIR="${INSTALL_DIR:-/opt/orca}"
APPIMAGE_PATH="${INSTALL_DIR}/orca-linux.AppImage"

if [[ "${ORCA_VERSION}" == "latest" ]]; then
  DOWNLOAD_URL="https://github.com/stablyai/orca/releases/latest/download/orca-linux.AppImage"
else
  DOWNLOAD_URL="https://github.com/stablyai/orca/releases/download/${ORCA_VERSION}/orca-linux.AppImage"
fi

echo "==> Installing dependencies (xvfb, fuse, curl)…"
sudo apt-get update -qq
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y -qq \
  curl ca-certificates xvfb libfuse2t64 fuse3 \
  || sudo DEBIAN_FRONTEND=noninteractive apt-get install -y -qq \
    curl ca-certificates xvfb libfuse2 fuse

echo "==> Downloading Orca AppImage (${ORCA_VERSION})…"
sudo mkdir -p "${INSTALL_DIR}"
sudo curl -L --fail --retry 3 --retry-delay 2 -o "${APPIMAGE_PATH}" "${DOWNLOAD_URL}"
sudo chmod +x "${APPIMAGE_PATH}"

echo "==> Installing CLI wrappers (/usr/local/bin/orca, orca-ide)…"
sudo tee /usr/local/bin/orca-ide >/dev/null <<'EOF'
#!/usr/bin/env bash
export LIBGL_ALWAYS_SOFTWARE="${LIBGL_ALWAYS_SOFTWARE:-1}"
exec /opt/orca/orca-linux.AppImage "$@"
EOF
sudo tee /usr/local/bin/orca >/dev/null <<'EOF'
#!/usr/bin/env bash
export LIBGL_ALWAYS_SOFTWARE="${LIBGL_ALWAYS_SOFTWARE:-1}"
exec /opt/orca/orca-linux.AppImage "$@"
EOF
sudo chmod +x /usr/local/bin/orca /usr/local/bin/orca-ide

echo "==> Verifying…"
orca --version || true
orca --help | head -n 8
echo "Installed: ${APPIMAGE_PATH}"
echo "Done. Next: ./scripts/serve-orca.sh"
