# Deployment Instructions for Quantum API v2.0.0

This guide covers deploying the v2.0.0 update with the new URL structure.

## Overview

The v2.0.0 update restructures the API URLs to nest them under your portfolio website. The actual API server remains on `quantum-api.davidjgrimsley.com`, but requests are proxied through `DavidJGrimsley.com/api/quantum/`.

## Architecture

```
User Request → DavidJGrimsley.com/api/quantum/* 
              ↓ (nginx reverse proxy)
           quantum-api.davidjgrimsley.com/api/quantum/* 
              ↓ (nginx reverse proxy on quantum-api host)
           Flask App (127.0.0.1:8000) via Gunicorn
```

## Deployment Steps

### 1. Update Quantum API Backend Server

On the server hosting `quantum-api.davidjgrimsley.com`:

```bash
cd /path/to/quantum-echo-server

# Pull latest changes
git pull origin main

# Restart the API service
pm2 restart quantum-echo-server
# OR if using systemd:
# sudo systemctl restart quantum-echo-server

# Verify it's running with new routes
pm2 logs quantum-echo-server
```

Test the backend directly:
```bash
curl https://quantum-api.davidjgrimsley.com/api/quantum/health
```

### 2. Configure Reverse Proxy on Portfolio Website

On your portfolio website hosting (Plesk admin for DavidJGrimsley.com):

1. **Navigate to**: Domains → DavidJGrimsley.com → Apache & nginx Settings

2. **Add the nginx configuration** from `deploy/portfolio-nginx-proxy.conf` to the "Additional nginx directives" field:

   ```nginx
   # Proxy API endpoints to the quantum-api backend server
   location ~ ^/api/quantum/(quantum_text|quantum_gate|quantum_echo_types|health)$ {
       proxy_pass https://quantum-api.davidjgrimsley.com;
       proxy_set_header Host quantum-api.davidjgrimsley.com;
       proxy_set_header X-Real-IP $remote_addr;
       proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
       proxy_set_header X-Forwarded-Proto $scheme;
       proxy_set_header X-Forwarded-Port $server_port;
       
       # CORS headers for browser requests
       add_header Access-Control-Allow-Origin * always;
       add_header Access-Control-Allow-Methods "GET, POST, OPTIONS" always;
       add_header Access-Control-Allow-Headers "Content-Type, Authorization" always;
       
       # Handle OPTIONS preflight requests
       if ($request_method = 'OPTIONS') {
           return 204;
       }
   }

   # Proxy API info endpoint
   location ~ ^/api/quantum/?$ {
       proxy_pass https://quantum-api.davidjgrimsley.com;
       proxy_set_header Host quantum-api.davidjgrimsley.com;
       proxy_set_header X-Real-IP $remote_addr;
       proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
       proxy_set_header X-Forwarded-Proto $scheme;
       proxy_set_header X-Forwarded-Port $server_port;
   }

   # Proxy Swagger UI to the quantum-api server
   location /api/quantum/docs {
       proxy_pass https://quantum-api.davidjgrimsley.com/swagger.html;
       proxy_set_header Host quantum-api.davidjgrimsley.com;
       proxy_set_header X-Real-IP $remote_addr;
       proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
       proxy_set_header X-Forwarded-Proto $scheme;
       
       # Rewrite links in the Swagger UI to work with the proxy
       sub_filter 'https://quantum-api.davidjgrimsley.com' 'https://DavidJGrimsley.com';
       sub_filter_once off;
       sub_filter_types text/html text/css application/javascript;
   }

   # Proxy OpenAPI spec
   location /api/quantum/openapi.yaml {
       proxy_pass https://quantum-api.davidjgrimsley.com/openapi.yaml;
       proxy_set_header Host quantum-api.davidjgrimsley.com;
       add_header Content-Type application/x-yaml;
   }
   ```

3. **Important Settings** in Plesk:
   - ✅ Enable "Smart static files processing"
   - ❌ Disable "Proxy mode" (if shown)
   - ❌ Disable PHP support (if this causes conflicts)

4. **Click "OK" or "Apply"** to save the configuration

5. **Test nginx configuration**:
   ```bash
   sudo nginx -t
   ```

6. **Reload nginx** (Plesk usually does this automatically, but if not):
   ```bash
   sudo systemctl reload nginx
   ```

### 3. Test the Proxied API

Test all endpoints through the portfolio URL:

```bash
# Service info
curl https://DavidJGrimsley.com/api/quantum/

# Health check
curl https://DavidJGrimsley.com/api/quantum/health

# Transform text
curl -X POST https://DavidJGrimsley.com/api/quantum/quantum_text \
  -H "Content-Type: application/json" \
  -d '{"text": "Hello quantum world!"}'

# Apply quantum gate
curl -X POST https://DavidJGrimsley.com/api/quantum/quantum_gate \
  -H "Content-Type: application/json" \
  -d '{"gate": "bit_flip"}'

# Check Swagger UI (open in browser)
# https://DavidJGrimsley.com/api/quantum/docs
```

### 4. Deploy Client Applications

Deploy your updated client applications:

**Godot Project:**
- Export the Godot game with updated URLs
- Deploy to itch.io or your hosting platform

**React/Expo Project:**
- Build and deploy to your portfolio site at `/api/quantum` route
- Ensure the interactive page is accessible

### 5. Update Portfolio Website

Add pages to your portfolio:

1. **`/api`** - Landing page listing all your APIs
2. **`/api/quantum`** - Interactive Expo/React page for Quantum API
3. The docs at `/api/quantum/docs` are already proxied from the backend

## Troubleshooting

### 502 Bad Gateway
- Check quantum-api backend is running: `pm2 status`
- Verify backend responds: `curl https://quantum-api.davidjgrimsley.com/api/quantum/health`
- Check nginx error logs: `sudo tail -f /var/log/nginx/error.log`

### CORS Errors
- Ensure CORS headers are in nginx config
- Check browser console for specific error messages
- Verify OPTIONS preflight is handled (returns 204)

### 404 Not Found
- Verify nginx configuration was applied
- Check nginx regex patterns match your URL structure
- Test nginx config: `sudo nginx -t`

### SSL/Certificate Issues
- Portfolio site SSL should cover all subpaths
- No need for separate SSL on quantum-api (handled by portfolio)
- Verify certificate: `curl -v https://DavidJGrimsley.com/api/quantum/health`

## Rollback Plan

If issues arise, you can temporarily rollback:

1. **Remove nginx proxy config** from portfolio site
2. **Update client apps** to use direct backend URL:
   ```
   https://quantum-api.davidjgrimsley.com/api/quantum/
   ```
3. **Announce temporary direct access** to users

The backend server supports both URL structures.

## Monitoring

Monitor the API after deployment:

```bash
# Backend server logs
pm2 logs quantum-echo-server

# Nginx access logs (portfolio site)
sudo tail -f /var/log/nginx/access.log | grep "/api/quantum"

# Nginx error logs
sudo tail -f /var/log/nginx/error.log
```

## Next Steps

1. Test thoroughly in staging/development
2. Deploy to production during low-traffic period
3. Monitor for errors and performance issues
4. Update documentation and announce to users
5. Consider adding API rate limiting
6. Set up monitoring/alerting for API health

## Support

For deployment issues:
- Check [V2-MIGRATION-GUIDE.md](V2-MIGRATION-GUIDE.md)
- Review [DEPLOYMENT-GUIDE.md](DEPLOYMENT-GUIDE.md) for backend setup
- Consult Plesk documentation for proxy configuration
