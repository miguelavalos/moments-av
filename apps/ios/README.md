# Moments AV iOS

SwiftUI app shell for Moments AV. The current v1 frontend includes account
state, credit gating, template draft creation, media metadata, story draft,
preview generation, final render/export, and project deletion flows.

The app uses the sibling public `account-av` package for Account AV sign-in.
`ACCOUNTAV_PUBLISHABLE_KEY` is intentionally blank in committed configs; set it
only in local or release build settings.
`MOMENTSAV_CONVEX_URL` is also blank in committed configs; set it in local or
release build settings to enable draft creation and realtime project sync.
`ACCOUNTAV_API_BASE_URL` is blank in committed configs; set it alongside the
Convex URL to enable signed account, credit, media, preview, final render,
render status, and project workflows through the shared Account AV API. Client
requests surface the API error message returned by Account AV for credit,
provider, storage, and deletion failures so the creation flow can distinguish
retryable setup/runtime issues from credit or policy blocks.
Generated staging and production configs reject non-canonical Account AV API
hosts so a local or release build cannot silently point at the wrong preview or
production Worker route.
Preview and final render responses also carry client-safe provider/model
metadata from Account AV so Convex project render records do not use placeholder
provider values.
Project workspaces include Convex render jobs, and the preview/final sections
can refresh their status through the shared Account AV render status endpoint.

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

## Test

Run the focused simulator test suite after generating the Xcode project:

```bash
xcodebuild test -project apps/ios/MomentsAV.xcodeproj -scheme MomentsAV -destination 'platform=iOS Simulator,name=iPhone 16,OS=18.5' CODE_SIGNING_ALLOWED=NO
```
