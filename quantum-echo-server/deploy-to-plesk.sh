#!/bin/bash
# deploy-to-plesk.sh - Script to prepare files for Plesk deployment

echo "Preparing Quantum Echo Server for Plesk deployment..."

# Create deployment directory
mkdir -p deploy

# Copy essential files
cp app.py deploy/
cp requirements.txt deploy/
cp README.md deploy/

# Create a simple startup script for Plesk
cat > deploy/startup.py << EOF
#!/usr/bin/env python3
import os
import sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from app import app

if __name__ == "__main__":
    app.run(host='0.0.0.0', port=int(os.environ.get('PORT', 5000)))
EOF

# Create Plesk-compatible requirements (no version conflicts)
cat > deploy/requirements-plesk.txt << EOF
flask
flask-cors
qiskit
qiskit-aer
numpy
requests
EOF

echo "Files prepared in 'deploy' directory!"
echo "Upload these files to your Plesk file manager:"
echo "- app.py"
echo "- startup.py" 
echo "- requirements-plesk.txt"
echo "- README.md"
EOF
