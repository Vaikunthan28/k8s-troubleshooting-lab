#!/bin/bash
echo "==> Verifying scenario 06 fix..."
PASS=true

# Check NetworkPolicy count - should be more than just the default deny
NP_COUNT=$(kubectl get networkpolicy -n lab --no-headers 2>/dev/null | wc -l | tr -d ' ')
if [ "$NP_COUNT" -gt 1 ]; then
  echo "    [PASS] $NP_COUNT NetworkPolicies found (default-deny + your allow policy)"
else
  echo "    [FAIL] Only $NP_COUNT NetworkPolicy found — you need to add an allow policy"
  PASS=false
fi

# Test actual connectivity from api-server to redis
echo "    Testing live connectivity api-server -> redis-cache:6379..."
API_POD=$(kubectl get pod -l app=api-server -n lab -o name 2>/dev/null | head -1)
if [ -n "$API_POD" ]; then
  RESULT=$(kubectl exec -n lab "$API_POD" -- nc -zv redis-cache 6379 2>&1 || echo "FAILED")
  if echo "$RESULT" | grep -qiE "open|succeeded|connected"; then
    echo "    [PASS] api-server can reach redis-cache:6379"
  else
    echo "    [FAIL] api-server still cannot reach redis-cache:6379"
    echo "           Result: $RESULT"
    PASS=false
  fi
else
  echo "    [WARN] No api-server pod found to test"
fi

# Check api-server logs for Redis OK
REDIS_OK=$(kubectl logs -l app=api-server -n lab --tail=10 2>/dev/null | grep -c "Redis: OK" || true)
if [ "$REDIS_OK" -gt 0 ]; then
  echo "    [PASS] api-server logs show Redis: OK"
else
  echo "    [INFO] No 'Redis: OK' in recent logs yet — may take a moment"
fi

echo ""
if [ "$PASS" = true ]; then
  echo "SUCCESS! Scenario 06 solved."
  echo ""
  echo "Interview talking point:"
  echo "  'A default-deny NetworkPolicy blocked all pod-to-pod traffic after"
  echo "   a security hardening change. I identified the broken connectivity"
  echo "   using kubectl exec + nc to test the connection directly, then"
  echo "   created targeted ingress and egress NetworkPolicies using label"
  echo "   selectors to allow only the api-server -> redis traffic on port 6379."
  echo "   I also remembered to allow DNS (port 53) in the egress rule, which"
  echo "   is a common gotcha people miss.'"
else
  echo "Not fixed yet."
  echo "Tip: kubectl apply -f manifests/solution/allow-policy.yaml"
fi
