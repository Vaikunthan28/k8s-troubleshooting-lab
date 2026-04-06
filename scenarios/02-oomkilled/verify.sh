#!/bin/bash
echo "==> Verifying scenario 02..."
PASS=true

RUNNING=$(kubectl get pods -n lab -l app=data-processor --no-headers 2>/dev/null | grep -c "Running" || true)
OOM=$(kubectl get pods -n lab -l app=data-processor --no-headers 2>/dev/null | grep -c "OOMKilled" || true)

if [ "$RUNNING" -ge 1 ]; then
  echo "    [PASS] data-processor pods are Running"
else
  echo "    [FAIL] No Running pods found — pods may still be restarting"
  PASS=false
fi

if [ "$OOM" -eq 0 ]; then
  echo "    [PASS] No OOMKilled pods"
else
  echo "    [FAIL] $OOM pod(s) still OOMKilled"
  PASS=false
fi

MEM_LIMIT=$(kubectl get deployment data-processor -n lab \
  -o jsonpath='{.spec.template.spec.containers[0].resources.limits.memory}' 2>/dev/null || echo "unknown")
echo "    Memory limit is now: $MEM_LIMIT"

echo ""
if [ "$PASS" = true ]; then
  echo "SUCCESS! Scenario 02 complete."
  echo ""
  echo "Interview talking point:"
  echo "  'The pods were OOMKilled — exit code 137 — because the memory limit"
  echo "   was set to 64Mi but the workload needed ~150MB. I identified this"
  echo "   by checking Last State in kubectl describe and correlating with"
  echo "   kubectl top pod. I increased the limit to 256Mi with 128Mi request"
  echo "   to give headroom, and recommended setting up VPA to right-size"
  echo "   resource limits automatically going forward.'"
else
  echo "Not fixed yet."
  echo ""
  echo "Tip: kubectl set resources deployment/data-processor -n lab \\"
  echo "       --limits=memory=256Mi --requests=memory=128Mi"
fi
