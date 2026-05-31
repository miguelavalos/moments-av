#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
workspace_root="$(cd "$repo_root/../.." && pwd)"
suite_root="${AVALSYS_SUITE_DIR:-$workspace_root/private/avalsys-suite}"
output_path="$repo_root/apps/ios/Config/Local.xcconfig"
env_name=""
stdout_only=0

usage() {
  cat <<'USAGE'
Usage:
  scripts/generate-ios-local-xcconfig.sh --env dev|staging|prod [--stdout]

Generates apps/ios/Config/Local.xcconfig from the private Infisical/Varlock
configuration. The output file is gitignored and must not be committed.
USAGE
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    --env)
      env_name="${2:-}"
      shift 2
      ;;
    --stdout)
      stdout_only=1
      shift
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

if [ ! -d "$suite_root" ]; then
  echo "Private avalsys suite repo not found: $suite_root" >&2
  echo "Set AVALSYS_SUITE_DIR if it lives somewhere else." >&2
  exit 1
fi

varlock_bin="$suite_root/node_modules/.bin/varlock"
if [ ! -x "$varlock_bin" ]; then
  echo "varlock CLI is required at $varlock_bin. Run bun install in $suite_root." >&2
  exit 1
fi

eval "$("$suite_root/scripts/resolve-infisical-bootstrap-env.sh" local)"
export INFISICAL_ENVIRONMENT="$env_name"

tmpdir="$(mktemp -d "$suite_root/tmp/moments-ios-config.XXXXXX")"
cleanup() {
  rm -rf "$tmpdir"
}
trap cleanup EXIT

cat > "$tmpdir/.env.schema" <<'SCHEMA'
# This env file uses @env-spec - see https://varlock.dev/env-spec for more info
#
# @plugin(@varlock/infisical-plugin@1.1.0)
# @initInfisical(
#   projectId=$INFISICAL_PROJECT_ID,
#   environment=$INFISICAL_ENVIRONMENT,
#   clientId=$INFISICAL_CLIENT_ID,
#   clientSecret=$INFISICAL_CLIENT_SECRET,
#   siteUrl=https://eu.infisical.com
# )
# @defaultRequired=infer @defaultSensitive=false
# ----------

INFISICAL_PROJECT_ID=
INFISICAL_ENVIRONMENT=
INFISICAL_CLIENT_ID=
INFISICAL_CLIENT_SECRET=

MOMENTSAV_CONVEX_URL=infisical()
ACCOUNTAV_API_BASE_URL=infisical()
ACCOUNTAV_PUBLISHABLE_KEY=infisical()
MOMENTSAV_REVENUECAT_PUBLIC_API_KEY=infisical()
MOMENTSAV_REVENUECAT_OFFERING_ID=infisical()
MOMENTSAV_REVENUECAT_MONTHLY_PACKAGE_ID=infisical()
AVALSYS_APPLE_DEVELOPMENT_TEAM=infisical()
MOMENTSAV_SUPPORT_URL=https://moments-av.avalsys.com/support
MOMENTSAV_PRIVACY_URL=https://moments-av.avalsys.com/privacy
MOMENTSAV_TERMS_URL=https://moments-av.avalsys.com/terms
ACCOUNTAV_DELETE_ACCOUNT_URL=https://account-av.avalsys.com/account/delete
SCHEMA

read_required_config() {
  local name="$1"
  local value

  if value="$("$varlock_bin" printenv --path "$tmpdir" "$name" 2>/dev/null)" && [ -n "$value" ]; then
    printf '%s' "$value"
    return 0
  fi

  echo "Missing $name in Infisical environment $env_name." >&2
  exit 1
}

require_http_url() {
  local name="$1"
  local value="$2"

  case "$value" in
    http://*|https://*)
      ;;
    *)
      echo "$name must be an http(s) URL." >&2
      exit 1
      ;;
  esac
}

require_expected_url() {
  local name="$1"
  local value="$2"
  local expected="$3"

  if [ "$value" != "$expected" ]; then
    echo "$name for $env_name must be $expected." >&2
    exit 1
  fi
}

require_revenuecat_public_key() {
  local value="$1"

  case "$value" in
    appl_*)
      ;;
    sk_*)
      echo "MOMENTSAV_REVENUECAT_PUBLIC_API_KEY must be a public Apple SDK key starting with appl_, not a RevenueCat secret key." >&2
      exit 1
      ;;
    *)
      echo "MOMENTSAV_REVENUECAT_PUBLIC_API_KEY must be a public Apple SDK key starting with appl_." >&2
      exit 1
      ;;
  esac
}

escape_xcconfig_value() {
  printf '%s' "$1" | sed 's#/#$(XCCONFIG_SLASH)#g'
}

moments_convex_url="$(read_required_config MOMENTSAV_CONVEX_URL)"
account_api_base_url="$(read_required_config ACCOUNTAV_API_BASE_URL)"
account_publishable_key="$(read_required_config ACCOUNTAV_PUBLISHABLE_KEY)"
revenuecat_api_key="$(read_required_config MOMENTSAV_REVENUECAT_PUBLIC_API_KEY)"
revenuecat_offering_id="$(read_required_config MOMENTSAV_REVENUECAT_OFFERING_ID)"
revenuecat_monthly_package_id="$(read_required_config MOMENTSAV_REVENUECAT_MONTHLY_PACKAGE_ID)"
development_team="$(read_required_config AVALSYS_APPLE_DEVELOPMENT_TEAM)"
support_url="$(read_required_config MOMENTSAV_SUPPORT_URL)"
privacy_url="$(read_required_config MOMENTSAV_PRIVACY_URL)"
terms_url="$(read_required_config MOMENTSAV_TERMS_URL)"
delete_account_url="$(read_required_config ACCOUNTAV_DELETE_ACCOUNT_URL)"

require_http_url MOMENTSAV_CONVEX_URL "$moments_convex_url"
require_http_url ACCOUNTAV_API_BASE_URL "$account_api_base_url"
require_http_url MOMENTSAV_SUPPORT_URL "$support_url"
require_http_url MOMENTSAV_PRIVACY_URL "$privacy_url"
require_http_url MOMENTSAV_TERMS_URL "$terms_url"
require_http_url ACCOUNTAV_DELETE_ACCOUNT_URL "$delete_account_url"
require_revenuecat_public_key "$revenuecat_api_key"
[ -n "$revenuecat_offering_id" ] || {
  echo "MOMENTSAV_REVENUECAT_OFFERING_ID must not be empty." >&2
  exit 1
}
[ -n "$revenuecat_monthly_package_id" ] || {
  echo "MOMENTSAV_REVENUECAT_MONTHLY_PACKAGE_ID must not be empty." >&2
  exit 1
}

if [ "$env_name" = "staging" ]; then
  require_expected_url ACCOUNTAV_API_BASE_URL "$account_api_base_url" "https://api-account-av-preview.avalsys.com"
elif [ "$env_name" = "prod" ]; then
  require_expected_url ACCOUNTAV_API_BASE_URL "$account_api_base_url" "https://api-account-av.avalsys.com"
fi

generated_at="$(date -u '+%Y-%m-%dT%H:%M:%SZ')"
content="$(cat <<EOF
// GENERATED by scripts/generate-ios-local-xcconfig.sh --env $env_name
// Generated at $generated_at
// Do not edit manually. Regenerate when switching environments.
XCCONFIG_SLASH = /
MOMENTSAV_CONFIG_ENVIRONMENT = $env_name
AVALSYS_APPLE_DEVELOPMENT_TEAM = $development_team
ACCOUNTAV_PUBLISHABLE_KEY = $account_publishable_key
MOMENTSAV_REVENUECAT_PUBLIC_API_KEY = $revenuecat_api_key
MOMENTSAV_REVENUECAT_OFFERING_ID = $revenuecat_offering_id
MOMENTSAV_REVENUECAT_MONTHLY_PACKAGE_ID = $revenuecat_monthly_package_id
ACCOUNTAV_API_BASE_URL = $(escape_xcconfig_value "$account_api_base_url")
MOMENTSAV_CONVEX_URL = $(escape_xcconfig_value "$moments_convex_url")
MOMENTSAV_SUPPORT_URL = $(escape_xcconfig_value "$support_url")
MOMENTSAV_PRIVACY_URL = $(escape_xcconfig_value "$privacy_url")
MOMENTSAV_TERMS_URL = $(escape_xcconfig_value "$terms_url")
ACCOUNTAV_DELETE_ACCOUNT_URL = $(escape_xcconfig_value "$delete_account_url")
EOF
)"

if [ "$stdout_only" -eq 1 ]; then
  printf '%s\n' "$content"
else
  umask 077
  mkdir -p "$(dirname "$output_path")"
  printf '%s\n' "$content" > "$output_path"
  echo "Generated $output_path for $env_name."
fi
