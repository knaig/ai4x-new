#!/usr/bin/env python3
"""
Test script to debug import issues
"""

print("Starting import test...")

try:
    print("Importing os...")
    import os
    print("✓ os imported successfully")
except Exception as e:
    print(f"✗ os import failed: {e}")

try:
    print("Importing json...")
    import json
    print("✓ json imported successfully")
except Exception as e:
    print(f"✗ json import failed: {e}")

try:
    print("Importing time...")
    import time
    print("✓ time imported successfully")
except Exception as e:
    print(f"✗ time import failed: {e}")

try:
    print("Importing requests...")
    import requests
    print("✓ requests imported successfully")
except Exception as e:
    print(f"✗ requests import failed: {e}")

try:
    print("Importing datetime...")
    from datetime import datetime
    print("✓ datetime imported successfully")
except Exception as e:
    print(f"✗ datetime import failed: {e}")

try:
    print("Importing Flask...")
    from flask import Flask
    print("✓ Flask imported successfully")
except Exception as e:
    print(f"✗ Flask import failed: {e}")

try:
    print("Importing CORS...")
    from flask_cors import CORS
    print("✓ CORS imported successfully")
except Exception as e:
    print(f"✗ CORS import failed: {e}")

print("Import test completed!")
