# AI4Bharat KServe Setup Script for Windows PowerShell
# Run this script as Administrator

Write-Host "🚀 Setting up KServe with AI4Bharat Model Support" -ForegroundColor Green
Write-Host "==================================================" -ForegroundColor Green

# Check if kubectl is available
try {
    $kubectlVersion = kubectl version --client
    Write-Host "✅ kubectl is available" -ForegroundColor Green
} catch {
    Write-Host "❌ kubectl is not installed. Please install kubectl first." -ForegroundColor Red
    Write-Host "💡 Download from: https://kubernetes.io/docs/tasks/tools/install-kubectl/" -ForegroundColor Yellow
    exit 1
}

# Check if Kubernetes cluster is accessible
try {
    $clusterInfo = kubectl cluster-info
    Write-Host "✅ Kubernetes cluster is accessible" -ForegroundColor Green
} catch {
    Write-Host "❌ Cannot connect to Kubernetes cluster. Please ensure your cluster is running." -ForegroundColor Red
    Write-Host "💡 If using Docker Desktop, make sure Kubernetes is enabled in Docker Desktop settings." -ForegroundColor Yellow
    exit 1
}

# Create namespaces
Write-Host "📦 Creating namespaces..." -ForegroundColor Blue
kubectl apply -f namespace.yaml
kubectl apply -f kserve-install.yaml

# Wait for KServe to be ready
Write-Host "⏳ Waiting for KServe to be ready..." -ForegroundColor Yellow
kubectl wait --for=condition=ready pod -l app=kserve-controller-manager -n kserve --timeout=300s

# Apply CRDs
Write-Host "🔧 Applying Custom Resource Definitions..." -ForegroundColor Blue
kubectl apply -f kserve-crds.yaml

# Wait for CRDs to be established
Write-Host "⏳ Waiting for CRDs to be established..." -ForegroundColor Yellow
kubectl wait --for=condition=established --timeout=60s crd/inferenceservices.serving.kserve.io
kubectl wait --for=condition=established --timeout=60s crd/servingruntimes.serving.kserve.io

# Apply HuggingFace runtime
Write-Host "🤗 Applying HuggingFace runtime..." -ForegroundColor Blue
kubectl apply -f huggingface-runtime.yaml

# Wait for runtime to be ready
Write-Host "⏳ Waiting for HuggingFace runtime to be ready..." -ForegroundColor Yellow
kubectl wait --for=condition=ready pod -l app=huggingface-runtime -n ai4bharat-serving --timeout=300s

# Deploy AI4Bharat model
Write-Host "🇮🇳 Deploying AI4Bharat model..." -ForegroundColor Blue
kubectl apply -f ai4bharat-model.yaml

# Wait for model to be ready
Write-Host "⏳ Waiting for AI4Bharat model to be ready..." -ForegroundColor Yellow
kubectl wait --for=condition=ready inferenceservice ai4bharat-bert -n ai4bharat-serving --timeout=600s

Write-Host "✅ Setup complete!" -ForegroundColor Green
Write-Host ""
Write-Host "🔍 Check the status with:" -ForegroundColor Cyan
Write-Host "   kubectl get inferenceservices -n ai4bharat-serving" -ForegroundColor White
Write-Host "   kubectl get pods -n ai4bharat-serving" -ForegroundColor White
Write-Host ""
Write-Host "🌐 The model will be available at the URL shown in the InferenceService status" -ForegroundColor Cyan
Write-Host "📊 Monitor logs with:" -ForegroundColor Cyan
Write-Host "   kubectl logs -f -l app=ai4bharat-bert -n ai4bharat-serving" -ForegroundColor White
Write-Host ""
Write-Host "🧪 Test the model with:" -ForegroundColor Cyan
Write-Host "   python test-model.py <service-url>" -ForegroundColor White
