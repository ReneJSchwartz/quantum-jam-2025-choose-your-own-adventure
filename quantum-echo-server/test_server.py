#!/usr/bin/env python3
"""
Test script for the Quantum Echo Server
Run this to verify the server is working correctly
"""

import requests
import json

def test_server(base_url="http://localhost:5000"):
    """Test all endpoints of the quantum echo server."""
    
    print(f"Testing Quantum Echo Server at {base_url}")
    print("=" * 50)
    
    # Test 1: Health check
    print("1. Testing health endpoint...")
    try:
        response = requests.get(f"{base_url}/health")
        if response.status_code == 200:
            print("✓ Health check passed")
            print(f"  Response: {response.json()}")
        else:
            print(f"✗ Health check failed: {response.status_code}")
    except Exception as e:
        print(f"✗ Health check error: {e}")
    
    print()
    
    # Test 2: Echo types
    print("2. Testing echo types endpoint...")
    try:
        response = requests.get(f"{base_url}/quantum_echo_types")
        if response.status_code == 200:
            print("✓ Echo types retrieved")
            data = response.json()
            for echo_type in data['echo_types']:
                print(f"  - {echo_type['name']}: {echo_type['description']}")
        else:
            print(f"✗ Echo types failed: {response.status_code}")
    except Exception as e:
        print(f"✗ Echo types error: {e}")
    
    print()
    
    # Test 3: Quantum echo transformations
    test_text = "Hello, quantum world! This is a test."
    echo_types = ['scramble', 'reverse', 'ghost', 'quantum_caps']
    
    print("3. Testing quantum echo transformations...")
    for echo_type in echo_types:
        print(f"  Testing '{echo_type}' echo type...")
        try:
            payload = {
                "text": test_text,
                "echo_type": echo_type
            }
            
            response = requests.post(
                f"{base_url}/quantum_echo",
                headers={"Content-Type": "application/json"},
                data=json.dumps(payload)
            )
            
            if response.status_code == 200:
                data = response.json()
                print(f"    ✓ Original: {data['original']}")
                print(f"    ✓ Echo:     {data['echo']}")
                print(f"    ✓ Type:     {data['echo_type']}")
            else:
                print(f"    ✗ Failed: {response.status_code}")
                print(f"    ✗ Error: {response.text}")
        except Exception as e:
            print(f"    ✗ Error: {e}")
        print()
    
    print("Testing complete!")

if __name__ == "__main__":
    import sys
    
    # Allow custom URL as command line argument
    url = sys.argv[1] if len(sys.argv) > 1 else "http://localhost:5000"
    test_server(url)
