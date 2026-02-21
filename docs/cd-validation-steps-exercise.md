# CD Validation Steps

## Deploy with Validation

```yaml
---
- name: Deploy app
  hosts: servers
  tasks:
    - name: Copy app
      copy:
        src: app.jar
        dest: /opt/app/app.jar

    - name: Restart service
      service:
        name: app
        state: restarted

    - name: Health check
      uri:
        url: http://localhost:8080/health
        status_code: 200

    - name: Verify process
      shell: pgrep -f app.jar
      changed_when: false

    - name: Success
      debug:
        msg: "✅ App healthy"
```

## Why Ansible?

- Same validation everywhere (dev, staging, prod)
- Fails immediately if check fails
- Captures all outputs for debugging
- No manual steps to forget
