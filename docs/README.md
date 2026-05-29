# Moments AV Docs

Public documentation for setting up, validating, and preparing the Moments AV
iOS app for first App Store publication.

## Setup

- [install-ios.md](install-ios.md): local iOS setup, XcodeGen, runtime config,
  tests, production config checks, and public config hygiene.

## Current iOS Creation Flow

The signed-in creation flow is media-first:

1. the user starts a Moment and selects photos or clips;
2. the user can choose individual media or add photos from an exposed Photos
   collection/album;
3. the app shows a blocking full-screen preparing state with item progress while
   local media is imported;
4. Moments AV stores the in-progress Moment locally until the user cancels or
   prepares the story;
5. the Creation Dashboard summarizes media and direction before story
   preparation;
6. media editing and Avi direction editing are separate screens that return to the
   dashboard.

During import, the app runs `AVMediaAnalysisFoundation` from `apps-av/apple` on
device. The local analyzer does not call backend AI. It produces cheap generic
signals such as orientation, face count, scene role, screenshot likelihood, and
quality score. Moments AV uses those signals, plus dates and filename hints, to
preselect a theme and music default for Avi.

The current product direction treats `Prepare story` as a cheap pre-render
review step, not as a video preview. It should organize the story, style, music,
pace, and optional user note before any paid video generation. Video creation
and any future video preview or final render remain separate workflow stages
with explicit credit gating.

When the user taps `Prepare story`, the app should keep the step lightweight:
it uses the selected local media, ordering, style, music, and note to prepare a
story review before video creation. Duplicate media selected in later imports is
skipped automatically.

The app remains local-first for editing. Local Photos assets and the app's local
thumbnail cache are the source of truth for Dashboard and Edit Media screens.
Temporary media needed for video creation is separate from the editable local
copy shown in the app. If local media is unavailable on the device, the user
must re-select it to edit the Moment.

Draft media must remain visible and editable for as long as the source asset is
still available to the app on the device. Reinstalling the app, clearing the
simulator, or losing Photos-library identifiers can break a local test draft, but
that is not acceptable as normal user behavior. A saved draft should keep its
local thumbnails and media references in sync, and it should ask for
re-selection only when the app can no longer access the original asset.

After story preparation, the dashboard shows a Story Review card with the
prepared scene plan before the paid video action. If the user changes media or
direction after that review, the app requires a fresh `Prepare story` step before
enabling video creation. Repeating `Prepare story` with the same local media
order, theme, music, and note reuses the prepared story state. When the user
confirms `Create video`, the app reserves the required credits and moves the
Moment into a video-creation progress state. Users should save final videos to
Photos or share/export them for durable local access.

Credit pricing and timing are product-owned, not provider-owned: 1 Moments AV
credit equals one 15-second final video block. The backend must build a render
plan with the target duration before calling any provider, and the provider
route must be treated as an implementation detail. If a provider can only return
5-second clips, the backend has to compose, stitch, or choose a different route
so the final user-facing output still matches the credit and duration promise.
The default product route is composition-first: Avi edits the user's real photos
and clips into a polished memory video. Expensive generative video should be an
optional future enhancement or premium route, not the baseline 1-credit promise.

The render plan should use the selected media intentionally. For photo-only
Moments it should distribute the selected images across the target duration in
the user's chosen order unless the quality gate excludes an item. For mixed
photo/video Moments it should preserve clip intent, trim or sample clips to fit
the target duration, and record how many selected assets were planned, used, or
rejected. Quality warnings should be friendly and actionable, for example asking
the user to remove a blurry image or shorten a very dense selection before the
paid render starts.
For a 15-second Moment, 4-10 media items is the preferred creative range. The
app can accept up to 20 so users are not forced to over-curate too early, but Avi
may keep dense selections brief or suggest exclusions before credits are spent.

During final creation, Convex is the realtime status authority. The draft is
locked for editing while a final render is queued, rendering, validating, or
saving, but the app itself must remain usable. The dashboard should show
cordial, non-technical status copy from the backend, expose retry only when the
backend says retry is safe, and never show raw provider or validation errors to
the user.

## Creation Reliability

Creation steps that leave the device should use blocking full-screen progress
states so the user cannot navigate into an ambiguous draft while work is still
running. The progress copy should identify the current stage: local import,
story preparation, media upload, or video creation.

The app should retry transient upload, API, and sync failures before surfacing an
error. If a step still fails, Moments AV must show a clear user-facing failure
message or alert, keep the local media selection editable, and allow the user to
retry or discard the draft intentionally. Errors must not fail silently or leave
the user on an unchanged screen after tapping a primary action.

Local media remains the source of truth for editing. Remote media created during
video preparation is only a generation dependency and must not replace local
Photos assets or cached thumbnails in Dashboard and Edit Media.

## First Publication

Use these documents in this order:

1. [release-checklist.md](release-checklist.md): top-level first-publication
   gate and App Store readiness checklist.
2. [app-privacy-inventory.md](app-privacy-inventory.md): technical input for
   App Store Connect App Privacy answers.
3. [app-store-metadata.md](app-store-metadata.md): ASO metadata draft, keywords,
   description, promotional text, and screenshot captions.
4. [app-store-screenshots.md](app-store-screenshots.md): screenshot capture plan,
   sample data rules, Avi rules, and canonical asset gate.
5. [app-review-notes.md](app-review-notes.md): App Review notes draft, demo
   account TODOs, reviewer route checks, and service availability notes.
6. [release-evidence-template.md](release-evidence-template.md): copyable
   template for recording checks, archive/upload, TestFlight, screenshots, App
   Store Connect fields, and final submission decision.
7. [canonical-asset-handoff.md](canonical-asset-handoff.md): required handoff
   record before adding approved icon, splash, AV monogram, Avi artwork, or
   framed screenshot assets.

## Asset Rule

Final icon, splash, screenshot frames, AV monogram usage, and Avi artwork must
wait for approved canonical assets. Do not use generated or approximate marks in
App Store artwork.
Use [canonical-asset-handoff.md](canonical-asset-handoff.md) when approved
assets are ready.

## Private Context

This public repo intentionally excludes credentials, provider configuration,
internal operations, private backend details, sensitive internal planning, and
final App Store Connect handoff values such as demo account passwords.
