# AI4Bharat KServe Setup - AI4X New

A comprehensive setup for hosting AI4Bharat language models on Kubernetes using KServe, with a modern web dashboard for translation and monitoring.

## 🚀 Features

- **AI4Bharat Model Deployment**: Deploy AI4Bharat transformer models on Kubernetes
- **KServe Integration**: Full KServe controller and CRD setup
- **Web Dashboard**: Modern, responsive web interface for translations
- **Real-time Monitoring**: Performance metrics, response times, and API logs
- **Multi-language Support**: Support for 11 Indian languages
- **Automated Setup**: PowerShell and Bash scripts with timestamps
- **Comprehensive Testing**: API testing and monitoring tools

## 🌟 What's Included

### Core Setup Files
- `namespace.yaml` - Kubernetes namespace for AI4Bharat services
- `kserve-install.yaml` - KServe controller installation
- `kserve-crds.yaml` - Custom Resource Definitions
- `huggingface-runtime.yaml` - HuggingFace model runtime
- `ai4bharat-model.yaml` - AI4Bharat model deployment

### Automation Scripts
- `setup-with-timestamps.ps1` - Windows PowerShell setup with timing
- `setup.sh` - Linux/Mac Bash setup
- `check-status.ps1` - Deployment status monitoring
- `monitor-deployment.ps1` - Real-time deployment monitoring

### Testing & API Tools
- `test-model.py` - Python API testing script
- `test-model-calls.ps1` - PowerShell API testing
- `test-with-curl.ps1` - cURL-based API testing
- `API_CALLS_GUIDE.md` - Comprehensive API usage guide

### Web Dashboard
- `frontend/index.html` - Main dashboard interface
- `frontend/styles.css` - Modern, responsive styling
- `frontend/script.js` - Interactive dashboard functionality
- `frontend/server.py` - Flask backend server
- `frontend/requirements.txt` - Python dependencies

## 🛠️ Prerequisites

- **Kubernetes Cluster**: Docker Desktop with Kubernetes enabled, or any Kubernetes cluster
- **kubectl**: Kubernetes command-line tool
- **Python 3.8+**: For testing and dashboard backend
- **PowerShell 7+** (Windows) or **Bash** (Linux/Mac)

## 🚀 Quick Start

### 1. Enable Kubernetes in Docker Desktop
1. Open Docker Desktop
2. Go to Settings → Kubernetes
3. Check "Enable Kubernetes"
4. Click "Apply & Restart"

### 2. Run Setup Script
**Windows:**
```powershell
.\setup-with-timestamps.ps1
```

**Linux/Mac:**
```bash
chmod +x setup.sh
./setup.sh
```

### 3. Start Web Dashboard
```bash
cd frontend
pip install -r requirements.txt
python server.py
```

### 4. Access Dashboard
Open your browser and go to: `http://localhost:5000`

## 📊 Dashboard Features

- **Translation Interface**: Source/target language selection with text input/output
- **Performance Metrics**: Response time, requests per minute, success rate
- **Real-time Charts**: Response time trends and language distribution
- **API Logs**: Detailed logging of all API calls
- **System Status**: Model health and endpoint information
- **Sample Texts**: Pre-loaded examples for testing

## 🔧 API Endpoints

### Model Health Check
```bash
curl http://localhost:8080/v1/models/ai4bharat-bert
```

### Translation Request
```bash
curl -X POST http://localhost:8080/v1/models/ai4bharat-bert:predict \
  -H "Content-Type: application/json" \
  -d '{
    "instances": ["नमस्ते, कैसे हो आप?"],
    "source_language": "hi",
    "target_language": "en"
  }'
```

## 🌍 Supported Languages

| Code | Language | Native Name | Script |
|------|----------|-------------|---------|
| hi | Hindi | हिंदी | Devanagari |
| en | English | English | Latin |
| ta | Tamil | தமிழ் | Tamil |
| mr | Marathi | मराठी | Devanagari |
| gu | Gujarati | ગુજરાતી | Gujarati |
| ne | Nepali | नेपाली | Devanagari |
| bn | Bengali | বাংলা | Bengali |
| te | Telugu | తెలుగు | Telugu |
| kn | Kannada | ಕನ್ನಡ | Kannada |
| ml | Malayalam | മലയാളം | Malayalam |
| pa | Punjabi | ਪੰਜਾਬੀ | Gurmukhi |

## 📈 Monitoring & Metrics

- **Response Time Tracking**: Real-time performance monitoring
- **Request Volume**: Requests per minute tracking
- **Success Rate**: API call success/failure rates
- **Language Usage**: Distribution of translation requests
- **System Health**: Model endpoint status monitoring

## 🧪 Testing

### Automated Testing
```powershell
# Comprehensive API testing
.\test-model-calls.ps1

# cURL-based testing
.\test-with-curl.ps1

# Python testing
python test-model.py
```

### Manual Testing
```bash
# Check deployment status
kubectl get inferenceservices
kubectl get pods -n ai4bharat

# View logs
kubectl logs -n ai4bharat -l app=ai4bharat-bert
```

## 🔍 Troubleshooting

### Common Issues

1. **Kubernetes Not Running**
   - Ensure Docker Desktop Kubernetes is enabled
   - Check `kubectl cluster-info`

2. **Model Not Loading**
   - Check pod status: `kubectl get pods -n ai4bharat`
   - View logs: `kubectl logs -n ai4bharat <pod-name>`

3. **Dashboard Not Starting**
   - Install dependencies: `pip install -r requirements.txt`
   - Check Python version: `python --version`

4. **API Connection Issues**
   - Verify service URL: `kubectl get svc -n ai4bharat`
   - Check port forwarding: `kubectl port-forward -n ai4bharat svc/ai4bharat-bert 8080:80`

## 📚 Documentation

- [KServe Documentation](https://kserve.github.io/website/)
- [AI4Bharat Models](https://ai4bharat.org/)
- [HuggingFace Transformers](https://huggingface.co/docs/transformers/)
- [Kubernetes Basics](https://kubernetes.io/docs/concepts/)

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🙏 Acknowledgments

- [KServe](https://github.com/kserve/kserve) - Kubernetes-native model serving
- [AI4Bharat](https://ai4bharat.org/) - Indian language AI models
- [HuggingFace](https://huggingface.co/) - Transformer model library
- [Flask](https://flask.palletsprojects.com/) - Web framework

## 📞 Support

For issues and questions:
- Create an issue in this repository
- Check the troubleshooting section
- Review the API calls guide

---

**Made with ❤️ for Indian Language AI**
