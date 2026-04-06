#!/bin/bash
echo "==> Verifying scenario 01..."
PASS=true

RUNNING=$(kubectl get pods -n lab -l app=payments-api --no-headers 2>/dev/null | grep -c "Running" || true)
CRASH=$(kubectl get pods -n lab -l app=payments-api --no-headers 2>/dev/null | grep -c "CrashLoopBackOff" || true)

if [ "$RUNNING" -eq 3 ]; then
  echo "    [PASS] All 3 payments-api pods are Running"
else
  echo "    [FAIL] Expected 3 Running pods, found: $RUNNING"
  PASS=false
fi

if [ "$CRASH" -eq 0 ]; then
  echo "    [PASS] No CrashLoopBackOff pods"
else
  echo "    [FAIL] $CRASH pod(s) still in CrashLoopBackOff"
  PASS=false
fi

kubectl get configmap payments-config -n lab &>/dev/null \
  && echo "    [PASS] ConfigMap 'payments-config' exists" \
  || { echo "    [FAIL] ConfigMap 'payments-config' missing"; PASS=false; }

kubectl get secret payments-secrets -n lab &>/dev/null \
  && echo "    [PASS] Secret 'payments-secrets' exists" \
  || { echo "    [FAIL] Secret 'payments-secrets' missing"; PASS=false; }

echo ""
if [ "$PASS" = true ]; then
  echo "SUCCESS! Scenario 01 complete."
  echo ""
  echo "Interview talking point:"
  echo "  'The pods were in CrashLoopBackOff because the deployment referenced"
  echo "   a ConfigMap and Secret that hadn't been created yet — a common"
  echo "   ordering problem in CI/CD pipelines. I checked kubectl logs and"
  echo "   describe to find the missing refs, created the resources, and the"
  echo "   pods recovered automatically. Going forward I'd use an init container"
  echo "   or Helm hooks to enforce deployment ordering.'"
else
  echo "Not fixed yet — review the failures above."
  echo ""
  echo "Tip: kubectl apply -f manifests/solution/configmap-and-secret.yaml"
fi
