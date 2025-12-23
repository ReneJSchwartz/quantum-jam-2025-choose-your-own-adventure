#!/bin/bash
# Quantum Echo Server - VPS Deployment Script
# This script sets up everything needed to run the server on any Linux VPS

set -e  # Exit on any error

echo "🚀 Starting Quantum Echo Server deployment..."

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Check if Python3 is available
if ! command -v python3 &> /dev/null; then
    echo "❌ Error: python3 is not installed. Please install Python 3.8+ first."
    exit 1
fi

# Check if pip is available
if ! command -v pip3 &> /dev/null && ! python3 -m pip --version &> /dev/null; then
    echo "❌ Error: pip is not available. Please install python3-pip first."
    echo "   Try: sudo apt update && sudo apt install python3-pip"
    exit 1
fi

# Create virtual environment if it doesn't exist
if [ ! -d "venv" ]; then
    echo "📦 Creating Python virtual environment..."
    python3 -m venv venv
fi

# Activate virtual environment
echo "🔧 Activating virtual environment..."
source venv/bin/activate

# Upgrade pip
echo "⬆️  Upgrading pip..."
python -m pip install --upgrade pip

# Install requirements
echo "📚 Installing Python dependencies..."
if [ -f "requirements.txt" ]; then
    pip install -r requirements.txt
else
    echo "❌ Error: requirements.txt not found!"
    exit 1
fi

# Check if main app file exists
if [ ! -f "app.py" ]; then
    echo "❌ Error: app.py not found!"
    exit 1
fi

# Set permissions
chmod +x "$0"

echo "✅ Deployment setup complete!"
echo ""
echo "🎯 Starting Quantum Echo Server..."
echo "   Server will be available at: http://localhost:5000"
echo "   Press Ctrl+C to stop the server"
echo ""

# Start the server
python app.py