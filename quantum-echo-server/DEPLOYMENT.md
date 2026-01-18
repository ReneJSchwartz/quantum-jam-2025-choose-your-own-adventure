# Quantum Echo API - Deployment Guide

## Overview

The Quantum Echo API v2.0.0 is hosted at `DavidJGrimsley.com/public-facing/api/quantum/` using a reverse proxy architecture. The Flask API runs locally on the VPS and nginx proxies requests from the public domain. The interactive info page stays at `DavidJGrimsley.com/api/quantum/`.

### Architecture

```
User Request → DavidJGrimsley.com/public-facing/api/quantum/* 
              ↓ (nginx reverse proxy)
           Flask App (127.0.0.1:8000) 
              ↑ (gunicorn + pm2)
```

## Quick Start

### Prerequisites
- Python 3.8+
- pm2 (Node.js process manager) or systemd
- nginx with Plesk control panel
- Access to DavidJGrimsley.com domain settings

### 1. Deploy Flask Application

```bash
# Navigate to the project directory
cd /home/deployer/quantum-jam-2025-choose-your-own-adventure/quantum-echo-server

# Pull latest changes
git pull origin main

# Install dependencies (if not already done)
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
```

### 2. Start with pm2 (Recommended)

```bash
# Start the service (first time)
pm2 start "gunicorn --bind 127.0.0.1:8000 --workers 4 app:app" --name quantum-echo-server

# Save pm2 configuration
pm2 save

# Setup pm2 to start on boot
pm2 startup

# Restart after updates
pm2 restart quantum-echo-server

# Check logs
pm2 logs quantum-echo-server
```

**Important:** Run gunicorn WITHOUT SSL certificates (--certfile/--keyfile) since nginx handles SSL termination.

### 3. Alternative: Start with systemd

Copy the service file template:
```bash
sudo cp deploy/quantum-echo.service.example /etc/systemd/system/quantum-echo.service
```

Edit the service file with your paths:
```bash
sudo nano /etc/systemd/system/quantum-echo.service
```

Update these fields:
- `User=deployer` (your deploy user)
- `WorkingDirectory=/path/to/quantum-echo-server`
- `ExecStart=/path/to/venv/bin/gunicorn ...`

Enable and start:
```bash
sudo systemctl daemon-reload
sudo systemctl enable quantum-echo-server
sudo systemctl start quantum-echo-server
sudo systemctl status quantum-echo-server
```

### 4. Configure nginx Reverse Proxy (Plesk)

1. Log into Plesk control panel
2. Navigate to: **Domains → DavidJGrimsley.com → Apache & nginx Settings**
3. Scroll to **Additional nginx directives**
4. Copy contents from `deploy/PLESK-NGINX-CONFIG.txt` and paste
5. Click **OK** to apply

The nginx configuration:
- Proxies API endpoints to `http://127.0.0.1:8000`
- Proxies `/public-facing/api/quantum/docs` and `/public-facing/api/quantum/openapi.yaml` for documentation
- Lets Expo/React app handle `/api` and `/api/quantum` root paths
- Adds CORS headers for browser access

### 5. Test Deployment

Test Flask app directly (should work):
```bash
curl http://127.0.0.1:8000/public-facing/api/quantum/health
```

Test through nginx proxy (should work after nginx config):
```bash
curl https://DavidJGrimsley.com/public-facing/api/quantum/health
curl -X POST https://DavidJGrimsley.com/public-facing/api/quantum/quantum_text \
  -H "Content-Type: application/json" \
  -d '{"text": "hello quantum"}'
```

Test Swagger documentation:
```bash
# Should serve Swagger UI HTML
curl https://DavidJGrimsley.com/public-facing/api/quantum/docs

# Should return OpenAPI YAML spec
curl https://DavidJGrimsley.com/public-facing/api/quantum/openapi.yaml
```

Visit in browser:
- API Info: https://DavidJGrimsley.com/api/quantum/ (Expo React page)
- Swagger UI: https://DavidJGrimsley.com/public-facing/api/quantum/docs
- Health Check: https://DavidJGrimsley.com/public-facing/api/quantum/health

## Configuration Details

### Environment Variables

No environment variables required. All configuration is in `app.py`:
- `API_PREFIX = "/public-facing/api/quantum"` - Public URL prefix for all routes
- `API_VERSION = "2.0.0"` - Current version
- CORS enabled for all origins

### Ports

- **8000**: Flask app (HTTP only, bound to 127.0.0.1)
- **80/443**: nginx (public-facing with SSL)

**Important:** Do NOT open port 8000 to the public. Keep it bound to localhost.

### SSL/TLS

SSL is handled by nginx/Plesk:
- Use Plesk's Let's Encrypt integration for automatic SSL certificates
- Flask app runs plain HTTP on localhost
- nginx proxies HTTPS → HTTP

### Log Files

**pm2:**
```bash
pm2 logs quantum-echo-server          # Tail logs
pm2 logs quantum-echo-server --lines 100  # Last 100 lines
```

**systemd:**
```bash
sudo journalctl -u quantum-echo-server -f  # Follow logs
sudo journalctl -u quantum-echo-server --since "1 hour ago"
```

**nginx:**
- Check Plesk → Domains → DavidJGrimsley.com → Logs

## Troubleshooting

### 502 Bad Gateway Errors

If you see 502 errors with "Connection reset by peer":

1. Check if Flask app is running: `pm2 status` or `systemctl status quantum-echo-server`
2. Verify Flask is HTTP, not HTTPS: `pm2 logs quantum-echo-server` should show `http://127.0.0.1:8000`
3. If gunicorn started with SSL certs, restart without them:
   ```bash
   pm2 delete quantum-echo-server
   pm2 start "gunicorn --bind 127.0.0.1:8000 --workers 4 app:app" --name quantum-echo-server
   pm2 save
   ```

### Port Already in Use

```bash
# Find process using port 8000
sudo lsof -i :8000

# Kill it if needed
sudo kill -9 <PID>
```

### Dependency Issues

```bash
# Reinstall dependencies
source venv/bin/activate
pip install --upgrade -r requirements.txt
```

### nginx Configuration Issues

1. Check nginx syntax: Plesk validates on save
2. View nginx error logs in Plesk
3. Verify upstream is reachable: `curl http://127.0.0.1:8000/public-facing/api/quantum/health`

## URL Structure

### Public URLs (via DavidJGrimsley.com)

- `GET /api/quantum/` - API info (Expo page)
- `GET /public-facing/api/quantum/health` - Health check
- `POST /public-facing/api/quantum/quantum_text` - Transform text with quantum
- `POST /public-facing/api/quantum/quantum_gate` - Apply quantum gate
- `GET /public-facing/api/quantum/quantum_echo_types` - List available effects
- `GET /public-facing/api/quantum/docs` - Swagger UI documentation
- `GET /public-facing/api/quantum/openapi.yaml` - OpenAPI specification

### Version Information

Version is not in the URL path but available in API responses:
```json
{
  "api": "Quantum Echo API",
  "version": "2.0.0",
  "endpoints": [...]
}
```

## Client Updates

After deployment, clients automatically use the new URLs:
- Godot game clients: `https://DavidJGrimsley.com/public-facing/api/quantum`
- React/Expo web app: `https://DavidJGrimsley.com/api/quantum`

No client-side changes needed after initial migration to v2.

## Maintenance

### Updating the API

```bash
cd /home/deployer/quantum-jam-2025-choose-your-own-adventure/quantum-echo-server
git pull origin main
pm2 restart quantum-echo-server
```

### Monitoring

```bash
# Check process status
pm2 status

# Monitor resource usage
pm2 monit

# View error logs only
pm2 logs quantum-echo-server --err
```

### Backup

The API is stateless, but backup these files:
- `app.py` - Main application
- `quantum_word_dictionary.py` - Word transformation logic
- `requirements.txt` - Dependencies
- `deploy/PLESK-NGINX-CONFIG.txt` - nginx config

All files are in git repository, so regular commits serve as backups.

## Security Notes

1. **Firewall**: Only ports 80/443 should be open to the public
2. **CORS**: Currently allows all origins (`*`) - restrict in production if needed
3. **Rate Limiting**: Consider adding rate limiting to nginx for production
4. **Monitoring**: Set up alerts for 5xx errors and high memory usage
5. **SSL**: Let's Encrypt certs auto-renew through Plesk

## Support

For issues, check:
1. pm2 logs: `pm2 logs quantum-echo-server`
2. nginx logs: Plesk → Logs
3. Flask app directly: `curl http://127.0.0.1:8000/public-facing/api/quantum/health`
4. GitHub issues: https://github.com/ReneJSchwartz/quantum-jam-2025-choose-your-own-adventure/issues
