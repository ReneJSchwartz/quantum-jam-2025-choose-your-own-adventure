# Quantum Echo Server - VPS Deployment Guide

## Quick Deployment (4 files only!)

### Files to Upload:
1. `app.py` - Main server application
2. `quantum_word_dictionary.py` - Word processing logic  
3. `requirements.txt` - Python dependencies
4. `deploy.py` - Auto-setup script (Python version)

### Deployment Steps:

1. **Upload the 4 files to your VPS:**
   ```bash
   # Example using scp (replace with your details)
   scp app.py quantum_word_dictionary.py requirements.txt deploy.py user@your-vps:/path/to/server/
   ```

2. **SSH into your VPS and navigate to the folder:**
   ```bash
   ssh user@your-vps
   cd /path/to/server/
   ```

3. **Run the deployment script (one command does everything!):**
   ```bash
   python3 deploy.py
   ```

   **Alternative if chmod is broken (like on your VPS):**
   ```bash
   bash deploy_vps.sh
   ```

That's it! The script will:
- Create a Python virtual environment
- Install all dependencies
- Start the server on port 5000

### Manual Steps (if auto-script fails):

```bash
# Create virtual environment
python3 -m venv venv
source venv/bin/activate

# Install dependencies  
pip install -r requirements.txt

# Run server
python app.py
```

### Server Access:
- Local: `http://localhost:5000`
- External: `http://your-vps-ip:5000` (if firewall allows)

### To Stop Server:
Press `Ctrl+C` in the terminal

### To Run in Background:
```bash
nohup ./deploy_vps.sh > server.log 2>&1 &
```

## Requirements:
- Python 3.8+
- pip3
- Internet connection (for installing dependencies)

## File Sizes (approximate):
- Total upload size: ~50KB (very lightweight!)
- After setup with dependencies: ~500MB (includes quantum libraries)