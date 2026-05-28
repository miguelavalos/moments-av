# Moments AV App Store Metadata

Status: first-publication ASO draft. Final text must be checked in App Store
Connect against the submitted build, current Apple field limits, screenshots,
App Privacy answers, and review notes.

Apple's current product-page guidance says the subtitle can be up to 30
characters and promotional text can be up to 170 characters. Apple's App Store
Connect help also warns that the app is already searchable by app name and
company name, so those values should not be duplicated in the keyword list.

Sources checked on 2026-05-20:

- Apple Developer, Creating Your Product Page:
  https://developer.apple.com/app-store/product-page/
- Apple Developer, App Store Connect Help, app review/platform version
  information:
  https://developer.apple.com/help/app-store-connect/reference/app-review-information

## Metadata Principles

- Match the exact submitted build.
- Put the strongest searchable phrase in the app name or subtitle, not both.
- Avoid duplicate words across app name, subtitle, and keywords.
- Use user-search language, not internal implementation terms.
- Do not mention unshipped roadmap features, unlimited generation, open-ended
  Avi chat, autonomous editing, or unsupported access claims.
- Keep privacy, credits, account deletion, and provider availability consistent
  with the app, screenshots, App Privacy inventory, and review notes.

## Recommended First-Publication Set

Use this as the starting candidate unless App Store Connect, legal/privacy
review, or final screenshot captions require changes.

```text
App name:
Moments AV: Memory Videos

Subtitle:
Turn photos into video stories

Promotional text:
Create private memory videos from selected photos and short clips. Avi helps prepare the story before you create the video.

Keywords draft:
birthday,party,recap,slideshow,memories,family,clips,story,maker,private,gift,photos
```

Notes:

- `Moments AV: Memory Videos` uses more of the visible 30-character name field
  while keeping the brand first.
- The subtitle avoids repeating `memory` and `videos` from the name.
- The keyword draft avoids `moments`, `AV`, `memory`, `video`, and `photos`
  duplication except `photos`, which should be removed if App Store Connect or
  final title/subtitle coverage makes it wasteful.
- `private` is useful only if the final privacy policy and service behavior
  support the claim.

## Alternative App Names

- `Moments AV`
- `Moments AV: Photo Stories`
- `Moments AV: Video Memories`

Selection rule:

Use the shortest name if final icon/screenshot branding needs the product name
to stay cleaner. Use the longer searchable name only if it fits App Store
Connect and does not create visual or metadata duplication.

## Alternative Subtitles

- `Turn photos into videos`
- `Private photo and clip stories`
- `Birthday and party videos`

Selection rule:

Pick the subtitle after the final app name. Do not repeat the same primary
tokens unless there is a deliberate ASO reason and enough room remains in the
keyword field.

## Description Draft

```text
Moments AV helps you turn selected photos and short clips into short memory videos for birthdays, parties, and personal moments.

Choose photos or clips, review the simple dashboard, and let Avi prepare the story direction, pacing, and music. Create the video when you are ready.

Moments AV is built around private projects, clear credit use, and account controls through Account AV.

What you can do:
- Select individual photos and clips, or add photos from supported Photos collections.
- Review the media and direction before video creation.
- Ask Avi to prepare an editable story plan, mood, pacing, and music.
- Create the video only when you are ready to spend credits.
- Keep projects tied to Account AV with support, privacy, terms, and deletion routes available from the app.
```

Before using this description:

- [ ] Confirm the credit/access surface visible in the submitted build.
- [ ] Confirm final provider availability during App Review.
- [ ] Confirm public Privacy Policy and App Privacy answers support the privacy
  language.
- [ ] Confirm Account AV deletion and project deletion language.

## Screenshot Caption Drafts

Use only captions that match real screenshots from the release-candidate build.

- `Create memory videos from selected photos and clips`
- `Start with birthday, party, or playful story templates`
- `Let Avi prepare the story before video creation`
- `Review media and direction before spending credits`
- `Keep credits, projects, and account controls clear`

Avoid captions that mention:

- unlimited generation;
- fully autonomous editing;
- open-ended chat;
- instant final delivery;
- unconfirmed retention or deletion timing;
- access modes, plans, or offers not live in the submitted build.

## Localization TODO

First publication can ship with one primary locale if the product, support, and
privacy surfaces are not yet localized.

- [ ] Confirm primary language in App Store Connect.
- [ ] Decide whether Spanish metadata is included at first publication.
- [ ] If Spanish is included, review every claim against the same screenshots,
  privacy answers, and review notes.
- [ ] Do not machine-translate legal, credit, deletion, or provider-availability
  claims without human review.

## Final Metadata Gate

Before entering metadata in App Store Connect:

1. App name and subtitle fit current App Store Connect limits.
2. Keyword field fits the current App Store Connect limit.
3. No high-value terms are duplicated across name, subtitle, and keywords
   without a deliberate reason.
4. Description and promotional text only describe shipped behavior.
5. Screenshot captions match real release-candidate screenshots.
6. App Privacy inventory and review notes agree with the metadata.
7. Canonical asset gate is complete before final screenshot framing or icon
   references are used.
