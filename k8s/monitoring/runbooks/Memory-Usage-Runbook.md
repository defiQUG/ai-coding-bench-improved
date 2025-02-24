# Memory Usage Alert Runbook

## Alert Description
This runbook addresses memory usage alerts for pods in the ai-coding-bench namespace.

### Warning Level (>70%)
Triggered when a pod's memory usage exceeds 70% for 5 minutes.

### Critical Level (>85%)
Triggered when a pod's memory usage exceeds 85% for 10 minutes.

## Initial Assessment

1. Check current memory usage:
```bash
kubectl top pods -n ai-coding-bench
kubectl describe pod <pod-name> -n ai-coding-bench
```

2. Check memory limits and requests:
```bash
kubectl get pod <pod-name> -n ai-coding-bench -o jsonpath='{.spec.containers[*].resources}'
```

3. Check if OOMKilled events occurred:
```bash
kubectl get events -n ai-coding-bench --field-selector reason=OOMKilled
```

## Remediation Steps

### For Warning Level Alerts:

1. Check memory consumption trend:
```bash
kubectl top pod <pod-name> -n ai-coding-bench --containers
```

2. Review application logs for memory-related issues:
```bash
kubectl logs <pod-name> -n ai-coding-bench --tail=200 | grep -i "memory\|heap\|GC"
```

3. Monitor garbage collection (if applicable):
```bash
kubectl exec -it <pod-name> -n ai-coding-bench -- jstat -gc 1 1000
```

### For Critical Level Alerts:

1. Immediate Actions:
   - Check for memory leaks
   - Review recent application changes
   - Monitor garbage collection patterns

2. Scale vertically if needed:
```bash
kubectl patch deployment <deployment-name> -n ai-coding-bench -p '{"spec":{"template":{"spec":{"containers":[{"name":"<container-name>","resources":{"limits":{"memory":"<new-limit>"},"requests":{"memory":"<new-request>"}}}]}}}}'
```

3. Force garbage collection (if applicable):
```bash
kubectl exec -it <pod-name> -n ai-coding-bench -- jcmd 1 GC.run
```

## Prevention

1. Memory optimization:
   - Review memory allocation patterns
   - Implement memory limits and requests
   - Configure appropriate JVM settings (if Java)

2. Long-term solutions:
   - Implement memory usage monitoring
   - Set up memory profiling
   - Review memory-intensive operations
   - Consider implementing caching

## Escalation

If the issue persists:
1. Escalate to platform team
2. Engage application development team
3. Consider temporary pod replacement

## Post-Incident

1. Document memory usage patterns
2. Review and adjust memory limits
3. Implement memory optimization recommendations
4. Update monitoring thresholds if needed
5. Schedule application memory profiling 