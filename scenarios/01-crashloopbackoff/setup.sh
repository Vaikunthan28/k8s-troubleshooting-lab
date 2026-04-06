#!/bin/bash
set -e
SCENARIO_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "==> Setting up scenario 01: CrashLoopBackOff"
kubectl create namespace lab --dry-run=client -o yaml | kubectl apply -f -
kubectl apply -f "$SCENARIO_DIR/manifests/broken/"

echo ""
echo "Deployed! Watch it crash:"
echo "  kubectl get pods -n lab -w"
echo ""
echo "Start investigating:"
echo "  kubectl describe pod -l app=payments-api -n lab"
echo "  kubectl logs -l app=payments-api -n lab"
