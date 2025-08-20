#!/usr/bin/env python3
"""
Mock Translation Service for AI4Bharat Dashboard
Provides sample translations for testing when the actual model isn't available
"""

import random
import time

# Sample translations for common phrases
SAMPLE_TRANSLATIONS = {
    "hi-en": {
        "नमस्ते, कैसे हो आप?": "Hello, how are you?",
        "धन्यवाद, आपका दिन शुभ हो": "Thank you, have a good day",
        "शुभ रात्रि, मीठे सपने": "Good night, sweet dreams",
        "मैं आपसे प्यार करता हूं": "I love you",
        "क्या आप मुझे समझ सकते हैं?": "Can you understand me?"
    },
    "ta-en": {
        "வணக்கம், எப்படி இருக்கிறீர்கள்?": "Hello, how are you?",
        "கடவுள் உங்களை காப்பாற்றட்டும்": "May God protect you",
        "நன்றி, உங்கள் நாள் நல்லதாக இருக்கட்டும்": "Thank you, have a good day",
        "நான் உங்களை நேசிக்கிறேன்": "I love you",
        "நீங்கள் என்னை புரிந்து கொள்ள முடியுமா?": "Can you understand me?"
    },
    "mr-en": {
        "नमस्कार, तुम्ही कसे आहात?": "Hello, how are you?",
        "धन्यवाद, तुमचा दिवस शुभ असो": "Thank you, have a good day",
        "शुभ रात्री, गोड स्वप्ने": "Good night, sweet dreams",
        "मी तुमच्यावर प्रेम करतो": "I love you",
        "तुम्ही मला समजू शकता का?": "Can you understand me?"
    },
    "gu-en": {
        "નમસ્તે, તમે કેમ છો?": "Hello, how are you?",
        "ધન્યવાદ, તમારો દિવસ શુભ રહો": "Thank you, have a good day",
        "શુભ રાત્રિ, મીઠા સ્વપ્નો": "Good night, sweet dreams",
        "હું તમને પ્રેમ કરું છું": "I love you",
        "શું તમે મને સમજી શકો છો?": "Can you understand me?"
    },
    "en-hi": {
        "Hello, how are you?": "नमस्ते, कैसे हो आप?",
        "Thank you, have a good day": "धन्यवाद, आपका दिन शुभ हो",
        "Good night, sweet dreams": "शुभ रात्रि, मीठे सपने",
        "I love you": "मैं आपसे प्यार करता हूं",
        "Can you understand me?": "क्या आप मुझे समझ सकते हैं?"
    }
}

def get_mock_translation(text, source_lang="auto", target_lang="en"):
    """
    Get a mock translation for testing purposes
    """
    # Simulate processing time
    time.sleep(random.uniform(0.5, 1.5))
    
    # Create language pair key
    lang_pair = f"{source_lang}-{target_lang}"
    
    # Check if we have a direct translation
    if lang_pair in SAMPLE_TRANSLATIONS:
        if text in SAMPLE_TRANSLATIONS[lang_pair]:
            return {
                "success": True,
                "translation": SAMPLE_TRANSLATIONS[lang_pair][text],
                "confidence": 0.95,
                "response_time": random.randint(800, 1500),
                "source_language": source_lang,
                "target_language": target_lang
            }
    
    # Generate a mock translation based on language
    mock_translations = {
        "hi": "नमस्ते! यह एक परीक्षण अनुवाद है।",
        "ta": "வணக்கம்! இது ஒரு சோதனை மொழிபெயர்ப்பு.",
        "mr": "नमस्कार! हे एक चाचणी भाषांतर आहे.",
        "gu": "નમસ્તે! આ એક પરીક્ષણ અનુવાદ છે.",
        "en": "Hello! This is a test translation."
    }
    
    # Return mock translation
    return {
        "success": True,
        "translation": f"[MOCK] {mock_translations.get(target_lang, 'Hello! This is a test translation.')}",
        "confidence": random.uniform(0.7, 0.9),
        "response_time": random.randint(600, 1200),
        "source_language": source_lang,
        "target_language": target_lang,
        "note": "This is a mock translation for testing. Deploy KServe to get real translations."
    }

def get_supported_languages():
    """
    Get list of supported languages
    """
    return {
        "hi": {"name": "Hindi", "native": "हिंदी", "script": "Devanagari"},
        "en": {"name": "English", "native": "English", "script": "Latin"},
        "ta": {"name": "Tamil", "native": "தமிழ்", "script": "Tamil"},
        "mr": {"name": "Marathi", "native": "मराठी", "script": "Devanagari"},
        "gu": {"name": "Gujarati", "native": "ગુજરાતી", "script": "Gujarati"},
        "ne": {"name": "Nepali", "native": "नेपाली", "script": "Devanagari"},
        "bn": {"name": "Bengali", "native": "বাংলা", "script": "Bengali"},
        "te": {"name": "Telugu", "native": "తెలుగు", "script": "Telugu"},
        "kn": {"name": "Kannada", "native": "ಕನ್ನಡ", "script": "Kannada"},
        "ml": {"name": "Malayalam", "native": "മലയാളം", "script": "Malayalam"},
        "pa": {"name": "Punjabi", "native": "ਪੰਜਾਬੀ", "script": "Gurmukhi"}
    }

def get_sample_texts():
    """
    Get sample texts for testing
    """
    return {
        "greetings": [
            "नमस्ते, कैसे हो आप?",
            "வணக்கம், எப்படி இருக்கிறீர்கள்?",
            "नमस्कार, तुम्ही कसे आहात?",
            "Hello, how are you?"
        ],
        "common_phrases": [
            "धन्यवाद, आपका दिन शुभ हो",
            "கடவுள் உங்களை காப்பாற்றட்டும்",
            "Thank you very much",
            "Good morning everyone"
        ]
    }
