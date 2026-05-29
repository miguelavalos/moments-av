# Moments AV iOS

SwiftUI app shell for Moments AV. The current v1 frontend includes account
state, credit gating, template draft creation, media metadata, story draft,
preview generation, final render/export, and project deletion flows.

For full local setup, see [../../docs/install-ios.md](../../docs/install-ios.md).
For production runtime variables and Clerk/Account AV validation, see
[../../docs/production-config.md](../../docs/production-config.md).

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
`MARKETING_VERSION` and `CURRENT_PROJECT_VERSION` are defined in committed
xcconfigs so App Store builds use the same version source as Xcode archives.
Legal/support URLs are also xcconfig-backed:
`MOMENTSAV_SUPPORT_URL`, `MOMENTSAV_PRIVACY_URL`, `MOMENTSAV_TERMS_URL`, and
`ACCOUNTAV_DELETE_ACCOUNT_URL`.
Generated staging and production configs reject non-canonical Account AV API
hosts so a local or release build cannot silently point at the wrong preview or
production Worker route.
Preview and final render responses also carry client-safe provider/model
metadata from Account AV so Convex project render records do not use placeholder
provider values.
Project workspaces include Convex render jobs, and the preview/final sections
can refresh their status through the shared Account AV render status endpoint.
Media upload must fail visibly when Account AV cannot return a signed upload
URL. The client should not save media metadata or advance the creation workflow
after an unavailable signed-upload response, because that would make the user
believe local media is safely available for preview or final render when no
source object exists in storage.

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

Validate the effective runtime config after generating local settings:

```bash
scripts/check-ios-runtime-config.sh --env dev
```

Before archiving for App Store review, run the same check against the Release
configuration and production local settings:

```bash
scripts/generate-ios-local-xcconfig.sh --env prod
scripts/check-ios-runtime-config.sh --env prod --configuration Release
```

## Test

Run the focused simulator test suite after generating the Xcode project:

```bash
xcodebuild test -project apps/ios/MomentsAV.xcodeproj -scheme MomentsAV -destination 'platform=iOS Simulator,name=iPhone 16,OS=18.5' CODE_SIGNING_ALLOWED=NO
```
