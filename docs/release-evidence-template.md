# Moments AV Release Evidence Template

Status: copy this template for each release candidate or App Store submission.
Do not record secrets, passwords, private URLs, access tokens, internal provider
request payloads, or private user data in this public repo.

Suggested copy name:

```text
docs/release-evidence-YYYY-MM-DD.md
```

## Release Candidate

- Release candidate:
- Date:
- Owner:
- Submitted commit SHA:
- Version:
- Build:
- Bundle ID:
- Xcode version:
- iOS SDK:
- Release mode:
- Backend environment:

## Public Checks

Record command results:

```bash
scripts/check-public-release-readiness.sh
```

- Result:
- Notes:

Record public URL reachability:

```bash
scripts/check-public-urls.sh
```

- Result:
- Notes:

## Runtime Config Check

Record non-secret output from:

```bash
scripts/check-ios-runtime-config.sh --env prod --configuration Release
```

- Result:
- Product bundle:
- Marketing version:
- Build number:
- Config environment:
- Account AV API:
- Project sync URL:
- Support URL:
- Privacy URL:
- Terms URL:
- Delete account URL:
- Publishable key prefix only:

## Build And Test Evidence

Record commands and outcomes:

```bash
xcodebuild -project apps/ios/MomentsAV.xcodeproj -scheme MomentsAV -destination 'generic/platform=iOS Simulator' CODE_SIGNING_ALLOWED=NO build
```

- Result:
- Log or artifact path:

```bash
xcodebuild test -project apps/ios/MomentsAV.xcodeproj -scheme MomentsAV -destination 'platform=iOS Simulator,name=iPhone 16,OS=18.5' CODE_SIGNING_ALLOWED=NO
```

- Result:
- Test count:
- Failure count:
- `.xcresult` path:

For signed Account AV/Clerk runtime evidence, do not use
`CODE_SIGNING_ALLOWED=NO`. Record the signed simulator/device build separately:

```bash
xcodebuild -project apps/ios/MomentsAV.xcodeproj -scheme MomentsAV -destination 'platform=iOS Simulator,name=iPhone 17' build
```

- Signed runtime result:
- Account sign-in result:
- Project/media workflow result:

## Archive And Upload

- Archive command or Xcode archive path:
- Archive result:
- Export/upload method:
- App Store Connect processing status:
- TestFlight build number:
- Processing warnings:
- SDK privacy manifest/signature warnings:

## Manual Smoke

Run on the exact build family intended for submission.

- [ ] Signed-out launch.
- [ ] Account AV sign-in with review-safe account.
- [ ] Media-first creation flow.
- [ ] Media selection with approved sample media or collection photos.
- [ ] Creation Dashboard review.
- [ ] Prepare story.
- [ ] Final render or documented final-render limitation.
- [ ] Projects list.
- [ ] Account support, privacy, terms, and deletion links.
- [ ] Project deletion route.
- [ ] Reduce Motion / accessibility spot check.
- [ ] Smallest supported iPhone spot check.

Notes:

- Device:
- OS:
- Locale:
- Appearance:
- Result:

## App Store Connect

- App name:
- Subtitle:
- Promotional text:
- Keywords:
- Description:
- Category:
- Age rating:
- Availability:
- Device families:
- App Privacy completed:
- Review notes completed:
- Demo account confirmed:
- Public URLs confirmed:

## Assets And Screenshots

- Canonical asset approval reference:
- App icon source:
- Splash/launch source:
- Screenshot raw capture folder:
- Final screenshot asset folder:
- Screenshot reviewer:
- Known exclusions:

Confirm:

- [ ] No generated or approximate AV marks.
- [ ] Avi is not used as app icon, product logo, or wordmark.
- [ ] Screenshots show real release-candidate UI.
- [ ] Captions match shipped behavior.
- [ ] No private user data appears.

## Final Decision

- Submit to App Review: yes/no
- Decision owner:
- Decision date:
- Remaining blockers:
- Follow-up version notes:
