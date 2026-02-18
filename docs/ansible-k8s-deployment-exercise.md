# Ansible-Driven Kubernetes Deployment Exercise

## Goal
Use Ansible to deploy and manage Kubernetes manifests with verification, monitoring, and error handling.

---

## Exercise 1: Deploy Kubernetes Manifest

**Playbook:** Apply K8s manifests using Ansible

```yaml
---
- name: Deploy to Kubernetes
  hosts: localhost
  tasks:
    - name: Apply nginx deployment
      kubernetes.core.k8s:
        state: present
        definition: "{{ lookup('template', 'nginx-deployment.yaml.j2') }}"
        kubeconfig: ~/.kube/config
        context: docker-desktop
        namespace: default

    - name: Create service
      kubernetes.core.k8s:
        state: present
        definition:
          apiVersion: v1
          kind: Service
          metadata:
            name: nginx-service
            namespace: default
          spec:
            selector:
              app: nginx
            ports:
              - protocol: TCP
                port: 80
                targetPort: 80
            type: LoadBalancer
```

**Why Ansible?** Single place to deploy all manifests + immediate verification.

---

## Exercise 2: Monitor Rollout Progress

**Playbook:** Wait for deployment to finish before continuing

```yaml
---
- name: Deploy and Monitor
  hosts: localhost
  tasks:
    - name: Apply deployment
      kubernetes.core.k8s:
        state: present
        definition: "{{ lookup('file', 'nginx-deployment.yaml') }}"
        wait: yes
        wait_condition:
          type: Available
          status: "True"
        wait_sleep: 5
        wait_timeout: 300

    - name: Wait for rollout
      shell: |
        kubectl rollout status deployment/nginx-deployment -n default --timeout=5m
      register: rollout_status
      failed_when: rollout_status.rc != 0

    - name: Show rollout result
      debug:
        msg: "{{ rollout_status.stdout }}"
```

---

## Exercise 3: Health Check & Verification

**Playbook:** Verify deployment is healthy

```yaml
---
- name: Health Check
  hosts: localhost
  tasks:
    - name: Get pod status
      kubernetes.core.k8s_info:
        kind: Pod
        namespace: default
        label_selectors:
          - app=nginx
      register: pod_info

    - name: Check all pods running
      assert:
        that:
          - pod_info.resources | length > 0
          - pod_info.resources[0].status.phase == "Running"
        fail_msg: "Pods not running"
        success_msg: "All pods are running"

    - name: Check pod readiness
      assert:
        that:
          - pod_info.resources[0].status.conditions | selectattr('type', 'equalto', 'Ready') | map(attribute='status') | list | first == 'True'
        fail_msg: "Pod not ready"
        success_msg: "Pod is ready"

    - name: Get service endpoint
      kubernetes.core.k8s_info:
        kind: Service
        name: nginx-service
        namespace: default
      register: svc_info

    - name: Show service details
      debug:
        msg: |
          Service: {{ svc_info.resources[0].metadata.name }}
          Endpoints: {{ svc_info.resources[0].status.loadBalancer.ingress | default('pending') }}
```

---

## Exercise 4: Rolling Update with Validation

**Playbook:** Update image and validate each step

```yaml
---
- name: Rolling Update
  hosts: localhost
  tasks:
    - name: Get current image
      kubernetes.core.k8s_info:
        kind: Deployment
        name: nginx-deployment
        namespace: default
      register: current_deploy

    - name: Show current image
      debug:
        msg: "Current image: {{ current_deploy.resources[0].spec.template.spec.containers[0].image }}"

    - name: Update image
      kubernetes.core.k8s:
        state: present
        definition:
          apiVersion: apps/v1
          kind: Deployment
          metadata:
            name: nginx-deployment
            namespace: default
          spec:
            replicas: 3
            selector:
              matchLabels:
                app: nginx
            template:
              metadata:
                labels:
                  app: nginx
              spec:
                containers:
                  - name: nginx
                    image: nginx:1.21  # New version
                    ports:
                      - containerPort: 80

    - name: Wait for rollout
      shell: kubectl rollout status deployment/nginx-deployment -n default --timeout=5m
      register: rollout

    - name: Verify new image
      kubernetes.core.k8s_info:
        kind: Deployment
        name: nginx-deployment
        namespace: default
      register: updated_deploy

    - name: Confirm update
      assert:
        that:
          - updated_deploy.resources[0].spec.template.spec.containers[0].image == "nginx:1.21"
        fail_msg: "Image update failed"
        success_msg: "Image updated successfully"
```

---

## Exercise 5: Error Handling & Cleanup

**Playbook:** Handle failures and clean up on error

```yaml
---
- name: Deploy with Error Handling
  hosts: localhost
  vars:
    namespace: default
  tasks:
    - name: Deployment block
      block:
        - name: Apply manifests
          kubernetes.core.k8s:
            state: present
            definition: "{{ lookup('file', item) }}"
          loop:
            - nginx-deployment.yaml
            - nginx-service.yaml
          register: deploy_result

        - name: Verify deployment
          kubernetes.core.k8s_info:
            kind: Deployment
            name: nginx-deployment
            namespace: "{{ namespace }}"
          register: deploy_info
          until: deploy_info.resources[0].status.readyReplicas | default(0) == deploy_info.resources[0].spec.replicas
          retries: 10
          delay: 10

      rescue:
        - name: Deployment failed
          debug:
            msg: "Deployment failed, rolling back..."

        - name: Show error
          debug:
            msg: "{{ ansible_failed_result }}"

        - name: Cleanup failed deployment
          kubernetes.core.k8s:
            state: absent
            kind: Deployment
            name: nginx-deployment
            namespace: "{{ namespace }}"

      always:
        - name: Get final status
          kubernetes.core.k8s_info:
            kind: Deployment
            namespace: "{{ namespace }}"
          register: final_status

        - name: Show final results
          debug:
            msg: "Deployments: {{ final_status.resources | map(attribute='metadata.name') | list }}"
```

---

## Exercise 6: Scaling and Updates

**Playbook:** Scale replicas and manage updates

```yaml
---
- name: Scaling Operations
  hosts: localhost
  tasks:
    - name: Scale deployment
      kubernetes.core.k8s:
        state: present
        kind: Deployment
        namespace: default
        name: nginx-deployment
        definition:
          spec:
            replicas: 5

    - name: Wait for scaling
      kubernetes.core.k8s_info:
        kind: Deployment
        name: nginx-deployment
        namespace: default
      register: deploy_info
      until: deploy_info.resources[0].status.readyReplicas | default(0) == 5
      retries: 15
      delay: 10

    - name: Show ready pods
      debug:
        msg: "Ready replicas: {{ deploy_info.resources[0].status.readyReplicas }}"

    - name: Get running pods
      kubernetes.core.k8s_info:
        kind: Pod
        namespace: default
        label_selectors:
          - app=nginx
      register: pods

    - name: List pod names
      debug:
        msg: "Pods: {{ pods.resources | map(attribute='metadata.name') | list }}"
```

---

## Quick Reference

| Task | Module |
|------|--------|
| Apply manifest | `kubernetes.core.k8s` |
| Get resource info | `kubernetes.core.k8s_info` |
| Delete resource | `kubernetes.core.k8s` (state: absent) |
| Scale deployment | `kubernetes.core.k8s` with spec.replicas |
| Wait for condition | `kubernetes.core.k8s` with wait options |
| Shell commands | `shell` (for kubectl) |

---

## Setup

Install Kubernetes collection:
```bash
ansible-galaxy collection install kubernetes.core
```

Ensure kubeconfig is set:
```bash
export KUBECONFIG=~/.kube/config
kubectl cluster-info
```

---

## Running Playbooks

```bash
# Check syntax
ansible-playbook playbooks/deploy-k8s.yml --syntax-check

# Dry run
ansible-playbook playbooks/deploy-k8s.yml --check

# Run playbook
ansible-playbook playbooks/deploy-k8s.yml -v

# Verify deployment
kubectl get deployments -n default
kubectl get pods -n default
kubectl get services -n default
```

---

## Key Points

1. **Manifest Application** — Use `kubernetes.core.k8s` module to apply YAML
2. **Idempotency** — Safe to run multiple times
3. **Rollout Monitoring** — Wait for ready replicas before continuing
4. **Health Checks** — Assert pod status and readiness
5. **Error Handling** — Block/rescue for safe rollbacks
6. **Verification** — Confirm deployment state after each step
