#!/bin/bash
set -e
SCENARIO_DIR="$(cd "$(dirname "$0")" && pwd)"
echo "==> Setting up scenario 05: RBAC"
kubectl create namespace lab --dry-run=client -o yaml | kubectl apply -f -
kubectl apply -f "$SCENARIO_DIR/manifests/broken/"
echo ""
echo "==> Deployed. Pod will run but log RBAC errors."
echo "    kubectl get pods -n lab"
echo "    kubectl logs -l app=audit-logger -n lab -f"
