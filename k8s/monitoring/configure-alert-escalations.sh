#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}Configuring advanced alert escalation policies...${NC}"

# Apply advanced alert rules
kubectl apply -f grafana-alerts-advanced.yaml

# Get Grafana admin password
GRAFANA_PASSWORD=$(kubectl get secret -n monitoring grafana-secrets -o jsonpath="{.data.admin-password}" | base64 --decode)

# Get Grafana service URL
GRAFANA_URL=$(kubectl get service -n monitoring grafana -o jsonpath='{.status.loadBalancer.ingress[0].ip}')

if [ -z "$GRAFANA_URL" ]; then
    echo -e "${RED}Could not get Grafana URL. Please check if the service is running.${NC}"
    exit 1
fi

# Configure Slack notification channels for different severity levels
echo -e "${BLUE}Configuring notification channels...${NC}"

# Warning level notifications
curl -X POST -H "Content-Type: application/json" -d '{
    "name": "slack-warnings",
    "type": "slack",
    "settings": {
        "url": "'$(kubectl get secret -n velero velero-notifications -o jsonpath="{.data.SLACK_WEBHOOK_URL}" | base64 --decode)'",
        "recipient": "#monitoring-warnings"
    },
    "secureSettings": {}
}' "http://admin:${GRAFANA_PASSWORD}@${GRAFANA_URL}/api/alert-notifications"

# Critical level notifications
curl -X POST -H "Content-Type: application/json" -d '{
    "name": "slack-critical",
    "type": "slack",
    "settings": {
        "url": "'$(kubectl get secret -n velero velero-notifications -o jsonpath="{.data.SLACK_WEBHOOK_URL}" | base64 --decode)'",
        "recipient": "#monitoring-critical"
    },
    "secureSettings": {}
}' "http://admin:${GRAFANA_PASSWORD}@${GRAFANA_URL}/api/alert-notifications"

# Configure notification routing
echo -e "${BLUE}Configuring notification routing...${NC}"
curl -X POST -H "Content-Type: application/json" -d '{
    "name": "Platform Team Alerts",
    "rules": [
        {
            "matcher": {
                "label": "severity",
                "match": "=",
                "value": "warning"
            },
            "notification_channel": "slack-warnings"
        },
        {
            "matcher": {
                "label": "severity",
                "match": "=",
                "value": "critical"
            },
            "notification_channel": "slack-critical"
        }
    ]
}' "http://admin:${GRAFANA_PASSWORD}@${GRAFANA_URL}/api/v1/provisioning/notification-policies"

echo -e "${GREEN}Alert escalation configuration complete!${NC}"
echo -e "${BLUE}Next steps:${NC}"
echo "1. Verify alert rules in Grafana UI"
echo "2. Test warning-level alerts"
echo "3. Test critical-level alerts"
echo "4. Check notification routing in Slack channels" 