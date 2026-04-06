#!/bin/bash
set -e
SCENARIO_DIR="$(cd "$(dirname "$0")" && pwd)"
echo "==> Setting up scenario 02: OOMKilled"
kubectl create namespace lab --dry-run=client -o yaml | kubectl apply -f -
kubectl apply -f "$SCENARIO_DIR/manifests/broken/"
echo ""
echo "Deployed. Pods will be OOMKilled shortly."
echo "  kubectl get pods -n lab -w"
echo "  kubectl describe pod -l app=data-processor -n lab"
