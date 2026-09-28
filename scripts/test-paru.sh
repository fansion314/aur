#!/usr/bin/env bash
set -euo pipefail
test "$(uname -sm)" = 'Linux x86_64'
(( EUID != 0 )) || { echo 'Run paru validation as a regular user.' >&2; exit 1; }
paru=${PARU_BIN:-paru}
temporary=$(mktemp -d)
trap 'rm -rf "$temporary"' EXIT
cat > "$temporary/paru.conf" <<EOF
[options]
CloneDir = $temporary/clones

[fansion314]
Url = https://github.com/fansion314/aur.git
Path = packages
EOF
export PARU_CONF="$temporary/paru.conf" LC_ALL=C
"$paru" --pkgbuilds --noconfirm -Sy
"$paru" --pkgbuilds -Sl fansion314 > "$temporary/packages.txt"
cat "$temporary/packages.txt"
python3 - "$temporary/packages.txt" <<'PY'
import json, sys
expected = {name for project in json.load(open('sources.json'))['projects'] for name in project['packages']}
actual = {line.split()[1] for line in open(sys.argv[1]) if line.startswith('fansion314 ')}
assert expected == actual, (expected - actual, actual - expected)
print(f'PARU_REPOSITORY_OK: {len(actual)} source and binary recipes')
PY
"$paru" --pkgbuilds -Si fansion314/dnc-bin fansion314/pi-dnr-bin fansion314/motrix-electron
