# Pod Restart Alert Runbook

## Alert Description
This runbook addresses pod restart alerts in the ai-coding-bench namespace.

### Warning Level
Triggered when a pod restarts more than 2 times in 30 minutes.

### Critical Level
Triggered when a pod restarts more than 3 times in 15 minutes.

## Initial Assessment

1. Check pod status and restart count:
```bash
kubectl get pods -n ai-coding-bench
kubectl describe pod <pod-name> -n ai-coding-bench
```

2. Check pod events:
```bash
kubectl get events -n ai-coding-bench --field-selector involvedObject.name=<pod-name> --sort-by='.lastTimestamp'
```

3. Check pod logs before crash:
```bash
kubectl logs <pod-name> -n ai-coding-bench --previous
```

## Remediation Steps

### For Warning Level Alerts:

1. Check for application errors:
```bash
kubectl logs <pod-name> -n ai-coding-bench --tail=500
```

2. Check resource constraints:
```bash
kubectl top pod <pod-name> -n ai-coding-bench
kubectl describe pod <pod-name> -n ai-coding-bench | grep -A3 Limits
```

3. Verify liveness and readiness probes:
```bash
kubectl get pod <pod-name> -n ai-coding-bench -o yaml | grep -A10 livenessProbe
```

### For Critical Level Alerts:

1. Immediate Actions:
   - Check for application deadlocks
   - Verify external dependencies
   - Check for network issues

2. Force pod replacement if needed:
```bash
kubectl delete pod <pod-name> -n ai-coding-bench
```

3. Check deployment status:
```bash
kubectl rollout status deployment/<deployment-name> -n ai-coding-bench
kubectl rollout history deployment/<deployment-name> -n ai-coding-bench
```

## Prevention

1. Pod health checks:
   - Review liveness probe configuration
   - Review readiness probe configuration
   - Implement startup probe if needed

2. Resource management:
   - Set appropriate resource limits
   - Configure HPA properly
   - Monitor resource usage trends

3. Application resilience:
   - Implement circuit breakers
   - Add retry mechanisms
   - Improve error handling

## Escalation

If the issue persists:
1. Escalate to platform team
2. Engage application development team
3. Consider rolling back to previous version

## Post-Incident

1. Document restart patterns
2. Review application logs
3. Update health check configurations
4. Implement additional monitoring
5. Review deployment procedures