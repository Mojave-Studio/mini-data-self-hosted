#!/usr/bin/env bash
# One-time publish helper — run after `gh auth login` if the repo is not on GitHub yet.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

if ! command -v gh >/dev/null 2>&1; then
  echo "Install GitHub CLI: https://cli.github.com/"
  exit 1
fi

gh auth status >/dev/null 2>&1 || {
  echo "Run: gh auth login"
  exit 1
}

if gh repo view mojavestudio/mini-data-self-hosted >/dev/null 2>&1; then
  echo "Repository already exists — pushing main…"
  git push -u origin main
else
  echo "Creating mojavestudio/mini-data-self-hosted and pushing…"
  gh repo create mojavestudio/mini-data-self-hosted \
    --public \
    --description "Provision Cloudflare D1/R2 for Mini Data — UI at minidata.io, data in your account." \
    --source=. \
    --remote=origin \
    --push
fi

echo "Done: https://github.com/mojavestudio/mini-data-self-hosted"
