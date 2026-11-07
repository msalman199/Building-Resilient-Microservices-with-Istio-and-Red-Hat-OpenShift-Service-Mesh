#!/bin/bash

echo "=== OpenShift Service Mesh Certificate Management Validation ==="
echo "Timestamp: $(date)"
echo ""

# Test 1: Verify automatic certificate provisioning
echo "Test 1: Certificate Provisioning"
PODS=$(oc get pods -n cert-management-demo -l app=sample-app --no-headers | wc -l)
PODS_WITH_CERTS=0

for pod in $(oc get pods -n cert-management-demo -l app=sample-app -o jsonpath='{.items[*].metadata.name}'); do
    if oc exec -n cert-management-demo $pod -c istio-proxy -- test -f /etc/ssl/certs/cert-chain.pem 2>/dev/null; then
        PODS_WITH_CERTS=$((PODS_WITH_CERTS + 1))
    fi
done

echo "Pods with certificates: $PODS_WITH_CERTS/$PODS"
if [ $PODS_WITH_CERTS -eq $PODS ]; then
    echo "✅ All pods have certificates provisioned"
else
    echo "❌ Some pods missing certificates"
fi
echo ""

# Test 2: Verify mTLS enforcement
echo "Test 2: mTLS Enforcement"
CLIENT_POD=$(oc get pods -n cert-management-demo -l app=client-app -o jsonpath='{.items[0].metadata.name}')
HTTP_CODE=$(oc exec -n cert-management-demo $CLIENT_POD -c client-app -- curl -s -o /dev/null -w "%{http_code}" http://sample-app-service.cert-management-demo.svc.cluster.local 2>/dev/null)

if [ "$HTTP_CODE" = "200" ]; then
    echo "✅ mTLS communication successful (HTTP $HTTP_CODE)"
else
    echo "⚠️  mTLS communication returned HTTP $HTTP_CODE"
fi
echo ""

# Test 3: Certificate validity check
echo "Test 3: Certificate Validity"
SAMPLE_POD=$(oc get pods -n cert-management-demo -l app=sample-app -o jsonpath='{.items[0].metadata.name}')
CERT_VALID=$(oc exec -n cert-management-demo $SAMPLE_POD -c istio-proxy -- openssl x509 -in /etc/ssl/certs/cert-chain.pem -checkend 0 -noout 2>/dev/null && echo "valid" || echo "invalid")

if [ "$CERT_VALID" = "valid" ]; then
    echo "✅ Certificates are valid"
else
    echo "❌ Certificates are invalid or expired"
fi
echo ""

# Test 4: Monitoring setup
echo "Test 4: Monitoring Configuration"
CRONJOB_COUNT=$(oc get cronjob -n cert-management-demo --no-headers | wc -l)
if [ $CRONJOB_COUNT -gt 0 ]; then
    echo "✅ Certificate monitoring CronJob configured"
else
    echo "❌ No monitoring CronJob found"
fi

echo ""
echo "=== Validation Complete ==="
