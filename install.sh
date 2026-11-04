#!/usr/bin/env sh
# Prelint CLI installer
#
# Usage:
#   curl -fsSL https://install.prelint.com | sh
#
# Environment variables:
#   PRELINT_VERSION       Version to install (default: latest, e.g. v0.1.0).
#                         A set version also turns off automatic updates.
#   PRELINT_INSTALL_DIR   Install location (default: ~/.local/bin)
#
# Sources the binary from https://github.com/prelint/cli/releases.
# Verifies the SHA256 against the published SHA256SUMS file before installing.
#
# Supported: macOS (arm64, x86_64), Linux (x86_64 / musl).
# Not yet supported: Linux arm64, Windows (install via brew or download manually).

set -eu

PRELINT_REPO="prelint/cli"
PRELINT_VERSION="${PRELINT_VERSION:-latest}"
PRELINT_INSTALL_DIR="${PRELINT_INSTALL_DIR:-${HOME}/.local/bin}"

err() {
  printf 'prelint-install: error: %s\n' "$1" >&2
  exit 1
}

info() {
  printf 'prelint-install: %s\n' "$1"
}

require_cmd() {
  command -v "$1" >/dev/null 2>&1 || err "required command not found: $1"
}

detect_platform() {
  uname_s="$(uname -s)"
  uname_m="$(uname -m)"
  case "${uname_s}-${uname_m}" in
    Darwin-arm64)         echo "macos-arm64" ;;
    Darwin-x86_64)        echo "macos-x86_64" ;;
    Linux-x86_64|Linux-amd64) echo "linux-x86_64-musl" ;;
    Linux-aarch64|Linux-arm64)
      err "Linux arm64 is not yet a published target; please file an issue at https://github.com/${PRELINT_REPO}/issues" ;;
    *)
      err "unsupported platform: ${uname_s} ${uname_m}; supported: macOS (arm64/x86_64), Linux x86_64" ;;
  esac
}

resolve_version() {
  if [ "${PRELINT_VERSION}" != "latest" ]; then
    echo "${PRELINT_VERSION}"
    return
  fi
  # Use the GitHub redirect to discover the latest tag without parsing JSON.
  redirect="$(curl -fsSLI -o /dev/null -w '%{url_effective}' \
    "https://github.com/${PRELINT_REPO}/releases/latest")"
  case "${redirect}" in
    */releases/tag/*) echo "${redirect##*/tag/}" ;;
    *) err "could not determine latest version (got: ${redirect})" ;;
  esac
}

download() {
  url="$1"
  dest="$2"
  curl -fsSL -o "${dest}" "${url}" \
    || err "download failed: ${url}"
}

verify_sha256() {
  sums_file="$1"
  artifact_name="$2"

  expected="$(awk -v n="${artifact_name}" '$2 == n {print $1}' "${sums_file}")"
  if [ -z "${expected}" ]; then
    err "no SHA256 entry for ${artifact_name} in SHA256SUMS"
  fi

  if command -v sha256sum >/dev/null 2>&1; then
    actual="$(sha256sum "${artifact_name}" | awk '{print $1}')"
  elif command -v shasum >/dev/null 2>&1; then
    actual="$(shasum -a 256 "${artifact_name}" | awk '{print $1}')"
  else
    err "no SHA256 tool available (need sha256sum or shasum)"
  fi

  if [ "${expected}" != "${actual}" ]; then
    err "SHA256 mismatch for ${artifact_name}: expected ${expected}, got ${actual}"
  fi
}

main() {
  require_cmd curl
  require_cmd uname
  require_cmd mkdir
  require_cmd mv

  platform="$(detect_platform)"
  version="$(resolve_version)"
  artifact="prelint-${platform}"
  base="https://github.com/${PRELINT_REPO}/releases/download/${version}"

  info "installing prelint ${version} for ${platform}"

  tmp="$(mktemp -d 2>/dev/null || mktemp -d -t prelint-install)"
  trap 'rm -rf "${tmp}"' EXIT INT TERM
  cd "${tmp}"

  download "${base}/${artifact}" "${artifact}"
  download "${base}/SHA256SUMS" "SHA256SUMS"

  verify_sha256 "SHA256SUMS" "${artifact}"

  chmod +x "${artifact}"
  mkdir -p "${PRELINT_INSTALL_DIR}"
  mv "${artifact}" "${PRELINT_INSTALL_DIR}/prelint"

  info "installed: ${PRELINT_INSTALL_DIR}/prelint"

  # Under sudo, the setting goes to the config of the person who ran sudo.
  as_user=""
  if [ "$(id -u)" = "0" ] && [ -n "${SUDO_USER:-}" ] && [ "${SUDO_USER}" != "root" ]; then
    as_user="sudo -H -u ${SUDO_USER}"
  fi
  # A version without automatic updates rejects the key, and has nothing to turn off.
  if [ "${PRELINT_VERSION}" != "latest" ] \
    && ${as_user} "${PRELINT_INSTALL_DIR}/prelint" config set auto_update false >/dev/null 2>&1; then
    info "automatic updates are off, so ${version} stays installed"
    info "to turn them on, run: prelint config set auto_update true"
  fi

  case ":${PATH}:" in
    *":${PRELINT_INSTALL_DIR}:"*)
      info "run: prelint --version"
      ;;
    *)
      info "warning: ${PRELINT_INSTALL_DIR} is not on your PATH"
      info "add this to your shell profile:"
      info "  export PATH=\"${PRELINT_INSTALL_DIR}:\$PATH\""
      info "then run: prelint --version"
      ;;
  esac
}

main "$@"
