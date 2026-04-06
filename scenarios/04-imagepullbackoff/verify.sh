#!/bin/bash
echo "==> Verifying scenario 04 fix..."
PASS=true

RUNNING=$(kubectl get pods -n lab -l app=frontend --no-headers 2>/dev/null | grep -c "Running" || true)
IMGFAIL=$(kubectl get pods -n lab -l app=frontend --no-headers 2>/dev/null | grep -cE "ImagePullBackOff|ErrImagePull" || true)

if [ "$RUNNING" -ge 1 ]; then
  echo "    [PASS] frontend pods are Running"
else
  echo "    [FAIL] No Running frontend pods"
  PASS=false
fi

if [ "$IMGFAIL" -eq 0 ]; then
  echo "    [PASS] No ImagePullBackOff errors"
else
  echo "    [FAIL] $IMGFAIL pod(s) still in ImagePullBackOff"
  PASS=false
fi

IMAGE=$(kubectl get deployment frontend -n lab -o jsonpath='{.spec.template.spec.containers[0].image}' 2>/dev/null || echo "")
echo "    Image now set to: $IMAGE"

echo ""
if [ "$PASS" = true ]; then
  echo "SUCCESS! Scenario 04 solved."
  echo ""
  echo "Interview talking point:"
  echo "  'ImagePullBackOff meant the kubelet couldn't pull the image."
  echo "   I checked the Events in describe pod to get the exact registry error,"
  echo "   confirmed the tag didn't exist, and rolled back to the last known"
  echo "   good tag. In production I would also check the CI/CD pipeline to"
  echo "   understand why the image build/push step failed silently.'"
else
  echo "Not fixed yet."
  echo "Tip: kubectl set image deployment/frontend frontend=busybox:1.36 -n lab"
fi
