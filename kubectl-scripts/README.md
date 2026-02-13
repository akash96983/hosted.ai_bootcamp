# kubectl-scripts — Minimal kubectl wrapper scripts

Minimal, easy-to-use Bash wrappers for common kubectl workflows: deploy, delete, and status checks.

Prerequisites:
- `kubectl` installed and configured to talk to a Kubernetes cluster.

Files added:
- `kubectl-scripts/deploy.sh` — Apply a manifest and wait for rollout.
- `kubectl-scripts/delete.sh` — Delete resources from a manifest and wait for removal.
- `kubectl-scripts/status.sh` — Show cluster info, pods and optional rollout status.
- `kubectl-scripts/manifests/nginx-deployment.yaml` — Small sample Deployment.

Quick usage:

Deploy the sample nginx deployment:

```bash
bash kubectl-scripts/deploy.sh
```

Delete the sample deployment:

```bash
bash kubectl-scripts/delete.sh
```

Check status (including rollout status):

```bash
bash kubectl-scripts/status.sh nginx-deployment
```

Notes:
- Scripts perform basic validation (checks `kubectl` in PATH) and return non-zero on failures.
- For custom manifests or names, pass the manifest path and/or deployment name as arguments.
