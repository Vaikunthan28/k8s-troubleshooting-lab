#!/bin/bash
echo "==> Verifying scenario 03 fix..."
PASS=true

# Check PVC is Bound
PVC_STATUS=$(kubectl get pvc app-data-pvc -n lab -o jsonpath='{.status.phase}' 2>/dev/null || echo "NotFound")
if [ "$PVC_STATUS" = "Bound" ]; then
  echo "    [PASS] PVC 'app-data-pvc' is Bound"
else
  echo "    [FAIL] PVC status is: $PVC_STATUS (expected: Bound)"
  echo "           Run: kubectl describe pvc app-data-pvc -n lab"
  PASS=false
fi

# Check pod is Running
RUNNING=$(kubectl get pods -n lab -l app=postgres-db --no-headers 2>/dev/null | grep -c "Running" || true)
if [ "$RUNNING" -ge 1 ]; then
  echo "    [PASS] postgres-db pod is Running"
else
  echo "    [FAIL] postgres-db pod is not Running yet"
  echo "           Run: kubectl get pods -n lab"
  PASS=false
fi

# Check StorageClass used
SC=$(kubectl get pvc app-data-pvc -n lab -o jsonpath='{.spec.storageClassName}' 2>/dev/null || echo "")
echo "    StorageClass used: $SC"

echo ""
if [ "$PASS" = true ]; then
  echo "SUCCESS! Scenario 03 solved."
  echo ""
  echo "Interview talking point:"
  echo "  'A pod was stuck Pending because its PVC referenced a StorageClass"
  echo "   that didn't exist in the cluster. I used kubectl describe pvc and"
  echo "   kubectl get storageclass to identify the mismatch, then patched"
  echo "   the PVC to use the correct StorageClass. In production I'd also"
  echo "   set a default StorageClass and add this check to our CI/CD validation.'"
else
  echo "Not fixed yet."
  echo "Tip: Delete the PVC and redeploy with storageClassName: standard"
  echo "     kubectl delete pvc app-data-pvc -n lab"
  echo "     kubectl apply -f manifests/solution/pvc.yaml"
fi
