#!/usr/bin/env bash
set -euo pipefail

BAD=0

need() {
  command -v "$1" >/dev/null 2>&1 || { echo "WARN: $1 not found" >&2; BAD=1; }
}

need ip
need ss
need ping
need traceroute || need tracepath
need dig || need nslookup
need curl || true

echo "=== Basic host info ==="
date
uname -a

echo "\n=== Interfaces and routes ==="
ip addr show || true
echo "\n--- routing table ---"
ip route show || true

echo "\n=== Listening services (tcp/udp) ==="
ss -tuln || true

echo "\n=== DNS resolution checks ==="
if command -v dig >/dev/null 2>&1; then
  echo "dig example.com (A records):"
  dig +short example.com
else
  echo "nslookup example.com:"
  nslookup example.com || true
fi

echo "\n=== Connectivity checks ==="
echo "Ping 8.8.8.8 (network reachability):"
ping -c 4 8.8.8.8 || true

echo "\nPing google.com (DNS + network):"
ping -c 4 google.com || true

echo "\n=== Traceroute (to show path) ==="
if command -v traceroute >/dev/null 2>&1; then
  traceroute -n -w 1 -q 1 google.com || true
elif command -v tracepath >/dev/null 2>&1; then
  tracepath google.com || true
else
  echo "(no traceroute/tracepath available)"
fi

echo "\n=== HTTP check (localhost:8080) ==="
if command -v curl >/dev/null 2>&1; then
  curl --max-time 5 -I http://localhost:8080 || true
else
  echo "(curl not available)"
fi

echo "\n=== Useful commands to run inside a pod for cluster debugging ==="
echo "kubectl run -it --rm dns-test --image=busybox --restart=Never -- nslookup kubernetes.default"
echo "kubectl exec -it <pod> -- cat /etc/resolv.conf"
echo "kubectl port-forward pod/<pod> 8080:80"

if [ "$BAD" -eq 1 ]; then
  echo "\nNote: some helper tools were missing — see WARN messages above." >&2
fi

exit 0
