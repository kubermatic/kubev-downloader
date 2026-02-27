#!/usr/bin/env sh

# Copyright 2026 The Kubermatic Virtualization Authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.


# Downloads and installs the kubev-downloader binary from the latest
# (or a pinned) GitHub release.
#
# Usage:
#   curl -sfL https://raw.githubusercontent.com/kubermatic/kubev-downloader/main/get.sh | sh
#
# Environment variables:
#   KUBEV_VERSION   - pin a specific release tag, e.g. "v1.2.0" (default: latest)
#   INSTALL_DIR     - directory to install the binary into   (default: current directory)

set -eu

# ─── Configuration ────────────────────────────────────────────────────────────

BINARY_NAME="kubev-downloader"
GITHUB_REPO="kubermatic/kubev-downloader"
INSTALL_DIR="${INSTALL_DIR:-.}"

# ─── Helpers ──────────────────────────────────────────────────────────────────

log()  { printf '[%s] %s\n' "$(date -u '+%Y-%m-%dT%H:%M:%SZ')" "$*" >&2; }
fail() { printf '[%s] FATAL  %s\n' "$(date -u '+%Y-%m-%dT%H:%M:%SZ')" "$*" >&2; exit 1; }

need() {
  command -v "$1" >/dev/null 2>&1 || fail "'$1' is required but not installed."
}

# ─── Dependency check ─────────────────────────────────────────────────────────

need curl
need unzip
need sha256sum

# ─── OS / arch detection ──────────────────────────────────────────────────────

OS="$(uname -s)"
ARCH="$(uname -m)"

case "$OS" in
  Linux)  OS="linux" ;;
  Darwin) OS="darwin" ;;
  *)      fail "Unsupported operating system: $OS" ;;
esac

case "$ARCH" in
  x86_64)          ARCH="amd64" ;;
  aarch64 | arm64) ARCH="arm64" ;;
  *)               fail "Unsupported architecture: $ARCH" ;;
esac

PLATFORM="${OS}-${ARCH}"
log "Platform        : $PLATFORM"

# ─── Version resolution ───────────────────────────────────────────────────────

if [ -z "${KUBEV_VERSION:-}" ]; then
  log "Resolving latest kubermatic virtualization release ..."
  KUBEV_VERSION="$(
    curl -sfL "https://api.github.com/repos/${GITHUB_REPO}/releases/latest" \
      | grep '"tag_name"' \
      | head -1 \
      | sed 's/.*"tag_name": *"\([^"]*\)".*/\1/'
  )"
  [ -n "$KUBEV_VERSION" ] || fail "Unable to resolve latest release tag. Set KUBEV_VERSION explicitly and retry."
  log "Resolved version: $KUBEV_VERSION"
else
  log "Pinned version  : $KUBEV_VERSION"
fi

# ─── Download ─────────────────────────────────────────────────────────────────

BASE_URL="https://github.com/${GITHUB_REPO}/releases/download/${KUBEV_VERSION}"
ARCHIVE="${BINARY_NAME}-${KUBEV_VERSION}-${PLATFORM}.zip"
CHECKSUMS="${BINARY_NAME}-${KUBEV_VERSION}-checksums.txt"

TMPDIR="$(mktemp -d)"
trap 'rm -rf "$TMPDIR"' EXIT

log "Pulling KubeV Downloader : $ARCHIVE"
curl -sfL --retry 3 "${BASE_URL}/${ARCHIVE}" -o "${TMPDIR}/${ARCHIVE}" \
  || fail "Failed to pull asset — URL: ${BASE_URL}/${ARCHIVE}"

log "Pulling checksum manifest: $CHECKSUMS"
curl -sfL --retry 3 "${BASE_URL}/${CHECKSUMS}" -o "${TMPDIR}/${CHECKSUMS}" \
  || fail "Failed to pull checksum manifest — URL: ${BASE_URL}/${CHECKSUMS}"

# ─── Checksum verification ────────────────────────────────────────────────────

log "Verifying SHA-256 integrity ..."
(
  cd "$TMPDIR"
  grep "${ARCHIVE}" "${CHECKSUMS}" | sha256sum --check --status -
) || fail "Integrity check failed — archive may be corrupted or tampered with"
log "Integrity check passed"

# ─── Extract & install ────────────────────────────────────────────────────────

log "Extracting binary ..."
unzip -q "${TMPDIR}/${ARCHIVE}" -d "$TMPDIR"

BINARY="${TMPDIR}/${BINARY_NAME}"
[ -f "$BINARY" ] || fail "Expected binary '${BINARY_NAME}' not found in archive"
chmod +x "$BINARY"

log "Installing to ${INSTALL_DIR}/${BINARY_NAME} ..."
mv "$BINARY" "${INSTALL_DIR}/${BINARY_NAME}"

# ─── Done ─────────────────────────────────────────────────────────────────────

log "Successfully installed ${BINARY_NAME} ${KUBEV_VERSION}"
