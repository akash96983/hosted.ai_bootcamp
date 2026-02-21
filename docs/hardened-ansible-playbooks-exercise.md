# Hardened Ansible Playbooks

## Safety Checks Before Deploy

```yaml
---
- name: Deploy safely
  hosts: servers
  tasks:
    - name: Check environment
      assert:
        that:
          - ansible_os_family in ['Debian', 'RedHat']
          - ansible_memtotal_mb > 512
          - ansible_mounts[0].size_available > 1000000000
        fail_msg: "❌ Env check failed: OS, memory, or disk"

    - name: Deploy app
      copy:
        src: app.jar
        dest: /opt/app/app.jar

    - name: Health check
      uri:
        url: http://localhost:8080/health
        status_code: 200
```

## Block Unsafe Production Deploy

```yaml
- name: Deploy to prod
  hosts: servers
  vars:
    approved: "{{ enable_deploy | default(false) }}"
  tasks:
    - name: Require approval for prod
      assert:
        that:
          - approved | bool
        fail_msg: "❌ BLOCKED: Run with -e enable_deploy=true"

    - name: Deploy
      copy:
        src: app.jar
        dest: /opt/app/app.jar
```

**Run:** 
```bash
ansible-playbook deploy.yml -e enable_deploy=true
```

## Helpful Error Messages

```yaml
- name: Deploy with guidance
  hosts: servers
  tasks:
    - name: Deploy
      block:
        - copy:
            src: app.jar
            dest: /opt/app/app.jar
      rescue:
        - fail:
            msg: |
              ❌ Deploy failed
              Check: journalctl -u app | tail -20
              Fix: See logs above, retry
```
