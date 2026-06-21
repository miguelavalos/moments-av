# Moments AV Web App Pattern

Moments AV follows the shared Apps AV web product app pattern documented in
`public/apps-av/docs/web-product-app-patterns.md`.

## Current Scope

Moments AV web currently has public home/sign-in routes and protected product
routes for create, in-progress, gallery, and Avi. It does not yet expose
dedicated `/account` or `/settings` routes.

## Shell And Avi

All product routes use `MomentsAppShell`, which delegates to the shared
`@avalsys/apps-av-web` `AppShell`.

Avi is exposed through the shared assistant slot and `/avi`. Do not add a fixed
bottom assistant button, and do not duplicate Avi in the main nav links.

## Public And Protected Routes

`/` renders public localized product copy inside the shared shell. Signed-out
users also see the compact sign-in panel on the home route.

Protected routes must keep using `ProtectedRoute` so create, in-progress,
gallery, and Avi stay behind Account AV.

## QA

Run:

```bash
bun run typecheck
bun run build:production
bun run qa:shared
```

`qa:shared` covers five locales, product-owned locale links, signed-out
protection gates, and public home/sign-in copy.
