# Plesk Deployment Guide for Quantum Echo Server

## Step 1: Upload Files to Plesk

1. **Access Plesk File Manager**:
   - Log into your Plesk panel
   - Go to **Files** section
   - Navigate to your domain's directory (probably `httpdocs` or `public_html`)

2. **Upload these files from the `deploy` folder**:
   - `app.py` (main Flask application)
   - `startup.py` (Plesk-compatible startup script)
   - `requirements-plesk.txt` (Python dependencies)
   - `README.md` (documentation)

## Step 2: Configure Python Application in Plesk

1. **Navigate to Python Settings**:
   - In your Plesk dashboard, look for **Python** under Dev Tools
   - If you don't see it, check if Python is enabled for your hosting plan

2. **Create Python Application**:
   - Click "Create Python Application" or similar
   - Set these parameters:
     - **Python Version**: Choose 3.9+ (preferably 3.11 or 3.12 if available)
     - **Application Root**: `/` (or your domain root)
     - **Application URL**: `/api` (or leave empty for root)
     - **Application startup file**: `startup.py`
     - **Application Entry Point**: `app` (this refers to the Flask app object)

3. **Install Dependencies**:
   - In the Python application settings, look for "Packages" or "Requirements"
   - Upload or specify `requirements-plesk.txt`
   - Plesk should automatically install the packages

## Step 3: Configure Environment Variables (Optional)

If Plesk allows environment variables:
- `FLASK_ENV=production`
- `PORT=5000` (or whatever port Plesk assigns)

## Step 4: Test the Application

1. **Check Application Status**:
   - In Plesk Python section, verify the application is running
   - Check logs for any errors

2. **Test Endpoints**:
   ```
   https://your-domain.com/health
   https://your-domain.com/quantum_echo_types
   ```

3. **Test Quantum Echo**:
   Use a tool like Postman or curl:
   ```bash
   curl -X POST https://your-domain.com/quantum_echo \
        -H "Content-Type: application/json" \
        -d '{"text": "Hello quantum world!", "echo_type": "scramble"}'
   ```

## Step 5: Update Your Godot Game

Change the server URL in your Godot script:
```gdscript
var server_url = "https://happy-noyce.108-175-12-95.plesk.page"
```

## Alternative: Subdirectory Setup

If you want to keep it separate from your main site:

1. **Create a subdirectory** like `/quantum-api/`
2. **Upload files there**
3. **Configure Python app** to run from that subdirectory
4. **Access via**: `https://your-domain.com/quantum-api/quantum_echo`

## Troubleshooting

### If Python isn't available:
- Check if your Plesk hosting plan includes Python support
- Contact your hosting provider to enable Python

### If packages fail to install:
- Some Plesk servers have limitations on certain packages
- Try installing packages one by one to identify problematic ones
- Consider using a lighter version without Qiskit if quantum simulation isn't critical

### If you get permission errors:
- Ensure files have correct permissions (755 for directories, 644 for files)
- Check that the Python application has write access to necessary directories

## Performance Notes

- Qiskit can be CPU intensive - monitor server resources
- Consider caching responses for repeated requests
- Plesk may have memory/CPU limits for Python applications

Let me know if you encounter any issues during deployment!
