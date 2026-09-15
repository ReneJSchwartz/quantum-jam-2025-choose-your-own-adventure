# Echoes of Light Quantum Integration

The shipped game uses `addons/quantum_api_client/` as a **runtime addon**. It
is not an editor plugin, so do not enable it in the Plugins tab. The bridge
creates the client when the scene tree is ready and queues first-frame calls so
dialogue and gate requests cannot race that lifecycle.

## Public build configuration

`project.godot` talks directly to Quantum API:

```ini
[quantum_api]
base_url="https://davidjgrimsley.com/public-facing/api/quantum/v1"
backend_proxy_mode=false
direct_api_key="<shipped game key>"
request_timeout_seconds=10.0
gate_execution_mode="simulator"
```

There is no game-specific gateway or VPS deployment. The game calls the
existing hosted Quantum API directly and sends its bundled key on protected
requests. This is the deliberately simple jam-game choice: anyone can extract
and reuse that key from the game build. The addon still exposes direct IBM
backend, transpile, job submission, status, and result methods; no route is
being blocked by the game.

## Vendored addon release

`addons/quantum_api_client/quantum_api_client.gd` is copied verbatim from
Quantum API commit `3021222b3019b134dcb1490713d8f94b6d45dcd9`, the hardening
commit to be released as immutable tag `godot-v0.1.2` after its pull request is
merged. Do not make game-specific edits in that addon; keep integration logic
in `source/dialogue/quantum_api_bridge.gd`.

## Direct-mode note

The checked-in game configuration is already in direct mode. `QUANTUM_API_KEY`
can still override the key for a developer-only test, but it is not required to
run the shipped game. Do not expect the shipped key to remain private.

## Regression runner

Run the committed `tests/quantum_regression.tscn` scene with
`-- --quantum-regression` when running Godot headlessly. It exits nonzero when
health, transformation, gate execution, or the API-down text fallback check
fails. For a deterministic local run only, set `QUANTUM_API_TEST_BASE_URL` to a
fixture URL; this overrides only that regression run. The bridge uses the
configured request timeout, so an outage cannot leave gameplay waiting
indefinitely.
