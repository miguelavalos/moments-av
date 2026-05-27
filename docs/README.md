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
3. the app shows a short preparing state with item progress while local media
   is imported;
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
and any future preview/final render provider calls remain separate workflow
stages with explicit credit gating.

When the user taps `Prepare story`, the app first persists the selected local
media into the active project, then sends the persisted media IDs to the story
draft endpoint. This avoids drafting against temporary local identifiers and
keeps the story plan aligned with the backend project state. Duplicate media
selected in later imports is skipped automatically.

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
   account TODOs, reviewer route checks, and provider availability notes.
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
