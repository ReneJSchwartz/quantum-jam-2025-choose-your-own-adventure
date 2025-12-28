Plesk deployment checklist for Quantum Echo Server

1. Document root
   - In Plesk, set the Document Root of the domain `quantum-api.davidjgrimsley.com` to the `public/` folder in this repo.
   - This allows `index.html` and `swagger.html` to be served as static docs.

2. Proxy configuration
   - Add the contents of `docs/plesk-nginx-proxy.conf` to the "Additional nginx directives" for the domain and click Apply.
   - This will proxy the API endpoints (e.g., `/quantum_text`, `/quantum_gate`, `/health`) to the local Gunicorn server at `127.0.0.1:8000`.

3. SSL / Let's Encrypt
   - Use Plesk's SSL/TLS Certificates (Let's Encrypt) feature to issue a cert for `quantum-api.davidjgrimsley.com`.
   - Once enabled, Plesk will serve HTTPS and the proxy will have `X-Forwarded-Proto: https` set.

4. Gunicorn and systemd
   - Create a Python virtualenv in the repo and install requirements (e.g., `python -m venv venv && venv/bin/pip install -r requirements.txt`).
   - Copy `deploy/quantum-echo.service.example` to `/etc/systemd/system/quantum-echo.service` and edit `User`, `WorkingDirectory`, and `PATH` to your deploy user.
   - Reload systemd and enable the service: `sudo systemctl daemon-reload && sudo systemctl enable --now quantum-echo.service`.
   - Check status with `sudo systemctl status quantum-echo.service` and logs with `sudo journalctl -u quantum-echo.service -f`.

5. Firewall
   - Do NOT open port 8000 to the public. Keep only 80/443 open. If you must modify firewall rules, use Plesk's Firewall extension or `ufw`/`firewalld` so rules persist.

6. Test
   - Health: `curl -k https://quantum-api.davidjgrimsley.com/health`
   - Swagger: Visit https://quantum-api.davidjgrimsley.com/swagger.html and try the endpoints.

7. Notes
   - The app is configured to trust `X-Forwarded-*` headers via `ProxyFix` (see `app.py`).
   - Keep Gunicorn bound to `127.0.0.1:8000` and let nginx handle TLS/HTTP/S for public-facing access.