# Scenario 03 — Pending Pod: PVC StorageClass mismatch

**Difficulty:** Medium | **Category:** Storage / PVC

---

## Situation

The `postgres-db` deployment in the `lab` namespace has been Pending for 10 minutes. No pod has ever started — it's stuck before even attempting to pull an image.

An engineer provisioned a PVC referencing a `fast-ssd` StorageClass from your old on-prem cluster. That StorageClass was never created in the new cloud environment.

---

## Setup

```bash
./setup.sh
```

---

## Your starting point

```bash
kubectl get pods -n lab
kubectl get pvc -n lab
kubectl describe pod -l app=postgres-db -n lab
kubectl describe pvc app-data-pvc -n lab
kubectl get events -n lab --sort-by='.lastTimestamp'
```

---

## Hints

<details>
<summary>Hint 1 — click to reveal</summary>

A pod stuck in Pending means the scheduler can't place it. The most common reasons are: no nodes have enough resources, a NodeSelector/Taint mismatch, or a required volume can't be provisioned. Check events first.

</details>

<details>
<summary>Hint 2 — click to reveal</summary>

Check the PVC status: `kubectl get pvc -n lab`

If the PVC is also in Pending state, the pod can't start until the PVC is Bound. Look at `kubectl describe pvc app-data-pvc -n lab` — what does it say about provisioning?

</details>

<details>
<summary>Hint 3 — click to reveal</summary>

Run `kubectl get storageclass` to see what StorageClasses actually exist in this cluster. Compare to what the PVC is requesting. In `kind`, the default StorageClass is `standard`.

To fix: delete the old PVC and recreate it with the correct StorageClass.

</details>

---

## Verify your fix

```bash
./verify.sh
```
