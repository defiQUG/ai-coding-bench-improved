#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}Deploying AI Coding Bench to Kubernetes...${NC}"

# Check if kubectl is installed
if ! command -v kubectl &> /dev/null; then
    echo -e "${RED}kubectl is not installed. Please install kubectl first.${NC}"
    exit 1
fi

# Check if kustomize is installed
if ! command -v kustomize &> /dev/null; then
    echo -e "${RED}kustomize is not installed. Please install kustomize first.${NC}"
    exit 1
fi

# Check if metrics-server is installed
if ! kubectl get deployment metrics-server -n kube-system &> /dev/null; then
    echo -e "${BLUE}Installing metrics-server...${NC}"
    kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
fi

# Install cert-manager
echo -e "${BLUE}Installing cert-manager...${NC}"
kubectl apply -f cert-manager/namespace.yaml
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.12.0/cert-manager.yaml
kubectl -n cert-manager wait --for=condition=available --timeout=300s deployment/cert-manager
kubectl -n cert-manager wait --for=condition=available --timeout=300s deployment/cert-manager-webhook
kubectl apply -f cert-manager/cluster-issuer.yaml

# Create namespace if it doesn't exist
kubectl apply -f base/namespace.yaml

# Apply kustomization
echo -e "${BLUE}Applying Kubernetes resources...${NC}"
kustomize build base | kubectl apply -f -

# Apply Pod Disruption Budgets
echo -e "${BLUE}Applying Pod Disruption Budgets...${NC}"
kubectl apply -f base/pod-disruption-budgets.yaml

# Deploy monitoring stack
echo -e "${BLUE}Deploying monitoring stack...${NC}"
cd monitoring
./deploy-monitoring.sh
echo -e "${BLUE}Configuring Grafana alerts...${NC}"
./configure-alerts.sh
cd ..

# Apply HPA configurations
echo -e "${BLUE}Applying HPA configurations...${NC}"
kubectl apply -f base/hpa.yaml

# Wait for deployments to be ready
echo -e "${BLUE}Waiting for deployments to be ready...${NC}"
kubectl -n ai-coding-bench wait --for=condition=available --timeout=300s deployment/api-gateway
kubectl -n ai-coding-bench wait --for=condition=available --timeout=300s deployment/pdf-analyzer
kubectl -n ai-coding-bench wait --for=condition=available --timeout=300s deployment/redis

# Get service URLs
echo -e "${BLUE}Getting service URLs...${NC}"
API_DOMAIN="api.ai-coding-bench.com"
GRAFANA_IP=$(kubectl -n monitoring get service grafana -o jsonpath='{.status.loadBalancer.ingress[0].ip}')

echo -e "${GREEN}Deployment complete!${NC}"
echo -e "${BLUE}Service URLs:${NC}"
echo -e "API Gateway: https://$API_DOMAIN"
if [ ! -z "$GRAFANA_IP" ]; then
    echo -e "Grafana: http://$GRAFANA_IP"
    echo -e "Grafana credentials:"
    echo -e "  Username: admin"
    echo -e "  Password: changeme"
fi

echo -e "${BLUE}Next steps:${NC}"
echo "1. Configure your DNS to point $API_DOMAIN to your ingress controller IP"
echo "2. Wait for SSL certificate to be issued (check with: kubectl get certificates -n ai-coding-bench)"
echo "3. Change the Grafana admin password"
echo "4. Monitor HPA status: kubectl get hpa -n ai-coding-bench"
echo "5. Verify PDBs: kubectl get pdb -n ai-coding-bench"
echo "6. Check Grafana alerts: http://$GRAFANA_IP/alerting/list"
echo "7. Set up backup system: cd backup && ./deploy-backup.sh" 