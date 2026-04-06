# Scenario 04 — ImagePullBackOff: bad image tag

**Difficulty:** Easy | **Category:** Image / Registry

---

## Situation

A junior dev on your team pushed a new deployment for the `frontend` app in the `lab` namespace. They updated the image tag to `v2.1.0` but the CI/CD pipeline that builds and pushes the image had already failed earlier — the image was never actually pushed to the registry.

The dev is insisting the image exists. Your job is to prove what's wrong and fix it.

---

## Setup

```bash
./setup.sh
```

---

## Your starting point

```bash
kubectl get pods -n lab
kubectl describe pod <pod-name> -n lab
```

Look at the Events section at the bottom of describe output carefully.

---

## Hints

<details>
<summary>Hint 1</summary>
ImagePullBackOff means the kubelet tried to pull the container image and failed. The Events section of `describe pod` will show the exact error from the container runtime.
</details>

<details>
<summary>Hint 2</summary>
Is the image name correct? Is the tag correct? Is the registry reachable? Run `kubectl get pod -o yaml` and check the `image` field under containers.
</details>

<details>
<summary>Hint 3</summary>
You can't push the missing image in this lab — instead, fix the deployment to use a valid existing tag. Check what tags are available: `busybox` has tags like `1.35`, `1.36`, `latest`.
</details>

---

## Verify

```bash
./verify.sh
```
