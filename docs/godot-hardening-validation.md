# Godot hardening validation record

Validated on 2026-09-14 from the clean game worktree.

## Revisions and layout

- Quantum API addon hardening commit: `3021222b3019b134dcb1490713d8f94b6d45dcd9`
  on `feature/phase-6-5-godot-hardening`; intended immutable release tag:
  `godot-v0.1.2` after merge.
- Game hardening commit: `ce7b10cbda0900f9e316bfcc94c36db3b10925b9` on
  `feature/godot-addon-0.1.2`.
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
- Godot 4.6.3 stable: the real game loaded headlessly and its committed
  `tests/quantum_regression.tscn` passed health, text, simulator gate, and
  API-down fallback checks against a local fixture. Its process exit status was
  zero.
- Godot 4.6.3 stable: Web export succeeded. The rebuilt public and Expo asset
  mirrors have identical SHA-256 values and the package contains the game-only
  HTTPS gateway URL.
- Game gateway: `python -m compileall -q quantum-game-gateway` and
  `python -m pytest quantum-game-gateway/tests -q` passed (3 tests).
- Expo: lint completed with zero errors and seven pre-existing unused-variable
  warnings. Web export completed, a local static server served the rebuilt
  Godot page, and the wrapper iframe used `/godot_web/index.html`.
- Security scan: no key-shaped `qapi_...` values were found in game source,
  rebuilt public assets, Expo asset mirror, or the local Expo export.
- Quantum API: `uv run ruff check .` passed.

## Follow-up gates before release completion

- Godot package CI is configured for 4.4.1, 4.5.2, 4.6.3, and 4.7.2. The local
  4.6.3 run is complete; the other package matrix jobs require CI. The official
  4.7.2 Windows release asset was unavailable at validation time (HTTP 404), so
  no 4.7.2 result is claimed.
- The full pre-existing Quantum API test suite did not complete in this local
  environment: it first required the omitted optional `networkx` dependency,
  then stopped on an existing integration expectation because unavailable
  Redis/Supabase services returned 503 where a test expected 400. This must be
  resolved or reproduced in CI before merging.
- The production game gateway URL returned HTTP 404 at validation time. Deploy
  the systemd and Plesk configuration with a newly created dedicated Echoes of
  Light gateway key, then repeat the production HTTPS smoke test.
- Revoke historical/local exposed credentials. With a fresh developer-only
  direct key supplied through the process environment, run and record the live
  IBM backend, transpile, 128-shot bit-flip job, poll, and result checks.
- Merge the addon PR, create `godot-v0.1.2`, verify the downloadable AssetLib
  archive, update Asset Library asset 5008, pin the game to that released tag,
  merge the game PR, and only then mark the Phase 6.5 TODOs complete.
