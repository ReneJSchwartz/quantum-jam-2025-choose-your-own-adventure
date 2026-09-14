# Echoes of Light Quantum Game Gateway

This is a deliberately narrow server-side gateway for **this public game only**.
It is not a shared Quantum API gateway and never accepts, stores, or forwards a
player's or another developer's API key.

It exposes exactly these routes beneath `/v1`:

- `GET /health`
- `POST /gates/run`
- `POST /text/transform`

The gateway binds only to `127.0.0.1:8101`, validates the two request payload
types, enforces Redis-backed per-IP limits, uses explicit production origins,
and sends its one dedicated upstream key only to Quantum API at
`127.0.0.1:8000/v1`. IBM, job, management, transpile, and arbitrary proxy
routes are deliberately unavailable.

## Production setup

1. Create a dedicated **Echoes of Light Web Gateway** Quantum API key. Revoke
   the historically exposed key before deploying.
2. Copy `.env.example` to `/etc/quantum-echoes-gateway.env`, set the key there,
   and make the file owned by root with mode `0600`.
3. Install the service example as `/etc/systemd/system/quantum-echoes-gateway.service`,
   create the unprivileged `quantumgateway` account and log directory, then
   enable and start it.
4. Add `deploy/PLESK-NGINX-CONFIG.txt` to Plesk's Additional nginx directives.
5. Smoke-test only the public game URL:
   `https://davidjgrimsley.com/public-facing/games/echoes-of-light/quantum/v1/health`.

Do not place production values in `.env` within this repository. The public
Godot Web build remains credential-free and talks only to the HTTPS gateway.
