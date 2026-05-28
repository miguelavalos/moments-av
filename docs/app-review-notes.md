# Moments AV App Review Notes

Status: first-publication draft. Final values must be copied into App Store
Connect only after the release-candidate build, production backend, public URLs,
App Privacy answers, and demo account are confirmed.

## Submission Context

- App: Moments AV
- Bundle ID: `com.avalsys.momentsav`
- Version: `1.0`
- Build: `1`
- Submitted commit SHA: TODO
- Backend environment: production
- Review contact: TODO
- Review phone: TODO
- Demo account: TODO
- Demo account password storage: TODO

## Suggested Review Notes

Use this as the starting point for App Store Connect review notes:

```text
Moments AV lets signed-in users create private memory video projects from
selected photos and short clips.

Account and sign-in:
- The app uses Account AV for authentication and account state.
- Use the provided demo account to sign in and reach the full creation flow.

Creation flow:
- Open Create.
- Sign in if prompted.
- Confirm readiness items for Account AV, credits, media, and Avi workflow.
- Select approved sample photos or short clips, or add photos from a supported
  Photos collection.
- Review the Creation Dashboard.
- Ask Avi to prepare the story.
- Create the final video when the story is ready and the credit cost is clear.

Credits:
- Final video creation requires spendable Moments AV credits.
- Final credits are committed only after a usable final export is delivered.
- Story preparation does not commit final credits. If an assisted story provider
  is unavailable, the app can still prepare an editable story plan from the
  selected media so the reviewer is not blocked before video creation.

Account deletion and project deletion:
- Account deletion is available from Account > Delete Account.
- Individual Moments AV projects can also be deleted from the project deletion
  flow; that requests deletion of source media, previews, exports, and project
  metadata where available.

Avi:
- Avi is a guided in-app assistant for onboarding, story preparation,
  preparation, final export status, credits, and recovery guidance.
- Avi is not presented as open-ended chat or autonomous cross-app control.

Public URLs:
- Support: https://moments-av.avalsys.com/support
- Privacy Policy: https://moments-av.avalsys.com/privacy
- Terms: https://moments-av.avalsys.com/terms
- Account deletion: https://account-av.avalsys.com/account/delete
```

## Demo Account TODO

- [ ] Create a review-safe Account AV user.
- [ ] Confirm the demo account can sign in on the submitted build.
- [ ] Confirm the demo account has enough spendable Moments AV credits to run
  preview and final export flows, or document why generation is limited.
- [ ] Confirm demo media is synthetic or approved for App Review.
- [ ] Confirm no private user data, internal IDs, or debug URLs appear.
- [ ] Store the password in the approved private handoff location, not this repo.

## Reviewer Route Checks

Before submission, test these paths on the exact build:

- [ ] Signed-out launch explains Account AV requirement.
- [ ] Account AV sign-in succeeds with the demo account.
- [ ] Create tab opens the media-first creation flow.
- [ ] Creation Dashboard is visible after media selection.
- [ ] Media selection uses Apple Photos picker and only user-selected media.
- [ ] Collection/album import, when available, asks for confirmation and skips
  duplicate selected media.
- [ ] Story draft flow can be reached after media selection and reaches the
  story-ready state even if provider-assisted drafting is unavailable.
- [ ] Final video creation can be reached after story readiness.
- [ ] Projects tab shows submitted demo projects.
- [ ] Account tab shows support, privacy, terms, and delete-account routes.
- [ ] Account deletion URL opens correctly.
- [ ] Project deletion messaging matches public service behavior.

## Provider Availability

Final review notes must say whether preview/final generation is expected to run
against production providers during review.

Choose one before submission:

- [ ] Production provider generation is fully enabled for the demo account.
- [ ] Generation is limited; review notes explain the limitation and provide
  screenshots/evidence of the expected states.

Do not submit if the selected mode would leave reviewers blocked without a clear
route through the app.

## Known Limitations TODO

Record only true limitations of the submitted build:

- [ ] Supported device families:
- [ ] Supported regions:
- [ ] Supported locales:
- [ ] Credit/access surface visible in this build:
- [ ] Provider generation availability during review:
- [ ] Any temporary service limitation visible to reviewers:

## Final Gate

Before copying notes into App Store Connect:

1. Demo account was tested on the archived build.
2. URLs were opened outside the app.
3. Credit behavior in notes matches code, backend, screenshots, and metadata.
4. Account deletion route was verified.
5. Provider availability statement matches production reality.
6. Notes do not include secrets, passwords, private URLs, or internal IDs.
