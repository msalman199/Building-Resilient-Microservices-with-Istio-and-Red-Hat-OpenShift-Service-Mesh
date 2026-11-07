#!/bin/bash

echo "Edge Case Testing for Resilience Patterns"
echo "========================================="

# Test 1: Rapid successive requests
echo "Test 1: Rapid successive requests (testing connection pooling)"
for i in {1..50}; do
    kubectl exec -n resilient-services test-client -- curl -s "http://failure-simulator:8080/?failure_rate=0.1" -o /dev/null &
done
wait
echo "Completed 50 concurrent requests"

# Test 2: Very long delays
echo ""
echo "Test 2: Very long delay (testing timeout behavior)"
timeout 15s kubectl exec -n resilient-services test-client -- curl -s "http://delay-simulator:8080/?delay=20" || echo "Request properly timed out"

# Test 3: Network partition simulation
echo ""
echo "Test 3: Simulating network issues"
# Scale down the failure simulator to simulate network partition
kubectl scale deployment failure-simulator --replicas=0 -n resilient-services
echo "Scaled down failure-simulator, testing requests..."
kubectl exec -n resilient-services test-client -- curl -s -m 5 "http://failure-simulator:8080/" || echo "Request failed as expected (service unavailable)"

# Restore the service
kubectl scale deployment failure-simulator --replicas=1 -n resilient-services
echo "Restored failure-simulator service"

# Wait for pod to be ready
echo "Waiting for service to be ready..."
kubectl wait --for=condition=ready pod -l app=failure-simulator -n resilient-services --timeout=60s
