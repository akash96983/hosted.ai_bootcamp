# Failure Handling & Rollback

## Deploy with Automatic Rollback

```yaml
---
- name: Safe deployment
  hosts: servers
  tasks:
    - name: Backup current app
      shell: cp -r /opt/app /opt/app.backup

    - name: Deploy block
      block:
        - name: Copy new version
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

        - name: Success
          debug:
            msg: "✅ Deployment OK"

      rescue:
        - name: Rollback
          shell: |
            rm -rf /opt/app
            cp -r /opt/app.backup /opt/app

        - name: Restart with old version
          service:
            name: app
            state: restarted

        - name: Verify rollback
          uri:
            url: http://localhost:8080/health
            status_code: 200

        - name: Alert
          debug:
            msg: "⚠️ ROLLBACK: Previous version restored"

        - name: Fail
          fail:
            msg: "Deployment failed, rolled back"
```

## Key Points

✅ Backup before deploying  
✅ Fail-fast on health check failure  
✅ Automatic rollback on error  
✅ Verify rollback successful
