# CPU Usage Alert Runbook

## Alert Description

This runbook addresses CPU usage alerts for pods in the ai-coding-bench namespace.

### Warning Level (>70%)

Triggered when a pod's CPU usage exceeds 70% for 5 minutes.

### Critical Level (>85%)

Triggered when a pod's CPU usage exceeds 85% for 10 minutes.

## Initial Assessment

1. Check which pods are affected:

```bash
kubectl top pods -n ai-coding-bench
kubectl describe pod <pod-name> -n ai-coding-bench
```

2. Check HPA status:

```bash
kubectl get hpa -n ai-coding-bench
```

3. View recent pod events:

```bash
kubectl get events -n ai-coding-bench --sort-by='.lastTimestamp'
```

## Remediation Steps

### For Warning Level Alerts

1. Monitor HPA behavior:

```bash
kubectl describe hpa <hpa-name> -n ai-coding-bench
```

2. Check if scaling is working as expected:

```bash
kubectl get pods -n ai-coding-bench -w
```

3. Review application logs:

```bash
kubectl logs <pod-name> -n ai-coding-bench --tail=100
```

### For Critical Level Alerts

1. Immediate Actions:
   - Verify if HPA has reached max replicas
   - Check for any stuck processes or infinite loops
   - Look for unusual traffic patterns

2. Scale up resources if needed:

```bash
kubectl edit hpa <hpa-name> -n ai-coding-bench  # Adjust max replicas
```

3. Check for potential memory leaks:

```bash
kubectl exec -it <pod-name> -n ai-coding-bench -- top -n 1
```

## Prevention

1. Regular monitoring:
   - Review CPU usage patterns
   - Adjust HPA thresholds if needed
   - Monitor application performance metrics

2. Long-term solutions:
   - Consider implementing rate limiting
   - Optimize application code
   - Review resource requests/limits

## Escalation

If the issue persists:

1. Escalate to platform team
2. Consider temporary service degradation
3. Engage application development team

## Post-Incident

1. Document incident timeline
2. Review HPA settings
3. Update monitoring thresholds if needed
4. Schedule performance review
