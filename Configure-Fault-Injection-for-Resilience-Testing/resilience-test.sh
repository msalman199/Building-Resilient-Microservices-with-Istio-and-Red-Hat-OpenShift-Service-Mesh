#!/bin/bash

GATEWAY_URL=$1

echo "Testing application resilience..."

echo "1. Testing normal operation:"
for i in {1..5}; do
    response=$(curl -s -w "%{http_code}" -o /dev/null http://$GATEWAY_URL/productpage)
    echo "Request $i: HTTP $response"
done

echo -e "\n2. Testing with fault injection (jason user):"
for i in {1..5}; do
    start_time=$(date +%s.%N)
    response=$(curl -s -w "%{http_code}" -o /dev/null -H "end-user: jason" http://$GATEWAY_URL/productpage)
    end_time=$(date +%s.%N)
    duration=$(echo "$end_time - $start_time" | bc)
    echo "Request $i: HTTP $response (${duration}s)"
done

echo -e "\n3. Testing retry behavior:"
kubectl apply -f - << 'RETRY_EOF'
apiVersion: networking.istio.io/v1beta1
kind: VirtualService
metadata:
  name: ratings-retry
spec:
  hosts:
  - ratings
  http:
  - route:
    - destination:
        host: ratings
        subset: v1
    retries:
      attempts: 3
      perTryTimeout: 2s
RETRY_EOF

sleep 5

for i in {1..3}; do
    start_time=$(date +%s.%N)
    response=$(curl -s -w "%{http_code}" -o /dev/null -H "end-user: jason" http://$GATEWAY_URL/productpage)
    end_time=$(date +%s.%N)
    duration=$(echo "$end_time - $start_time" | bc)
    echo "Retry test $i: HTTP $response (${duration}s)"
done
