#!/usr/bin/env nix-shell
#!nix-shell -i bash -p curl jq gnused nix

set -euo pipefail

repo="$(git rev-parse --show-toplevel)"
package_file="${repo}/pkgs/by-name/ze/zen-browser-unwrapped/package.nix"

current_version="$(
  sed -n 's/^  version = "\([^"]*\)";$/\1/p' "${package_file}"
)"

release="$(
  curl -fsSL \
    -H 'Accept: application/vnd.github+json' \
    -H 'User-Agent: nix-packages-zen-browser-updater' \
    'https://api.github.com/repos/zen-browser/desktop/releases/latest'
)"

latest_version="$(jq -er '.tag_name' <<<"${release}")"
latest_version="${latest_version#v}"

if [[ "${current_version}" == "${latest_version}" ]]; then
  echo "zen-browser is up-to-date: ${current_version}"
  exit 0
fi

get_hash() {
  local url="${1}"

  nix store prefetch-file \
    --hash-type sha256 \
    --json \
    "${url}" |
    jq -er '.hash'
}

x86_64_hash="$(
  get_hash \
    "https://github.com/zen-browser/desktop/releases/download/${latest_version}/zen.linux-x86_64.tar.xz"
)"

aarch64_hash="$(
  get_hash \
    "https://github.com/zen-browser/desktop/releases/download/${latest_version}/zen.linux-aarch64.tar.xz"
)"

sed -i \
  "s|^  version = \".*\";|  version = \"${latest_version}\";|" \
  "${package_file}"

sed -i \
  "/^  x86_64-linux = {/,/^  };/ s|^    hash = .*;|    hash = \"${x86_64_hash}\";|" \
  "${package_file}"

sed -i \
  "/^  aarch64-linux = {/,/^  };/ s|^    hash = .*;|    hash = \"${aarch64_hash}\";|" \
  "${package_file}"

echo "Updated zen-browser: ${current_version} -> ${latest_version}"
