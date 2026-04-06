#!/bin/bash
set -e

echo "==> Deleting 'lab' namespace to reset state..."
kubectl delete namespace lab --ignore-not-found

echo "==> Waiting for namespace to terminate..."
kubectl wait --for=delete namespace/lab --timeout=60s 2>/dev/null || true

echo ""
echo "Reset complete. Pick your next scenario and run ./setup.sh"
echo "To fully destroy the cluster: kind delete cluster --name k8s-lab"
