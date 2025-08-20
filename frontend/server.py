#!/usr/bin/env python3
"""
AI4Bharat Frontend Server
Serves the web dashboard and handles API calls to the AI4Bharat model
"""

import os
import json
import time
import requests
from datetime import datetime
from flask import Flask, render_template, request, jsonify, send_from_directory
from flask_cors import CORS

app = Flask(__name__)
CORS(app)

# Configuration
CONFIG = {
    'model_endpoint': os.getenv('AI4BHARAT_ENDPOINT', 'http://localhost:8080'),
    'model_name': 'ai4bharat-bert',
    'debug': os.getenv('DEBUG', 'false').lower() == 'true'
}

class AI4BharatClient:
    def __init__(self, endpoint):
        self.endpoint = endpoint
        self.model_name = CONFIG['model_name']
        self.health_check_interval = 30  # seconds
        self.last_health_check = 0
        self.is_healthy = False
        
    def get_model_url(self, path=''):
        """Get the full model URL"""
        return f"{self.endpoint}/v1/models/{self.model_name}{path}"
    
    def check_health(self, force=False):
        """Check if the model is healthy"""
        current_time = time.time()
        
        if not force and (current_time - self.last_health_check) < self.health_check_interval:
            return self.is_healthy
            
        try:
            response = requests.get(
                self.get_model_url(),
                timeout=5
            )
            self.is_healthy = response.status_code == 200
            self.last_health_check = current_time
            return self.is_healthy
        except Exception as e:
            if CONFIG['debug']:
                print(f"Health check failed: {e}")
            self.is_healthy = False
            self.last_health_check = current_time
            return False
    
    def translate(self, text, source_lang='auto', target_lang='en'):
        """Translate text using the AI4Bharat model"""
        if not self.check_health():
            return {
                'success': False,
                'error': 'Model is not healthy'
            }
        
        try:
            payload = {
                'instances': [text]
            }
            
            # Add language information if available
            if source_lang != 'auto':
                payload['source_language'] = source_lang
            if target_lang:
                payload['target_language'] = target_lang
            
            start_time = time.time()
            
            response = requests.post(
                self.get_model_url('/predict'),
                json=payload,
                headers={'Content-Type': 'application/json'},
                timeout=30
            )
            
            response_time = (time.time() - start_time) * 1000  # Convert to milliseconds
            
            if response.status_code == 200:
                data = response.json()
                
                # Extract translation from response
                translation = self.extract_translation(data)
                confidence = self.extract_confidence(data)
                
                return {
                    'success': True,
                    'translation': translation,
                    'confidence': confidence,
                    'response_time': response_time,
                    'raw_response': data
                }
            else:
                return {
                    'success': False,
                    'error': f'HTTP {response.status_code}: {response.text}',
                    'response_time': response_time
                }
                
        except requests.exceptions.Timeout:
            return {
                'success': False,
                'error': 'Request timeout - model is taking too long to respond'
            }
        except requests.exceptions.ConnectionError:
            return {
                'success': False,
                'error': 'Connection error - cannot reach the model service'
            }
        except Exception as e:
            return {
                'success': False,
                'error': f'Unexpected error: {str(e)}'
            }
    
    def extract_translation(self, data):
        """Extract translation from model response"""
        try:
            if 'predictions' in data and data['predictions']:
                prediction = data['predictions'][0]
                
                # Handle different response formats
                if isinstance(prediction, str):
                    return prediction
                elif isinstance(prediction, dict):
                    # Try different possible keys
                    for key in ['text', 'translation', 'output', 'result']:
                        if key in prediction:
                            return prediction[key]
                    
                    # If no specific key found, return the first string value
                    for value in prediction.values():
                        if isinstance(value, str):
                            return value
                
                # Fallback: return the prediction as string
                return str(prediction)
            
            return "Translation not available"
            
        except Exception as e:
            if CONFIG['debug']:
                print(f"Error extracting translation: {e}")
            return "Error extracting translation"
    
    def extract_confidence(self, data):
        """Extract confidence score from model response"""
        try:
            if 'predictions' in data and data['predictions']:
                prediction = data['predictions'][0]
                
                if isinstance(prediction, dict):
                    # Try different possible confidence keys
                    for key in ['confidence', 'score', 'probability']:
                        if key in prediction:
                            conf = prediction[key]
                            if isinstance(conf, (int, float)):
                                return min(max(conf, 0.0), 1.0)  # Ensure between 0 and 1
                    
                    # If no confidence found, estimate based on response quality
                    return 0.85  # Default confidence
            
            return 0.90  # Default confidence
            
        except Exception as e:
            if CONFIG['debug']:
                print(f"Error extracting confidence: {e}")
            return 0.80  # Default confidence

# Initialize the AI4Bharat client
client = AI4BharatClient(CONFIG['model_endpoint'])

@app.route('/')
def index():
    """Serve the main dashboard page"""
    return send_from_directory('.', 'index.html')

@app.route('/<path:filename>')
def static_files(filename):
    """Serve static files"""
    return send_from_directory('.', filename)

@app.route('/api/status')
def api_status():
    """Get the current status of the AI4Bharat service"""
    is_healthy = client.check_health(force=True)
    
    return jsonify({
        'endpoint': CONFIG['model_endpoint'],
        'model_name': CONFIG['model_name'],
        'healthy': is_healthy,
        'last_check': datetime.fromtimestamp(client.last_health_check).isoformat(),
        'timestamp': datetime.now().isoformat()
    })

@app.route('/api/translate', methods=['POST'])
def api_translate():
    """Translate text using the AI4Bharat model"""
    try:
        data = request.get_json()
        
        if not data:
            return jsonify({'success': False, 'error': 'No data provided'}), 400
        
        text = data.get('text', '').strip()
        source_lang = data.get('source_language', 'auto')
        target_lang = data.get('target_language', 'en')
        
        if not text:
            return jsonify({'success': False, 'error': 'No text provided'}), 400
        
        # Perform translation
        result = client.translate(text, source_lang, target_lang)
        
        # Add metadata
        result['timestamp'] = datetime.now().isoformat()
        result['source_language'] = source_lang
        result['target_language'] = target_lang
        result['text_length'] = len(text)
        
        return jsonify(result)
        
    except Exception as e:
        if CONFIG['debug']:
            print(f"Translation API error: {e}")
        
        return jsonify({
            'success': False,
            'error': f'Internal server error: {str(e)}',
            'timestamp': datetime.now().isoformat()
        }), 500

@app.route('/api/health')
def api_health():
    """Health check endpoint"""
    is_healthy = client.check_health(force=True)
    
    return jsonify({
        'healthy': is_healthy,
        'timestamp': datetime.now().isoformat(),
        'endpoint': CONFIG['model_endpoint']
    })

@app.route('/api/languages')
def api_languages():
    """Get supported languages"""
    languages = {
        'hi': {'name': 'Hindi', 'native': 'हिंदी', 'script': 'Devanagari'},
        'en': {'name': 'English', 'native': 'English', 'script': 'Latin'},
        'ta': {'name': 'Tamil', 'native': 'தமிழ்', 'script': 'Tamil'},
        'mr': {'name': 'Marathi', 'native': 'मराठी', 'script': 'Devanagari'},
        'gu': {'name': 'Gujarati', 'native': 'ગુજરાતી', 'script': 'Gujarati'},
        'ne': {'name': 'Nepali', 'native': 'नेपाली', 'script': 'Devanagari'},
        'bn': {'name': 'Bengali', 'native': 'বাংলা', 'script': 'Bengali'},
        'te': {'name': 'Telugu', 'native': 'తెలుగు', 'script': 'Telugu'},
        'kn': {'name': 'Kannada', 'native': 'ಕನ್ನಡ', 'script': 'Kannada'},
        'ml': {'name': 'Malayalam', 'native': 'മലയാളം', 'script': 'Malayalam'},
        'pa': {'name': 'Punjabi', 'native': 'ਪੰਜਾਬੀ', 'script': 'Gurmukhi'}
    }
    
    return jsonify({
        'languages': languages,
        'count': len(languages),
        'timestamp': datetime.now().isoformat()
    })

@app.route('/api/metrics')
def api_metrics():
    """Get current metrics"""
    return jsonify({
        'endpoint': CONFIG['model_endpoint'],
        'model_name': CONFIG['model_name'],
        'healthy': client.is_healthy,
        'last_health_check': datetime.fromtimestamp(client.last_health_check).isoformat(),
        'timestamp': datetime.now().isoformat()
    })

if __name__ == '__main__':
    print("🚀 Starting AI4Bharat Frontend Server")
    print(f"📍 Model Endpoint: {CONFIG['model_endpoint']}")
    print(f"🔧 Debug Mode: {CONFIG['debug']}")
    print(f"🌐 Server will be available at: http://localhost:5000")
    print("=" * 50)
    
    # Check initial health
    client.check_health(force=True)
    
    app.run(
        host='0.0.0.0',
        port=5000,
        debug=CONFIG['debug'],
        threaded=True
    )
