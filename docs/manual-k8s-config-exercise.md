# Manual Kubernetes Configuration Exercise

## Goal
Apply config changes manually, observe pod behavior, document what happened.

## Quick Start

### Deploy sample app
```bash
kubectl apply -f kubectl-scripts/manifests/nginx-deployment.yaml
kubectl get pods
```

## Exercise 1: ConfigMap Change

**Step 1:** Create a ConfigMap
```bash
kubectl create configmap app-config --from-literal=MESSAGE="Hello v1"
```

**Step 2:** Update the message in ConfigMap
```bash
kubectl patch configmap app-config -p '{"data":{"MESSAGE":"Hello v2"}}'
```

**Step 3:** Observe
```bash
kubectl describe configmap app-config
kubectl get events
```

**What to note:** Did the running pods pick up the change? Why or why not?

---

## Exercise 2: Resource Limits

**Step 1:** Apply resource limits to deployment
```bash
kubectl set resources deployment/nginx-deployment -c=nginx --limits=cpu=100m,memory=128Mi
```

**Step 2:** Watch pods
```bash
kubectl get pods -w
kubectl describe pod <pod-name>
```

**What to note:** Did pods restart? Check `kubectl top pods` to see resource usage.

---

## Exercise 3: Liveness Probe

**Step 1:** Add a failing probe to restart the pod
```bash
kubectl set probe deployment/nginx-deployment --liveness --initial-delay-seconds=5 --failure-threshold=1 -- sh -c 'exit 1'
```

**Step 2:** Watch the pod
```bash
kubectl get pods -w
kubectl describe pod <pod-name>
```

**What to note:** How many times did the pod restart? Check restart count.

---

## Observation Commands

Run these after each change:

```bash
# Watch pod status in real-time
kubectl get pods -w

# See pod details
kubectl describe pod <pod-name>

# See container logs
kubectl logs <pod-name>

# See all events
kubectl get events --sort-by=.metadata.creationTimestamp
```

---

## What to Document

For each exercise, write down:
1. **Change made** — exact command
2. **Expected outcome** — what you thought would happen
3. **Actual outcome** — what really happened
4. **Timing** — when did it happen? (seconds, minutes)
5. **Proof** — command output or screenshot

---

## Example Documentation Format

```
Exercise: ConfigMap Update

Change: kubectl patch configmap app-config -p '{"data":{"MESSAGE":"Hello v2"}}'
Expected: Pods pick up new value immediately
Actual: Pods did NOT pick up new value. Needed to delete/recreate pod manually.
Timing: Change applied at 10:05, pod still had old value at 10:06
Proof: kubectl exec <pod> -- echo $MESSAGE showed "Hello v1"
```
