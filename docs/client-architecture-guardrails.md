# Client Architecture Guardrails

Status: active public-safe rule for the Moments AV iOS client.

This repository owns the native iOS client. It does not own private backend
architecture, provider selection, pricing policy, admin operations, or secret
runtime configuration.

## Backend-Owned Workflows

Final video creation is backend-owned. The iOS app sends user intent and renders
the state returned by the configured backend/realtime layer.

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
- show a temporary local loading state while waiting for synced state to arrive.

## UI Rule

After final video confirmation, editing must lock from synced workflow state
until the final render reaches a terminal state. The user should see exactly one
clear status: waiting, creating, failed, or ready.

If the app appears to need a timer or manual status loop for final video
creation, stop and review the private architecture contract before adding code.

## Public Documentation Boundary

Keep this public repo limited to client behavior and public-safe build/test
instructions. Details about Cloudflare, Convex deployment, D1/R2 operations,
provider models, pricing policy, credits policy, admin repair flows, and
production smoke credentials belong in the private AVALSYS suite.
