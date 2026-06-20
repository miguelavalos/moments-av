# Localization Copy Guide

Status: active public-safe rule for Moments AV client copy.

Moments AV localized strings must keep product vocabulary, placeholders, and
visible workflow expectations aligned across `en`, `ca`, `es`, `fr`, and `de`.

## Source Files

Runtime iOS copy lives in:

```text
apps/ios/MomentsAV/Resources/<locale>.lproj/Localizable.strings
```

All locale files must expose the same key set. Every translated value must keep
the same placeholder contract as English, including `%@`, `%d`, and ordered
format placeholders.

## Product Terms

Use these product terms consistently:

- `Moments AV`, `Apps AV`, `Account AV`, `Avi`, `Pro`, `Gallery`, and
  `Credits` are product terms. Translate only when the shipped app already uses
  a stable localized product label for that concept.
- User-selected Photos assets should be described as photos and clips in
  visible copy. Avoid generic inherited words such as `media`, `medios`,
  `médias`, or `Medien` when the screen is talking about selected Photos
  assets.
- Story/planning copy should read naturally in each locale. Do not leave
  fallback labels such as `Story`, `Media`, `Credits`, `timing`, or full
  English CTAs in non-English locale values unless they are deliberate product
  terms.
- Keep local file availability separate from account-owned metadata. Copy must
  say whether photos/clips, generated videos, Gallery metadata, or downloaded
  files are local to this device or recoverable through the account.

## UI Copy Rules

- Do not add visible promises for generated audio, narration, captions,
  subtitles, text overlays, generated previews, provider quality, permanent
  cloud video storage, or model behavior unless the verified client workflow
  supports them.
- Use the ellipsis character `…` for visible loading or progressive states, not
  three ASCII dots.
- Keep destructive-action copy explicit about what is deleted and what remains
  available.
- Keep account deletion, privacy, support, terms, and purchase copy aligned
  with the shared Apps AV / Account AV pattern.

## Required Checks

Run these checks before committing localization changes:

```bash
plutil -lint apps/ios/MomentsAV/Resources/{ca,es,en,fr,de}.lproj/Localizable.strings
git diff --check
```

Also verify key and placeholder parity:

```bash
node <<'NODE'
const fs = require('fs');
const path = require('path');
const root = 'apps/ios/MomentsAV/Resources';
const locales = ['en', 'ca', 'es', 'fr', 'de'];

function parse(file) {
  const text = fs.readFileSync(file, 'utf8');
  const re = /^"((?:[^"\\]|\\.)*)"\s*=\s*"((?:[^"\\]|\\.)*)";\s*$/gm;
  const out = new Map();
  let match;
  while ((match = re.exec(text))) out.set(match[1], match[2]);
  return out;
}

function placeholders(value) {
  return [...value.matchAll(/%(?:\d+\$)?[0-9.]*[@dfsu]/g)]
    .map((match) => match[0].replace(/%\d+\$/, '%$'))
    .sort();
}

const maps = Object.fromEntries(
  locales.map((locale) => [
    locale,
    parse(path.join(root, `${locale}.lproj/Localizable.strings`)),
  ]),
);
const englishKeys = [...maps.en.keys()].sort();
const problems = [];

for (const locale of locales) {
  const keys = [...maps[locale].keys()].sort();
  const missing = englishKeys.filter((key) => !maps[locale].has(key));
  const extra = keys.filter((key) => !maps.en.has(key));
  if (missing.length || extra.length) problems.push({ locale, missing, extra });
}

for (const key of englishKeys) {
  const base = placeholders(maps.en.get(key)).join(' ');
  for (const locale of locales.filter((item) => item !== 'en')) {
    const value = maps[locale].get(key);
    if (value == null) continue;
    const translated = placeholders(value).join(' ');
    if (translated !== base) {
      problems.push({ locale, key, english: base, translated, value });
    }
  }
}

if (problems.length) {
  console.log(JSON.stringify(problems, null, 2));
  process.exit(1);
}

console.log('Localization key and placeholder parity OK');
NODE
```

When changing translated values, search for common fallback residue:

```bash
rg -n '= ".*(Improve with Avi|Add %@|Story|Media|timing|Timing|\\.\\.\\.).*";' \
  apps/ios/MomentsAV/Resources/{ca,es,fr,de}.lproj/Localizable.strings
```

Review matches manually because product terms such as `Credits`, `Pro`, and
`Avi` may be intentional.
