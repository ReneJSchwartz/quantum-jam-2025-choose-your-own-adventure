# Echoes of Light Quantum Integration

The shipped game uses `addons/quantum_api_client/` as a **runtime addon**. It
is not an editor plugin, so do not enable it in the Plugins tab. The bridge
creates the client when the scene tree is ready and queues first-frame calls so
dialogue and gate requests cannot race that lifecycle.

## Public build configuration

`project.godot` is deliberately credential-free:

```ini
[quantum_api]
base_url="https://davidjgrimsley.com/public-facing/games/echoes-of-light/quantum/v1"
backend_proxy_mode=true
direct_api_key=""
request_timeout_seconds=10.0
gate_execution_mode="simulator"
```

The public endpoint is the game-only gateway in `../quantum-game-gateway/`.
It forwards only health, text transform, and simulator gate calls. It is not a
general-purpose Quantum API proxy and it never receives a browser or player API
key.

## Vendored addon release

`addons/quantum_api_client/quantum_api_client.gd` is copied verbatim from
Quantum API commit `3021222b3019b134dcb1490713d8f94b6d45dcd9`, the hardening
commit to be released as immutable tag `godot-v0.1.2` after its pull request is
merged. Do not make game-specific edits in that addon; keep integration logic
in `source/dialogue/quantum_api_bridge.gd`.

## Local direct-mode validation

For an operator-only live IBM check, set `QUANTUM_API_KEY` in the process that
launches Godot, set `backend_proxy_mode=false` for that local process, and use a
fresh key. Do not save that setting, put it in `.env`, commit it, or export it.
The supplied `.env.example` is documentation only; Godot reads the process
environment, not `.env` files.

## Regression runner

Run the committed `tests/quantum_regression.tscn` scene with
`-- --quantum-regression` when running Godot headlessly. It exits nonzero when
health, transformation, gate execution, or the API-down text fallback check
fails. For a deterministic local run only, set `QUANTUM_API_TEST_BASE_URL` to a
fixture URL; this never changes the committed public configuration. The bridge
uses the configured request timeout, so an outage cannot leave gameplay waiting
indefinitely.
