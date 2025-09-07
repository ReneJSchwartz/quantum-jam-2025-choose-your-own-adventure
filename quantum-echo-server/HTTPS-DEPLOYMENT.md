# HTTPS Deployment Guide for Quantum Echo Server

## Problem: Mixed Content Security Error
Your Expo app is hosted on HTTPS (`https://happy-noyce.108-175-12-95.plesk.page/godot_web/index.html`) but trying to access your Flask server over HTTP (`http://108.175.12.95:8000`). Modern browsers block this for security reasons.

## Solution: Enable HTTPS on Flask Server

### Option 1: Quick Fix with Self-Signed Certificate (Testing)

1. **Install PyOpenSSL** (already added to requirements.txt):
```bash
pip install pyopenssl
```

2. **Run with HTTPS**:
```bash
python deploy_https.py
```

This creates a temporary self-signed certificate. Your browser will show a security warning, but you can proceed.

### Option 2: Production Setup with Let's Encrypt (Recommended)

1. **Install Certbot on your VPS**:
```bash
sudo apt update
sudo apt install certbot
```

2. **Get SSL Certificate**:
```bash
sudo certbot certonly --standalone -d 108.175.12.95
```

3. **Update app.py to use real certificates**:
```python
if __name__ == '__main__':
    context = ssl.SSLContext(ssl.PROTOCOL_TLS_SERVER)
    context.load_cert_chain('/etc/letsencrypt/live/108.175.12.95/fullchain.pem', 
                           '/etc/letsencrypt/live/108.175.12.95/privkey.pem')
    app.run(host='0.0.0.0', port=8000, ssl_context=context, debug=False)
```

### Option 3: Use Nginx as HTTPS Proxy (Most Professional)

1. **Install Nginx**:
```bash
sudo apt install nginx
```

2. **Configure Nginx** (/etc/nginx/sites-available/quantum-server):
```nginx
server {
    listen 443 ssl;
    server_name 108.175.12.95;

    ssl_certificate /etc/letsencrypt/live/108.175.12.95/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/108.175.12.95/privkey.pem;

    location / {
        proxy_pass http://127.0.0.1:8000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

3. **Enable site and restart Nginx**:
```bash
sudo ln -s /etc/nginx/sites-available/quantum-server /etc/nginx/sites-enabled/
sudo systemctl restart nginx
```

4. **Keep Flask on HTTP (Nginx handles HTTPS)**:
```bash
python app.py
```

## What We've Already Done

✅ Updated all Godot files to use `https://108.175.12.95:8000` instead of `http://`
✅ Added PyOpenSSL to requirements.txt
✅ Created deploy_https.py for easy HTTPS deployment
✅ Updated app.py with HTTPS configuration comments

## Files Updated
- `dialogue_ui_manager.gd` - quantum_text endpoint
- `quantum_echo_service.gd` - SERVER_URL constant
- `QuantumEchoManager.gd` - server_url variable
- `quantum_gate_manager.gd` - quantum_gates endpoint
- `quantum_dialogue_test.gd` - quantum_gates endpoint

## Next Steps
1. Choose one of the HTTPS options above
2. Deploy your server with HTTPS enabled
3. Test your Expo app - the mixed content error should be resolved!

## Testing
After enabling HTTPS, test these endpoints:
- `https://108.175.12.95:8000/quantum_text`
- `https://108.175.12.95:8000/quantum_gates`

Your Godot game should now work properly in the HTTPS Expo environment!
