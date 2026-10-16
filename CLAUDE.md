@../verox-ai/CLAUDE.md

# verox-l10n

Translation JSON files for Verox's web UI (`verox-webui`) — copied from `RoPieee/ropieee-l10n`. `en-US.json` is the master file: both the default language and the fallback when a specific translation is missing a key. Keys/subkeys are used by the software and must not be renamed.

Shared Verox/RoPieee ecosystem context (naming, branding, migration status, which repos are live) is imported above from `../verox-ai/CLAUDE.md`.

This repo is **public** (like its upstream `ropieee-l10n`) — community translators submit PRs directly against it.

**New keys: add them to `en-US.json` only** (Harry, 2026-10-12). Don't fill in the other languages yourself, even when you could: each translator picks up the new key for their own language later, and until then the web UI falls back to English. `TODO.md` (regenerated with `./check.sh todo`) lists the missing keys per language for them.

**Changed English text: reset the translations only when the meaning changes** (Harry, 2026-10-16). When an `en-US.json` value now says something different (new information, a different instruction, the old sentence is now wrong), remove that key from every other language file and run `./check.sh todo`: `TODO.md` then lists it as missing for translators, and the web UI shows the new English until they catch up. A wording or punctuation tweak that keeps the meaning leaves the other languages alone, because their translations are still correct. `check.sh` can't detect an outdated translation on its own, only a missing or empty one, so this reset is the only signal translators get.
