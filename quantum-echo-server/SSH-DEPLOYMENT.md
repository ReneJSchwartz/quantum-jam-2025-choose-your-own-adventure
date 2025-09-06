# SSH Manual Deployment Guide for Quantum Echo Server

## Step 1: Prepare Files for Upload

First, let's create a compressed package of your files for easy upload.

### On Your Local Machine (Windows):

```powershell
# Navigate to your quantum-echo-server directory
cd D:\ReactNativeProjects\quantum-jam-2025-choose-your-own-adventure\quantum-echo-server

# Create a ZIP file with the essential files
Compress-Archive -Path deploy\app.py, deploy\app-minimal.py, deploy\startup.py, deploy\requirements-plesk.txt, deploy\requirements-minimal.txt, README.md -DestinationPath quantum-echo-server.zip
```

## Step 2: SSH into Your Server

```bash
ssh your-username@108.175.12.95
# or however you normally SSH into your server
```

## Step 3: Navigate to Your Domain Directory

```bash
# Navigate to your domain's directory
cd /var/www/vhosts/davidjgrimsley.com/happy-noyce.108-175-12-95.plesk.page/

# Create a backup of current content (optional)
mkdir backup-$(date +%Y%m%d)
cp -r httpdocs/* backup-$(date +%Y%m%d)/ 2>/dev/null || true

# Create a directory for the Python app
mkdir quantum-api
cd quantum-api
```

## Step 4: Upload Your Files

### Option A: Upload via SCP (from your local machine)
```powershell
# From your Windows machine
scp quantum-echo-server.zip your-username@108.175.12.95:/var/www/vhosts/davidjgrimsley.com/happy-noyce.108-175-12-95.plesk.page/quantum-api/
```

### Option B: Upload via Plesk File Manager
1. Go to Plesk → Files
2. Navigate to your domain
3. Create `quantum-api` folder
4. Upload the files from your `deploy` folder

## Step 5: Install Python and Dependencies

```bash
# Check if Python 3 is available
python3 --version

# If not available, install it (Ubuntu/Debian)
sudo apt update
sudo apt install python3 python3-pip python3-venv -y

# Create virtual environment
cd /var/www/vhosts/davidjgrimsley.com/happy-noyce.108-175-12-95.plesk.page/quantum-api
python3 -m venv venv

# Activate virtual environment
source venv/bin/activate

# Upgrade pip
pip install --upgrade pip

# Try installing full requirements first
pip install flask flask-cors qiskit qiskit-aer numpy requests

# If Qiskit fails, install minimal version:
# pip install flask flask-cors requests
```

## Step 6: Set Up the Application

```bash
# If you uploaded a zip file, extract it
unzip quantum-echo-server.zip

# Make sure you have the right files
ls -la
# You should see: app.py, startup.py, requirements files

# Test the app locally first
python3 app.py
# Press Ctrl+C to stop after confirming it works
```

## Step 7: Create passenger_wsgi.py for Plesk

```bash
# Create the Passenger WSGI file
cat > passenger_wsgi.py << 'EOF'
#!/usr/bin/env python3
import sys
import os

# Add the current directory to Python path
INTERP = os.path.join(os.getcwd(), 'venv', 'bin', 'python3')
if sys.executable != INTERP:
    os.execl(INTERP, INTERP, *sys.argv)

# Add current directory to sys.path
sys.path.insert(0, os.getcwd())

# Import your Flask app
from app import app as application

# For debugging
if __name__ == "__main__":
    application.run()
EOF

# Make it executable
chmod +x passenger_wsgi.py
```

## Step 8: Install Passenger (if not already installed)

```bash
# Check if Passenger is installed
passenger-config --version

# If not installed (Ubuntu/Debian):
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 561F9B9CAC40B2F7
sudo sh -c 'echo deb https://oss-binaries.phusionpassenger.com/apt/passenger $(lsb_release -cs) main > /etc/apt/sources.list.d/passenger.list'
sudo apt update
sudo apt install libapache2-mod-passenger -y

# Enable Passenger module
sudo a2enmod passenger
sudo systemctl restart apache2
```

## Step 9: Configure Apache/Nginx for Your App

### Option A: Via Plesk GUI
1. Go to Plesk → Websites & Domains → your-domain.com → Hosting Settings
2. Set Document Root to: `httpdocs/quantum-api`
3. Add these Apache directives in "Additional Apache directives":

```apache
PassengerEnabled on
PassengerAppRoot /var/www/vhosts/davidjgrimsley.com/happy-noyce.108-175-12-95.plesk.page/quantum-api
PassengerPython /var/www/vhosts/davidjgrimsley.com/happy-noyce.108-175-12-95.plesk.page/quantum-api/venv/bin/python3
```

### Option B: Create .htaccess file
```bash
cat > .htaccess << 'EOF'
PassengerEnabled on
PassengerAppRoot /var/www/vhosts/davidjgrimsley.com/happy-noyce.108-175-12-95.plesk.page/quantum-api
PassengerPython /var/www/vhosts/davidjgrimsley.com/happy-noyce.108-175-12-95.plesk.page/quantum-api/venv/bin/python3
RewriteEngine On
RewriteCond %{REQUEST_FILENAME} !-f
RewriteRule ^(.*)$ passenger_wsgi.py [QSA,L]
EOF
```

## Step 10: Set Correct Permissions

```bash
# Set ownership to the web server user (usually www-data or your domain user)
sudo chown -R $(whoami):$(whoami) /var/www/vhosts/davidjgrimsley.com/happy-noyce.108-175-12-95.plesk.page/quantum-api

# Set permissions
find /var/www/vhosts/davidjgrimsley.com/happy-noyce.108-175-12-95.plesk.page/quantum-api -type f -exec chmod 644 {} \;
find /var/www/vhosts/davidjgrimsley.com/happy-noyce.108-175-12-95.plesk.page/quantum-api -type d -exec chmod 755 {} \;
chmod +x passenger_wsgi.py
chmod +x venv/bin/*
```

## Step 11: Restart and Test

```bash
# Create tmp directory for Passenger restarts
mkdir -p tmp
touch tmp/restart.txt

# Test the application
curl -X GET http://happy-noyce.108-175-12-95.plesk.page/quantum-api/health
```

## Step 12: Update Your Godot Game

Change the server URL in your Godot script:
```gdscript
var server_url = "https://happy-noyce.108-175-12-95.plesk.page/quantum-api"
```

## Troubleshooting

### Check Logs
```bash
# Check Apache error logs
sudo tail -f /var/log/apache2/error.log

# Check Plesk domain logs
tail -f /var/www/vhosts/davidjgrimsley.com/happy-noyce.108-175-12-95.plesk.page/logs/error_log
```

### If Qiskit Installation Fails
```bash
# Use the minimal version instead
cp app-minimal.py app.py
pip install flask flask-cors requests
touch tmp/restart.txt
```

### If Passenger Doesn't Work
```bash
# Try running as a regular Python app (for testing)
source venv/bin/activate
python3 app.py &
```

### Common Issues
1. **Permission Errors**: Make sure file permissions are correct
2. **Module Not Found**: Ensure virtual environment is activated and packages installed
3. **Port Already in Use**: Kill existing processes or use different port
4. **Passenger Not Loading**: Check Apache/Nginx configuration

## Test Commands

```bash
# Test health endpoint
curl https://happy-noyce.108-175-12-95.plesk.page/quantum-api/health

# Test quantum echo
curl -X POST https://happy-noyce.108-175-12-95.plesk.page/quantum-api/quantum_echo \
     -H "Content-Type: application/json" \
     -d '{"text": "Hello quantum world!", "echo_type": "scramble"}'
```

Let me know what happens at each step and I'll help you debug any issues!
