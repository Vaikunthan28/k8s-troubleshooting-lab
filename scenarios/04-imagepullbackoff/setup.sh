#!/bin/bash
set -e
SCENARIO_DIR="$(cd "$(dirname "$0")" && pwd)"
echo "==> Setting up scenario 04: ImagePullBackOff"
kubectl create namespace lab --dry-run=client -o yaml | kubectl apply -f -
kubectl apply -f "$SCENARIO_DIR/manifests/broken/"
echo ""
echo "==> Deployed. Pods will enter ImagePullBackOff shortly."
echo "    kubectl get pods -n lab -w"
echo "    kubectl describe pod -l app=frontend -n lab"
