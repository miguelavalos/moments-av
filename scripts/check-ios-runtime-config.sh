#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
env_name=""
configuration="Debug"
destination_args=(-destination "generic/platform=iOS")

usage() {
  cat <<'USAGE'
Usage:
  scripts/check-ios-runtime-config.sh --env dev|staging|prod [--configuration Debug|Release] [--device <UDID>]

Validates the effective Xcode build settings for Moments AV without printing
secret values. Generate Local.xcconfig for the target environment first.
USAGE
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    --env)
      env_name="${2:-}"
      shift 2
      ;;
    --configuration)
      configuration="${2:-}"
      shift 2
      ;;
    --device)
      destination_args=(-destination "id=${2:-}")
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown argument: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

case "$env_name" in
  dev|staging|prod)
    ;;
  *)
    echo "--env must be dev, staging, or prod." >&2
    exit 2
    ;;
esac

settings_file="$(mktemp)"
trap 'rm -f "$settings_file"' EXIT

show_settings_args=(
  -project "$repo_root/apps/ios/MomentsAV.xcodeproj"
  -scheme MomentsAV
  -configuration "$configuration"
)

if [ "${#destination_args[@]}" -gt 0 ]; then
  show_settings_args+=("${destination_args[@]}")
fi

xcodebuild "${show_settings_args[@]}" -showBuildSettings > "$settings_file"

setting() {
  local key="$1"
  awk -F= -v wanted="$key" '
    $1 ~ "^[[:space:]]*" wanted "[[:space:]]*$" {
      value=$2
      sub(/^[[:space:]]+/, "", value)
      sub(/[[:space:]]+$/, "", value)
      print value
      exit
    }
  ' "$settings_file"
}

failures=0
fail() {
  printf 'FAIL %s\n' "$1" >&2
  failures=$((failures + 1))
}

require_present() {
  local key="$1"
  local value="$2"
  if [ -z "$value" ] || [ "$value" = '$(inherited)' ]; then
    fail "$key is missing"
  fi
}

product_bundle_identifier="$(setting PRODUCT_BUNDLE_IDENTIFIER)"
config_environment="$(setting MOMENTSAV_CONFIG_ENVIRONMENT)"
api_base_url="$(setting ACCOUNTAV_API_BASE_URL)"
convex_url="$(setting MOMENTSAV_CONVEX_URL)"
publishable_key="$(setting ACCOUNTAV_PUBLISHABLE_KEY)"
development_team="$(setting DEVELOPMENT_TEAM)"

for item in \
  "PRODUCT_BUNDLE_IDENTIFIER:$product_bundle_identifier" \
  "MOMENTSAV_CONFIG_ENVIRONMENT:$config_environment" \
  "ACCOUNTAV_API_BASE_URL:$api_base_url" \
  "MOMENTSAV_CONVEX_URL:$convex_url" \
  "ACCOUNTAV_PUBLISHABLE_KEY:$publishable_key"; do
  require_present "${item%%:*}" "${item#*:}"
done

[ "$config_environment" = "$env_name" ] || fail "MOMENTSAV_CONFIG_ENVIRONMENT must be $env_name, got ${config_environment:-missing}"
[[ "$convex_url" == https://*.convex.cloud ]] || fail "MOMENTSAV_CONVEX_URL must be a Convex cloud URL"

if [ "$env_name" = "prod" ]; then
  [ "$product_bundle_identifier" = "com.avalsys.momentsav" ] || fail "prod bundle must be com.avalsys.momentsav, got $product_bundle_identifier"
  [ "$api_base_url" = "https://api-account-av.avalsys.com" ] || fail "prod API URL mismatch"
  [[ "$publishable_key" == pk_live_* ]] || fail "prod publishable key must use pk_live"
  if printf '%s\n%s\n%s\n' "$product_bundle_identifier" "$api_base_url" "$convex_url" | rg -q 'preview|127\.0\.0\.1|localhost|\.dev'; then
    fail "prod settings contain preview/local/dev values"
  fi
elif [ "$env_name" = "staging" ]; then
  [ "$product_bundle_identifier" = "com.avalsys.momentsav.dev" ] || fail "staging bundle must be com.avalsys.momentsav.dev, got $product_bundle_identifier"
  [ "$api_base_url" = "https://api-account-av-preview.avalsys.com" ] || fail "staging API URL mismatch"
  [[ "$publishable_key" == pk_test_* ]] || fail "staging publishable key must use pk_test"
else
  [ "$product_bundle_identifier" = "com.avalsys.momentsav.dev" ] || fail "$env_name bundle must be com.avalsys.momentsav.dev, got $product_bundle_identifier"
  if [ "$api_base_url" != "http://127.0.0.1:8788" ] && [ "$api_base_url" != "https://api-account-av-preview.avalsys.com" ]; then
    fail "dev API URL must be local worker or preview worker"
  fi
  [[ "$publishable_key" == pk_test_* ]] || fail "$env_name publishable key must use pk_test"
fi

redacted_key=""
if [ -n "$publishable_key" ]; then
  redacted_key="${publishable_key:0:8}...${#publishable_key}"
fi

cat <<EOF
Moments AV iOS runtime config ($env_name)
  configuration: $configuration
  product bundle: $product_bundle_identifier
  config environment: $config_environment
  development team: ${development_team:-unknown}
  Account AV API: $api_base_url
  Convex URL: $convex_url
  publishable key: $redacted_key
EOF

if [ "$failures" -gt 0 ]; then
  exit 1
fi

echo "Runtime config check passed."
