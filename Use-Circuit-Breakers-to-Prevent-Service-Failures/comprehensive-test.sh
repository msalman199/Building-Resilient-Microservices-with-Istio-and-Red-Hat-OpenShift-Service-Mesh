#!/bin/bash
echo "=== Comprehensive Circuit Breaker Test ==="
echo "Testing current configuration..."

echo "1. Testing consecutive errors threshold..."
for i in {1..5}; do
  response=$(kubectl exec -it test-client -n circuit-breaker-demo -- curl -s -o /dev/null -w "%{http_code}" http://backend/status/500)
  echo "Error test $i: HTTP $response"
  sleep 1
done

echo ""
echo "2. Testing recovery after errors..."
sleep 35  # Wait for ejection time
for i in {1..3}; do
  response=$(kubectl exec -it test-client -n circuit-breaker-demo -- curl -s -o /dev/null -w "%{http_code}" http://backend/status/200)
  echo "Recovery test $i: HTTP $response"
  sleep 1
done

echo ""
echo "3. Testing connection limits..."
for i in {1..12}; do
  kubectl exec -it test-client -n circuit-breaker-demo -- curl -s -o /dev/null -w "%{http_code} " http://backend/delay/1 &
done
wait
echo ""
echo "Comprehensive test completed"
