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

For local iOS/macOS builds, also follow
`../../private/avalsys-suite/docs/agents/native-cache-hygiene.md`: use
repo-local purpose-named `-derivedDataPath` directories and remove repo-local
`.DerivedData*`/`.derived-data*` caches after the task when no build is using
them.

Before changing `apps/ios/MomentsAV/Resources/*/Localizable.strings`, read
`docs/localization-copy-guide.md` and run its key, placeholder, lint, and
fallback checks before committing.

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
- Infisical is the owner's and read-only for agents: never create, change
  or delete a value there by any means; tell the owner the name,
  environment and reason and the owner does it by hand ("Infisical" in
  `project-bootstrap/docs/WORKING_RULES.md`);
- use Infisical/Varlock-backed private tooling for config, deploy keys, and
  secret resolution;
- Account AV iOS login must match Tune AV's keychain pattern:
  `ACCOUNTAV_PUBLISHABLE_KEY`, `ACCOUNTAV_KEYCHAIN_SERVICE`, and
  `ACCOUNTAV_KEYCHAIN_ACCESS_GROUP` must be exposed through Info.plist,
  passed to Account AV, and validated by the runtime config check;
- before unattended TestFlight/App Store export/upload from a new or recently
  reconfigured Mac, complete the private release-machine setup in
  `private/avalsys-suite/docs/platform/apple-release-machine-setup.md`; the
  Apple Distribution private key must pass non-interactive `codesign`;
- keep account and product APIs split: `ACCOUNTAV_API_BASE_URL` is for shared
  Account AV routes such as `/v1/me`; `MOMENTSAV_API_BASE_URL` is for
  `/v1/apps/momentsav/*`;
- never trigger real-money spend without explicit approval from the user in the
  current conversation. Paid provider calls, real purchase flows, production
  credit-consuming provider routes, and provider evaluation smokes are
  prohibited until the user approves the exact spend path;
- use the mock final-render route for no-spend validation unless private docs
  explicitly approve a paid provider smoke;
- treat "no-spend" as "no paid provider call", not "skip user credit workflow";
- for Moments AV v1, the final flow is create final video -> download -> finish
  -> Gallery. Do not add preview/versioning branches in this public app.

If the private repo is unavailable, stop and say that the authoritative runbook
cannot be checked. Do not substitute a guessed local workflow.

## Verification

Before opening a pull request, run `scripts/check-public-hygiene.sh` once from
the repository root. The web typecheck, the full iOS suite, release builds and
device runs belong to CI and the required checks and are not repeated locally
unless the change needs it; a change to the iOS app runs the simulator test
command in `docs/install-ios.md` before the pull request.

## Review

The independent review that sets `agent-review` follows
[project-bootstrap/docs/REVIEW.md](https://github.com/miguelavalos/project-bootstrap/blob/main/docs/REVIEW.md),
available as `~/github/project-bootstrap/docs/REVIEW.md` on agent machines.
The reviewer is a fresh agent that did not write the change, and its review
comment starts with `PASS` or `BLOCK`.
