# Scenario 05 — RBAC: service account missing permissions

**Difficulty:** Medium | **Category:** Security / RBAC

---

## Situation

The `audit-logger` app in the `lab` namespace is supposed to watch all pods across the cluster and write an audit log. It has been running for weeks. After a security team review, they deleted some ClusterRoleBindings they thought were unused.

Now the app logs show: `Error: pods is forbidden: User "system:serviceaccount:lab:audit-sa" cannot list resource "pods"`.

---

## Setup

```bash
./setup.sh
```

---

## Your starting point

```bash
kubectl get pods -n lab
kubectl logs -l app=audit-logger -n lab
kubectl get serviceaccount -n lab
kubectl get clusterrolebinding | grep audit
```

---

## Hints

<details>
<summary>Hint 1</summary>
The app is Running but erroring in logs — RBAC issues don't crash pods, they produce permission denied errors at runtime. Check `kubectl logs` carefully.
</details>

<details>
<summary>Hint 2</summary>
Check what ServiceAccount the pod uses: `kubectl get pod <name> -n lab -o yaml | grep serviceAccountName`. Then check what roles are bound to it: `kubectl get clusterrolebinding -o yaml | grep audit-sa`
</details>

<details>
<summary>Hint 3</summary>
The ServiceAccount `audit-sa` exists but has no ClusterRoleBinding. You need to create one that grants `list` and `watch` on `pods` across all namespaces. Should this be a Role or ClusterRole? Why?
</details>

---

## Verify

```bash
./verify.sh
```
