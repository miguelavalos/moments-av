# Moments AV Release Checklist

Status: first-publication TODO for the iOS App Store release.

This document keeps public release and ASO work aligned with the shipped iOS app.
Do not use it to promise roadmap behavior. Every App Store field, screenshot,
and review note must match the exact build submitted for review.

## Current Release Surface

- App: Moments AV
- Platform: iOS
- Bundle ID: `com.avalsys.momentsav`
- Development bundle ID: `com.avalsys.momentsav.dev`
- Marketing version: `1.0`
- Build number: `1`
- Account system: Account AV
- Assistant: Avi
- Initial flow: select a template, choose photos or short clips, draft a story,
  generate a preview, then request a final export.
- Initial templates: Birthday Message, Party Recap, Soft Roast.
- Credit behavior: previews and final exports require spendable credits; failed
  provider runs must not be described as final credit commits.

## Hard Blockers Before App Review

- [ ] Archive uses Release config and resolves to `com.avalsys.momentsav`.
- [ ] `MARKETING_VERSION` and `CURRENT_PROJECT_VERSION` match App Store Connect.
- [ ] Production `MOMENTSAV_CONVEX_URL` is configured.
- [ ] Production `ACCOUNTAV_API_BASE_URL` is configured.
- [ ] Production Account AV publishable key is configured.
- [ ] Support, Privacy Policy, Terms, and Delete Account URLs are live and
  reachable outside the app.
- [ ] `scripts/check-public-urls.sh` passes.
- [ ] App Privacy answers match Account AV, selected user media, generated
  artifacts, credits, diagnostics, and backend retention behavior.
- [ ] App Privacy answers have been checked against
  [app-privacy-inventory.md](app-privacy-inventory.md).
- [ ] Account deletion is reachable from the app and documented for review.
- [ ] The app has been smoke tested on every device family enabled in App Store
  Connect.
- [ ] App Store screenshots are captured from the real release-candidate build.
- [ ] App Store metadata does not claim unlimited generation, open-ended chat,
  autonomous editing, or capabilities not present in the submitted build.
- [ ] Final App Store icon, splash, and screenshot branding use only approved
  canonical assets.

## Canonical Asset Gate

Do not create or integrate final App Store artwork until the canonical Moments
AV asset export is approved. Use
[canonical-asset-handoff.md](canonical-asset-handoff.md) to record the approved
package before adding assets.

Required before touching final icon or splash assets:

- [ ] Approved Moments AV app icon source exists.
- [ ] Any embedded AV monogram uses the canonical AVALSYS monogram, not a
  regenerated or approximate mark.
- [ ] The app icon includes at most a small AV mark; the AV mark must not become
  the primary product icon.
- [ ] Avi is not used as the app icon, product logo, or wordmark.
- [ ] Avi appears only as an in-app assistant or screenshot UI element when that
  surface ships in the submitted build.
- [ ] Screenshot captions and frames do not hide core UI, account deletion,
  legal, credit, or export-state copy.

## App Store Connect TODO

Record final values before submission:

- [ ] App name:
- [ ] Subtitle:
- [ ] Bundle ID:
- [ ] SKU:
- [ ] Primary language:
- [ ] Category:
- [ ] Secondary category:
- [ ] Copyright:
- [ ] Version:
- [ ] Build:
- [ ] Submitted commit SHA:
- [ ] Countries/regions:
- [ ] Supported device families:
- [ ] Minimum iOS version:
- [ ] Review demo account:
- [ ] Review contact:
- [ ] Review notes:

## ASO Draft

Use [app-store-metadata.md](app-store-metadata.md) for the working metadata
package. These are quick candidates only. Recheck Apple field limits, token
duplication, localization, and screenshot captions before entering them in App
Store Connect.

### App Name Candidates

- `Moments AV`
- `Moments AV: Memory Videos`
- `Moments AV: Photo Videos`

Recommendation for first publication: use a longer searchable name only if App
Store Connect allows it within the 30-character limit and the final icon remains
clearly product-specific.

### Subtitle Candidates

- `Turn photos into memory videos`
- `Private photo and clip stories`
- `Birthday and party video maker`

Avoid repeating the exact strongest name tokens in subtitle and keywords.

### Keyword Themes

Use the final keyword field to cover high-intent terms that are not already
covered by the app name or subtitle.

- memory video
- photo video
- birthday video
- party recap
- slideshow
- family moments
- short clips
- video maker
- memories
- private

Before submission:

- [ ] Build the final comma-separated keyword field under Apple's limit.
- [ ] Remove duplicate terms already covered by app name/subtitle.
- [ ] Prefer user-search language over internal product terms.
- [ ] Do not include competitor names, third-party brands, or unsupported
  feature claims.

### Promotional Text Draft

Create private memory videos from selected photos and short clips. Avi helps
shape the story, preview the result, and prepare the final export.

### Description Draft

Moments AV helps you turn selected photos and short clips into short memory
videos for birthdays, parties, and personal moments.

Choose a template, add the media you want to use, and let Avi help shape a
simple story draft. Review the draft, generate a preview, and request the final
export when you are ready.

Moments AV is built around private projects, clear credit use, and account
controls through Account AV.

## Screenshot Plan

Capture only shipped, release-candidate UI. Use
[app-store-screenshots.md](app-store-screenshots.md) for the full capture and
approval plan.

- [ ] First-run or signed-out Account AV gate.
- [ ] Template selection with Birthday Message, Party Recap, and Soft Roast.
- [ ] Readiness checklist with credits, media, and Avi workflow.
- [ ] Media selection with selected photos or clips.
- [ ] Story draft screen showing Avi guidance.
- [ ] Preview generation state or preview-ready state.
- [ ] Final export or final-render readiness state.
- [ ] Projects list.
- [ ] Account screen with support, legal, credits, and deletion routes.

Screenshot rules:

- [ ] No debug URLs, IDs, secrets, private emails, or real personal media.
- [ ] No placeholder backend or mocked paid behavior.
- [ ] No screenshot implies open-ended Avi chat or fully autonomous creation.
- [ ] No screenshot uses unapproved icon, splash, AV monogram, or Avi artwork.
- [ ] Captions emphasize real workflows: select, draft, preview, export,
  credits, privacy, and account controls.

## Review Notes TODO

Use [app-review-notes.md](app-review-notes.md) as the App Store Connect review
notes draft.

- [ ] Explain Account AV sign-in and demo account access.
- [ ] Explain where account deletion is located.
- [ ] Explain credit behavior and when credits are committed.
- [ ] Explain whether preview/final generation requires production provider
  availability during review.
- [ ] Explain any region, device, or backend limitation.
- [ ] Confirm support, privacy, terms, and deletion URLs.

## Final Submission Gate

Create a release evidence file from
[release-evidence-template.md](release-evidence-template.md) before making the
final submit/no-submit decision.

Submit only when all answers are yes:

1. Does the archive use production config and the production bundle ID?
2. Are public URLs live and aligned with in-app links?
3. Are App Privacy answers backed by the real iOS and backend behavior?
4. Are screenshots captured from the same build family being submitted?
5. Are all visible assets canonical and approved?
6. Does every ASO claim match a shipped, reviewable feature?
7. Are account deletion, credits, and generated media handling clear to review?
8. Is the release evidence file complete and free of secrets, passwords, private
   URLs, access tokens, and private user data?
