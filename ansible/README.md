# Ansible examples and ad-hoc commands

Quick commands (run from repo root):

```bash
# Ping all hosts using the INI inventory
ansible all -i ansible/inventory/hosts.ini -m ping

# Run uptime on web group
ansible web -i ansible/inventory/hosts.ini -m command -a "uptime"

# Gather facts (long output)
ansible web -i ansible/inventory/hosts.ini -m setup

# Use YAML inventory
ansible all -i ansible/inventory/hosts.yml -m ping

# Run a small playbook (example playbook not included in this repo)
ansible-playbook -i ansible/inventory/hosts.ini playbooks/site.yml
```

Notes
- Replace `example.com` hostnames with your hosts or use IPs.
- Ensure your SSH agent or `ansible_ssh_private_key_file` is set correctly.
