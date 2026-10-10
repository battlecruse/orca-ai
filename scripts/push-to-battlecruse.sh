#!/usr/bin/env bash
# Push this scaffold to github.com/battlecruse/orca-ai (requires gh auth as battlecruse).
set -euo pipefail

OWNER="${GITHUB_OWNER:-battlecruse}"
REPO="${GITHUB_REPO:-orca-ai}"
BRANCH="${PUSH_BRANCH:-cursor/orca-ai-github-setup-87b8}"
REMOTE_NAME="${REMOTE_NAME:-github}"

if ! gh auth status -h github.com >/dev/null 2>&1; then
  cat <<EOF >&2
ERROR: gh is not authenticated for github.com on this machine.

Single remaining user action (pick one):
  A) In this VM:  gh auth login -h github.com
     then re-run: ./scripts/push-to-battlecruse.sh
  B) On your machine (already logged into github.com as ${OWNER}):
     1. Create empty repo https://github.com/${OWNER}/${REPO}
     2. git remote add ${REMOTE_NAME} https://github.com/${OWNER}/${REPO}.git
     3. git push -u ${REMOTE_NAME} ${BRANCH}
     4. Open draft PR: ${BRANCH} → main
EOF
  exit 1
fi

LOGIN="$(gh api user --jq .login)"
echo "Authenticated as: ${LOGIN}"
if [[ "${LOGIN}" != "${OWNER}" ]]; then
  echo "WARNING: expected ${OWNER}, got ${LOGIN}. Continuing anyway…" >&2
fi

if ! gh repo view "${OWNER}/${REPO}" >/dev/null 2>&1; then
  echo "==> Creating ${OWNER}/${REPO}…"
  gh repo create "${OWNER}/${REPO}" --private --description "Orca (오르카AI) install + GitHub hosting scaffold" --confirm
fi

REMOTE_URL="https://github.com/${OWNER}/${REPO}.git"
if git remote get-url "${REMOTE_NAME}" >/dev/null 2>&1; then
  git remote set-url "${REMOTE_NAME}" "${REMOTE_URL}"
else
  git remote add "${REMOTE_NAME}" "${REMOTE_URL}"
fi

echo "==> Pushing ${BRANCH} → ${OWNER}/${REPO}…"
git push -u "${REMOTE_NAME}" "${BRANCH}"

echo "==> Opening draft PR (if main exists)…"
gh pr create --repo "${OWNER}/${REPO}" --base main --head "${BRANCH}" --draft \
  --title "Orca(오르카) Linux 설치 스캐폴드 및 GitHub 탑재 가이드" \
  --body "Install/serve scripts and README for stablyai/orca (GitHub Releases + source clone)." \
  || echo "PR create skipped/failed (maybe already exists). Check: https://github.com/${OWNER}/${REPO}/pulls"

echo "Done: https://github.com/${OWNER}/${REPO}"
