#!/bin/bash

echo "🚀 Setting up KServe with AI4Bharat Model Support"
echo "=================================================="

# Check if kubectl is available
if ! command -v kubectl &> /dev/null; then
    echo "❌ kubectl is not installed. Please install kubectl first."
    exit 1
fi

# Check if Kubernetes cluster is accessible
if ! kubectl cluster-info &> /dev/null; then
    echo "❌ Cannot connect to Kubernetes cluster. Please ensure your cluster is running."
    echo "💡 If using Docker Desktop, make sure Kubernetes is enabled in Docker Desktop settings."
    exit 1
fi

echo "✅ Kubernetes cluster is accessible"

# Create namespaces
echo "📦 Creating namespaces..."
kubectl apply -f namespace.yaml
kubectl apply -f kserve-install.yaml

# Wait for KServe to be ready
echo "⏳ Waiting for KServe to be ready..."
kubectl wait --for=condition=ready pod -l app=kserve-controller-manager -n kserve --timeout=300s

# Apply CRDs
echo "🔧 Applying Custom Resource Definitions..."
kubectl apply -f kserve-crds.yaml

# Wait for CRDs to be established
echo "⏳ Waiting for CRDs to be established..."
kubectl wait --for=condition=established --timeout=60s crd/inferenceservices.serving.kserve.io
kubectl wait --for=condition=established --timeout=60s crd/servingruntimes.serving.kserve.io

# Apply HuggingFace runtime
echo "🤗 Applying HuggingFace runtime..."
kubectl apply -f huggingface-runtime.yaml

# Wait for runtime to be ready
echo "⏳ Waiting for HuggingFace runtime to be ready..."
kubectl wait --for=condition=ready pod -l app=huggingface-runtime -n ai4bharat-serving --timeout=300s

# Deploy AI4Bharat model
echo "🇮🇳 Deploying AI4Bharat model..."
kubectl apply -f ai4bharat-model.yaml

# Wait for model to be ready
echo "⏳ Waiting for AI4Bharat model to be ready..."
kubectl wait --for=condition=ready inferenceservice ai4bharat-bert -n ai4bharat-serving --timeout=600s

echo "✅ Setup complete!"
echo ""
echo "🔍 Check the status with:"
echo "   kubectl get inferenceservices -n ai4bharat-serving"
echo "   kubectl get pods -n ai4bharat-serving"
echo ""
echo "🌐 The model will be available at the URL shown in the InferenceService status"
echo "📊 Monitor logs with:"
echo "   kubectl logs -f -l app=ai4bharat-bert -n ai4bharat-serving"
