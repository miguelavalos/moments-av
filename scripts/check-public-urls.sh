#!/usr/bin/env bash
set -euo pipefail

urls=(
  "https://moments-av.avalsys.com/support"
  "https://moments-av.avalsys.com/privacy"
  "https://moments-av.avalsys.com/terms"
  "https://account.avalsys.com/account/delete"
)

failures=0

for url in "${urls[@]}"; do
  if curl --fail --silent --show-error --location --head --max-time 15 "$url" >/dev/null; then
    printf 'OK %s\n' "$url"
    continue
  fi

  if curl --fail --silent --show-error --location --max-time 15 "$url" >/dev/null; then
    printf 'OK %s\n' "$url"
    continue
  fi

  printf 'FAIL %s\n' "$url" >&2
  failures=$((failures + 1))
done

if [ "$failures" -gt 0 ]; then
  exit 1
fi

printf 'Public URL check passed.\n'
