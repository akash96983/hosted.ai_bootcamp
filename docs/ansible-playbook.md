# First Ansible Playbook — Idempotency Demonstration

This document accompanies `ansible/playbooks/basic.yml`. It explains how to run the playbook and verify idempotent behavior.

Run the playbook

```bash
# From repo root, using the INI inventory
ansible-playbook -i ansible/inventory/hosts.ini ansible/playbooks/basic.yml
```

If your SSH user requires a password or `become` requires a password, add `--ask-become-pass` or configure SSH keys.

Verify idempotency

1. Run the playbook once; you should see tasks with `changed=1` for items the playbook created or modified.
2. Run the same command again; properly idempotent modules will report `changed=0` on the second run (Ansible will skip changes if state already matches).

Example expected output snippets

- First run (sample): `TASK [Create demo file with stable content (idempotent)] *********** changed=1`
- Second run (sample): `TASK [Create demo file with stable content (idempotent)] *********** ok=1 changed=0`

Notes
- The `copy` and `package` modules used in this playbook are idempotent by design.
- Avoid including volatile data (timestamps, generated values) in module `content` or you will always get `changed` on every run.
- Use `ansible-playbook --check` for a dry-run (some modules do not support check mode fully).

Video demo checklist

- Show `ansible/playbooks/basic.yml` in the repo.
- Run the playbook once and capture output (show `changed=1` where appropriate).
- Run the playbook a second time and capture output (show `changed=0` on second run).
- Explain why modules used are idempotent and what to avoid to maintain idempotency.
