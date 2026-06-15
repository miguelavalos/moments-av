# Moments AV Agent Rules

Before work that touches signed runtime, credits, paid providers, final renders,
billing, deployment, TestFlight/App Store, Convex, Cloudflare remote state, or
cross-app workflow behavior, run the private workspace preflight first:

```bash
bash ../../private/avalsys-suite/scripts/agent-preflight.sh --app moments-av --intent <intent>
```

Read `../../private/avalsys-suite/docs/agents/workspace-guardrails.md` and every doc
printed by the preflight before executing commands. If the private repo is
unavailable, stop instead of guessing.

This public repo does not define the full signed-runtime testing workflow.

For any native app workflow validation that touches signed account state,
credits, uploads, Convex, render plans, final renders, artifacts, purchases,
billing, or deletion flows, follow the private AVALSYS guide. Do not invent a
local runtime flow from this public repo.

- `private/avalsys-suite/docs/platform/native-preview-dev-validation-guide.md`
- `private/avalsys-suite/docs/platform/account-av-ios-testflight-contract.md`
- `private/avalsys-suite/docs/moments-av/release-validation-runbook.md`
- `private/avalsys-suite/docs/agents/plan-step.md` when the user says
  `usa plan-step` or asks for step-by-step plan execution.
- `private/avalsys-suite/docs/agents/plan-goal.md` when the user says
  `usa plan-goal` or asks for reviewed full-plan execution.

Mandatory rules:

- use Cloudflare preview for API runtime;
- use Convex cloud `dev`, not local Convex;
- do not use `wrangler dev` or another local Worker as product app backend;
- do not invent alternate runtime/testing flows when the private guide already
  defines one;
- use Infisical/Varlock-backed private tooling for config, deploy keys, and
  secret resolution;
- Account AV iOS login must match Tune AV's keychain pattern:
  `ACCOUNTAV_PUBLISHABLE_KEY`, `ACCOUNTAV_KEYCHAIN_SERVICE`, and
  `ACCOUNTAV_KEYCHAIN_ACCESS_GROUP` must be exposed through Info.plist,
  passed to Account AV, and validated by the runtime config check;
- keep account and product APIs split: `ACCOUNTAV_API_BASE_URL` is for shared
  Account AV routes such as `/v1/me`; `MOMENTSAV_API_BASE_URL` is for
  `/v1/apps/momentsav/*`;
- use the mock final-render route for no-spend validation unless private docs
  explicitly approve a paid provider smoke;
- treat "no-spend" as "no paid provider call", not "skip user credit workflow";
- for Moments AV v1, the final flow is create final video -> download -> finish
  -> Gallery. Do not add preview/versioning branches in this public app.

If the private repo is unavailable, stop and say that the authoritative runbook
cannot be checked. Do not substitute a guessed local workflow.
