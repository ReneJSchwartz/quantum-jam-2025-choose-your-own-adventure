#!/usr/bin/env python3
"""
HTTPS Deployment Script for Quantum Echo Server
This script helps deploy the Flask server with HTTPS support.
"""

from flask import Flask, request, jsonify
from flask_cors import CORS
import ssl
import os
import sys

# Import your app
try:
    from app import app
except ImportError:
    print("Error: Could not import app from app.py")
    sys.exit(1)

def create_self_signed_cert():
    """Create a self-signed certificate for testing HTTPS locally"""
    try:
        import ssl
        context = ssl.create_default_context(ssl.Purpose.CLIENT_AUTH)
        context.load_cert_chain('cert.pem', 'key.pem')
        return context
    except FileNotFoundError:
        print("SSL certificates not found. Creating self-signed certificate...")
        return 'adhoc'  # This will create a temporary self-signed cert

def run_https_server():
    """Run the Flask server with HTTPS"""
    print("Starting Quantum Echo Server with HTTPS support...")
    print("Server will be available at: https://108.175.12.95:8000")
    print("Note: For production, use proper SSL certificates!")
    
    try:
        # For production, replace 'adhoc' with proper SSL context
        app.run(
            host='0.0.0.0', 
            port=8000, 
            ssl_context='adhoc',  # Creates temporary self-signed cert
            debug=False  # Set to False for production
        )
    except Exception as e:
        print(f"Error starting HTTPS server: {e}")
        print("Falling back to HTTP...")
        app.run(host='0.0.0.0', port=8000, debug=True)

if __name__ == '__main__':
    run_https_server()
