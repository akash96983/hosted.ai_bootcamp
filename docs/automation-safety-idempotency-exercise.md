# Automation Safety & Idempotency Review Exercise

## Goal
Make playbooks safe to run multiple times without side effects, add validation checks, and prevent destructive operations.

---

## What is Idempotency?

**Idempotent:** Run 10 times, same result every time. No errors, no duplicates, no damage.

**Not idempotent:** Creates duplicates or fails on second run.

```yaml
# NOT idempotent - creates duplicate entries
- name: Add line to file
  shell: echo "hello" >> /etc/config

# IDEMPOTENT - line added only once
- name: Add line to file
  lineinfile:
    path: /etc/config
    line: hello
    create: yes
```

---

## Exercise 1: Idempotent File Operations

**Playbook:** File operations that are safe to repeat

```yaml
---
- name: Idempotent File Operations
  hosts: localhost
  tasks:
    - name: Create directory (idempotent)
      file:
        path: /opt/app
        state: directory
        mode: '0755'

    - name: Copy file only if content changed
      copy:
        src: app.conf
        dest: /opt/app/app.conf
        backup: yes
      register: copy_result

    - name: Show if changed
      debug:
        msg: "File changed: {{ copy_result.changed }}"

    - name: Add line to file (idempotent)
      lineinfile:
        path: /opt/app/app.conf
        line: "DEBUG=true"
        state: present

    - name: Ensure permission (idempotent)
      file:
        path: /opt/app/app.conf
        mode: '0644'
        owner: root
```

**Why idempotent?** `file`, `copy`, `lineinfile` modules check state before changing. No duplicates.

---

## Exercise 2: Precondition Validation Checks

**Playbook:** Validate environment before making changes

```yaml
---
- name: Precondition Validation
  hosts: localhost
  tasks:
    - name: Check OS
      assert:
        that:
          - ansible_os_family in ['Debian', 'RedHat']
        fail_msg: "Only Linux supported"

    - name: Check available disk space
      assert:
        that:
          - ansible_mounts[0].size_available > 1000000000
        fail_msg: "Not enough disk space (need 1GB+)"
        success_msg: "Disk space OK"

    - name: Check if user exists
      getent:
        database: passwd
        key: appuser
        fail_key: no
      register: user_check

    - name: Only continue if user doesn't exist
      assert:
        that:
          - user_check.ansible_facts.getent_passwd is not defined
        fail_msg: "User appuser already exists"
        success_msg: "User appuser does not exist, safe to create"

    - name: Check if package installed
      shell: dpkg -l | grep nginx
      register: pkg_check
      failed_when: false
      changed_when: false

    - name: Skip if already installed
      debug:
        msg: "nginx already installed"
      when: pkg_check.rc == 0

    - name: Install only if not present
      apt:
        name: nginx
        state: present
      when: pkg_check.rc != 0
```

---

## Exercise 3: Safety Mechanisms - Dry Run

**Playbook:** Validate changes before applying

```yaml
---
- name: Safety with Dry Run
  hosts: localhost
  vars:
    run_mode: "{{ dry_run | default(true) }}"
  tasks:
    - name: Show execution mode
      debug:
        msg: "Running in {{ 'DRY RUN' if run_mode else 'APPLY' }} mode"

    - name: Install packages (with check mode)
      apt:
        name:
          - curl
          - git
        state: present
      check_mode: "{{ run_mode }}"
      register: pkg_result

    - name: Show what would change
      debug:
        msg: |
          Would change: {{ pkg_result.changed }}
          Packages: {{ pkg_result.stdout | default('check mode') }}

    - name: Apply only in apply mode
      apt:
        name: nginx
        state: present
      when: not run_mode
```

**Run dry run:**
```bash
ansible-playbook playbook.yml -e dry_run=true
```

**Run for real:**
```bash
ansible-playbook playbook.yml -e dry_run=false
```

---

## Exercise 4: Prevent Destructive Operations

**Playbook:** Add guards against accidental deletion

```yaml
---
- name: Destructive Operations Protection
  hosts: localhost
  vars:
    enable_destructive: false  # Default: safe
  tasks:
    - name: Require ALLOW_DELETE flag
      assert:
        that:
          - enable_destructive | bool
        fail_msg: "Destructive operations disabled. Set enable_destructive=true to proceed."
        success_msg: "Destructive operations enabled"

    - name: Delete stale files (protected)
      file:
        path: /tmp/oldfile
        state: absent
      when: enable_destructive | bool

    - name: Delete deployment (protected)
      kubernetes.core.k8s:
        state: absent
        kind: Deployment
        name: temp-app
      when: enable_destructive | bool

    - name: Drop database (protected)
      mysql_query:
        query: "DROP DATABASE IF EXISTS tempdb"
      when: enable_destructive | bool
```

**Safe by default:**
```bash
ansible-playbook playbook.yml  # No deletion happens
```

**Explicit deletion:**
```bash
ansible-playbook playbook.yml -e enable_destructive=true
```

---

## Exercise 5: State Validation Before & After

**Playbook:** Verify system state changed correctly

```yaml
---
- name: State Validation
  hosts: localhost
  tasks:
    - name: Get current state
      shell: |
        systemctl is-active nginx
      register: nginx_state_before
      failed_when: false
      changed_when: false

    - name: Show initial state
      debug:
        msg: "nginx status before: {{ nginx_state_before.stdout }}"

    - name: Start nginx
      service:
        name: nginx
        state: started
        enabled: yes

    - name: Verify state changed
      shell: |
        systemctl is-active nginx
      register: nginx_state_after
      failed_when: false
      changed_when: false

    - name: Validate service is running
      assert:
        that:
          - nginx_state_after.stdout == "active"
        fail_msg: "nginx failed to start"
        success_msg: "nginx is running"

    - name: Verify port listening
      shell: netstat -tlnp | grep nginx
      register: port_check
      failed_when: false
      changed_when: false

    - name: Confirm port 80 open
      assert:
        that:
          - port_check.rc == 0
        fail_msg: "nginx not listening on port 80"
        success_msg: "Port 80 is open"
```

---

## Exercise 6: Hardened Update Playbook

**Playbook:** Safe updates with multiple checks

```yaml
---
- name: Hardened Update Playbook
  hosts: localhost
  vars:
    service_name: nginx
    safe_mode: true
    allow_restart: false
  tasks:
    - name: Pre-flight checks
      block:
        - name: Is service running?
          service_facts:

        - name: Ensure service exists
          assert:
            that:
              - services[service_name] is defined
            fail_msg: "Service {{ service_name }} not found"

        - name: Backup current config
          copy:
            src: "/etc/{{ service_name }}/{{ service_name }}.conf"
            dest: "/etc/{{ service_name }}/{{ service_name }}.conf.backup.{{ ansible_date_time.iso8601_basic_short }}"
            remote_src: yes
          ignore_errors: yes

    - name: Validate configuration syntax
      block:
        - name: Test new config
          shell: "{{ service_name }} -t"
          register: config_test
          changed_when: false

        - name: Verify syntax OK
          assert:
            that:
              - config_test.rc == 0
            fail_msg: "Config syntax error: {{ config_test.stderr }}"
            success_msg: "Config syntax valid"

      rescue:
        - name: Restore backup on fail
          copy:
            src: "/etc/{{ service_name }}/{{ service_name }}.conf.backup.{{ ansible_date_time.iso8601_basic_short }}"
            dest: "/etc/{{ service_name }}/{{ service_name }}.conf"
            remote_src: yes

        - name: Fail playbook
          fail:
            msg: "Config update failed, restored backup"

    - name: Apply update safely
      copy:
        src: "{{ service_name }}.conf"
        dest: "/etc/{{ service_name }}/{{ service_name }}.conf"
        backup: yes
      register: config_update

    - name: Apply only if allowed
      service:
        name: "{{ service_name }}"
        state: restarted
      when: 
        - allow_restart | bool
        - config_update.changed

    - name: Warn in safe mode
      debug:
        msg: |
          Service restart skipped (safe_mode=true).
          To apply: ansible-playbook playbook.yml -e allow_restart=true
      when: safe_mode | bool
```

---

## Idempotency Checklist

| Check | What to do |
|-------|-----------|
| **Run twice** | Should succeed both times |
| **Check state before** | Use `register:` and `when:` |
| **Use smart modules** | `lineinfile`, `blockinfile`, `copy` not `shell` |
| **Backup data** | Use `backup: yes` before changes |
| **Validate after** | Assert correct state |
| **Handle errors** | Use rescue blocks |
| **Guard destructive ops** | Require explicit flag |

---

## Example: Before & After

**NOT Idempotent:**
```yaml
- name: Setup app
  shell: |
    mkdir -p /opt/app
    echo "config" >> /etc/app.conf
    systemctl restart app
```

**Idempotent:**
```yaml
- name: Setup app
  block:
    - name: Create directory
      file:
        path: /opt/app
        state: directory

    - name: Add config (safe)
      lineinfile:
        path: /etc/app.conf
        line: "config"
        create: yes

    - name: Restart service
      service:
        name: app
        state: restarted
      when: config_changed | default(false)
```

---

## Run Playbooks Safely

```bash
# 1. Check syntax
ansible-playbook playbook.yml --syntax-check

# 2. Dry run (no changes)
ansible-playbook playbook.yml --check

# 3. Show what changes
ansible-playbook playbook.yml --check -v

# 4. Run for real
ansible-playbook playbook.yml

# 5. Run again (should be idempotent)
ansible-playbook playbook.yml
```

**Safe playbook:** Produces same result on runs 1, 2, and 10.
