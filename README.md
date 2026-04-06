# K8s Troubleshooting Lab

A hands-on Kubernetes troubleshooting playground. Each scenario deploys a **broken** workload to a real local cluster using `kind`. Your job is to find the root cause and fix it using real `kubectl` commands — exactly like a production incident.

Built for DevOps engineers preparing for AU interviews and CKA exam practice.

---

## Prerequisites

| Tool | Install |
|------|---------|
| Docker | [docs.docker.com/get-docker](https://docs.docker.com/get-docker/) |
| kind | `brew install kind` or [kind.sigs.k8s.io](https://kind.sigs.k8s.io/) |
| kubectl | `brew install kubectl` |

---

## Quick start

```bash
# 1. Clone the repo
git clone https://github.com/YOUR_USERNAME/k8s-troubleshooting-lab.git
cd k8s-troubleshooting-lab

# 2. Create the local kind cluster (one time only)
chmod +x scripts/*.sh scenarios/**/*.sh
./scripts/init-cluster.sh

# 3. Pick a scenario and deploy the broken state
cd scenarios/01-crashloopbackoff
./setup.sh

# 4. Investigate using kubectl
kubectl get pods -n lab
kubectl describe pod -n lab <pod-name>
kubectl logs -n lab <pod-name>

# 5. Fix the issue, then verify
./verify.sh

# 6. Reset between scenarios
cd ../../ && ./scripts/reset-cluster.sh
```

---

## Scenarios

| # | Scenario | Difficulty | Category |
|---|----------|-----------|----------|
| 01 | [CrashLoopBackOff — missing ConfigMap & Secret](./scenarios/01-crashloopbackoff/) | Easy | Config / Env |
| 02 | [OOMKilled — memory limit too low](./scenarios/02-oomkilled/) | Easy | Resources |
| 03 | [Pending pod — PVC StorageClass mismatch](./scenarios/03-pending-pvc/) | Medium | Storage |
| 04 | [ImagePullBackOff — bad image tag](./scenarios/04-imagepullbackoff/) | Easy | Image |
| 05 | [RBAC — service account missing permissions](./scenarios/05-rbac/) | Medium | Security |
| 06 | [Network Policy — traffic blocked between pods](./scenarios/06-network-policy/) | Hard | Networking |

---

## How each scenario is structured

```
scenarios/XX-name/
├── README.md           ← Situation, symptoms, hints (NO solution here)
├── setup.sh            ← Deploys the broken manifests into the cluster
├── verify.sh           ← Validates your fix programmatically
└── manifests/
    ├── broken/         ← What gets deployed (the broken state)
    └── solution/       ← The fix — only look after you've genuinely tried!
```

---

## Useful kubectl commands to get started

```bash
# See what's running
kubectl get pods -n lab
kubectl get all -n lab

# Understand why a pod is failing
kubectl describe pod <pod-name> -n lab
kubectl logs <pod-name> -n lab
kubectl logs <pod-name> -n lab --previous

# Check events (sorted by time — very useful!)
kubectl get events -n lab --sort-by='.lastTimestamp'

# Inspect a resource as full YAML
kubectl get pod <pod-name> -n lab -o yaml

# Test connectivity from inside a pod
kubectl exec -it <pod-name> -n lab -- sh

# Check RBAC permissions
kubectl auth can-i list pods --as=system:serviceaccount:lab:my-sa -n lab
```

---

## Contributing

PRs welcome! To add a new scenario:
1. Copy `scenarios/01-crashloopbackoff/` as a template
2. Write a realistic broken manifest based on a real incident
3. Ensure `verify.sh` validates the fix programmatically (not just checks if pods are running)
4. Open a PR with `scenario:` prefix in the title

---

## Author

Built by [Vaikunthan Rajaratnam](https://linkedin.com/in/YOUR_PROFILE) — DevOps / Cloud Engineer, Sydney Australia.

AWS SAA | CKA | RHCSA
