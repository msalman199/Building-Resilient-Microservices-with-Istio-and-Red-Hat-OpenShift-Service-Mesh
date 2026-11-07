#!/bin/bash

echo "Comprehensive Timeout and Retry Testing"
echo "======================================="

# Test 1: Normal operation
echo "Test 1: Normal operation (no delay, no failures)"
kubectl exec -n resilient-services test-client -- curl -s "http://delay-simulator:8080/?delay=0"
echo ""

# Test 2: Timeout scenario
echo "Test 2: Timeout scenario (5 second delay with 3 second timeout)"
start_time=$(date +%s)
kubectl exec -n resilient-services test-client -- curl -s -m 5 "http://delay-simulator:8080/?delay=5" || echo "Request timed out as expected"
end_time=$(date +%s)
echo "Total time: $((end_time - start_time)) seconds"
echo ""

# Test 3: Retry with failures
echo "Test 3: Retry scenario with transient failures"
for i in {1..5}; do
    echo -n "Attempt $i: "
    response=$(kubectl exec -n resilient-services test-client -- curl -s -w "%{http_code}" "http://failure-simulator:8080/?failure_rate=0.5" 2>/dev/null)
    echo "HTTP $response"
done
echo ""

# Test 4: Circuit breaker test
echo "Test 4: Circuit breaker behavior (high failure rate)"
echo "Sending 20 requests to trigger circuit breaker..."
success_count=0
failure_count=0

for i in {1..20}; do
    response=$(kubectl exec -n resilient-services test-client -- curl -s -w "%{http_code}" "http://failure-simulator:8080/?failure_rate=0.8" -o /dev/null 2>/dev/null)
    if [[ "$response" == "200" ]]; then
        ((success_count++))
    else
        ((failure_count++))
    fi
    echo -n "."
    sleep 0.5
done

echo ""
echo "Results: $success_count successes, $failure_count failures"
echo "Circuit breaker should have activated to prevent cascading failures"
