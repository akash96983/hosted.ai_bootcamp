# Building App-Library-Style Roles Exercise

## Goal
Convert flat playbooks into reusable Ansible roles with proper structure, variables, and documentation.

---

## Role Directory Structure

```
roles/
  nginx/
    tasks/
      main.yml          # What tasks to run
    handlers/
      main.yml          # Handlers (restart service, reload, etc.)
    templates/
      nginx.conf.j2     # Config file template
    files/
      index.html        # Static files
    defaults/
      main.yml          # Default variables (lowest priority)
    vars/
      main.yml          # Role variables (higher priority)
    README.md           # Role documentation
```

---

## Exercise 1: Create Nginx Role Structure

**Step 1:** Create role directory
```bash
mkdir -p roles/nginx/{tasks,handlers,templates,defaults,vars,files}
```

**Step 2:** `roles/nginx/defaults/main.yml` - Default variables
```yaml
nginx_port: 80
nginx_user: www-data
nginx_worker_processes: 4
nginx_enable_https: no
nginx_ssl_cert: /etc/ssl/certs/nginx.crt
```

**Step 3:** `roles/nginx/tasks/main.yml` - Main tasks
```yaml
---
- name: Install nginx
  apt:
    name: nginx
    state: present

- name: Configure nginx
  template:
    src: nginx.conf.j2
    dest: /etc/nginx/nginx.conf
    mode: '0644'
  notify: Restart nginx

- name: Start nginx
  service:
    name: nginx
    state: started
    enabled: yes
```

**Step 4:** `roles/nginx/handlers/main.yml` - Handlers
```yaml
---
- name: Restart nginx
  service:
    name: nginx
    state: restarted

- name: Reload nginx
  service:
    name: nginx
    state: reloaded
```

**Step 5:** `roles/nginx/templates/nginx.conf.j2` - Template
```
user {{ nginx_user }};
worker_processes {{ nginx_worker_processes }};

events {
  worker_connections 1024;
}

http {
  server {
    listen {{ nginx_port }};
    server_name _;
    
    location / {
      root /var/www/html;
      index index.html;
    }
  }
}
```

**Step 6:** `roles/nginx/README.md` - Documentation
```markdown
# Nginx Role

Installs and configures Nginx web server.

## Variables

| Variable | Default | Description |
|----------|---------|-------------|
| nginx_port | 80 | Listening port |
| nginx_user | www-data | Nginx user |
| nginx_worker_processes | 4 | Worker processes |
| nginx_enable_https | no | Enable SSL |

## Example

\`\`\`yaml
- hosts: web
  roles:
    - role: nginx
      vars:
        nginx_port: 8080
        nginx_worker_processes: 2
\`\`\`

## Files

- `templates/nginx.conf.j2` - Main config template
- `files/index.html` - Static content
```

---

## Exercise 2: Use Role in Playbook

**Playbook:** `playbooks/deploy-web.yml`
```yaml
---
- name: Deploy web servers
  hosts: web
  roles:
    - role: nginx
      vars:
        nginx_port: 8080
        nginx_worker_processes: 2

    - role: ssl
      vars:
        ssl_cert_path: /etc/ssl/certs
```

**Run playbook:**
```bash
ansible-playbook -i inventory/hosts.ini playbooks/deploy-web.yml
```

---

## Exercise 3: Role with Variables & Defaults

**Role:** User management role

**`roles/user-management/defaults/main.yml`**
```yaml
users_list: []
user_home_dir: /home
user_shell: /bin/bash
user_groups: []
```

**`roles/user-management/tasks/main.yml`**
```yaml
---
- name: Create users
  user:
    name: "{{ item.name }}"
    home: "{{ user_home_dir }}/{{ item.name }}"
    shell: "{{ item.shell | default(user_shell) }}"
    groups: "{{ item.groups | default(user_groups) }}"
    state: present
  loop: "{{ users_list }}"
```

**Use in playbook:**
```yaml
---
- hosts: servers
  roles:
    - role: user-management
      vars:
        users_list:
          - name: alice
            groups: [sudo, docker]
          - name: bob
            shell: /bin/nologin
```

---

## Key Differences

| Before (Flat Playbook) | After (Role) |
|---|---|
| One big playbook file | Organized directories |
| Hardcoded values | Variables with defaults |
| No documentation | README explains usage |
| Not reusable | Use same role everywhere |
| Order matters | Auto-loads tasks/handlers |

---

## Role Priority (Low to High)

1. `defaults/main.yml` (lowest)
2. `group_vars/`
3. `host_vars/`
4. `vars/main.yml` (highest)

Later overrides earlier.

---

## Run Role Tests

```bash
# 1. Syntax check
ansible-playbook -i inventory/hosts.ini playbooks/deploy.yml --syntax-check

# 2. Dry run
ansible-playbook -i inventory/hosts.ini playbooks/deploy.yml --check

# 3. Run with verbose
ansible-playbook -i inventory/hosts.ini playbooks/deploy.yml -v

# 4. Run specific role only
ansible-playbook -i inventory/hosts.ini playbooks/deploy.yml --tags nginx
```

---

## Checklist for Role

- [ ] `tasks/main.yml` exists and is idempotent
- [ ] `defaults/main.yml` has sensible defaults
- [ ] `handlers/main.yml` for service restarts
- [ ] `templates/` for config files
- [ ] `files/` for static content
- [ ] `README.md` documents variables and usage
- [ ] Role can be reused in multiple playbooks
- [ ] Variables can be overridden from playbook

---

