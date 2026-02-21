# Running Ansible from CI

## GitHub Actions Workflow

**Create `.github/workflows/deploy.yml`:**

```yaml
name: Deploy

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: Install Ansible
        run: sudo apt-get install -y ansible

      - name: Setup SSH key
        run: |
          mkdir -p ~/.ssh
          echo "${{ secrets.DEPLOY_KEY }}" > ~/.ssh/id_rsa
          chmod 600 ~/.ssh/id_rsa
          ssh-keyscan -H ${{ secrets.HOST_IP }} >> ~/.ssh/known_hosts 2>/dev/null

      - name: Run playbook
        run: |
          ansible-playbook -i inventory/hosts.ini playbooks/deploy.yml \
            --user ubuntu --key-file ~/.ssh/id_rsa -v

      - name: Cleanup
        if: always()
        run: rm ~/.ssh/id_rsa
```

## Add GitHub Secrets

Go to: Repo → Settings → Secrets → New secret

| Name | Value |
|------|-------|
| DEPLOY_KEY | SSH private key |
| HOST_IP | Server IP address |

## Run Command

```bash
ansible-playbook -i inventory/hosts.ini playbooks/deploy.yml -v
```
