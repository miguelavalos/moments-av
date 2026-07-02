# Moments AV Web Functional Parity Progress

Date: 2026-06-18

Status: public-safe implementation note for the Moments AV web app.

## Scope

This note covers the web app in `apps/web`. It intentionally avoids private
Cloudflare, Convex, provider, billing, operator, and credential details.

The current web parity work uses iOS as the product source of truth for:

- workspace command API shape;
- media upload preparation and completion;
- story plan request/response shape;
- render plan and final render confirmation shape;
- artifact download preparation;
- Convex realtime projection reads;
- local availability versus remote metadata language.

## Spend Rule

Agents must never trigger real-money spend without explicit user approval in the
current conversation.

For Moments AV, this means:

- no paid provider final-render route without approval;
- no paid provider evaluation smoke without approval;
- no real purchase flow without approval;
- no production or preview operation that intentionally enables paid traffic
  without approval;
- no "test" action that could consume paid provider quota unless the user has
  approved the exact spend path.

No-spend validation must still exercise product workflow logic. It must validate
render planning, credit blockers/reservation/confirmation behavior, Convex
projection, artifact download preparation, and Finish -> Gallery behavior. It
must not call paid providers.

## Runtime Boundaries

Functional web routes require sign-in. There is no functional guest mode.

The web app keeps the product API split:

- Account AV uses `VITE_ACCOUNTAV_API_BASE_URL`.
- Moments AV product API uses `VITE_MOMENTSAV_API_BASE_URL` for
  `/v1/apps/momentsav/*`.
- Convex realtime projection uses `VITE_MOMENTSAV_CONVEX_URL`.

Convex is read as a backend-owned realtime projection. The web app does not
write Moment, media, story, render, artifact, Gallery, or workflow state to
Convex.

## Implemented Web Surfaces

### API Client

`apps/web/src/lib/moments-api.ts` implements web clients for:

- `POST /v1/apps/momentsav/workspace/moments`
- `PATCH /v1/apps/momentsav/workspace/moments/:momentId/setup`
- `PATCH /v1/apps/momentsav/workspace/moments/:momentId/title`
- `DELETE /v1/apps/momentsav/workspace/moments/:momentId`
- `POST /v1/apps/momentsav/media/prepare-upload`
- signed upload PUT/POST completion flow
- `POST /v1/apps/momentsav/story/plans`
- `POST /v1/apps/momentsav/renders/plan`
- `POST /v1/apps/momentsav/renders/final/confirm`
- `POST /v1/apps/momentsav/artifacts/:artifactId/download`
- `POST /v1/apps/momentsav/workspace/realtime-sessions`

The request payloads follow the iOS clients, including `appId: "momentsav"`,
`mood`, `safetyAcknowledged`, render `planId`, and final-render
`idempotencyKey`.

### Models

`apps/web/src/lib/moments-types.ts` ports web equivalents of:

- `InProgressMoment`
- `MomentWorkspace`
- `MomentMediaAsset`
- `MomentArtifact`
- `MomentRenderJob`
- story scenes and story response
- render plan and final-render confirmation response
- credit balance and spend plan shapes
- setup form fields: `creationMode`, `look`, `theme`, `mood`, `duration`,
  `mediaUse`, `title`, `occasion`, and `details`

### Realtime Hooks

`apps/web/src/lib/moments-hooks.ts` creates a backend realtime session before
starting owner-scoped Convex subscriptions.

Implemented subscriptions:

- `moments:listMoments` with `collection: "in_progress"`
- `moments:listMoments` with `collection: "gallery"`
- `moments:getMomentWorkspace`

If `VITE_MOMENTSAV_CONVEX_URL` is absent, the UI fails closed with a
configuration state instead of falling back to local Convex.

### Create

`/create` is now a functional progressive flow:

1. Select photos/clips from the browser.
2. Calculate browser-side SHA-256 for upload preparation.
3. Reorder selected media.
4. Edit setup fields.
5. Create/update the Moment workspace.
6. Prepare and upload media.
7. Request a story plan.
8. Request render plan as source of truth for cost/blockers/options.
9. Confirm final render exactly once per `planId`.

The UI does not call a paid provider directly. Final render confirmation must
use the backend route configured by the preview environment.

### In Progress

`/in-progress` subscribes to `collection: "in_progress"` and can inspect a
workspace detail projection:

- moment status;
- media assets;
- story scenes;
- render jobs;
- artifacts.

It also exposes workspace command API actions for rename and delete. Delete
sends the same intent shape as iOS: delete source media and generated artifacts.

### Gallery

`/gallery` subscribes to `collection: "gallery"` and shows final artifact
metadata when projected.

Artifact download uses the backend `prepare download` API and then downloads
from the prepared URL. The UI copy distinguishes:

- remote Gallery metadata;
- remote download availability;
- local browser file availability;
- missing/unavailable final artifacts.

### Avi

`/avi` is no longer static copy. It reads account access plus In Progress and
Gallery projections to choose guidance:

- continue active Moment;
- open Gallery/download;
- start Create;
- explain that render plan is the cost/blocker source of truth.

## Auth And Localization

Functional routes redirect unauthenticated users to `/sign-in`. They do not show
functional guest mode.

Supported locales remain:

- `en`
- `es`
- `fr`
- `de`
- `ca`

Internal web links preserve `lang`. Changing language updates the URL query so
the selected locale remains shareable and Back/Reload stay coherent.

## Verification Completed

Completed locally with preview Varlock config:

```bash
vp run --filter ./apps/web typecheck
vp run --filter ./apps/web build:preview
```

Browser verification covered:

- public `/` informational behavior;
- `/create`, `/in-progress`, `/gallery`, and `/avi` unauthenticated redirect to
  `/sign-in`;
- no functional guest mode in unauthenticated routes;
- `/sign-in?lang=es` internal links preserve `lang=es`;
- language switch `es -> fr`, reload, and Back restore the correct localized
  state;
- mobile 390 px sign-in has no horizontal overflow;
- home Sign in CTA updates URL correctly in touch/mobile context.

The local dev server emitted Clerk development-key warnings and session refresh
warnings when using local preview auth configuration. Those warnings are not
treated as signed-session validation evidence.

## Not Yet Completed

The following remain required before commit/push or release confidence:

- signed-in preview QA with a real Account AV session;
- no-spend end-to-end flow:
  `create -> upload -> story -> render plan -> confirm mock -> Convex -> download -> Finish -> Gallery`;
- verification that final render confirmation uses the approved mock/no-spend
  backend route;
- verification that credits are blocked/reserved/confirmed through backend
  workflow and not bypassed;
- Gallery Finish -> Gallery behavior against live preview state;
- accessibility/performance cleanup for the Clerk sign-in surface if it becomes
  part of this implementation slice.
