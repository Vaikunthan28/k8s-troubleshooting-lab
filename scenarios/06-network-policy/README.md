# Scenario 06 — Network Policy: traffic blocked between pods

**Difficulty:** Hard | **Category:** Networking

---

## Situation

Your team recently applied a "default deny all" NetworkPolicy to the `lab` namespace as part of a security hardening initiative. Now the `api-server` pod cannot reach the `redis-cache` pod, breaking the application.

The devs say: *"It was working before the security team applied their policies."*

You need to create a targeted NetworkPolicy that allows only the necessary traffic while keeping the rest denied.

---

## Setup

```bash
./setup.sh
```

---

## Your starting point

```bash
kubectl get pods -n lab
kubectl get networkpolicy -n lab

# Test connectivity from api-server to redis
kubectl exec -it -n lab $(kubectl get pod -l app=api-server -n lab -o name | head -1) -- wget -qO- redis-cache:6379 --timeout=3 || echo "CONNECTION FAILED"
```

---

## Hints

<details>
<summary>Hint 1</summary>
Run `kubectl get networkpolicy -n lab -o yaml`. There's a default-deny policy blocking all ingress. You need to add a policy that explicitly allows traffic FROM api-server TO redis-cache on port 6379.
</details>

<details>
<summary>Hint 2</summary>
NetworkPolicies use label selectors. Check what labels api-server and redis-cache pods have: `kubectl get pods -n lab --show-labels`. Your policy needs to reference those labels.
</details>

<details>
<summary>Hint 3</summary>
You need TWO things: an egress rule on api-server allowing outbound to redis on 6379, AND an ingress rule on redis allowing inbound from api-server. Or a single policy with both. Think about which pod the policy applies to.
</details>

---

## Verify

```bash
./verify.sh
```
