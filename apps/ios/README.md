# Moments AV iOS

SwiftUI client for Moments AV.

This public README is intentionally limited to frontend build and test notes.
Business rules, pricing, provider/model routing, purchase setup, App Store
review handoff, and private backend operations belong in the private AVALSYS
suite.

For full local setup, see [../../docs/install-ios.md](../../docs/install-ios.md).
For client workflow ownership rules, see
[../../docs/client-architecture-guardrails.md](../../docs/client-architecture-guardrails.md).
For runtime-config hygiene, see
[../../docs/production-config.md](../../docs/production-config.md).

## Runtime Config

Committed config files keep runtime values blank or public-safe. Local and
release values are generated into ignored local config by private maintainer
tooling.

Do not commit:

- generated `Local.xcconfig`;
- production URLs or private endpoints;
- signing team IDs or provisioning material;
- client keys generated for a specific environment;
- provider, purchase, promo, or reviewer configuration.

## Build

Generate the Xcode project after editing `project.yml`:

```bash
xcodegen generate --spec apps/ios/project.yml
```

Build for simulator:

```bash
xcodebuild -project apps/ios/MomentsAV.xcodeproj -scheme MomentsAV -destination 'generic/platform=iOS Simulator' CODE_SIGNING_ALLOWED=NO build
```

That command is compile-only. Do not use `CODE_SIGNING_ALLOWED=NO` for signed
runtime flows. Account/session flows and end-to-end smoke tests require normal
simulator or device signing.

Validate effective runtime config after generating local settings:

```bash
scripts/check-ios-runtime-config.sh --env staging
```

Use the private release runbook for production archive checks.

## Test

Run the focused simulator test suite after generating the Xcode project:

```bash
xcodebuild test -project apps/ios/MomentsAV.xcodeproj -scheme MomentsAV -destination 'platform=iOS Simulator,name=iPhone 16,OS=18.5' CODE_SIGNING_ALLOWED=NO
```
