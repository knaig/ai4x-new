# 🔗 Connect Dashboard to AI4Bharat Model

This guide will help you connect your live dashboard to the actual AI4Bharat model running on KServe.

## 🎯 Current Status

✅ **Dashboard**: Live on Vercel with mock translations  
✅ **Mock Service**: Working fallback for testing  
❌ **Real Model**: Not yet connected to AI4Bharat  

## 🚀 Step 1: Deploy KServe with AI4Bharat Model

### Option A: Use the Setup Scripts (Recommended)
```powershell
# Navigate to the setup directory
cd ai4bharat-kserve-setup

# Run the automated setup
.\setup-with-timestamps.ps1
```

### Option B: Manual Deployment
```bash
# 1. Create namespace
kubectl apply -f namespace.yaml

# 2. Install KServe
kubectl apply -f kserve-install.yaml

# 3. Apply CRDs
kubectl apply -f kserve-crds.yaml

# 4. Deploy HuggingFace runtime
kubectl apply -f huggingface-runtime.yaml

# 5. Deploy AI4Bharat model
kubectl apply -f ai4bharat-model.yaml
```

## 🌐 Step 2: Get Your Model Endpoint

### Check the Service URL
```bash
kubectl get inferenceservice ai4bharat-bert -n ai4bharat -o jsonpath='{.status.url}'
```

### Expected Output
```
http://ai4bharat-bert.ai4bharat.example.com
```

## 🔧 Step 3: Update Dashboard Configuration

### Option A: Update Vercel Environment Variables
1. Go to [Vercel Dashboard](https://vercel.com/dashboard)
2. Select your `frontend` project
3. Go to Settings → Environment Variables
4. Add/Update:
   - **Key**: `AI4BHARAT_ENDPOINT`
   - **Value**: Your actual KServe endpoint URL
   - **Environment**: Production

### Option B: Update vercel.json
```json
{
  "env": {
    "AI4BHARAT_ENDPOINT": "http://your-actual-kserve-endpoint.com",
    "DEBUG": "false"
  }
}
```

### Option C: Use Vercel CLI
```bash
vercel env add AI4BHARAT_ENDPOINT
# Enter your KServe endpoint URL when prompted
```

## 🚀 Step 4: Redeploy Dashboard

After updating the configuration:
```bash
cd frontend
vercel --prod
```

## 🧪 Step 5: Test the Connection

### Check API Status
```bash
curl https://your-dashboard.vercel.app/api/status
```

**Expected Response:**
```json
{
  "endpoint": "http://your-kserve-endpoint.com",
  "model_name": "ai4bharat-bert",
  "healthy": true,
  "status": "connected",
  "timestamp": "2025-08-20T..."
}
```

### Test Translation
```bash
curl -X POST https://your-dashboard.vercel.app/api/translate \
  -H "Content-Type: application/json" \
  -d '{
    "text": "नमस्ते, कैसे हो आप?",
    "source_language": "hi",
    "target_language": "en"
  }'
```

**Expected Response:**
```json
{
  "success": true,
  "translation": "Hello, how are you?",
  "confidence": 0.95,
  "source": "ai4bharat_model",
  "response_time": 1200
}
```

## 🔍 Troubleshooting Connection Issues

### 1. **Model Not Responding**
```bash
# Check if model is running
kubectl get pods -n ai4bharat

# Check model logs
kubectl logs -n ai4bharat -l app=ai4bharat-bert

# Check service status
kubectl get svc -n ai4bharat
```

### 2. **Network Connectivity**
```bash
# Test from within cluster
kubectl run test-curl --image=curlimages/curl -i --rm --restart=Never -- \
  curl -s http://ai4bharat-bert.ai4bharat.svc.cluster.local/v1/models/ai4bharat-bert
```

### 3. **Authentication Issues**
- Check if your model requires authentication
- Verify API keys or tokens are configured
- Check CORS settings

### 4. **Model Loading Issues**
```bash
# Check model download progress
kubectl describe inferenceservice ai4bharat-bert -n ai4bharat

# Check events
kubectl get events -n ai4bharat --sort-by='.lastTimestamp'
```

## 🌟 Advanced Configuration

### Custom Model Arguments
```yaml
# In ai4bharat-model.yaml
spec:
  predictor:
    model:
      args:
        - --model_name=ai4bharat-bert
        - --model_id=ai4bharat/indic-bert
        - --task=text-classification
        - --dtype=auto
```

### Resource Limits
```yaml
resources:
  limits:
    cpu: "2"
    memory: 4Gi
    nvidia.com/gpu: "1"  # If using GPU
  requests:
    cpu: 500m
    memory: 2Gi
```

### Environment Variables
```yaml
env:
  - name: SAFETENSORS_FAST_GPU
    value: "1"
  - name: HF_HUB_DISABLE_TELEMETRY
    value: "1"
```

## 📊 Monitoring Real Model Performance

### Dashboard Metrics
- **Response Time**: Real API call times
- **Success Rate**: Successful vs failed translations
- **Model Health**: Connection status
- **Language Usage**: Actual translation patterns

### Vercel Analytics
- **Function Execution**: Python function performance
- **Edge Network**: Global response times
- **Error Tracking**: Automatic error monitoring

## 🔄 Continuous Deployment

### Automatic Updates
- **GitHub Integration**: Every push triggers deployment
- **Model Updates**: Update model without dashboard changes
- **Rollback**: Easy rollback to previous versions

### Environment Management
```bash
# Development
vercel env add AI4BHARAT_ENDPOINT development

# Preview
vercel env add AI4BHARAT_ENDPOINT preview

# Production
vercel env add AI4BHARAT_ENDPOINT production
```

## 🎯 Success Checklist

- ✅ **KServe deployed** and running
- ✅ **AI4Bharat model** loaded and healthy
- ✅ **Endpoint URL** obtained and verified
- ✅ **Environment variable** set in Vercel
- ✅ **Dashboard redeployed** with new config
- ✅ **API status** shows "connected"
- ✅ **Translation API** returns real results
- ✅ **Performance metrics** tracking real calls

## 🚀 Next Steps After Connection

1. **Monitor Performance**: Track real response times
2. **Scale Model**: Adjust resources based on usage
3. **Add More Models**: Deploy additional AI4Bharat models
4. **Custom Domains**: Set up professional URLs
5. **Team Access**: Add collaborators to your project

---

## 🌟 **Your Dashboard Will Then:**

- **Connect directly** to AI4Bharat models
- **Provide real translations** in 11 Indian languages
- **Show actual performance** metrics
- **Scale automatically** with Vercel's edge network
- **Be production-ready** for real users

**Once connected, your dashboard will be a fully functional AI4Bharat translation service accessible globally! 🎉**
