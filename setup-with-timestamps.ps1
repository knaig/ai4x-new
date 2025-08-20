# AI4Bharat KServe Setup Script with Timestamps for Windows PowerShell
# Run this script as Administrator

function Write-TimestampedMessage {
    param(
        [string]$Message,
        [string]$Color = "White"
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Write-Host "[$timestamp] $Message" -ForegroundColor $Color
}

Write-TimestampedMessage "🚀 Starting KServe with AI4Bharat Model Support" "Green"
Write-TimestampedMessage "==================================================" "Green"

# Check if kubectl is available
Write-TimestampedMessage "🔍 Checking kubectl availability..." "Blue"
try {
    $kubectlVersion = kubectl version --client
    Write-TimestampedMessage "✅ kubectl is available" "Green"
} catch {
    Write-TimestampedMessage "❌ kubectl is not installed. Please install kubectl first." "Red"
    Write-TimestampedMessage "💡 Download from: https://kubernetes.io/docs/tasks/tools/install-kubectl/" "Yellow"
    exit 1
}

# Check if Kubernetes cluster is accessible
Write-TimestampedMessage "🔍 Checking Kubernetes cluster accessibility..." "Blue"
try {
    $clusterInfo = kubectl cluster-info
    Write-TimestampedMessage "✅ Kubernetes cluster is accessible" "Green"
} catch {
    Write-TimestampedMessage "❌ Cannot connect to Kubernetes cluster. Please ensure your cluster is running." "Red"
    Write-TimestampedMessage "💡 If using Docker Desktop, make sure Kubernetes is enabled in Docker Desktop settings." "Yellow"
    exit 1
}

# Create namespaces
Write-TimestampedMessage "📦 Creating namespaces..." "Blue"
$startTime = Get-Date
kubectl apply -f namespace.yaml
kubectl apply -f kserve-install.yaml
$endTime = Get-Date
$duration = $endTime - $startTime
Write-TimestampedMessage "✅ Namespaces created in $($duration.TotalSeconds.ToString('F2')) seconds" "Green"

# Wait for KServe to be ready
Write-TimestampedMessage "⏳ Waiting for KServe to be ready..." "Yellow"
$startTime = Get-Date
kubectl wait --for=condition=ready pod -l app=kserve-controller-manager -n kserve --timeout=300s
$endTime = Get-Date
$duration = $endTime - $startTime
Write-TimestampedMessage "✅ KServe controller ready in $($duration.TotalSeconds.ToString('F2')) seconds" "Green"

# Apply CRDs
Write-TimestampedMessage "🔧 Applying Custom Resource Definitions..." "Blue"
$startTime = Get-Date
kubectl apply -f kserve-crds.yaml
$endTime = Get-Date
$duration = $endTime - $startTime
Write-TimestampedMessage "✅ CRDs applied in $($duration.TotalSeconds.ToString('F2')) seconds" "Green"

# Wait for CRDs to be established
Write-TimestampedMessage "⏳ Waiting for CRDs to be established..." "Yellow"
$startTime = Get-Date
kubectl wait --for=condition=established --timeout=60s crd/inferenceservices.serving.kserve.io
kubectl wait --for=condition=established --timeout=60s crd/servingruntimes.serving.kserve.io
$endTime = Get-Date
$duration = $endTime - $startTime
Write-TimestampedMessage "✅ CRDs established in $($duration.TotalSeconds.ToString('F2')) seconds" "Green"

# Apply HuggingFace runtime
Write-TimestampedMessage "🤗 Applying HuggingFace runtime..." "Blue"
$startTime = Get-Date
kubectl apply -f huggingface-runtime.yaml
$endTime = Get-Date
$duration = $endTime - $startTime
Write-TimestampedMessage "✅ HuggingFace runtime applied in $($duration.TotalSeconds.ToString('F2')) seconds" "Green"

# Wait for runtime to be ready
Write-TimestampedMessage "⏳ Waiting for HuggingFace runtime to be ready..." "Yellow"
$startTime = Get-Date
kubectl wait --for=condition=ready pod -l app=huggingface-runtime -n ai4bharat-serving --timeout=300s
$endTime = Get-Date
$duration = $endTime - $startTime
Write-TimestampedMessage "✅ HuggingFace runtime ready in $($duration.TotalSeconds.ToString('F2')) seconds" "Green"

# Deploy AI4Bharat model
Write-TimestampedMessage "🇮🇳 Deploying AI4Bharat model..." "Blue"
$startTime = Get-Date
kubectl apply -f ai4bharat-model.yaml
$endTime = Get-Date
$duration = $endTime - $startTime
Write-TimestampedMessage "✅ AI4Bharat model deployment initiated in $($duration.TotalSeconds.ToString('F2')) seconds" "Green"

# Wait for model to be ready
Write-TimestampedMessage "⏳ Waiting for AI4Bharat model to be ready..." "Yellow"
$startTime = Get-Date
kubectl wait --for=condition=ready inferenceservice ai4bharat-bert -n ai4bharat-serving --timeout=600s
$endTime = Get-Date
$duration = $endTime - $startTime
Write-TimestampedMessage "✅ AI4Bharat model ready in $($duration.TotalSeconds.ToString('F2')) seconds" "Green"

$totalEndTime = Get-Date
$totalDuration = $totalEndTime - $startTime

Write-TimestampedMessage "🎉 Setup complete!" "Green"
Write-TimestampedMessage "⏱️ Total setup time: $($totalDuration.TotalMinutes.ToString('F2')) minutes" "Cyan"
Write-TimestampedMessage ""
Write-TimestampedMessage "🔍 Check the status with:" "Cyan"
Write-TimestampedMessage "   kubectl get inferenceservices -n ai4bharat-serving" "White"
Write-TimestampedMessage "   kubectl get pods -n ai4bharat-serving" "White"
Write-TimestampedMessage ""
Write-TimestampedMessage "🌐 The model will be available at the URL shown in the InferenceService status" "Cyan"
Write-TimestampedMessage "📊 Monitor logs with:" "Cyan"
Write-TimestampedMessage "   kubectl logs -f -l app=ai4bharat-bert -n ai4bharat-serving" "White"
Write-TimestampedMessage ""
Write-TimestampedMessage "🧪 Test the model with:" "Cyan"
Write-TimestampedMessage "   python test-model.py <service-url>" "White"
Write-TimestampedMessage ""
Write-TimestampedMessage "📱 Or use the provided test scripts:" "Cyan"
Write-TimestampedMessage "   .\test-model-calls.ps1" "White"
