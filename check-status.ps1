# AI4Bharat KServe Status Checker
# Run this script to check the deployment status

Write-Host "🔍 Checking AI4Bharat KServe Deployment Status" -ForegroundColor Green
Write-Host "=============================================" -ForegroundColor Green

# Check namespaces
Write-Host "📦 Checking namespaces..." -ForegroundColor Blue
kubectl get namespaces | Select-String -Pattern "kserve|ai4bharat-serving"

# Check KServe controller
Write-Host "`n🎮 Checking KServe controller..." -ForegroundColor Blue
kubectl get pods -n kserve

# Check CRDs
Write-Host "`n🔧 Checking Custom Resource Definitions..." -ForegroundColor Blue
kubectl get crd | Select-String -Pattern "kserve"

# Check HuggingFace runtime
Write-Host "`n🤗 Checking HuggingFace runtime..." -ForegroundColor Blue
kubectl get servingruntimes -n ai4bharat-serving

# Check AI4Bharat model
Write-Host "`n🇮🇳 Checking AI4Bharat model..." -ForegroundColor Blue
kubectl get inferenceservices -n ai4bharat-serving

# Check pods in ai4bharat-serving namespace
Write-Host "`n🐳 Checking pods in ai4bharat-serving namespace..." -ForegroundColor Blue
kubectl get pods -n ai4bharat-serving

# Check services
Write-Host "`n🌐 Checking services..." -ForegroundColor Blue
kubectl get services -n ai4bharat-serving

# Check events
Write-Host "`n📋 Recent events in ai4bharat-serving namespace..." -ForegroundColor Blue
kubectl get events -n ai4bharat-serving --sort-by='.lastTimestamp' | Select-Object -First 10

Write-Host "`n✅ Status check complete!" -ForegroundColor Green
Write-Host "💡 Use 'kubectl describe' commands for more detailed information" -ForegroundColor Yellow
