#!/usr/bin/env bash
# Install Orca FROM GitHub: clone stablyai/orca + download Linux AppImage from GitHub Releases.
set -euo pipefail

ORCA_VERSION="${ORCA_VERSION:-latest}"
INSTALL_DIR="${INSTALL_DIR:-/opt/orca}"
SRC_DIR="${INSTALL_DIR}/src"
APPIMAGE_PATH="${INSTALL_DIR}/orca-linux.AppImage"
UPSTREAM_REPO="${UPSTREAM_REPO:-https://github.com/stablyai/orca.git}"

echo "==> Installing dependencies (git, curl, xvfb, fuse)…"
sudo apt-get update -qq
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y -qq \
  git curl ca-certificates xvfb libfuse2t64 fuse3 \
  || sudo DEBIAN_FRONTEND=noninteractive apt-get install -y -qq \
    git curl ca-certificates xvfb libfuse2 fuse

echo "==> Cloning / updating upstream source from GitHub…"
sudo mkdir -p "${INSTALL_DIR}"
if [[ -d "${SRC_DIR}/.git" ]]; then
  sudo git -C "${SRC_DIR}" fetch --tags --force origin
  sudo git -C "${SRC_DIR}" pull --ff-only origin main
else
  sudo git clone --depth 1 "${UPSTREAM_REPO}" "${SRC_DIR}"
fi
echo "    source: ${SRC_DIR} @ $(sudo git -C "${SRC_DIR}" rev-parse --short HEAD)"

echo "==> Resolving AppImage asset from GitHub Releases API…"
if [[ "${ORCA_VERSION}" == "latest" ]]; then
  RELEASE_JSON="$(curl -sL "https://api.github.com/repos/stablyai/orca/releases/latest")"
  TAG="$(python3 -c 'import json,sys; print(json.load(sys.stdin)["tag_name"])' <<<"${RELEASE_JSON}")"
  DOWNLOAD_URL="$(python3 -c 'import json,sys; a=json.load(sys.stdin)["assets"]; print(next(x["browser_download_url"] for x in a if x["name"]=="orca-linux.AppImage"))' <<<"${RELEASE_JSON}")"
else
  TAG="${ORCA_VERSION}"
  DOWNLOAD_URL="https://github.com/stablyai/orca/releases/download/${ORCA_VERSION}/orca-linux.AppImage"
fi
echo "    tag: ${TAG}"
echo "    url: ${DOWNLOAD_URL}"

TMP="$(mktemp /tmp/orca-linux.AppImage.XXXXXX)"
curl -L --fail --retry 3 --retry-delay 2 -o "${TMP}" "${DOWNLOAD_URL}"
sudo mv "${TMP}" "${APPIMAGE_PATH}"
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
echo "Installed AppImage: ${APPIMAGE_PATH}"
echo "Upstream clone:     ${SRC_DIR}"
echo "Done. Next: ./scripts/serve-orca.sh"
