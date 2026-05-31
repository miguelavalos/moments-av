# Install Moments AV iOS

This guide covers local setup for the public Moments AV iOS client. It does not
include production credentials, private provider setup, App Store Connect
operations, pricing, or business configuration.

## Requirements

- Xcode with the iOS SDK used by the project.
- XcodeGen available on `PATH`.
- Access to the sibling public `account-av` checkout at the expected workspace
  path.
- Private runtime access only when testing signed-in flows.

## Generate The Xcode Project

Run from the repository root:

```bash
xcodegen generate --spec apps/ios/project.yml
```

Re-run this command after changing `apps/ios/project.yml`.

## Public Compile Check

The committed configs intentionally leave runtime endpoints and publishable
client keys blank. A public simulator build can still compile without signing:

```bash
xcodebuild -project apps/ios/MomentsAV.xcodeproj -scheme MomentsAV -destination 'generic/platform=iOS Simulator' CODE_SIGNING_ALLOWED=NO build
```

This verifies the app compiles. Do not use this unsigned build for sign-in,
account, purchase, upload, render, or deletion smoke tests. Those flows require
normal simulator or device signing and local runtime configuration generated
outside this public repo.

## Local Runtime Config

Runtime config is generated into:

```text
apps/ios/Config/Local.xcconfig
```

That file is intentionally gitignored and must not be committed.

Generate and validate local runtime config through the private AVALSYS tooling
available to maintainers. Public docs should describe the hygiene rules, not
the production values. See [production-config.md](production-config.md).

After generating local settings, validate the effective build settings:

```bash
scripts/check-ios-runtime-config.sh --env staging
```

Use the environment required by the private release runbook when preparing a
signed release or App Store archive.

## Signed Runtime Smoke

For any flow that depends on a real account session, build and launch without
`CODE_SIGNING_ALLOWED=NO`:

```bash
xcodebuild -project apps/ios/MomentsAV.xcodeproj -scheme MomentsAV -destination 'platform=iOS Simulator,name=iPhone 17' build
```

If the simulator has already run an unsigned build and auth reports Keychain or
signed-out errors, remove stale app state before reinstalling a signed simulator
build:

```bash
xcrun simctl uninstall booted com.avalsys.momentsav.dev
```

Then rebuild with simulator signing enabled.

## Tests

Run the focused simulator test suite after generating the Xcode project:

```bash
xcodebuild test -project apps/ios/MomentsAV.xcodeproj -scheme MomentsAV -destination 'platform=iOS Simulator,name=iPhone 16,OS=18.5' CODE_SIGNING_ALLOWED=NO
```

If the requested simulator is unavailable, pick an installed iPhone simulator
and keep the destination explicit.

## Public Config Hygiene

Before committing, run:

```bash
scripts/check-public-release-readiness.sh
```

This blocks tracked local configs, local worker URLs, development team IDs,
secret-looking keys, broken public Markdown links, and accidental final artwork
that has not passed the public asset gate.
