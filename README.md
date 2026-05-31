# Moments AV

[![Public Readiness](https://github.com/miguelavalos/moments-av/actions/workflows/public-readiness.yml/badge.svg)](https://github.com/miguelavalos/moments-av/actions/workflows/public-readiness.yml)

Open-source frontend app repository for Moments AV.

Moments AV helps people turn selected photos and short clips into memory videos.
This public repository contains the iOS client code, public setup docs, support
policy, security policy, and client-side checks that are safe to publish.

It intentionally excludes credentials, signing material, production runtime
values, private backend implementation, provider/model policy, pricing strategy,
App Store review handoff material, promo codes, and internal business planning.

## Repository Shape

```text
apps/
  ios/      SwiftUI iOS app
docs/
  README.md
  install-ios.md
  production-config.md
  release-checklist.md
  release-evidence-template.md
  canonical-asset-handoff.md
```

## Local Setup

See [docs/install-ios.md](docs/install-ios.md) for local iOS setup.

Quick compile check:

```bash
xcodegen generate --spec apps/ios/project.yml
xcodebuild -project apps/ios/MomentsAV.xcodeproj -scheme MomentsAV -destination 'generic/platform=iOS Simulator' CODE_SIGNING_ALLOWED=NO build
```

Use unsigned builds only for compile checks. Authenticated runtime flows need
normal simulator or device signing and local runtime configuration generated
outside this public repo.

Before opening a pull request, run:

```bash
scripts/check-public-hygiene.sh
```

Before an App Store release candidate, run the full release readiness check:

```bash
scripts/check-public-release-readiness.sh
```

## Contributing And Security

- Contribution guide: [CONTRIBUTING.md](CONTRIBUTING.md)
- Security policy: [SECURITY.md](SECURITY.md)
- Support policy: [SUPPORT.md](SUPPORT.md)

## License

This repository is released under the MIT license. See [LICENSE](LICENSE).
