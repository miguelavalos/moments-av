# Moments AV iOS

SwiftUI app shell for Moments AV.

## Build

Generate the Xcode project after editing `project.yml`:

```bash
xcodegen generate --spec apps/ios/project.yml
```

Build for simulator:

```bash
xcodebuild -project apps/ios/MomentsAV.xcodeproj -scheme MomentsAV -destination 'generic/platform=iOS Simulator' CODE_SIGNING_ALLOWED=NO build
```

Local signing values belong in untracked local configuration only.
