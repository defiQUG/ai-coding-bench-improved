#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}Configuring Grafana alerts...${NC}"

# Apply alert rules
kubectl apply -f grafana-alerts.yaml

# Get Grafana admin password
GRAFANA_PASSWORD=$(kubectl get secret -n monitoring grafana-secrets -o jsonpath="{.data.admin-password}" | base64 --decode)

# Get Grafana service URL
GRAFANA_URL=$(kubectl get service -n monitoring grafana -o jsonpath='{.status.loadBalancer.ingress[0].ip}')

if [ -z "$GRAFANA_URL" ]; then
    echo -e "${RED}Could not get Grafana URL. Please check if the service is running.${NC}"
    exit 1
fi

# Configure alert notification channel (Slack)
echo -e "${BLUE}Configuring Slack notification channel...${NC}"
curl -X POST -H "Content-Type: application/json" -d '{
    "name": "slack",
    "type": "slack",
    "settings": {
        "url": "'$(kubectl get secret -n velero velero-notifications -o jsonpath="{.data.SLACK_WEBHOOK_URL}" | base64 --decode)'"
    }
}' "http://admin:${GRAFANA_PASSWORD}@${GRAFANA_URL}/api/alert-notifications"

echo -e "${GREEN}Alert configuration complete!${NC}"
echo -e "${BLUE}Next steps:${NC}"
echo "1. Access Grafana at http://${GRAFANA_URL}"
echo "2. Verify alert rules in Alerting > Alert Rules"
echo "3. Test alerts by generating high CPU/memory load"
echo "4. Check Slack for notifications" 