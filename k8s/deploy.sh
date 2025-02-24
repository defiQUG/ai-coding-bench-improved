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

# Create namespace if it doesn't exist
kubectl apply -f base/namespace.yaml

# Apply kustomization
echo -e "${BLUE}Applying Kubernetes resources...${NC}"
kustomize build base | kubectl apply -f -

# Wait for deployments to be ready
echo -e "${BLUE}Waiting for deployments to be ready...${NC}"
kubectl -n ai-coding-bench wait --for=condition=available --timeout=300s deployment/api-gateway
kubectl -n ai-coding-bench wait --for=condition=available --timeout=300s deployment/pdf-analyzer
kubectl -n ai-coding-bench wait --for=condition=available --timeout=300s deployment/redis

# Get service URL
echo -e "${BLUE}Getting service URL...${NC}"
EXTERNAL_IP=$(kubectl -n ai-coding-bench get service api-gateway -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
if [ -z "$EXTERNAL_IP" ]; then
    echo -e "${RED}External IP not yet available. Please check service status.${NC}"
else
    echo -e "${GREEN}API Gateway is accessible at: http://$EXTERNAL_IP${NC}"
fi

echo -e "${GREEN}Deployment complete!${NC}" 