#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}Deploying monitoring stack...${NC}"

# Create monitoring namespace
kubectl apply -f namespace.yaml

# Deploy Prometheus
echo -e "${BLUE}Deploying Prometheus...${NC}"
kubectl apply -f prometheus-config.yaml
kubectl apply -f prometheus-deployment.yaml

# Deploy Grafana
echo -e "${BLUE}Deploying Grafana...${NC}"
kubectl apply -f grafana-deployment.yaml

# Wait for deployments to be ready
echo -e "${BLUE}Waiting for deployments to be ready...${NC}"
kubectl -n monitoring wait --for=condition=available --timeout=300s deployment/prometheus
kubectl -n monitoring wait --for=condition=available --timeout=300s deployment/grafana

# Get Grafana URL
echo -e "${BLUE}Getting Grafana URL...${NC}"
GRAFANA_IP=$(kubectl -n monitoring get service grafana -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
if [ -z "$GRAFANA_IP" ]; then
    echo -e "${RED}Grafana external IP not yet available. Please check service status.${NC}"
else
    echo -e "${GREEN}Grafana is accessible at: http://$GRAFANA_IP${NC}"
    echo -e "${BLUE}Default credentials:${NC}"
    echo -e "Username: admin"
    echo -e "Password: changeme"
fi

echo -e "${GREEN}Monitoring stack deployment complete!${NC}" 