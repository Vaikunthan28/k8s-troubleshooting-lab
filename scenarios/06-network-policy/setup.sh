#!/bin/bash
set -e
SCENARIO_DIR="$(cd "$(dirname "$0")" && pwd)"
echo "==> Setting up scenario 06: Network Policy"
kubectl create namespace lab --dry-run=client -o yaml | kubectl apply -f -
kubectl apply -f "$SCENARIO_DIR/manifests/broken/"
echo ""
echo "==> Deployed with default-deny-all NetworkPolicy."
echo "    All pod-to-pod traffic in 'lab' namespace is now blocked."
echo ""
echo "    Check connectivity:"
echo "    kubectl exec -it -n lab \$(kubectl get pod -l app=api-server -n lab -o name | head -1) -- nc -zv redis-cache 6379"
echo ""
echo "    Check policies:"
echo "    kubectl get networkpolicy -n lab"
