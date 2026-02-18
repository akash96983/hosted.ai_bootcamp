# Ansible System Configuration Exercise

## Goal
Write Ansible playbooks to manage Linux systems safely (users, packages, services, files) with error handling and idempotency.

---

## Exercise 1: User Management

**Playbook:** Create users and groups idempotently

```yaml
---
- name: User Management
  hosts: localhost
  become: yes
  tasks:
    - name: Create group
      group:
        name: devops
        state: present

    - name: Create user
      user:
        name: john
        group: devops
        home: /home/john
        shell: /bin/bash
        state: present

    - name: Add user to sudo group
      user:
        name: john
        groups: sudo
        append: yes
```

**Why idempotent?** Running twice does the same thing—doesn't fail if user exists.

**Test:**
```bash
ansible-playbook playbooks/01-users.yml
ansible-playbook playbooks/01-users.yml  # Run again, should be OK
```

---

## Exercise 2: Package Management

**Playbook:** Install and update packages safely

```yaml
---
- name: Package Management
  hosts: localhost
  become: yes
  tasks:
    - name: Update package cache
      apt:
        update_cache: yes
        cache_valid_time: 3600

    - name: Install packages
      apt:
        name:
          - curl
          - git
          - vim
        state: present

    - name: Install with validation
      apt:
        name: nginx
        state: present
      register: install_result

    - name: Show install result
      debug:
        msg: "{{ install_result }}"
```

**Error handling:**
```yaml
    - name: Install with error handling
      apt:
        name: nginx
        state: present
      ignore_errors: yes
      register: pkg_result

    - name: Fail if critical error
      fail:
        msg: "Failed to install nginx"
      when: pkg_result.rc != 0 and pkg_result.rc != 100
```

---

## Exercise 3: Service Management

**Playbook:** Start, stop, enable services

```yaml
---
- name: Service Management
  hosts: localhost
  become: yes
  tasks:
    - name: Start nginx
      service:
        name: nginx
        state: started
        enabled: yes

    - name: Check service status
      service_facts:

    - name: Show nginx status
      debug:
        msg: "nginx state: {{ services['nginx'].state }}"

    - name: Restart service
      service:
        name: nginx
        state: restarted
      when: some_config_changed | default(false)
```

---

## Exercise 4: File Operations

**Playbook:** Create, modify, manage files and permissions

```yaml
---
- name: File Operations
  hosts: localhost
  become: yes
  tasks:
    - name: Create directory
      file:
        path: /opt/myapp
        state: directory
        mode: '0755'
        owner: john
        group: devops

    - name: Create config file from template
      template:
        src: config.j2
        dest: /opt/myapp/config.conf
        mode: '0644'
        owner: john
        group: devops
      notify: restart app

    - name: Ensure file exists
      file:
        path: /opt/myapp/data.txt
        state: touch
        mode: '0644'

    - name: Copy file only if changed
      copy:
        src: files/app.conf
        dest: /opt/myapp/app.conf
        owner: john
        backup: yes
      register: copy_result

    - name: Show if file changed
      debug:
        msg: "File changed: {{ copy_result.changed }}"
```

---

## Exercise 5: Error Handling & Validation

**Playbook:** Handle errors and validate success

```yaml
---
- name: Error Handling
  hosts: localhost
  become: yes
  tasks:
    - name: Task with error handling
      block:
        - name: Install package
          apt:
            name: somepackage
            state: present
          register: result

        - name: Show result
          debug:
            msg: "Installed: {{ result.changed }}"

      rescue:
        - name: Handle error
          debug:
            msg: "Install failed, trying alternative"

      always:
        - name: Cleanup
          debug:
            msg: "Cleanup code here"

    - name: Validate system state
      assert:
        that:
          - ansible_os_family == "Debian"
          - ansible_memtotal_mb > 512
        fail_msg: "System does not meet requirements"
        success_msg: "System meets requirements"
```

---

## Key Concepts

| Concept | Meaning |
|---------|---------|
| **Idempotent** | Run playbook 10 times, same result every time |
| **Handlers** | Triggered actions (e.g., restart service if config changes) |
| **Register** | Save command output to variable |
| **When** | Conditional task execution |
| **Block/Rescue/Always** | Try-catch-finally in Ansible |
| **Become** | Run as root (sudo) |

---

## Running Your Playbooks

```bash
# Syntax check
ansible-playbook playbooks/01-users.yml --syntax-check

# Dry run (show what would happen)
ansible-playbook playbooks/01-users.yml --check

# Run with verbose output
ansible-playbook playbooks/01-users.yml -v

# Run specific task by tag
ansible-playbook playbooks/01-users.yml --tags "create-user"
```

---

## Example Inventory

Create `inventory/local.ini`:
```ini
[local]
localhost ansible_connection=local
```

Run:
```bash
ansible-playbook -i inventory/local.ini playbooks/01-users.yml
```

---

## What to Check in Your Playbooks

1. **Idempotency** — Run twice, no errors second time
2. **Error handling** — Handle failed tasks gracefully
3. **Validation** — Check system state before/after
4. **Handlers** — Restart services only when config changes
5. **Become** — Correct privilege escalation
6. **Documentation** — Comments explaining what each task does
