#!/bin/bash
set -e

echo "🎮 Minimal GitOps Setup (No sudo required)"
echo ""

# Check kubectl
if ! command -v kubectl >/dev/null 2>&1; then
    echo "❌ kubectl not found"
    exit 1
fi

echo "✅ kubectl found"

# Check cluster
if ! kubectl cluster-info >/dev/null 2>&1; then
    echo "❌ Cannot connect to cluster"
    exit 1
fi

echo "✅ Connected to: $(kubectl config current-context)"

# Install ArgoCD
echo ""
echo "🚀 Installing ArgoCD..."
kubectl create namespace argocd --dry-run=client -o yaml | kubectl apply -f -
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

echo "⏳ Waiting for ArgoCD..."
kubectl wait --for=condition=Available deployment/argocd-server -n argocd --timeout=300s

# Configure ArgoCD access
kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}}'

# Install Ingress
echo ""
echo "🌐 Installing Nginx Ingress..."
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.10.1/deploy/static/provider/cloud/deploy.yaml

echo "⏳ Waiting for Ingress..."
kubectl wait --for=condition=Available deployment/ingress-nginx-controller -n ingress-nginx --timeout=300s

echo ""
echo "✅ Setup Complete!"
echo ""
echo "🔑 Access Info:"
echo ""

# Get ArgoCD password
PASS=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" 2>/dev/null | base64 -d 2>/dev/null || echo "run: kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath=\"{.data.password}\" | base64 -d")

echo "ArgoCD:"
echo "  URL: https://localhost:8080"
echo "  User: admin"
echo "  Pass: $PASS"
echo "  Access: kubectl port-forward -n argocd svc/argocd-server 8080:443"
echo ""

echo "Number Game (after deployment):"
echo "  Access: kubectl port-forward -n number-game-dev svc/number-game 3000:80"
echo "  URL: http://localhost:3000"
echo ""

echo "Next steps:"
echo "1. kubectl port-forward -n argocd svc/argocd-server 8080:443"
echo "2. Open https://localhost:8080"
echo "3. Deploy your app with Helm"
echo ""
echo "🎯 GitOps platform ready!"