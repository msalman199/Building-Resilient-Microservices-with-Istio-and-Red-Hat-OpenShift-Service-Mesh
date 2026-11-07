#!/bin/bash

echo "Testing failure simulator with retries..."
echo "========================================="

# Test with 30% failure rate
echo "Test 1: 30% failure rate (should mostly succeed with retries)"
for i in {1..10}; do
    echo -n "Request $i: "
    kubectl exec -n resilient-services test-client -- curl -s -w "%{http_code}" "http://failure-simulator:8080/?failure_rate=0.3" -o /dev/null
    echo ""
done

echo ""
echo "Test 2: 70% failure rate (some may still fail after retries)"
for i in {1..10}; do
    echo -n "Request $i: "
    kubectl exec -n resilient-services test-client -- curl -s -w "%{http_code}" "http://failure-simulator:8080/?failure_rate=0.7" -o /dev/null
    echo ""
done
