#!/bin/bash
set -e

echo "🎮 Setting up Enterprise Number Game Platform locally..."

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check prerequisites
echo "🔍 Checking prerequisites..."
command -v kubectl >/dev/null 2>&1 || { echo -e "${RED}kubectl is required but not installed. Aborting.${NC}" >&2; exit 1; }
command -v helm >/dev/null 2>&1 || { echo -e "${RED}helm is required but not installed. Aborting.${NC}" >&2; exit 1; }
command -v docker >/dev/null 2>&1 || { echo -e "${RED}docker is required but not installed. Aborting.${NC}" >&2; exit 1; }

echo -e "${GREEN}✅ All prerequisites found${NC}"

# Check if Kubernetes is running
if ! kubectl cluster-info >/dev/null 2>&1; then
    echo -e "${RED}❌ Kubernetes cluster is not accessible. Please start your local cluster.${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Kubernetes cluster is accessible${NC}"

# Create namespace
echo "📦 Creating namespace..."
kubectl create namespace number-game-dev --dry-run=client -o yaml | kubectl apply -f -

# Install nginx ingress controller if not present
if ! kubectl get ingressclass nginx >/dev/null 2>&1; then
    echo -e "${YELLOW}📥 Installing nginx ingress controller...${NC}"
    kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.8.2/deploy/static/provider/cloud/deploy.yaml
    
    echo "⏳ Waiting for ingress controller to be ready..."
    kubectl wait --namespace ingress-nginx \
        --for=condition=ready pod \
        --selector=app.kubernetes.io/component=controller \
        --timeout=300s
    
    echo -e "${GREEN}✅ Nginx ingress controller installed${NC}"
else
    echo -e "${GREEN}✅ Nginx ingress controller already installed${NC}"
fi

# Install Prometheus operator if not present
if ! kubectl get crd servicemonitors.monitoring.coreos.com >/dev/null 2>&1; then
    echo -e "${YELLOW}📊 Installing Prometheus operator...${NC}"
    helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
    helm repo update
    
    kubectl create namespace monitoring --dry-run=client -o yaml | kubectl apply -f -
    
    helm install kube-prometheus-stack prometheus-community/kube-prometheus-stack \
        --namespace monitoring \
        --set prometheus.prometheusSpec.serviceMonitorSelectorNilUsesHelmValues=false \
        --set prometheus.prometheusSpec.ruleSelectorNilUsesHelmValues=false \
        --wait --timeout=10m
    
    echo -e "${GREEN}✅ Prometheus stack installed${NC}"
else
    echo -e "${GREEN}✅ Prometheus operator already available${NC}"
fi

# Add entries to /etc/hosts for local development
if ! grep -q "game.local" /etc/hosts; then
    echo -e "${YELLOW}🌐 Adding game.local to /etc/hosts...${NC}"
    echo "127.0.0.1 game.local" | sudo tee -a /etc/hosts
    echo -e "${GREEN}✅ Added game.local to /etc/hosts${NC}"
else
    echo -e "${GREEN}✅ game.local already in /etc/hosts${NC}"
fi

echo ""
echo -e "${GREEN}🎉 Local setup complete!${NC}"
echo ""
echo "Next steps:"
echo "1. Run ${YELLOW}./scripts/build.sh${NC} to build the application"
echo "2. Run ${YELLOW}helm install number-game ./helm-chart -f helm-chart/values/development.yaml -n number-game-dev${NC}"
echo "3. Access the game at ${YELLOW}http://game.local${NC}"
echo "4. View metrics at ${YELLOW}http://game.local/metrics${NC}"
echo "5. Access Grafana at ${YELLOW}http://localhost:3000${NC} (admin/prom-operator)"
echo ""
echo "Useful commands:"
echo "- ${YELLOW}kubectl port-forward -n monitoring svc/kube-prometheus-stack-grafana 3000:80${NC} # Access Grafana"
echo "- ${YELLOW}kubectl port-forward -n monitoring svc/kube-prometheus-stack-prometheus 9090:9090${NC} # Access Prometheus"
echo "- ${YELLOW}kubectl get pods -n number-game-dev${NC} # Check application pods"
