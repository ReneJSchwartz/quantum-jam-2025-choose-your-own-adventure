#!/usr/bin/env python3
"""
Quantum Echo Server - VPS Deployment Script (Python version)
This script sets up everything needed to run the server on any Linux VPS
No chmod needed - just run: python3 deploy.py
"""

import os
import sys
import subprocess
import venv

def run_command(cmd, description=""):
    """Run a command and handle errors."""
    if description:
        print(f"🔧 {description}")
    
    try:
        result = subprocess.run(cmd, shell=True, check=True, capture_output=True, text=True)
        if result.stdout:
            print(result.stdout)
        return True
    except subprocess.CalledProcessError as e:
        print(f"❌ Error running command: {cmd}")
        print(f"   Error: {e.stderr}")
        return False

def main():
    print("🚀 Starting Quantum Echo Server deployment...")
    
    # Get current directory
    script_dir = os.path.dirname(os.path.abspath(__file__))
    os.chdir(script_dir)
    
    # Check if required files exist
    required_files = ['app.py', 'requirements.txt', 'quantum_word_dictionary.py']
    for file in required_files:
        if not os.path.exists(file):
            print(f"❌ Error: {file} not found!")
            return False
    
    # Create virtual environment if it doesn't exist
    venv_path = os.path.join(script_dir, 'venv')
    if not os.path.exists(venv_path):
        print("📦 Creating Python virtual environment...")
        try:
            venv.create(venv_path, with_pip=True)
        except Exception as e:
            print(f"❌ Error creating virtual environment: {e}")
            return False
    
    # Determine the correct python executable in venv
    if os.name == 'nt':  # Windows
        python_exe = os.path.join(venv_path, 'Scripts', 'python.exe')
        pip_exe = os.path.join(venv_path, 'Scripts', 'pip.exe')
    else:  # Linux/Mac
        python_exe = os.path.join(venv_path, 'bin', 'python')
        pip_exe = os.path.join(venv_path, 'bin', 'pip')
    
    # Upgrade pip
    if not run_command(f'"{pip_exe}" install --upgrade pip', "Upgrading pip..."):
        return False
    
    # Install requirements
    if not run_command(f'"{pip_exe}" install -r requirements.txt', "Installing Python dependencies..."):
        return False
    
    print("✅ Deployment setup complete!")
    print("")
    print("🎯 Starting Quantum Echo Server...")
    print("   Server will be available at: http://localhost:5000")
    print("   Press Ctrl+C to stop the server")
    print("")
    
    # Start the server
    try:
        subprocess.run([python_exe, 'app.py'])
    except KeyboardInterrupt:
        print("\n👋 Server stopped.")
    except Exception as e:
        print(f"❌ Error starting server: {e}")
        return False
    
    return True

if __name__ == "__main__":
    success = main()
    sys.exit(0 if success else 1)