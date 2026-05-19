# Moments AV App Privacy Inventory

Status: technical draft for first App Store publication. This is not legal
approval. Final App Store Connect answers must be confirmed against the exact
submitted build, production Account AV behavior, backend retention, SDKs, and
the public Privacy Policy.

## Submission Context

- App: Moments AV
- Bundle ID: `com.avalsys.momentsav`
- Version: `1.0`
- Build: `1`
- Release mode: first iOS App Store submission
- Account system: Account AV
- Privacy owner: TODO
- Review date: TODO
- Submitted commit SHA: TODO

## Data Inventory

### Account Identity

- Examples: Account AV user ID, session state, account display name.
- Collected by: Account AV iOS package and Account AV backend.
- Stored where: Account AV services and local app session/cache where required.
- Linked to user: yes.
- Used for tracking: no, unless a future SDK/provider changes this.
- Purpose: authentication, account routing, project ownership, credits, deletion.
- User-visible control: sign in/out, account screen, delete account URL.
- Sign-out behavior: local authenticated app state is cleared by Account AV.
- Account deletion behavior: handled by Account AV; Moments AV project deletion
  is separate and removes project media/generated artifacts where available.
- Retention: TODO confirm Account AV production retention policy.
- App Privacy category: Identifiers.
- Notes: App Store review notes must explain where account deletion is reached.

### Credits And Entitlements

- Examples: spendable credit balance, credit source counts, credit reservation
  IDs, credit cost, final render credits committed.
- Collected by: Account AV API and Moments AV client.
- Stored where: Account AV services; project metadata may reference credit
  reservation IDs.
- Linked to user: yes.
- Used for tracking: no.
- Purpose: enforce preview/final-render eligibility and account billing rules.
- User-visible control: Account and creation flow show credit state.
- Sign-out behavior: hidden from the signed-out app.
- Account deletion behavior: TODO confirm Account AV credit/billing retention.
- Retention: TODO confirm production backend retention.
- App Privacy category: Purchases or Other Data, depending on final App Store
  Connect interpretation and whether paid credit purchase is live.
- Notes: Metadata and screenshots must not imply unlimited generation.

### Selected User Media

- Examples: photos, short clips, filenames or metadata needed for upload,
  selected order, source media references.
- Collected by: Moments AV media picker and upload flow.
- Stored where: uploaded to the configured backend/storage only after user
  selection and project creation.
- Linked to user: yes.
- Used for tracking: no.
- Purpose: create private memory video drafts, previews, and final exports.
- User-visible control: user selects media; project deletion requests deletion
  of source media and generated artifacts where available.
- Sign-out behavior: projects and media are not visible in the signed-out app.
- Account deletion behavior: TODO confirm Account AV deletion cascade and
  storage retention.
- Retention: TODO confirm production media retention and deletion timing.
- App Privacy category: User Content.
- Notes: App Store screenshots must not show real private personal media.

### Story Drafts And Project Metadata

- Examples: template, occasion, recipient text, tone, tempo, scene draft,
  project status, media asset IDs, render job IDs.
- Collected by: Moments AV client and Account AV/Moments backend.
- Stored where: Convex project workspace and Account AV workflow records.
- Linked to user: yes.
- Used for tracking: no.
- Purpose: maintain private project state and let users preview/edit/export.
- User-visible control: Projects list, project detail, project deletion.
- Sign-out behavior: hidden from the signed-out app.
- Account deletion behavior: TODO confirm deletion cascade.
- Retention: TODO confirm project retention policy.
- App Privacy category: User Content and Usage Data.
- Notes: Free-text fields can contain personal information entered by users.

### Generated Artifacts

- Examples: story draft output, preview artifact, final export artifact, R2 key,
  provider/model metadata, workflow run ID, render status.
- Collected by: Account AV/Moments backend and returned to the app.
- Stored where: backend object storage and Convex project records.
- Linked to user: yes.
- Used for tracking: no.
- Purpose: preview and deliver requested memory videos.
- User-visible control: preview/final render screens, project deletion.
- Sign-out behavior: hidden from the signed-out app.
- Account deletion behavior: TODO confirm backend artifact deletion.
- Retention: TODO confirm storage retention.
- App Privacy category: User Content.
- Notes: Provider/model metadata should be treated as operational metadata, not
  App Store marketing copy.

### Diagnostics And Operational Errors

- Examples: client-safe API error codes/messages, render provider failures,
  failed configuration states.
- Collected by: app/backend as part of request handling.
- Stored where: TODO confirm production logging and crash/diagnostic providers.
- Linked to user: TODO confirm backend log correlation.
- Used for tracking: no.
- Purpose: reliability, support, abuse prevention, debugging.
- User-visible control: support and deletion links; no in-app diagnostics export
  currently documented.
- Sign-out behavior: TODO confirm log retention.
- Account deletion behavior: TODO confirm log deletion/anonymization policy.
- Retention: TODO confirm production retention.
- App Privacy category: Diagnostics or Other Data.
- Notes: Final App Privacy answers require the production SDK/logging inventory.

## SDK And Provider Inventory

### Account AV

- SDK/package: sibling public `account-av` package.
- Purpose: identity, account session, credits, shared Account AV API access.
- Data received: account/session identifiers, publishable key, API requests
  associated with signed-in user flows.
- Linked to user: yes.
- Tracking: no.
- Retention owner: Account AV.
- Enabled in submitted build: yes.
- Notes: Confirm production privacy policy and deletion behavior.

### Clerk

- SDK/package: `clerk-ios`.
- Purpose: authentication through Account AV.
- Data received: authentication/session data required by Account AV.
- Linked to user: yes.
- Tracking: TODO confirm provider configuration.
- Retention owner: Clerk/Account AV.
- Enabled in submitted build: yes.
- Notes: Include in final SDK/provider review.

### Convex

- SDK/package: `convex-swift`.
- Purpose: project workspace sync and project mutations.
- Data received: project metadata, media references, story scenes, render job
  records, artifact references.
- Linked to user: yes.
- Tracking: no.
- Retention owner: Moments AV/Account AV backend.
- Enabled in submitted build: yes when `MOMENTSAV_CONVEX_URL` is configured.
- Notes: Confirm production deployment and retention.

### Apple Photos Picker

- SDK/package: Apple PhotosUI.
- Purpose: user-selected media import.
- Data received: only media the user selects for the project.
- Linked to user: yes once uploaded to the project backend.
- Tracking: no.
- Retention owner: Moments AV/Account AV backend after upload.
- Enabled in submitted build: yes.
- Notes: Do not describe this as full photo library access unless the submitted
  entitlement/permission surface changes.

### Nuke

- SDK/package: `Nuke`.
- Purpose: image loading/caching where used by app surfaces.
- Data received: image URLs and image bytes requested by the app.
- Linked to user: depends on URL/source; TODO confirm current usage in submitted
  build.
- Tracking: no.
- Retention owner: local app cache/backend source.
- Enabled in submitted build: yes as a dependency.
- Notes: Confirm whether final build actually exercises remote image loading.

### PhoneNumberKit

- SDK/package: `PhoneNumberKit`.
- Purpose: phone number formatting/validation where Account AV requires it.
- Data received: phone number text if that Account AV flow is used.
- Linked to user: yes if submitted to authentication/account backend.
- Tracking: no.
- Retention owner: Account AV/auth provider.
- Enabled in submitted build: yes as a dependency.
- Notes: Confirm visible auth methods for App Review.

## Draft App Privacy Answers

These are draft technical inputs only:

- Data used to track users: none known in the current iOS app.
- Data linked to users: identifiers, user content, project metadata, generated
  artifacts, credits/entitlement state, diagnostics where logs are user-linked.
- Data not linked to users: TODO confirm anonymous diagnostics, if any.
- Data not collected: precise location, contacts, health, calendar, microphone,
  camera capture, advertising identifiers, browsing history, financial
  information, unless a future submitted build adds them.
- Purchases: TODO, depends on whether first submission includes paid credits,
  subscriptions, or only credit display.
- Contact information: TODO, depends on Account AV auth method and support flow.
- User content: selected photos/clips, draft text, generated previews/exports.
- Identifiers: Account AV/Clerk user/session identifiers.
- Usage data: project/template/action metadata needed for app function.
- Diagnostics: TODO confirm crash/log providers and backend log policy.

## Final Privacy Gate

Before entering App Store Connect answers:

1. Inspect the exact archived build, not only `main`.
2. Confirm Account AV production auth methods and deletion behavior.
3. Confirm backend storage, object storage, Convex, and log retention.
4. Confirm whether paid credits/subscriptions are live in the submitted build.
5. Confirm third-party SDK privacy manifests and App Store processing warnings.
6. Confirm the public Privacy Policy matches this inventory.
7. Confirm screenshots and review notes do not expose private user data or
   overstate privacy/deletion behavior.
