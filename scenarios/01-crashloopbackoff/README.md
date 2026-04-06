# Scenario 01 — CrashLoopBackOff: missing ConfigMap & Secret

**Difficulty:** Easy | **Category:** Config / Environment Variables

---

## Situation

You're on-call at a Sydney fintech. A developer just deployed a new version of `payments-api` to the `lab` namespace. Within 90 seconds Slack alerts fire — all 3 pods are crashing repeatedly.

The dev says: *"I didn't change the app code, just bumped the image tag and referenced a new config."*

---

## Setup

```bash
./setup.sh
```

---

## Your starting point

```bash
kubectl get pods -n lab
kubectl describe pod -l app=payments-api -n lab
kubectl logs -l app=payments-api -n lab
```

---

## Hints

<details>
<summary>Hint 1 — click to reveal</summary>

The app exits on startup. Check the logs — what environment variable is it failing to read?

</details>

<details>
<summary>Hint 2 — click to reveal</summary>

Look at the pod spec: `kubectl get pod -l app=payments-api -n lab -o yaml`

Check the `env` section. Is it referencing a `configMapKeyRef` or `secretKeyRef`?

</details>

<details>
<summary>Hint 3 — click to reveal</summary>

Run `kubectl get configmap -n lab` and `kubectl get secret -n lab`.

Compare what actually exists vs what the deployment references. What's missing?

</details>

---

## Verify your fix

```bash
./verify.sh
```

---

## Solution

Only look after you've genuinely tried → `manifests/solution/`
