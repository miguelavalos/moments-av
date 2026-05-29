# Moments AV Production Runtime Config

This guide is the Moments AV counterpart to the Tune AV production config flow.
Use it before TestFlight/App Store archives or any signed device QA that must
exercise the production Account AV and Clerk stack.

## Source Of Truth

Runtime values must resolve through the private AVALSYS Varlock/Infisical setup.
Do not add checked-in `.env` files, example secret files, hardcoded production
URLs, or hand-written `Local.xcconfig` values to this public repo.

The local generated file is:

```text
apps/ios/Config/Local.xcconfig
```

It is gitignored generated output. Regenerate it every time you switch between
`dev`, `staging`, and `prod`.

## Required Variables

The production iOS config generator reads these values from Infisical through
Varlock:

| Variable | Production expectation |
| --- | --- |
| `MOMENTSAV_CONVEX_URL` | HTTPS project sync URL for Moments AV production |
| `ACCOUNTAV_API_BASE_URL` | `https://api-account-av.avalsys.com` |
| `ACCOUNTAV_PUBLISHABLE_KEY` | Clerk publishable key with `pk_live_` prefix |
| `AVALSYS_APPLE_DEVELOPMENT_TEAM` | Apple team used for signed builds |
| `MOMENTSAV_SUPPORT_URL` | HTTPS public support URL |
| `MOMENTSAV_PRIVACY_URL` | HTTPS public privacy URL |
| `MOMENTSAV_TERMS_URL` | HTTPS public terms URL |
| `ACCOUNTAV_DELETE_ACCOUNT_URL` | HTTPS Account AV deletion URL |

`ACCOUNTAV_PUBLISHABLE_KEY` is the client-side Clerk key consumed by the shared
`AccountAV` package. If this value is missing or uses a test key in production,
`AccountAVClerk.configureIfPossible` will not configure production Clerk
correctly and sign-in flows will fail or point at the wrong Clerk environment.

## Generate Production Config

Run from the Moments AV repository root:

```bash
scripts/generate-ios-local-xcconfig.sh --env prod
```

The script loads the private suite bootstrap, sets the Infisical environment to
`prod`, validates the canonical Account AV production API host, and writes
`apps/ios/Config/Local.xcconfig`.

If the private suite checkout is not at the standard workspace path, point the
script at it without committing that path:

```bash
AVALSYS_SUITE_DIR=/path/to/private/avalsys-suite \
  scripts/generate-ios-local-xcconfig.sh --env prod
```

## Validate Before Archive

After generating the config, validate the effective Xcode build settings:

```bash
scripts/check-ios-runtime-config.sh --env prod --configuration Release
```

The checker must pass before archiving. It verifies:

- `MOMENTSAV_CONFIG_ENVIRONMENT=prod`
- Release bundle identifier is `com.avalsys.momentsav`
- Account AV API is `https://api-account-av.avalsys.com`
- Clerk publishable key has a `pk_live_` prefix
- project sync URL is a valid HTTPS production URL
- legal/support URLs are HTTPS
- no preview, local, localhost, or `.dev` values are compiled into production
- Account AV callback URI resolves to `com.avalsys.momentsav://callback`

The checker redacts the publishable key in output.

## Clerk Smoke

Do not validate Clerk sign-in with an unsigned compile-only build. Clerk native
auth uses Keychain and app callback handling, so QA needs a signed app with the
expected bundle identifier and entitlements.

`CODE_SIGNING_ALLOWED=NO` is acceptable only for compile checks and isolated
unit tests. It must not be used for Apple/Google sign-in, token, project sync,
media upload, preview, final render, or full workflow smoke testing. On
simulator, unsigned builds can fail with `unexpectedStatus(-34018)` followed by
`signed_out` or "You are signed out"; uninstall the stale app and rebuild with
normal simulator signing enabled.

For production-flavored QA:

1. Generate prod config with `scripts/generate-ios-local-xcconfig.sh --env prod`.
2. Run `scripts/check-ios-runtime-config.sh --env prod --configuration Release`.
3. Build/sign the app with the production bundle identifier.
4. Confirm the Account AV provider allows the redirect URI printed by the
   checker: `com.avalsys.momentsav://callback`.
5. Launch the signed app on device and complete a Clerk-backed Account AV sign-in.
6. Confirm the app reaches signed-in state, shows the Account screen identity,
   and can call a signed Account AV route such as credits or project sync.

If sign-in opens but never returns to the app, first check the redirect URI and
bundle identifier. If sign-in is unavailable immediately, check that
`ACCOUNTAV_PUBLISHABLE_KEY` is present and uses the live Clerk key for prod.

## Safe Defaults For Non-Production

Use `staging` for preview Account AV API and test Clerk keys:

```bash
scripts/generate-ios-local-xcconfig.sh --env staging
scripts/check-ios-runtime-config.sh --env staging
```

Use `dev` for local or preview Account AV API and test Clerk keys:

```bash
scripts/generate-ios-local-xcconfig.sh --env dev
scripts/check-ios-runtime-config.sh --env dev
```

Never reuse a generated `Local.xcconfig` after switching environments.
