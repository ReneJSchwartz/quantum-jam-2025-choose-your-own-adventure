@echo off
REM deploy-to-plesk.bat - Windows script to prepare files for Plesk deployment

echo Preparing Quantum Echo Server for Plesk deployment...

REM Create deployment directory
if not exist "deploy" mkdir deploy

REM Copy essential files
copy app.py deploy\
copy requirements.txt deploy\
copy README.md deploy\

REM Create a simple startup script for Plesk
echo #!/usr/bin/env python3 > deploy\startup.py
echo import os >> deploy\startup.py
echo import sys >> deploy\startup.py
echo sys.path.insert(0, os.path.dirname(os.path.abspath(__file__))) >> deploy\startup.py
echo from app import app >> deploy\startup.py
echo. >> deploy\startup.py
echo if __name__ == "__main__": >> deploy\startup.py
echo     app.run(host='0.0.0.0', port=int(os.environ.get('PORT', 5000))) >> deploy\startup.py

REM Create Plesk-compatible requirements
echo flask > deploy\requirements-plesk.txt
echo flask-cors >> deploy\requirements-plesk.txt
echo qiskit >> deploy\requirements-plesk.txt
echo qiskit-aer >> deploy\requirements-plesk.txt
echo numpy >> deploy\requirements-plesk.txt
echo requests >> deploy\requirements-plesk.txt

echo.
echo Files prepared in 'deploy' directory!
echo Upload these files to your Plesk file manager:
echo - app.py
echo - startup.py
echo - requirements-plesk.txt
echo - README.md

pause
