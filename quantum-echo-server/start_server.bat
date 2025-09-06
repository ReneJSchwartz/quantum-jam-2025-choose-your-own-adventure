@echo off
REM start_server.bat - Windows script to start the Quantum Echo Server

echo Starting Quantum Echo Server...

REM Check if virtual environment exists
if not exist "venv" (
    echo Creating virtual environment...
    python -m venv venv
)

REM Activate virtual environment
echo Activating virtual environment...
call venv\Scripts\activate.bat

REM Install/update requirements
echo Installing requirements...
pip install -r requirements.txt

REM Start the server
echo Starting server on http://localhost:5000
python app.py

pause
