# Linux networking basics → how they map to Kubernetes (simple)

This short note maps basic Linux networking concepts to Kubernetes abstractions and gives a few example commands to inspect ports and DNS.

Key concepts
- TCP/IP & ports: processes listen on ports on an IP. In Kubernetes, a Pod has an IP; containers listen on ports inside the Pod.
- localhost (127.0.0.1): loopback on a host or inside a container. Pod-local localhost is different from node localhost.
- DNS: resolves names to IPs. Kubernetes provides cluster DNS (CoreDNS) for service name resolution.

Kubernetes mapping (high-level)
- Pod: like a process namespace with its own IP.
- Service (ClusterIP): virtual, cluster-wide stable IP that routes to Pod backends.
- NodePort / LoadBalancer: exposes service ports on the node or external LB.
- kube-proxy / CNI: handles routing and iptables/nft rules so traffic reaches Pods.

Quick inspection commands (run on Linux host where you have access to cluster and `kubectl`):

- Show pods and pod IPs:

```bash
kubectl get pods -o wide
```

- Show service and cluster IP/ports:

```bash
kubectl get svc
kubectl describe svc my-service
```

- Inspect DNS resolution from a pod:

```bash
kubectl run -it --rm dns-debug --image=busybox --restart=Never -- nslookup kubernetes.default
```

- Port-forward a pod (access pod port from localhost):

```bash
kubectl port-forward pod/<pod-name> 8080:80
# then open http://localhost:8080 on your host
```

- Check listening ports on a node (Linux):

```bash
ss -tuln | grep LISTEN
# or: sudo netstat -tuln
```

Traffic flow (simple):
1. Client → NodeIP:NodePort (or LoadBalancer) if exposed externally.
2. kube-proxy routes NodePort to Service (ClusterIP) endpoints.
3. Service forwards to one of the Pod IPs (backend).

Notes / next steps
- This is intentionally small. If you want, I can expand this into a full README with diagrams and a short demo script showing `kubectl port-forward` and `nslookup` recorded for a video.
