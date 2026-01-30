#!/usr/bin/env bash
set -euo pipefail

ZIP_PATH="${1:-}"
COMMIT_MSG="${2:-"Docs: add roadmap, issue backlog, and GitHub templates"}"

if [[ -z "${ZIP_PATH}" ]]; then
  echo "Usage: $0 /path/to/Luciuz-updated-docs-issues.zip [commit message]"
  exit 1
fi

if [[ ! -f "${ZIP_PATH}" ]]; then
  echo "ERROR: zip not found: ${ZIP_PATH}"
  exit 1
fi

# Must be inside a git repo
git rev-parse --show-toplevel >/dev/null 2>&1 || { echo "ERROR: not a git repo"; exit 1; }
REPO_ROOT="$(git rev-parse --show-toplevel)"
cd "${REPO_ROOT}"

# Safety checks
BRANCH="$(git rev-parse --abbrev-ref HEAD)"
if [[ "${BRANCH}" != "main" ]]; then
  echo "ERROR: you're on branch '${BRANCH}'. Switch to main first."
  exit 1
fi

if [[ -n "$(git status --porcelain)" ]]; then
  echo "ERROR: working tree not clean. Commit/stash first."
  git status --porcelain
  exit 1
fi

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "${TMP_DIR}"' EXIT

unzip -q "${ZIP_PATH}" -d "${TMP_DIR}"

SRC="${TMP_DIR}/Luciuz-main"
if [[ ! -d "${SRC}" ]]; then
  echo "ERROR: expected '${SRC}' inside zip"
  exit 1
fi

echo "==> Applying pack files into repo..."

# Copy only the intended “doc/metadata” files (avoid touching src code)
# Overwrite if present.
rsync -a "${SRC}/README.md" "./" || true
rsync -a "${SRC}/docs/" "./docs/" || true
rsync -a "${SRC}/.github/" "./.github/" || true

# Optional: project meta files (safe to overwrite)
for f in CHANGELOG.md CONTRIBUTING.md SECURITY.md NOTICE LICENSE Cargo.toml; do
  if [[ -f "${SRC}/${f}" ]]; then
    rsync -a "${SRC}/${f}" "./"
  fi
done

echo "==> Done. Git diff summary:"
git status --short

if [[ -z "$(git status --porcelain)" ]]; then
  echo "No changes detected. Nothing to commit."
  exit 0
fi

git add README.md docs .github CHANGELOG.md CONTRIBUTING.md SECURITY.md NOTICE LICENSE Cargo.toml 2>/dev/null || true
git commit -m "${COMMIT_MSG}"
git push origin main

echo "✅ Pack applied + committed + pushed on main."
