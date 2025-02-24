# Service Latency Alert Runbook

## Alert Description
This runbook addresses service latency alerts in the ai-coding-bench namespace.

### Warning Level
Triggered when average service latency exceeds 1 second over 5 minutes.

## Initial Assessment

1. Check service status and endpoints:
```bash
kubectl get svc -n ai-coding-bench
kubectl get endpoints -n ai-coding-bench
```

2. Check pod metrics:
```bash
kubectl top pods -n ai-coding-bench
kubectl get pods -n ai-coding-bench -o wide
```

3. View service latency metrics:
```bash
kubectl exec -it -n monitoring prometheus-0 -- curl -s 'localhost:9090/api/v1/query' --data-urlencode 'query=rate(http_request_duration_seconds_sum{namespace="ai-coding-bench"}[5m])'
```

## Remediation Steps

### For Warning Level Alerts:

1. Check network connectivity:
```bash
kubectl exec -it <pod-name> -n ai-coding-bench -- ping -c 3 api-gateway
kubectl exec -it <pod-name> -n ai-coding-bench -- curl -v api-gateway:8000/health
```

2. Review resource utilization:
```bash
kubectl top pods -n ai-coding-bench --containers
kubectl describe nodes | grep -A10 "Allocated resources"
```

3. Check for slow database queries (if applicable):
```bash
kubectl logs -n ai-coding-bench <pod-name> | grep -i "slow query"
```

### For Performance Investigation:

1. Enable detailed tracing:
```bash
kubectl patch deployment <deployment-name> -n ai-coding-bench -p '{"spec":{"template":{"metadata":{"annotations":{"debug.trace/enabled":"true"}}}}}'
```

2. Check for network issues:
```bash
kubectl exec -it <pod-name> -n ai-coding-bench -- tcpdump -i any -w /tmp/dump.pcap
kubectl cp <pod-name>:/tmp/dump.pcap ./dump.pcap -n ai-coding-bench
```

3. Analyze service dependencies:
```bash
kubectl describe pods -n ai-coding-bench | grep "Ready\|Started"
kubectl get endpoints -n ai-coding-bench -o yaml
```

## Prevention

1. Performance optimization:
   - Implement caching where appropriate
   - Optimize database queries
   - Use connection pooling
   - Configure appropriate timeouts

2. Resource management:
   - Review and adjust resource limits
   - Configure HPA based on latency metrics
   - Monitor network policies

3. Monitoring enhancements:
   - Set up detailed latency metrics
   - Configure request tracing
   - Monitor backend services

## Escalation

If the issue persists:
1. Escalate to platform team
2. Engage application development team
3. Consider scaling resources

## Post-Incident

1. Document latency patterns
2. Review service architecture
3. Update performance baselines
4. Implement performance improvements
5. Update monitoring thresholds

## Performance Testing

Run load tests to verify improvements:
```bash
kubectl run -n ai-coding-bench loadtest \
  --image=fortio/fortio \
  -- load -qps 100 -t 60s http://api-gateway:8000/
```

Monitor results:
```bash
kubectl logs -n ai-coding-bench loadtest
``` 