# Moments AV Docs

Public documentation for setting up, validating, and preparing the Moments AV
iOS app for first App Store publication.

## Setup

- [install-ios.md](install-ios.md): local iOS setup, XcodeGen, runtime config,
  tests, production config checks, and public config hygiene.

## Current iOS Creation Flow

The signed-in creation flow is media-first:

1. the user starts a Moment and selects photos or clips;
2. the app shows a short preparing state while local media is imported;
3. Moments AV stores the in-progress Moment locally until the user cancels or
   prepares a preview;
4. the Creation Dashboard summarizes media and options before preview;
5. media editing and option editing are separate screens that return to the
   dashboard.

During import, the app runs `AVMediaAnalysisFoundation` from `apps-av/apple` on
device. The local analyzer does not call backend AI. It produces cheap generic
signals such as orientation, face count, scene role, screenshot likelihood, and
quality score. Moments AV uses those signals, plus dates and filename hints, to
preselect a theme and music default for Avi. Backend AI-assisted story planning
and rendering remain separate future workflow stages.

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
