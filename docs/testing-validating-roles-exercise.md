# Testing & Validating Reusable Roles Exercise

## Goal
Test roles across different scenarios, configs, and environments. Document results.

---

## Test 1: Syntax & Lint Check

**Validate playbook syntax:**
```bash
ansible-playbook playbooks/test-nginx.yml --syntax-check
```

**Lint roles (find issues):**
```bash
ansible-lint roles/nginx/
```

**Output:** Should show no errors.

---

## Test 2: Dry Run (Check Mode)

**Test without making changes:**
```bash
ansible-playbook playbooks/test-nginx.yml --check
```

**What it shows:** What tasks would run, no actual changes.

---

## Test 3: Run on Different OS

**Test on Debian/Ubuntu:**
```yaml
---
- hosts: debian_servers
  roles:
    - nginx
```

**Test on RHEL/CentOS:**
```yaml
---
- hosts: rhel_servers
  roles:
    - nginx
```

**Document:** Which OS versions work, which don't.

---

## Test 4: Different Variable Configs

**Config 1 - Default:**
```yaml
- hosts: servers
  roles:
    - nginx
```

**Config 2 - Custom port:**
```yaml
- hosts: servers
  roles:
    - role: nginx
      vars:
        nginx_port: 8080
```

**Config 3 - HTTPS enabled:**
```yaml
- hosts: servers
  roles:
    - role: nginx
      vars:
        nginx_enable_https: yes
        nginx_ssl_cert: /etc/ssl/certs/server.crt
```

**Document:** All configs work correctly.

---

## Test 5: Idempotency Test

**Run playbook twice:**
```bash
# First run
ansible-playbook playbooks/test-nginx.yml

# Second run - should be identical
ansible-playbook playbooks/test-nginx.yml
```

**Check output:**
- Second run shows `changed=0`
- No errors on second execution
- Same result both times

**Pass:** ✅ Idempotent  
**Fail:** ❌ Created duplicates or errors

---

## Test 6: Environment Variations

**Test in different environments:**

| Environment | Variables | Notes |
|---|---|---|
| Dev | nginx_port: 8080, small worker count | Quick, minimal |
| Staging | nginx_port: 80, medium worker count | Close to prod |
| Prod | nginx_port: 80, large worker count, HTTPS | High perf |

**Playbook:**
```yaml
---
- hosts: "{{ target_env }}"
  roles:
    - role: nginx
      vars:
        nginx_port: "{{ env_nginx_port }}"
        nginx_worker_processes: "{{ env_worker_count }}"
```

**Run:**
```bash
ansible-playbook test.yml -e target_env=dev
ansible-playbook test.yml -e target_env=staging
ansible-playbook test.yml -e target_env=prod
```

---

## Test 7: Error Handling

**Test missing prerequisites:**
```yaml
- name: Test error handling
  hosts: servers
  tasks:
    - name: Verify package manager exists
      assert:
        that:
          - ansible_os_family in ['Debian', 'RedHat']
        fail_msg: "Unsupported OS"
```

**Test failure recovery:**
```bash
# Run on wrong OS - should fail gracefully
ansible-playbook playbooks/test-nginx.yml
```

**Document:** Error messages are clear, no corruption.

---

## Test 8: Multiple Executions

**Simulate repeated deployments:**
```bash
for i in {1..5}; do
  echo "=== Run $i ==="
  ansible-playbook playbooks/deploy.yml
done
```

**Expected:** Same result all 5 times, no duplicates.

---

## Test Results Document

**Create `TESTING_RESULTS.md`:**

```markdown
# Role Testing Results

## Test Coverage

| Test | Status | Notes |
|------|--------|-------|
| Syntax Check | ✅ PASS | No errors |
| Lint | ✅ PASS | 0 warnings |
| Dry Run | ✅ PASS | Correct tasks shown |
| Ubuntu 20.04 | ✅ PASS | All tasks successful |
| Ubuntu 22.04 | ✅ PASS | All tasks successful |
| CentOS 8 | ✅ FAIL | Different package names |
| Default vars | ✅ PASS | nginx_port: 80 works |
| Custom port | ✅ PASS | nginx_port: 8080 works |
| HTTPS enabled | ✅ PASS | Certs configured |
| Idempotent x5 | ✅ PASS | changed=0 all runs |
| Dev environment | ✅ PASS | 8080 port, 2 workers |
| Prod environment | ✅ PASS | 80 port, 4 workers |
| Error: no curl | ✅ PASS | Failed gracefully |

## Summary

- **8/12 scenarios passing** (67% coverage)
- **Known issue:** CentOS needs different package names
- **Action:** Update role for yum package manager

## Next Steps

1. Fix CentOS support
2. Add 4 more scenarios
3. Retest and update results
```

---

## Quick Test Script

**Create `test-role.sh`:**
```bash
#!/bin/bash

ROLE=$1
ENV=$2

echo "Testing $ROLE in $ENV..."

# 1. Syntax check
ansible-playbook -i inventory/$ENV playbooks/test-$ROLE.yml --syntax-check
if [ $? -ne 0 ]; then echo "FAIL: Syntax"; exit 1; fi

# 2. Dry run
ansible-playbook -i inventory/$ENV playbooks/test-$ROLE.yml --check
if [ $? -ne 0 ]; then echo "FAIL: Dry run"; exit 1; fi

# 3. First execution
ansible-playbook -i inventory/$ENV playbooks/test-$ROLE.yml
if [ $? -ne 0 ]; then echo "FAIL: First run"; exit 1; fi

# 4. Second execution (idempotency)
ansible-playbook -i inventory/$ENV playbooks/test-$ROLE.yml
if [ $? -ne 0 ]; then echo "FAIL: Idempotency"; exit 1; fi

echo "✅ All tests PASSED for $ROLE in $ENV"
```

**Run:**
```bash
bash test-role.sh nginx dev
bash test-role.sh nginx prod
bash test-role.sh user-mgmt staging
```

---

## Testing Checklist

- [ ] Syntax check passes
- [ ] Lint has no critical errors
- [ ] Dry run shows correct tasks
- [ ] Works on all target OS versions
- [ ] Works with default variables
- [ ] Works with custom variables
- [ ] Idempotent (run twice, same result)
- [ ] Works in all target environments
- [ ] Handles errors gracefully
- [ ] Documentation complete
