#!/bin/bash
echo "==> Verifying scenario 05 fix..."
PASS=true

# Check ClusterRoleBinding exists for audit-sa
CRB=$(kubectl get clusterrolebinding -o json 2>/dev/null | \
  python3 -c "
import json,sys
data=json.load(sys.stdin)
for item in data.get('items',[]):
  for sub in item.get('subjects',[]):
    if sub.get('name')=='audit-sa' and sub.get('namespace')=='lab':
      print(item['metadata']['name'])
" 2>/dev/null || echo "")

if [ -n "$CRB" ]; then
  echo "    [PASS] ClusterRoleBinding found for audit-sa: $CRB"
else
  echo "    [FAIL] No ClusterRoleBinding found binding audit-sa to a ClusterRole"
  PASS=false
fi

# Check pod can list pods (check logs for success)
sleep 5
FORBIDDEN=$(kubectl logs -l app=audit-logger -n lab --tail=20 2>/dev/null | grep -c "forbidden" || true)
if [ "$FORBIDDEN" -eq 0 ]; then
  echo "    [PASS] No 'forbidden' errors in recent logs"
else
  echo "    [FAIL] Still seeing 'forbidden' in logs ($FORBIDDEN occurrences)"
  echo "           kubectl logs -l app=audit-logger -n lab --tail=20"
  PASS=false
fi

echo ""
if [ "$PASS" = true ]; then
  echo "SUCCESS! Scenario 05 solved."
  echo ""
  echo "Interview talking point:"
  echo "  'The pod was Running but failing at runtime with a permissions error."
  echo "   RBAC issues don'\''t prevent pods starting — they surface in app logs."
  echo "   I identified the missing ClusterRoleBinding using kubectl auth can-i"
  echo "   --as system:serviceaccount:lab:audit-sa and created the binding."
  echo "   I also recommended using least-privilege and auditing all CRBs"
  echo "   before deletion in future security reviews.'"
else
  echo "Not fixed yet."
  echo "Tip: kubectl apply -f manifests/solution/clusterrolebinding.yaml"
fi
