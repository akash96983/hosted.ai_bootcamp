# Linux Processes & Resource Awareness (Minimal submission)

## Goal
Provide a concise explanation connecting Linux process concepts to containers, plus two tiny example scripts that demonstrate inspecting processes and checking ports.

## Key concepts (brief)
- Process: an instance of a running program, identified by PID.
- PID namespace: Containers get a different PID namespace so PIDs inside a container may not match host PIDs; `init` inside container is PID 1 for that namespace.
- cgroups: Control resource allocation (CPU, memory, I/O) for processes; containers use cgroups to limit resources.
- Namespaces: Containers isolate process, network, mount, IPC, UTS, and user views from the host.

## How these map to containers
- Inside a container, `ps` shows processes in that container's PID namespace; the host can see all namespaces and PIDs.
- Killing PID inside the container affects that namespace; host may need to target host PID to affect processes from outside.
- Resource limits applied via cgroups affect containerized processes similarly to regular processes.

## What to demonstrate (minimal)
1. Inspect processes with `ps` and `top` (script provided).
2. Check which process is listening on a port with `ss`/`ss -ltnp` or `lsof -i` (script provided).
3. Short note for video demo: start a container, show `ps` inside container vs host, show PID differences and `ss` output.

## Scripts included
- `inspect-processes.sh` — run `ps` and a short `top` snapshot (non-interactive)
- `check-ports.sh` — show listening TCP ports and owning processes using `ss` and `lsof` if available

## Demo instructions (for the video)
1. Start a sample container (e.g., `docker run -d --name demo-nginx -p 8080:80 nginx`).
2. Inside container: `docker exec -it demo-nginx ps aux` and note PID 1 is the container init.
3. On host: `ps aux | grep nginx` and `ss -ltnp | grep 8080` to show host process owning the port mapping.
4. Mention PID namespaces and cgroups briefly and show `cat /proc/<PID>/cgroup` for a process.

## Files
- `inspect-processes.sh` (executable)
- `check-ports.sh` (executable)

"""
Minimal submission ready for mentor evaluation.
