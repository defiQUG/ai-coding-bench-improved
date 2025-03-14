#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}Starting alert testing...${NC}"

# Function to clean up test resources
cleanup() {
    echo -e "${BLUE}Cleaning up test resources...${NC}"
    kubectl delete pod cpu-test -n ai-coding-bench --ignore-not-found
    kubectl delete pod memory-test -n ai-coding-bench --ignore-not-found
    kubectl delete pod crash-test -n ai-coding-bench --ignore-not-found
    kubectl delete pod loadtest -n ai-coding-bench --ignore-not-found
    kubectl delete pod latency-test -n ai-coding-bench --ignore-not-found
}

# Clean up any existing test resources
cleanup

# Test CPU Usage Alert
echo -e "${BLUE}Testing CPU Usage Alert...${NC}"
kubectl run cpu-test -n ai-coding-bench --image=busybox -- /bin/sh -c "while true; do dd if=/dev/zero of=/dev/null; done"
echo "Waiting for CPU alert to trigger (may take 5-10 minutes)..."
sleep 30

# Test Memory Usage Alert
echo -e "${BLUE}Testing Memory Usage Alert...${NC}"
kubectl run memory-test -n ai-coding-bench --image=polinux/stress -- stress --vm 1 --vm-bytes 800M --vm-hang 1
echo "Waiting for Memory alert to trigger (may take 5-10 minutes)..."
sleep 30

# Test Pod Restart Alert
echo -e "${BLUE}Testing Pod Restart Alert...${NC}"
kubectl run crash-test -n ai-coding-bench --image=busybox -- /bin/sh -c "while true; do sleep 10; exit 1; done"
echo "Waiting for Pod Restart alert to trigger (may take 15-30 minutes)..."
sleep 30

# Test Service Latency Alert
echo -e "${BLUE}Testing Service Latency Alert...${NC}"
# Create a test service that introduces artificial latency
cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: latency-test
  namespace: ai-coding-bench
spec:
  replicas: 1
  selector:
    matchLabels:
      app: latency-test
  template:
    metadata:
      labels:
        app: latency-test
    spec:
      containers:
      - name: latency-test
        image: nginx
        ports:
        - containerPort: 80
        lifecycle:
          postStart:
            exec:
              command: ["/bin/sh", "-c", "sed -i 's/keepalive_timeout.*/keepalive_timeout 2s;/g' /etc/nginx/nginx.conf && nginx -s reload"]
EOF

# Generate load to trigger latency alert
echo -e "${BLUE}Generating load for latency test...${NC}"
kubectl run -n ai-coding-bench loadtest \
  --image=fortio/fortio \
  -- load -qps 100 -t 300s http://latency-test.ai-coding-bench.svc.cluster.local

echo "Waiting for Latency alert to trigger (may take 5-10 minutes)..."
sleep 30

# Monitor alerts in Grafana
GRAFANA_URL=$(kubectl get service -n monitoring grafana -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
if [ ! -z "$GRAFANA_URL" ]; then
    echo -e "${GREEN}Grafana is accessible at: http://$GRAFANA_URL${NC}"
    echo "Check the Alerting section for triggered alerts"
fi

# Show current pod status
echo -e "${BLUE}Current pod status:${NC}"
kubectl get pods -n ai-coding-bench
kubectl top pods -n ai-coding-bench

# Show current alerts
echo -e "${BLUE}Current alerts:${NC}"
kubectl exec -n monitoring $(kubectl get pod -n monitoring -l app=prometheus -o jsonpath='{.items[0].metadata.name}') -- curl -s localhost:9090/api/v1/alerts

echo -e "${BLUE}Alert testing in progress...${NC}"
echo "1. Check Grafana UI for triggered alerts"
echo "2. Verify Slack notifications in #monitoring-warnings and #monitoring-critical"
echo "3. Run 'kubectl get events -n ai-coding-bench' to see related events"
echo "4. When finished testing, run: cleanup"

# Export the cleanup function for later use
export -f cleanup 