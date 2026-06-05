# Moments AV Agent Rules

This public repo does not define the full signed-runtime testing workflow.

For any Moments AV workflow validation that touches signed account state,
credits, uploads, Convex, render plans, final renders, artifacts, purchases, or
deletion flows, follow the private AVALSYS guide:

- `private/avalsys-suite/docs/platform/native-preview-dev-validation-guide.md`
- `private/avalsys-suite/docs/moments-av/preview-dev-validation-guide.md`

Mandatory rules:

- use Cloudflare preview for API runtime;
- use Convex cloud `dev`, not local Convex;
- do not use `wrangler dev` or another local Worker as product app backend;
- do not invent alternate runtime/testing flows when the private guide already
  defines one;
- use Infisical/Varlock-backed private tooling for config, deploy keys, and
  secret resolution;
- use the mock final-render route for no-spend validation unless private docs
  explicitly approve a paid provider smoke.

If the private repo is unavailable, stop and say that the authoritative runbook
cannot be checked. Do not substitute a guessed local workflow.
