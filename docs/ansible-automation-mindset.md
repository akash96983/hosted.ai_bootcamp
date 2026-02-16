# Intro to Ansible & Automation Mindset

Purpose
- Summarize what to automate (and what not to), where Ansible fits vs scripts and CI, and explain idempotency and best practices for configuration management.

What to automate
- Repetitive, well-defined tasks with low human decision-making: package installs, service configuration, user provisioning, environment bootstrap.
- Tasks that must be auditable, versioned, and repeatable across environments.
- Workflows that benefit from declarative state: ensure service X is present and configured, not run a set of imperative shell commands.

What not to automate (or automate carefully)
- Tasks requiring frequent human judgement or one-off exploratory actions.
- Highly volatile experimentation steps; prefer scripts run interactively until stabilized.
- Secrets handling: automate retrieval from a secrets manager, but avoid storing plaintext secrets in playbooks or repos.

Where Ansible fits vs Scripts vs CI tools
- Ansible (configuration management / orchestration):
  - Declarative, idempotent resource models (packages, files, services).
  - Suited for long-lived infrastructure and configuration drift correction.
  - Good for multi-node orchestration where order and safety matter.
- Shell/Bash scripts (glue logic):
  - Imperative, good for small tasks, complex ad-hoc logic, or CI glue steps.
  - Use when you need procedural control or when a higher-level tool is unnecessary.
  - Must be designed idempotently and fail-fast for CI usage.
- CI systems (GitHub Actions, GitLab CI, Jenkins):
  - Orchestrate pipeline steps (build, test, deploy). Not a replacement for config management.
  - Trigger Ansible runs or scripts; keep pipelines declarative and short.

Idempotency concepts
- Idempotent action: running it multiple times yields the same end state and causes no harmful side effects.
- Ansible promotes idempotency by describing desired state; modules perform checks and only change when needed.
- For scripts: design with markers, checks, or compare-before-change patterns (e.g., `if [ -f /etc/service.conf ] && grep -q 'x' ...`), and exit codes that are CI-friendly.

Examples and patterns
- Ansible example: use `package:` and `service:` modules rather than `command:` for installs and service control.
- Script pattern: create marker files (e.g., `.deployed`) or check artifact timestamps before rebuilding.
- CI pattern: fail-fast with `set -euo pipefail`, structured logging, and minimal side effects; keep secrets in environment or vaults.

Repository structure (recommendation)
- `playbooks/` — Ansible playbooks and inventories
- `roles/` — Reusable Ansible roles
- `ci-scripts/` — CI-safe bash scripts (build/test/deploy)
- `docs/` — Architecture and automation philosophy notes (this document)

Best practices
- Prefer declarative modules (Ansible) for configuration; only use commands when necessary and wrap them to be idempotent.
- Keep secrets out of VCS; use Ansible Vault or external secret managers integrated into CI.
- Test playbooks in a disposable environment (containers or ephemeral VMs) before production runs.
- Use CI to lint and unit-test Ansible roles (ansible-lint, molecule) and to run idempotence checks.

Video presentation & PR checklist
- Show the doc file changes and explain the distinctions (Ansible vs scripts vs CI).
- Demonstrate an idempotence example: run an Ansible role or `ci-scripts/build.sh` twice showing the second run makes no changes.
- Explain where secrets are stored and demo a safe retrieval pattern (mock or describe if not possible to show credentials).
- PR description should include:
  - Short summary of the doc and why it's useful.
  - Link to the demonstration video (hosted on YouTube or cloud storage).
  - Any recommended follow-up tasks (e.g., add `molecule` tests, scaffold a sample role).
