#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}Setting up backup system...${NC}"

# Check if velero CLI is installed
if ! command -v velero &> /dev/null; then
    echo -e "${RED}Velero CLI is not installed. Please install it first:${NC}"
    echo "brew install velero"
    exit 1
fi

# Check for Slack webhook URL
if [ ! -f "./slack-webhook-url" ]; then
    echo -e "${RED}Slack webhook URL file not found. Please create 'slack-webhook-url' file with your webhook URL.${NC}"
    exit 1
fi

# Create namespace
kubectl apply -f namespace.yaml

# Create Slack webhook secret
SLACK_WEBHOOK_URL=$(cat ./slack-webhook-url)
kubectl create secret generic velero-notifications \
    --from-literal=SLACK_WEBHOOK_URL="$SLACK_WEBHOOK_URL" \
    -n velero

# Install Velero with AWS S3 provider (modify credentials and bucket as needed)
echo -e "${BLUE}Installing Velero...${NC}"
velero install \
    --provider aws \
    --plugins velero/velero-plugin-for-aws:v1.7.0 \
    --bucket ai-coding-bench-backup \
    --backup-location-config region=us-west-2 \
    --snapshot-location-config region=us-west-2 \
    --secret-file ./credentials-velero

# Wait for Velero to be ready
echo -e "${BLUE}Waiting for Velero to be ready...${NC}"
kubectl -n velero wait --for=condition=available --timeout=300s deployment/velero

# Apply backup schedules
echo -e "${BLUE}Creating backup schedules...${NC}"
kubectl apply -f schedule.yaml

# Apply notification configuration
echo -e "${BLUE}Setting up backup notifications...${NC}"
kubectl apply -f notifications.yaml

echo -e "${GREEN}Backup system setup complete!${NC}"
echo -e "${BLUE}Next steps:${NC}"
echo "1. Verify backup schedules: velero schedule get"
echo "2. Monitor backup jobs: velero backup get"
echo "3. Test restore: velero restore create --from-backup <backup-name>"
echo "4. Check Slack channel for backup notifications" 