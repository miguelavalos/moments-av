# Moments AV Web Audit

Status: current as of 2026-06-18.

Moments AV commercial web and Moments AV web app were checked as part of the AV
web visual audit.

## Contract

- User-facing web content supports `en`, `es`, `fr`, `de`, and `ca`.
- AV-owned links preserve the active language.
- The interactive web app exposes a public informational `/`, requires login for
  functional product routes, and does not expose guest-mode product
  functionality in signed-out app areas.
- The app surface avoids visible lowercase `avalsys` except where legal or
  commercial context requires company naming.

## Latest Audit Result

- Commercial desktop and mobile browser QA passed.
- Web app desktop and mobile browser QA passed.
- Protected app routes require sign-in and keep language on sign-in links.
- Preview app legal/support/account links use preview URLs when those URLs
  exist; production links from preview are allowed only as documented temporary
  exceptions until matching preview targets exist.
- Commercial metadata and Avi asset presentation were polished during the
  audit.
- The preview web app build no longer emits the large client chunk warning:
  vendor chunks are split for Clerk, serialization, UI, and app bootstrap while
  keeping the same public `/`, sign-in, and protected-route behavior.
- The production web app was deployed at `https://app.moments-av.avalsys.com`.
  Production QA passed for public `/`, `/sign-in`, `/create`, `/gallery`, and
  `/avi` with localized routes, Clerk secrets present, no guest-mode copy, no
  visible lowercase `avalsys`, and no app-owned links dropping the active
  language.
