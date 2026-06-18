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
- Preview app legal/support/account links use preview URLs.
- Commercial metadata and Avi asset presentation were polished during the
  audit.
