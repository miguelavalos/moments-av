# Moments AV App Store Screenshots

Status: first-publication screenshot capture plan. Use this only after the
release-candidate build, public URLs, App Privacy draft, and canonical asset
gate are ready.

Screenshots must show real Moments AV UI from the submitted or release-candidate
build. Marketing frames and captions are allowed, but the app UI inside the
device frame must be real.

## Capture Inputs

Record these values before capture:

- Version:
- Build:
- Commit SHA:
- Release mode:
- Bundle ID:
- Device:
- Simulator or physical device:
- Locale:
- Appearance:
- Screenshot owner:
- Raw capture folder:
- Final asset folder:

## Required Screens

Capture candidates:

- [ ] Signed-out Account AV gate.
- [ ] Template selection with Birthday Message, Party Recap, and Soft Roast.
- [ ] Launch readiness checklist with Account AV, credits, media, and Avi.
- [ ] Media selection after user-selected sample media is attached.
- [ ] Story draft screen with Avi guidance and realistic draft scenes.
- [ ] Preview screen showing preview-ready or preview-generation state.
- [ ] Final render screen showing final-export readiness, not unsupported
  instant delivery.
- [ ] Projects list with non-private sample project names.
- [ ] Account screen with support, legal, credits, privacy, and deletion routes.

Optional only if the submitted build fully supports the state:

- [ ] Project deletion confirmation.
- [ ] Render status refresh.
- [ ] Credit explanation or purchase route.

## Sample Data Rules

- Use synthetic media that is approved for public marketing.
- Do not use real family photos, private faces, private locations, private
  event names, real emails, phone numbers, internal IDs, access tokens, or
  provider request IDs.
- Use neutral sample names such as `Birthday Message`, `Party Recap`, and
  `Weekend Highlights`.
- Keep draft text realistic but generic.
- Do not show backend URLs or debug state.

## Avi Rules

- Avi can appear only where the submitted UI actually includes Avi.
- Captions must not imply open-ended chat, autonomous editing, or background
  cross-app control.
- Safe claims: guidance, story shaping, preview preparation, export status,
  credit explanation, recovery guidance.
- Unsafe claims: unlimited AI creation, automatic perfect edits, autonomous
  account actions, or unsupported chat.

## Canonical Asset Rules

- Do not use generated or approximate AV marks.
- Do not use Avi as the product logo, wordmark, app icon, or screenshot brand
  anchor.
- Do not create final framed screenshots until the approved Moments AV icon and
  any AV monogram usage have passed the canonical asset gate in
  [release-checklist.md](release-checklist.md).
- If an AV mark is visible in final artwork, it must be the approved canonical
  AVALSYS monogram and must be secondary to the Moments AV product surface.

## Caption Themes

Use short captions that describe shipped workflows:

- Turn selected photos and clips into memory videos.
- Start with birthday, party, or playful story templates.
- Let Avi help shape the draft before preview.
- Preview first, then request the final export.
- Keep credits, projects, and deletion controls visible.

Avoid:

- Claims about unlimited generation.
- Claims about subscriptions or paid credit packs unless live in the submitted
  build and App Store Connect.
- Competitor names or third-party brand names.
- Claims that all media is deleted instantly unless the production retention
  policy confirms it.

## Capture Checks

Before approving the screenshot set:

1. Every screenshot comes from the release-candidate build.
2. Device family matches App Store Connect availability.
3. Text fits without clipping or awkward truncation.
4. Safe areas, sheets, tab bar, and navigation are clean.
5. Legal, account, credit, and deletion copy matches the submitted build.
6. No disabled, mocked, placeholder, debug, or roadmap-only feature is visible.
7. No unapproved icon, splash, AV monogram, Avi artwork, or brand frame is used.
8. Captions match App Store metadata and do not add unsupported claims.

## Evidence

Record:

- raw capture file paths;
- final asset file paths;
- build/archive used for capture;
- command or tool used to capture and frame assets;
- reviewer;
- known exclusions and why they are acceptable.
