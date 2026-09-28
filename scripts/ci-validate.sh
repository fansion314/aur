#!/usr/bin/env bash
set -euo pipefail
test "$(uname -sm)" = 'Linux x86_64'
if (( EUID == 0 )); then
  pacman -Syu --noconfirm --needed base-devel git python libarchive asar xz
  useradd --create-home --uid "${BUILD_UID:-1001}" builder
  chown -R builder:builder /repo
  # Do not forward GitHub credentials to code evaluated by makepkg.
  exec runuser -u builder -- env -u GH_TOKEN -u GITHUB_TOKEN python scripts/validate.py --build-bins --changed-only
fi
exec python scripts/validate.py --build-bins --changed-only
