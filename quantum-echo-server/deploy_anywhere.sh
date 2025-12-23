#!/bin/bash
# deploy_anywhere.sh - One-command deployment script for Quantum Echo Server
# Usage: ./deploy_anywhere.sh [port] [host]
# Example: ./deploy_anywhere.sh 8000 0.0.0.0

set -e  # Exit on any error

# Configuration
DEFAULT_PORT=8000
DEFAULT_HOST="0.0.0.0"
SERVER_PORT=${1:-$DEFAULT_PORT}
SERVER_HOST=${2:-$DEFAULT_HOST}
VENV_DIR="venv"
LOG_FILE="quantum_server.log"

echo "🚀 Quantum Echo Server Deployment Script"
echo "========================================"
echo "Deploying on: $SERVER_HOST:$SERVER_PORT"
echo "Log file: $LOG_FILE"
echo

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check Python 3
if ! command_exists python3; then
    echo "❌ Error: python3 not found. Please install Python 3.8+ first."
    exit 1
fi

# Check Python version
PYTHON_VERSION=$(python3 -c 'import sys; print(".".join(map(str, sys.version_info[:2])))')
echo "✅ Python version: $PYTHON_VERSION"

# Create virtual environment if it doesn't exist
if [ ! -d "$VENV_DIR" ]; then
    echo "📦 Creating virtual environment..."
    python3 -m venv "$VENV_DIR"
else
    echo "✅ Virtual environment exists"
fi

# Activate virtual environment
echo "🔧 Activating virtual environment..."
source "$VENV_DIR/bin/activate"

# Upgrade pip
echo "📈 Upgrading pip..."
pip install --upgrade pip

# Install requirements
echo "📋 Installing requirements..."
if [ -f "requirements.txt" ]; then
    pip install -r requirements.txt
else
    echo "❌ Error: requirements.txt not found!"
    exit 1
fi

# Check if app.py exists
if [ ! -f "app.py" ]; then
    echo "❌ Error: app.py not found!"
    exit 1
fi

# Check if quantum_word_dictionary.py exists
if [ ! -f "quantum_word_dictionary.py" ]; then
    echo "⚠️  Warning: quantum_word_dictionary.py not found. Server will use fallback mode."
fi

# Create systemd service file (optional)
create_service_file() {
    local service_file="/etc/systemd/system/quantum-echo-server.service"
    local current_dir=$(pwd)
    local current_user=$(whoami)
    
    echo "🔧 Creating systemd service file..."
    
    sudo tee "$service_file" > /dev/null <<EOF
[Unit]
Description=Quantum Echo Server
After=network.target

[Service]
Type=simple
User=$current_user
WorkingDirectory=$current_dir
Environment=PATH=$current_dir/$VENV_DIR/bin
ExecStart=$current_dir/$VENV_DIR/bin/python $current_dir/app.py
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF
    
    echo "✅ Service file created at $service_file"
    echo "   To enable auto-start: sudo systemctl enable quantum-echo-server"
    echo "   To start service: sudo systemctl start quantum-echo-server"
}

# Function to start server
start_server() {
    echo "🌟 Starting Quantum Echo Server..."
    echo "   URL: http://$SERVER_HOST:$SERVER_PORT"
    echo "   Health check: http://$SERVER_HOST:$SERVER_PORT/health"
    echo "   Logs: $LOG_FILE"
    echo "   Press Ctrl+C to stop"
    echo

    # Update app.py to use custom host/port if needed
    if [ "$SERVER_HOST" != "0.0.0.0" ] || [ "$SERVER_PORT" != "8000" ]; then
        echo "🔧 Updating server configuration for $SERVER_HOST:$SERVER_PORT"
        # Create a temporary starter script
        cat > start_custom.py <<EOF
import sys
import os

# Add current directory to Python path
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from app import app

if __name__ == '__main__':
    app.run(host='$SERVER_HOST', port=$SERVER_PORT, debug=False)
EOF
        python start_custom.py 2>&1 | tee "$LOG_FILE"
    else
        python app.py 2>&1 | tee "$LOG_FILE"
    fi
}

# Main execution
echo "🔍 Running pre-flight checks..."

# Test import
python3 -c "
import sys
try:
    from flask import Flask
    from qiskit import QuantumCircuit
    print('✅ All major dependencies available')
except ImportError as e:
    print(f'❌ Import error: {e}')
    sys.exit(1)
"

echo
echo "🎯 Deployment complete! Choose an option:"
echo "1) Start server now (foreground)"
echo "2) Create systemd service (requires sudo)"
echo "3) Show startup commands"
echo

read -p "Enter choice [1-3]: " choice

case $choice in
    1)
        start_server
        ;;
    2)
        if command_exists sudo && command_exists systemctl; then
            create_service_file
            echo
            echo "Service created. To start:"
            echo "  sudo systemctl start quantum-echo-server"
            echo "  sudo systemctl enable quantum-echo-server  # Auto-start on boot"
        else
            echo "❌ systemd or sudo not available"
        fi
        ;;
    3)
        echo
        echo "Manual startup commands:"
        echo "  source $VENV_DIR/bin/activate"
        echo "  python app.py"
        echo
        echo "Background startup:"
        echo "  nohup ./deploy_anywhere.sh > quantum_server.log 2>&1 &"
        ;;
    *)
        echo "No action taken. Server is ready to run with:"
        echo "  ./deploy_anywhere.sh"
        ;;
esac

echo
echo "🎉 Deployment script completed!"