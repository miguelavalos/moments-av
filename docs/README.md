# Moments AV Docs

Public documentation for setting up, validating, and preparing the Moments AV
iOS app for first App Store publication.

## Setup

- [install-ios.md](install-ios.md): local iOS setup, XcodeGen, runtime config,
  tests, production config checks, and public config hygiene.

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

## Asset Rule

Final icon, splash, screenshot frames, AV monogram usage, and Avi artwork must
wait for approved canonical assets. Do not use generated or approximate marks in
App Store artwork.

## Private Context

This public repo intentionally excludes credentials, provider configuration,
internal operations, private backend details, and final App Store Connect
handoff values such as demo account passwords.
