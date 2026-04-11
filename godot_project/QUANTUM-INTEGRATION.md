# Quantum Integration for Godot

This game now targets the public Quantum Gateway flow by default.

## Runtime Model

- The Godot client talks to `https://davidjgrimsley.com/public-facing/api/quantum-gateway/v1`.
- Protected runtime calls do not ship a raw Quantum API key.
- The client uses a publishable Gateway client key to mint a short-lived runtime token.
- Gateway forwards the request to Quantum API through the internal Gateway trust path.
- Direct Quantum API key mode stays available only for local/dev fallback.

## Tracked Settings

The tracked `project.godot` file should keep these empty:

- `quantum_api/publishable_gateway_client_key`
- `quantum_api/direct_api_key`

For local testing, set one of these at runtime:

- `QUANTUM_GATEWAY_CLIENT_KEY`
- `QUANTUM_API_KEY`

If both are empty, health checks still work and protected runtime routes fail with clear diagnostics.

## Vendored Addon Policy

- Vendored install path: `addons/quantum_api_client/`
- Canonical source: `DavidJGrimsley/quantum-api`
- Update procedure: replace the vendored addon with the current `addons/quantum_api_client/` contents from the shared source repo

## Jeff Flow

1. Jeff signs in with an Identerest account.
2. Jeff creates a Quantum API key and IBM profile on the Quantum API page.
3. Jeff creates a Gateway project on the Gateway page.
4. Jeff creates a publishable Gateway client key for this game.
5. Jeff sets `QUANTUM_GATEWAY_CLIENT_KEY` locally while testing.
6. The game mints runtime tokens automatically before protected runtime calls.
