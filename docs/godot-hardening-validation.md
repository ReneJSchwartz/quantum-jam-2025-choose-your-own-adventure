# Godot hardening validation record

Initially validated on 2026-09-14 from the clean game worktree, with the
direct-mode update recorded below on 2026-09-15.

## Current game shipping choice (2026-09-15)

The earlier game-only gateway approach is retired. Echoes of Light again calls
the existing hosted Quantum API at
`https://davidjgrimsley.com/public-facing/api/quantum/v1` directly with its
bundled game key. There is no additional game server, gateway, VPS process, or
reverse-proxy deployment to operate.

This is the requested jam-game trade-off: the key is present in source and can
be extracted from the build. The game does not block IBM backend discovery,
transpilation, circuit-job submission, status, or result calls provided by the
addon. The gateway-specific files and deployment instructions were removed
from the game branch.

## Revisions and layout

- Quantum API addon hardening commit: `3021222b3019b134dcb1490713d8f94b6d45dcd9`
  on `feature/phase-6-5-godot-hardening`; intended immutable release tag:
  `godot-v0.1.2` after merge.
- Game baseline commit: `ce7b10cbda0900f9e316bfcc94c36db3b10925b9` on
  `feature/godot-addon-0.1.2`; the following branch commit restores the direct
  jam-build arrangement and removes the gateway files.
- Vendored runtime install path:
  `godot_project/addons/quantum_api_client/quantum_api_client.gd`.
- The game copy compares byte-for-byte with the addon source apart from line
  endings. The AssetLib archive at the addon commit had five entries, all under
  `addons/`, and included the runtime client.

## Completed local validation

- Godot 4.6.3 stable: addon package harness passed all 25 cases against its
  deterministic fixture. Coverage includes URL normalization, concurrent
  requests, proxy/direct headers, missing key, request-start failure, 401/429/
  5xx, empty and malformed JSON, timeout, unreachable host, text fallback,
  all three gates, and IBM discovery/transpile/job methods.
- GitHub Actions run 34879977930 passed the archived-addon harness on Godot
  4.4.1, 4.5.2, 4.6.3, and 4.7.2. Its complete Quantum API lint, test, package,
  and Docker build job also passed.
- Godot 4.6.3 stable: the real game loaded headlessly and its committed
  `tests/quantum_regression.tscn` passed health, text, simulator gate, and
  API-down fallback checks against a local fixture while running in direct-key
  mode. Its process exit status was zero.
- Godot 4.6.3 stable: Web export succeeded. The rebuilt public and Expo asset
  mirrors had identical SHA-256 values under the previous gateway configuration.
- Expo: lint completed with zero errors and seven pre-existing unused-variable
  warnings. Web export completed, a local static server served the rebuilt
  Godot page, and the wrapper iframe used `/godot_web/index.html`.
- Rebuilt Web package: contains the direct hosted-API address, contains no
  reference to the retired game gateway, and contains the expected bundled game
  key. The key was not printed during validation.
- Quantum API: `uv run ruff check .` passed.

## Follow-up gates before release completion

- The local game run remains 4.6.3. The archived-addon CI matrix passed 4.4.1,
  4.5.2, 4.6.3, and 4.7.2; a separate local 4.7.2 game-editor run was not
  performed. A direct Windows 4.7.2 download URL returned 404 during local
  setup, but this does not affect the successful Linux CI matrix.
- A reduced local Quantum API test invocation first lacked optional `networkx`
  and then encountered unavailable Redis/Supabase services. The repository CI
  installs all declared extras and its complete Python test stages passed, so
  that local environment limitation is not a merge blocker.
- Direct production smoke: health and simulator gate execution succeeded. Text
  transformation currently receives an HTTP 500 from the existing hosted
  Quantum API, so the hardened regression runner now correctly fails rather
  than treating the local fallback text as an API success. An API-side fallback
  fix is committed in Quantum API PR #16 and must be merged and deployed before
  repeating this production text check.
- After that API deployment, repeat the direct production smoke, then run and
  record the IBM backend, transpile, 128-shot bit-flip job, poll, and result
  checks.
- Merge the addon PR, create `godot-v0.1.2`, verify the downloadable AssetLib
  archive, update Asset Library asset 5008, pin the game to that released tag,
  merge the game PR, and only then mark the Phase 6.5 TODOs complete.
