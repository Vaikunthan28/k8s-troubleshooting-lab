# Scenario 02 — OOMKilled: memory limit too low

**Difficulty:** Easy | **Category:** Resources

---

## Situation

You're on-call. The `data-processor` deployment in `lab` keeps getting killed and restarting. It was fine for months. Recently the dataset it processes doubled in size after a new client onboarded.

The dev says: *"We didn't change anything in the deployment."*

---

## Setup

```bash
./setup.sh
```

---

## Your starting point

```bash
kubectl get pods -n lab -w
kubectl describe pod -l app=data-processor -n lab
kubectl logs -l app=data-processor -n lab --previous
```

Pay close attention to "Last State: Terminated" and the exit code.

---

## Hints

<details>
<summary>Hint 1 — click to reveal</summary>

In `kubectl describe pod`, check the `Last State` section. What is the `Reason` and what is the exit code? Exit code 137 = OOMKilled.

</details>

<details>
<summary>Hint 2 — click to reveal</summary>

Run `kubectl top pod -n lab` — how much memory is the pod actually using vs its limit? (metrics-server must be running)

</details>

<details>
<summary>Hint 3 — click to reveal</summary>

Edit the deployment to increase the memory limit: `kubectl edit deployment data-processor -n lab`

Or patch it: `kubectl set resources deployment/data-processor -n lab --limits=memory=256Mi --requests=memory=128Mi`

</details>

---

## Verify your fix

```bash
./verify.sh
```
