#!/bin/bash
echo "Starting normal load test..."
for i in {1..50}; do
  kubectl exec -it test-client -n circuit-breaker-demo -- curl -s -o /dev/null -w "%{http_code} " http://backend/status/200
  sleep 0.1
done
echo ""
echo "Normal load test completed"
