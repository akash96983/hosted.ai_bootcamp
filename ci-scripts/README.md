# CI-safe Bash scripts

Overview
- Simple, CI-friendly Bash helper and example scripts for pipeline integration.

Files
- `common.sh` — shared logging, error handling, and `run()` wrapper (`set -euo pipefail`).
- `build.sh` — idempotent build that writes `build/artifact.txt`.
- `test.sh` — idempotent test runner (simulated here).
- `deploy.sh` — idempotent deploy that creates a `.deployed` marker.

How to run locally
1. Ensure you have Bash available (Linux, macOS, or Git Bash / WSL on Windows).
2. From the repo root run:

```bash
bash ci-scripts/build.sh
bash ci-scripts/test.sh
bash ci-scripts/deploy.sh
```

CI integration notes
- Scripts emit structured logs in key=value form for easy parsing by CI systems.
- Scripts are idempotent: re-running `build.sh` or `deploy.sh` will be safe.
- Use `set -euo pipefail` and the included `run()` wrapper to keep fail-fast behaviour while allowing controlled error handling.

Video demo checklist for PR
1. Show repository changes (files added).
2. Run the three scripts locally demonstrating idempotency (run twice to show skips).
3. Show GitHub Actions run using the included workflow or explain equivalent GitLab CI snippet.
4. Provide a short URL to the recorded demo in your PR description.
