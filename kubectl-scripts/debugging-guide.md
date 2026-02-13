# Bash-driven Kubernetes Debugging (minimal)

This short note and script help collect common debugging information for a Pod.

Checklist (systematic approach)
- Identify the failing Pod (name or label).
- Describe the Pod: `kubectl describe pod <pod>` to see events and conditions.
- Check events: `kubectl get events` for scheduling/oom/killing messages.
- Fetch logs: `kubectl logs <pod> -c <container>` and `--previous` for crashloops.
- Inspect container statuses: readiness, liveness, restart count.
- If needed, `kubectl exec -it <pod> -- sh` to inspect filesystem or run commands.

Script
- `kubectl-scripts/debug.sh <pod|label> [namespace]` runs through the above steps and prints commands to run next.

Example

```bash
bash kubectl-scripts/debug.sh app=nginx default
```

Notes
- The script is intentionally small — use it as a starting point for automating further checks (ephemeral containers, probing metrics, or automated log aggregation).
