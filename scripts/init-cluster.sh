#!/bin/bash
set -e

echo "==> Checking prerequisites..."
for cmd in docker kind kubectl; do
  if ! command -v $cmd &>/dev/null; then
    echo "ERROR: '$cmd' is not installed. See README for install instructions."
    exit 1
  fi
done

echo "==> Creating kind cluster 'k8s-lab'..."
if kind get clusters 2>/dev/null | grep -q "^k8s-lab$"; then
  echo "    Cluster already exists — skipping creation."
else
  kind create cluster --config "$(dirname "$0")/../kind-config.yaml"
fi

echo "==> Setting kubectl context..."
kubectl cluster-info --context kind-k8s-lab

echo "==> Installing metrics-server (needed for HPA scenarios)..."
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
kubectl patch deployment metrics-server -n kube-system \
  --type='json' \
  -p='[{"op":"add","path":"/spec/template/spec/containers/0/args/-","value":"--kubelet-insecure-tls"}]'

echo ""
echo "============================================"
echo "  Cluster ready! Start your first scenario:"
echo "  cd scenarios/01-crashloopbackoff"
echo "  ./setup.sh"
echo "============================================"
