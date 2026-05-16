# Moments AV iOS

SwiftUI app shell for Moments AV.

The app uses the sibling public `account-av` package for Account AV sign-in.
`ACCOUNTAV_PUBLISHABLE_KEY` is intentionally blank in committed configs; set it
only in local or release build settings.
`MOMENTSAV_CONVEX_URL` is also blank in committed configs; set it in local or
release build settings to enable draft creation and realtime project sync.
`MOMENTSAV_API_BASE_URL` is blank in committed configs; set it alongside the
Convex URL to enable signed media upload preparation.

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
