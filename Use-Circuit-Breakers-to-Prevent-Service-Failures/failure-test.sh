#!/bin/bash
echo "Testing circuit breaker with 500 errors..."
for i in {1..20}; do
  response=$(kubectl exec -it test-client -n circuit-breaker-demo -- curl -s -o /dev/null -w "%{http_code}" http://backend/status/500)
  echo "Request $i: HTTP $response"
  sleep 0.5
done
