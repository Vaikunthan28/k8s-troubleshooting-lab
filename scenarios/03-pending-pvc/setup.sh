#!/bin/bash
set -e
SCENARIO_DIR="$(cd "$(dirname "$0")" && pwd)"
echo "==> Setting up scenario 03: Pending Pod / PVC StorageClass mismatch"
kubectl create namespace lab --dry-run=client -o yaml | kubectl apply -f -
kubectl apply -f "$SCENARIO_DIR/manifests/broken/"
echo ""
echo "Deployed. The pod will stay Pending indefinitely — it will never start."
echo ""
echo "Investigate:"
echo "  kubectl get pods -n lab"
echo "  kubectl get pvc -n lab"
echo "  kubectl describe pvc app-data-pvc -n lab"
echo "  kubectl get events -n lab --sort-by='.lastTimestamp'"
