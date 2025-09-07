#!/bin/bash
# start_server.sh - Simple script to start the Quantum Echo Server

echo "Starting Quantum Echo Server..."

# Check if virtual environment exists
if [ ! -d "venv" ]; then
    echo "Creating virtual environment..."
    python3 -m venv venv
fi

# Activate virtual environment
echo "Activating virtual environment..."
source venv/bin/activate

# Install/update requirements
echo "Installing requirements..."
pip install -r requirements.txt

# Start the server
echo "Starting server on http://0.0.0.0:8000"
python app.py
