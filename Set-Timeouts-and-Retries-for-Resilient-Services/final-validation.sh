#!/bin/bash

echo "Final Validation of Resilience Configuration"
echo "============================================"

echo "1. Checking service health:"
kubectl get pods -n resilient-services
echo ""

echo "2. Testing timeout configuration:"
echo "   - Quick request (should succeed):"
kubectl exec -n resilient-services test-client -- curl -s -w "Time: %{time_total}s, Status: %{http_code}\n" "http://delay-simulator:8080/?delay=1" -o /dev/null

echo "   - Slow request (should timeout):"
kubectl exec -n resilient-services test-client -- curl -s -w "Time: %{time_total}s, Status: %{http_code}\n" "http://delay-simulator:8080/?delay=5" -o /dev/null

echo ""
echo "3. Testing retry configuration:"
success=0
total=10
for i in $(seq 1 $total); do
    response=$(kubectl exec -n resilient-services test-client -- curl -s -w "%{http_code}" "http://failure-simulator:8080/?failure_rate=0.4" -o /dev/null)
    if [[ "$response" == "200" ]]; then
        ((success++))
    fi
done
echo "   Success rate: $success/$total ($(( success * 100 / total ))%)"

echo ""
echo "4. Configuration summary:"
echo "   - Timeout: 3 seconds for delay-simulator"
echo "   - Retries: 3 attempts with 2s per-try timeout"
echo "   - Circuit breaker: 3 consecutive errors trigger ejection"
echo ""
echo "Validation complete!"
