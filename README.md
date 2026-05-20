# Moments AV

[![Public Readiness](https://github.com/miguelavalos/moments-av/actions/workflows/public-readiness.yml/badge.svg)](https://github.com/miguelavalos/moments-av/actions/workflows/public-readiness.yml)

Open-source frontend app repo for Moments AV.

Moments AV helps people turn personal photos and short clips into short memory
videos.

This repository contains the public client app code and public user-facing docs.
It intentionally excludes credentials, provider configuration, internal
operations, and private service implementation details.

Project status: iOS v1 frontend scaffold with account, credit gate, draft,
media, story, preview, final render, and deletion flows. Production endpoints
and store credentials are configured outside this public repo.

## License

This repository is released under the MIT license. See [LICENSE](LICENSE).

## Repository Shape

```text
apps/
  ios/      SwiftUI iOS app
docs/
  README.md
  install-ios.md
  release-checklist.md
  app-privacy-inventory.md
  app-store-metadata.md
  app-store-screenshots.md
  app-review-notes.md
```

## What Is Included

- iOS frontend app code;
- public setup docs;
- public support and security policies;
- client-side code that is safe to publish.

## Local Setup

See [docs/install-ios.md](docs/install-ios.md) for the full iOS setup flow.

Quick build check:

1. Install Xcode and XcodeGen.
2. Run `xcodegen generate --spec apps/ios/project.yml`.
3. Build with `xcodebuild -project apps/ios/MomentsAV.xcodeproj -scheme MomentsAV -destination 'generic/platform=iOS Simulator' CODE_SIGNING_ALLOWED=NO build`.

Generated local config, signing material, and machine-specific files must stay
out of git.

Run public release checks before opening a PR or preparing release docs:

```bash
scripts/check-public-release-readiness.sh
```

## Contributing And Security

- Contribution guide: [CONTRIBUTING.md](CONTRIBUTING.md)
- Security policy: [SECURITY.md](SECURITY.md)
- Support policy: [SUPPORT.md](SUPPORT.md)
