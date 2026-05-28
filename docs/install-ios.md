# Install Moments AV iOS

This guide covers local iOS setup for the public Moments AV app repo. It does
not include production credentials, private provider setup, or App Store Connect
operations.

## Requirements

- Xcode with the iOS SDK used by the project.
- XcodeGen available on `PATH`.
- Access to the sibling public `account-av` checkout at the expected workspace
  path.
- For authenticated runtime flows, access to the private AVALSYS suite repo and
  its Infisical/Varlock setup.

## Generate The Xcode Project

Run from the repository root:

```bash
xcodegen generate --spec apps/ios/project.yml
```

Re-run this command after changing `apps/ios/project.yml`.

## Public Build Without Runtime Secrets

The committed configs intentionally leave runtime endpoints and publishable keys
blank. A public simulator build can still compile without signing:

```bash
xcodebuild -project apps/ios/MomentsAV.xcodeproj -scheme MomentsAV -destination 'generic/platform=iOS Simulator' CODE_SIGNING_ALLOWED=NO build
```

This verifies the app compiles, but signed-in Account AV, project sync, media
upload, preview, final render, and deletion flows need local environment
configuration.

## Local Runtime Config

Generate the untracked iOS config from the private suite repo:

```bash
scripts/generate-ios-local-xcconfig.sh --env staging
```

Valid environments:

- `dev`: development bundle ID with local or preview Account AV API.
- `staging`: development bundle ID with preview Account AV API.
- `prod`: production bundle ID with production Account AV API.

The generated file is:

```text
apps/ios/Config/Local.xcconfig
```

It is intentionally gitignored and must not be committed.

For the production variable contract, Clerk expectations, and signed Account AV
smoke flow, see [Production runtime config](production-config.md).

Validate the effective build settings before running the app:

```bash
scripts/check-ios-runtime-config.sh --env staging
```

For App Store archive preparation, regenerate production local config and check
Release settings:

```bash
scripts/generate-ios-local-xcconfig.sh --env prod
scripts/check-ios-runtime-config.sh --env prod --configuration Release
```

The runtime check prints non-secret values and redacts the publishable key. It
fails if the bundle ID, environment, Account AV API host, project sync URL, version,
build number, legal URLs, or key prefix do not match the selected environment.

## Tests

Run the focused simulator test suite:

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

This blocks tracked local configs, local worker URLs, development team IDs, and
secret-looking keys from entering the public repo.
The documentation link check catches broken relative links across public
Markdown files.
The canonical asset gate blocks accidental App Store icon, splash, AV monogram,
or Avi artwork commits until approved assets are ready.

## App Store Preparation Links

- [Release checklist](release-checklist.md)
- [App Privacy inventory](app-privacy-inventory.md)

Use those documents before creating screenshots, App Store metadata, review
notes, or production archives.
