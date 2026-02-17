# Ansible Setup & Inventory

Purpose
- Install Ansible, create inventories with host/group definitions, establish SSH connectivity, and test with ad-hoc commands.

Prerequisites
- A control machine with Bash (Linux/macOS, or Windows via WSL/Git Bash).
- SSH access to managed nodes (public key auth recommended).
- Python 3 on control node (Ansible requires it).

Installing Ansible

- Ubuntu / Debian:

```bash
sudo apt update
sudo apt install -y software-properties-common
sudo add-apt-repository --yes --update ppa:ansible/ansible
sudo apt install -y ansible
ansible --version
```

- macOS (Homebrew):

```bash
brew update
brew install ansible
ansible --version
```

- Windows: Use WSL (Ubuntu) or a Linux VM and follow the Linux steps above. Avoid installing Ansible directly on Windows PowerShell.

Basic `ansible.cfg` recommendation (repo root)

```ini
[defaults]
inventory = ansible/inventory/hosts.ini
host_key_checking = False
# cache_plugin = 'memory'  # optional
# retry files: retry_files_enabled = False
```

Inventory formats
- INI-style (simple, widely used)
- YAML (structured, supports nested vars)

SSH connectivity
- Ensure you can SSH from the control machine to the managed node as the intended Ansible user:

```bash
ssh -i ~/.ssh/id_rsa ubuntu@web1.example.com
```

- If SSH uses a non-default key or user, include `ansible_ssh_private_key_file` and `ansible_user` in the inventory entries.

Ad-hoc testing commands
- Ping all hosts from repo root:

```bash
ansible all -m ping
```

- Run a command on the `web` group:

```bash
ansible web -m command -a "uptime"
```

- Gather facts from a host:

```bash
ansible web -m setup
```

Troubleshooting
- `UNREACHABLE` often means SSH/auth issues or wrong hostnames/ports.
- If `host_key_checking` blocks you, either accept the host key manually or set `host_key_checking = False` in `ansible.cfg` for CI/testing.

Testing idempotency and playbooks
- Use `ansible-playbook` to run plays and re-run them to verify idempotence.

CI integration
- Use the control machine or CI runner with SSH access (via bastion or ephemeral hosts) and run ad-hoc checks or playbooks as pipeline steps.
- Keep inventory and secrets out of VCS; use CI variables, Vault, or secret managers.

Video demo checklist for PR
1. Show installing Ansible on the control machine (or show `ansible --version`).
2. Show `ansible/inventory/hosts.ini` and `hosts.yml` files in the repo.
3. Demonstrate SSH connectivity to a managed node via `ssh -i ...`.
4. Run `ansible all -m ping` and one command against a group.
5. Show how to run an example playbook and re-run to show idempotence.
