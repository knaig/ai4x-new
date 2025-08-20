#!/usr/bin/env python3
"""
Test script for AI4Bharat model deployed on KServe
"""

import requests
import json
import time
import sys

def test_model_prediction(service_url, text="नमस्ते, कैसे हो आप?"):
    """
    Test the AI4Bharat model with Hindi text
    """
    try:
        # Prepare the request payload
        payload = {
            "instances": [text]
        }
        
        # Make prediction request
        response = requests.post(
            f"{service_url}/v1/models/ai4bharat-bert:predict",
            json=payload,
            headers={"Content-Type": "application/json"},
            timeout=30
        )
        
        if response.status_code == 200:
            result = response.json()
            print(f"✅ Prediction successful!")
            print(f"📝 Input text: {text}")
            print(f"🎯 Prediction: {json.dumps(result, indent=2, ensure_ascii=False)}")
            return True
        else:
            print(f"❌ Prediction failed with status code: {response.status_code}")
            print(f"Response: {response.text}")
            return False
            
    except requests.exceptions.RequestException as e:
        print(f"❌ Request failed: {e}")
        return False
    except json.JSONDecodeError as e:
        print(f"❌ JSON decode error: {e}")
        return False

def test_model_health(service_url):
    """
    Test the model health endpoint
    """
    try:
        response = requests.get(f"{service_url}/v1/models/ai4bharat-bert", timeout=10)
        if response.status_code == 200:
            print("✅ Model health check passed")
            return True
        else:
            print(f"❌ Model health check failed: {response.status_code}")
            return False
    except Exception as e:
        print(f"❌ Health check error: {e}")
        return False

def main():
    print("🧪 Testing AI4Bharat Model on KServe")
    print("=" * 40)
    
    # Get service URL from command line or use default
    if len(sys.argv) > 1:
        service_url = sys.argv[1]
    else:
        print("💡 Usage: python test-model.py <service-url>")
        print("💡 Example: python test-model.py http://localhost:8080")
        print("💡 Or get the URL from: kubectl get inferenceservice ai4bharat-bert -n ai4bharat-serving")
        return
    
    # Test model health
    print("\n🔍 Testing model health...")
    if not test_model_health(service_url):
        print("❌ Model is not healthy. Please check the deployment.")
        return
    
    # Test with different Indian languages
    test_texts = [
        "नमस्ते, कैसे हो आप?",  # Hindi
        "Hello, how are you?",   # English
        "வணக்கம், எப்படி இருக்கிறீர்கள்?",  # Tamil
        "नमस्कार, तुम्ही कसे आहात?",  # Marathi
    ]
    
    print("\n🚀 Testing predictions with different languages...")
    for i, text in enumerate(test_texts, 1):
        print(f"\n--- Test {i} ---")
        if test_model_prediction(service_url, text):
            time.sleep(1)  # Small delay between requests
        else:
            print(f"❌ Test {i} failed")
    
    print("\n🎉 Testing completed!")

if __name__ == "__main__":
    main()
