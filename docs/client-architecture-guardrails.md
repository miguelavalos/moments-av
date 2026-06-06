# Client Architecture Guardrails

Status: active public-safe rule for the Moments AV iOS client.

This repository owns the native iOS client. It does not own private backend
architecture, provider selection, pricing policy, admin operations, or secret
runtime configuration.

## Backend-Owned Workflows

Final video creation is backend-owned. The iOS app sends user intent and renders
the state returned by the configured backend/realtime layer.

The current v1 user flow is:

```text
Choose moments -> edit options -> Create video -> confirm credits -> final render -> local download -> Gallery
```

There is no public generated preview step and no separate Story Review currency
in v1. Story preparation is internal planning support for final render.

The iOS app must not:

- calculate final video credit cost;
- calculate final provider route, provider capability, or final duration;
- create or persist final render jobs as local authority;
- update final render job status;
- attach final render artifacts;
- poll backend status endpoints for normal product UI;
- call provider APIs directly.

The iOS app may:

- collect user media choices and setup options;
- show local editing affordances before final confirmation;
- request an official backend render plan;
- confirm the selected backend render plan;
- subscribe to synced workspace state and render progress, failure, and final
  artifact availability;
- download the completed final artifact to local device storage;
- move the downloaded final video into the local Gallery and clear the active
  Create draft/session;
- show a temporary local loading state while waiting for synced state to arrive.

## UI Rule

After final video confirmation, editing must lock from synced workflow state
until the final render reaches a terminal state. The user should see exactly one
clear status: waiting, creating, failed, or ready.

When the final video is ready, v1 shows only the download/finish path. After
finish, the Create screen closes and Gallery shows the newest saved video first.
The v1 client must not offer final-video versions or "create another version"
from the completed state.

If the app appears to need a timer or manual status loop for final video
creation, stop and review the private architecture contract before adding code.

## V1 Media Rule

V1 final videos are silent visual memory videos. The client must not present
generated audio, narration, voiceover, voice cloning, music, captions,
subtitles, text overlays, or user audio uploads as available v1 features.

## Public Documentation Boundary

Keep this public repo limited to client behavior and public-safe build/test
instructions. Details about Cloudflare, Convex deployment, D1/R2 operations,
provider models, pricing policy, credits policy, admin repair flows, and
production smoke credentials belong in the private AVALSYS suite.
