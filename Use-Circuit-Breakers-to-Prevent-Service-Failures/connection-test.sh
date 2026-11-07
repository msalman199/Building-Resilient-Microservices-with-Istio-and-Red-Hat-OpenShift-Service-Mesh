#!/bin/bash
echo "Testing connection pool limits..."
for i in {1..15}; do
  kubectl exec -it test-client -n circuit-breaker-demo -- curl -s -o /dev/null -w "%{http_code} " http://backend/delay/2 &
done
wait
echo ""
echo "Connection test completed"
