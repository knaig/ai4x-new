# 🚀 AI4Bharat Model API Calls Guide

This guide shows you how to make API calls to your deployed AI4Bharat model on KServe.

## 📋 Prerequisites

- ✅ KServe deployed and running
- ✅ AI4Bharat model deployed and ready
- ✅ Service URL available

## 🔍 Get Your Service URL

First, get the service URL where your model is accessible:

```bash
kubectl get inferenceservice ai4bharat-bert -n ai4bharat-serving -o jsonpath='{.status.url}'
```

Example output: `http://ai4bharat-bert-predictor.ai4bharat-serving.svc.cluster.local`

## 🌐 API Endpoints

### 1. Health Check
**GET** `/v1/models/ai4bharat-bert`

Check if your model is healthy and ready to serve requests.

### 2. Prediction
**POST** `/v1/models/ai4bharat-bert:predict`

Send text for classification/prediction.

## 📱 Making API Calls

### Option 1: PowerShell Scripts (Recommended)

#### A. Comprehensive Testing
```powershell
.\test-model-calls.ps1
```

#### B. Curl-based Testing
```powershell
.\test-with-curl.ps1
```

### Option 2: Python Script
```bash
python test-model.py <service-url>
```

### Option 3: Manual curl Commands

#### Health Check
```bash
curl "http://your-service-url/v1/models/ai4bharat-bert"
```

#### Hindi Text Prediction
```bash
curl -X POST "http://your-service-url/v1/models/ai4bharat-bert:predict" \
  -H "Content-Type: application/json" \
  -d '{"instances": ["नमस्ते, कैसे हो आप?"]}'
```

#### English Text Prediction
```bash
curl -X POST "http://your-service-url/v1/models/ai4bharat-bert:predict" \
  -H "Content-Type: application/json" \
  -d '{"instances": ["Hello, how are you?"]}'
```

#### Tamil Text Prediction
```bash
curl -X POST "http://your-service-url/v1/models/ai4bharat-bert:predict" \
  -H "Content-Type: application/json" \
  -d '{"instances": ["வணக்கம், எப்படி இருக்கிறீர்கள்?"]}'
```

### Option 4: PowerShell Invoke-RestMethod

```powershell
$serviceUrl = "http://your-service-url"
$payload = @{
    instances = @("नमस्ते, कैसे हो आप?")
} | ConvertTo-Json

$response = Invoke-RestMethod -Uri "$serviceUrl/v1/models/ai4bharat-bert:predict" -Method Post -Body $payload -Headers @{"Content-Type"="application/json"}
$response | ConvertTo-Json
```

### Option 5: Python requests

```python
import requests
import json

service_url = "http://your-service-url"
payload = {
    "instances": ["नमस्ते, कैसे हो आप?"]
}

response = requests.post(
    f"{service_url}/v1/models/ai4bharat-bert:predict",
    json=payload,
    headers={"Content-Type": "application/json"}
)

print(json.dumps(response.json(), indent=2, ensure_ascii=False))
```

## 🌍 Multi-Language Examples

### Hindi (हिंदी)
```json
{"instances": ["नमस्ते, कैसे हो आप?", "आज का दिन कैसा है?"]}
```

### Tamil (தமிழ்)
```json
{"instances": ["வணக்கம், எப்படி இருக்கிறீர்கள்?", "இன்று நாள் எப்படி இருக்கிறது?"]}
```

### Marathi (मराठी)
```json
{"instances": ["नमस्कार, तुम्ही कसे आहात?", "आजचा दिवस कसा आहे?"]}
```

### Gujarati (ગુજરાતી)
```json
{"instances": ["નમસ્તે, તમે કેમ છો?", "આજનો દિવસ કેવો છે?"]}
```

### Nepali (नेपाली)
```json
{"instances": ["नमस्कार, तपाईं कसरी हुनुहुन्छ?", "आजको दिन कस्तो छ?"]}
```

## 📊 Request Format

### Input Format
```json
{
  "instances": [
    "Text in any supported language",
    "Another text example"
  ]
}
```

### Response Format
```json
{
  "predictions": [
    {
      "label": "classification_label",
      "score": 0.95
    }
  ]
}
```

## ⚡ Performance Testing

### Batch Testing
Test multiple languages at once:

```powershell
.\test-model-calls.ps1
```

### Load Testing
Test performance with multiple iterations:

```powershell
# The test script automatically runs 10 iterations for performance metrics
```

## 🔧 Troubleshooting

### Common Issues

1. **Connection Refused**
   - Check if the model is deployed and ready
   - Verify the service URL is correct

2. **Timeout Errors**
   - Model might be loading or processing
   - Check resource availability

3. **Model Not Ready**
   - Wait for the model to fully load
   - Check pod logs: `kubectl logs -f -l app=ai4bharat-bert -n ai4bharat-serving`

### Debug Commands

```bash
# Check model status
kubectl get inferenceservice ai4bharat-bert -n ai4bharat-serving

# Check pod status
kubectl get pods -n ai4bharat-serving

# View logs
kubectl logs -f -l app=ai4bharat-bert -n ai4bharat-serving

# Check events
kubectl get events -n ai4bharat-serving --sort-by='.lastTimestamp'
```

## 📈 Monitoring

### Real-time Monitoring
```powershell
.\monitor-deployment.ps1
```

### Status Check
```powershell
.\check-status.ps1
```

## 🎯 Best Practices

1. **Start with Health Check**: Always verify the model is ready before making predictions
2. **Use Appropriate Timeouts**: Set reasonable timeouts for your use case
3. **Batch Requests**: Send multiple texts in a single request when possible
4. **Monitor Performance**: Use the provided scripts to track response times
5. **Error Handling**: Implement proper error handling in your applications

## 🚀 Next Steps

After testing your API calls:

1. **Integrate with Applications**: Use the API in your web/mobile apps
2. **Scale Up**: Adjust resource limits based on usage patterns
3. **Monitor**: Set up monitoring and alerting
4. **Customize**: Modify the model configuration for your specific needs

## 📚 Additional Resources

- [KServe API Documentation](https://kserve.github.io/website/)
- [HuggingFace Transformers](https://huggingface.co/docs/transformers/)
- [AI4Bharat Models](https://huggingface.co/ai4bharat)

---

**Happy Testing! 🎉**

Your AI4Bharat model is now ready to serve predictions in multiple Indian languages!
