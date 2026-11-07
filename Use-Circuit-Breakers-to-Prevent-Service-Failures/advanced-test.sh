#!/bin/bash
echo "=== Advanced Circuit Breaker Testing ==="

echo "Test 1: Fast failure detection (2 consecutive errors)"
for i in {1..4}; do
  response=$(kubectl exec -it test-client -n circuit-breaker-demo -- curl -s -o /dev/null -w "%{http_code}" http://backend/status/500)
  echo "Fast failure $i: HTTP $response"
  if [ "$response" = "503" ]; then
    echo "Circuit breaker opened after $i errors"
    break
  fi
  sleep 0.5
done

echo ""
echo "Test 2: Quick recovery (15s ejection time)"
echo "Waiting 16 seconds for recovery..."
sleep 16

response=$(kubectl exec -it test-client -n circuit-breaker-demo -- curl -s -o /dev/null -w "%{http_code}" http://backend/status/200)
echo "Recovery test: HTTP $response"

echo ""
echo "Test 3: Higher connection capacity (20 connections)"
for i in {1..25}; do
  kubectl exec -it test-client -n circuit-breaker-demo -- curl -s -o /dev/null -w "%{http_code} " http://backend/delay/1 &
done
wait
echo ""

echo "Advanced testing completed"
