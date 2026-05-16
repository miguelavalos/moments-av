# Moments AV

Open-source frontend app repo for Moments AV.

Moments AV helps people turn personal photos and short clips into short memory
videos.

This repository contains the public client app code and public user-facing docs.

Project status: early setup.

## License

This repository is released under the MIT license. See [LICENSE](LICENSE).

## Repository Shape

```text
apps/
  ios/      SwiftUI iOS app
docs/
  install-ios.md
  release-checklist.md
shared/
  apple/    Swift modules and shared Apple-domain code
```

## What Is Included

- iOS frontend app code;
- public setup docs;
- public support and security policies;
- client-side code that is safe to publish.

## Local Setup

1. Install Xcode and XcodeGen.
2. Run `xcodegen generate --spec apps/ios/project.yml`.
3. Build with `xcodebuild -project apps/ios/MomentsAV.xcodeproj -scheme MomentsAV -destination 'generic/platform=iOS Simulator' CODE_SIGNING_ALLOWED=NO build`.

Generated local config, signing material, and machine-specific files must stay
out of git.

## Contributing And Security

- Contribution guide: [CONTRIBUTING.md](CONTRIBUTING.md)
- Security policy: [SECURITY.md](SECURITY.md)
- Support policy: [SUPPORT.md](SUPPORT.md)
