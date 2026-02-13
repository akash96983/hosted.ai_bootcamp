# Linux-level networking & troubleshooting (minimal)

This is a minimal deliverable showing basic Linux networking checks and how they map to Kubernetes troubleshooting.

Files
- `diagnostics.sh` — simple host-level checks: interfaces, routes, listening ports, DNS checks, ping, traceroute, and a small HTTP probe.

Run the script on a Linux host (or WSL) with network access:

```bash
bash linux-networking/diagnostics.sh
```

How it maps to Kubernetes
- Run the same DNS/resolve checks from within a Pod to validate cluster DNS: `kubectl run -it --rm dns-test --image=busybox --restart=Never -- nslookup kubernetes.default`
- Use `kubectl port-forward` to expose Pod ports to localhost, then re-run the `curl` check to validate traffic.

Next steps (optional)
- Add an automated run that executes `kubectl exec` into a debug pod and runs the same checks (useful for reproducing cluster-only networking issues).
