#!/usr/bin/env python3 
import os 
import sys 
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__))) 
from app import app 
 
if __name__ == "__main__": 
    app.run(host='0.0.0.0', port=int(os.environ.get('PORT', 5000))) 
