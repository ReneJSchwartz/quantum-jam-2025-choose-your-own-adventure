# Git-Based Deployment Guide for Quantum Echo Server

## 🚀 **Deployment via Git (Recommended)**

Since you have SSH access as the `deployer` user, let's deploy using Git which is much cleaner.

### **Step 1: SSH into Your Server**

```bash
ssh deployer@108.175.12.95
```

### **Step 2: Clone the Repository**

```bash
# Navigate to your home directory
cd /home/deployer

# Clone the repository
git clone https://github.com/ReneJSchwartz/quantum-jam-2025-choose-your-own-adventure.git

# Navigate to the quantum echo server
cd quantum-jam-2025-choose-your-own-adventure/quantum-echo-server
```

### **Step 3: Set Up Python Environment**

```bash
# Check Python version
python3 --version

# Create virtual environment
python3 -m venv venv

# Activate virtual environment
source venv/bin/activate

# Upgrade pip
pip install --upgrade pip

# Install dependencies (start with minimal)
pip install flask flask-cors requests

# Test if it works
python3 deploy/app-minimal.py &
curl http://localhost:5000/health
# Press Ctrl+C to stop
```

### **Step 4: Test the Full Version (Optional)**

```bash
# If the minimal version works, try the full version
pip install qiskit qiskit-aer numpy

# Test the full version
python3 deploy/app.py &
curl http://localhost:5000/health
# Press Ctrl+C to stop
```

### **Step 5: Set Up as a Service (Run in Background)**

Create a simple systemd service or use screen/tmux:

#### **Option A: Using screen (Simple)**
```bash
# Install screen if not available
sudo apt install screen -y

# Start a screen session
screen -S quantum-echo

# In the screen session, run your app
cd /home/deployer/quantum-jam-2025-choose-your-own-adventure/quantum-echo-server
source venv/bin/activate
python3 deploy/app-minimal.py  # or app.py for full version

# Press Ctrl+A then D to detach from screen
# The app will keep running in the background

# To reconnect to the screen later:
# screen -r quantum-echo
```

#### **Option B: Using systemd service (Advanced)**
```bash
# Create service file
sudo tee /etc/systemd/system/quantum-echo.service << EOF
[Unit]
Description=Quantum Echo Server
After=network.target

[Service]
Type=simple
User=deployer
WorkingDirectory=/home/deployer/quantum-jam-2025-choose-your-own-adventure/quantum-echo-server
Environment=PATH=/home/deployer/quantum-jam-2025-choose-your-own-adventure/quantum-echo-server/venv/bin
ExecStart=/home/deployer/quantum-jam-2025-choose-your-own-adventure/quantum-echo-server/venv/bin/python deploy/app-minimal.py
Restart=always

[Install]
WantedBy=multi-user.target
EOF

# Enable and start the service
sudo systemctl daemon-reload
sudo systemctl enable quantum-echo
sudo systemctl start quantum-echo
sudo systemctl status quantum-echo
```

### **Step 6: Set Up Reverse Proxy (Make it Accessible)**

Since your app runs on localhost:5000, you need to make it accessible from the internet.

#### **Option A: Nginx Reverse Proxy**
```bash
# Install nginx if not available
sudo apt install nginx -y

# Create nginx config
sudo tee /etc/nginx/sites-available/quantum-echo << EOF
server {
    listen 80;
    server_name happy-noyce.108-175-12-95.plesk.page;
    
    location /quantum-api/ {
        proxy_pass http://127.0.0.1:5000/;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}
EOF

# Enable the site
sudo ln -s /etc/nginx/sites-available/quantum-echo /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx
```

#### **Option B: Use a Different Port**
```bash
# Modify your app to run on a different port (like 8000)
# Edit deploy/app-minimal.py and change the last line:
# app.run(host='0.0.0.0', port=8000, debug=False)

# Then access it via: http://108.175.12.95:8000/health
```

### **Step 7: Test Your Deployment**

```bash
# Test health endpoint
curl http://happy-noyce.108-175-12-95.plesk.page/quantum-api/health

# Test quantum echo
curl -X POST http://happy-noyce.108-175-12-95.plesk.page/quantum-api/quantum_echo \
     -H "Content-Type: application/json" \
     -d '{"text": "Hello quantum world!", "echo_type": "scramble"}'
```

### **Step 8: Update Your Godot Game**

Change the server URL in your Godot script:
```gdscript
var server_url = "http://happy-noyce.108-175-12-95.plesk.page/quantum-api"
# or if using port directly:
# var server_url = "http://108.175.12.95:8000"
```

### **Step 9: Future Updates**

To update your server code:
```bash
# SSH into server
ssh deployer@108.175.12.95

# Navigate to project
cd /home/deployer/quantum-jam-2025-choose-your-own-adventure

# Pull latest changes
git pull origin main

# Restart the service
sudo systemctl restart quantum-echo
# or if using screen:
# screen -r quantum-echo
# Ctrl+C to stop, then restart the app
```

## 🔧 **Troubleshooting**

### **Check if service is running:**
```bash
# For systemd service
sudo systemctl status quantum-echo
sudo journalctl -u quantum-echo -f

# For screen session
screen -list
screen -r quantum-echo
```

### **Check logs:**
```bash
# If running directly
python3 deploy/app-minimal.py

# Check nginx logs
sudo tail -f /var/log/nginx/error.log
```

### **Firewall issues:**
```bash
# Allow port through firewall
sudo ufw allow 5000
sudo ufw allow 8000
```

This approach keeps everything under your control in `/home/deployer` and doesn't require special Plesk permissions!
