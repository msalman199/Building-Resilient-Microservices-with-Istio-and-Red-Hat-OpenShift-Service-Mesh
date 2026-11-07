#!/bin/bash

echo "Monitoring Service Resilience Metrics"
echo "====================================="

# Check Istio proxy metrics
echo "1. Request success rate:"
kubectl exec -n resilient-services test-client -- curl -s "http://prometheus.istio-system:9090/api/v1/query?query=sum(rate(istio_requests_total{destination_service_name=\"failure-simulator\"}[1m]))" | grep -o '"result":\[[^]]*\]'

echo ""
echo "2. Request duration percentiles:"
kubectl exec -n resilient-services test-client -- curl -s "http://prometheus.istio-system:9090/api/v1/query?query=histogram_quantile(0.95,sum(rate(istio_request_duration_milliseconds_bucket{destination_service_name=\"failure-simulator\"}[1m]))by(le))" | grep -o '"result":\[[^]]*\]'

echo ""
echo "3. Circuit breaker status:"
kubectl get destinationrule failure-simulator-circuit-breaker -n resilient-services -o yaml | grep -A 10 outlierDetection
