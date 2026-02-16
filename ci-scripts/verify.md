# Deployment Verification Scripts

Overview
- `verify.sh` — simple post-deployment verification runner. It reads a config file with checks and runs them, emitting structured logs for CI parsing.

Supported checks in `verify.conf` (one per line):
- `HTTP=https://example.com/health` — performs an HTTP GET and expects 2xx/3xx.
- `TCP=host:port` — checks TCP connectivity (uses `nc` if available, falls back to `/dev/tcp`).
- `CMD=systemctl is-active myservice` — runs an arbitrary command, expecting exit 0.

Usage
1. Create a config file (example below) at `ci-scripts/verify.conf` or pass an alternate file as the first arg.
2. Run:

```bash
bash ci-scripts/verify.sh ci-scripts/verify.conf
```

Example `ci-scripts/verify.conf`:

```
# HTTP health endpoint
HTTP=https://localhost:8080/health

# TCP port check
TCP=localhost:8080

# Service command check
CMD=systemctl is-active --quiet myapp.service
```

Exit codes
- `0` — all checks passed
- `2` — one or more checks failed
- `3` — config file missing or unreadable

CI integration notes
- Use this script as a last step in your pipeline to verify deployment success.
- Structured logs are emitted via `common.sh` in key=value format.
- Ensure required tools (`curl`, `nc`, `timeout`) are available in the CI runner or rely on the fallback checks.

Video demo checklist
- Show `ci-scripts/verify.conf` contents.
- Run the script against a demo service and show the success path.
- Induce a failure (stop the service or change URL) and show the failure exit code and logs.
- Explain how to wire this script into a pipeline (run after deploy stage, gate merges on success).
