#!/bin/bash

NAMESPACE="cert-management-demo"
echo "=== Certificate Monitoring Report ==="
echo "Timestamp: $(date)"
echo "Namespace: $NAMESPACE"
echo ""

# Get all pods in the namespace
PODS=$(oc get pods -n $NAMESPACE -l app=sample-app -o jsonpath='{.items[*].metadata.name}')

for POD in $PODS; do
    echo "--- Pod: $POD ---"
    
    # Check if the pod has istio-proxy container
    if oc get pod $POD -n $NAMESPACE -o jsonpath='{.spec.containers[*].name}' | grep -q istio-proxy; then
        echo "Istio sidecar detected"
        
        # Extract certificate expiry information
        CERT_INFO=$(oc exec -n $NAMESPACE $POD -c istio-proxy -- cat /etc/ssl/certs/cert-chain.pem 2>/dev/null | openssl x509 -text -noout 2>/dev/null | grep -A2 "Validity")
        
        if [ $? -eq 0 ]; then
            echo "Certificate Validity:"
            echo "$CERT_INFO"
            
            # Extract expiry date
            EXPIRY_DATE=$(echo "$CERT_INFO" | grep "Not After" | cut -d: -f2- | xargs)
            echo "Certificate expires: $EXPIRY_DATE"
            
            # Calculate days until expiry
            EXPIRY_EPOCH=$(date -d "$EXPIRY_DATE" +%s 2>/dev/null)
            CURRENT_EPOCH=$(date +%s)
            
            if [ $? -eq 0 ]; then
                DAYS_UNTIL_EXPIRY=$(( (EXPIRY_EPOCH - CURRENT_EPOCH) / 86400 ))
                echo "Days until expiry: $DAYS_UNTIL_EXPIRY"
                
                if [ $DAYS_UNTIL_EXPIRY -lt 1 ]; then
                    echo "⚠️  WARNING: Certificate expires in less than 1 day!"
                elif [ $DAYS_UNTIL_EXPIRY -lt 7 ]; then
                    echo "⚠️  NOTICE: Certificate expires in less than 7 days"
                else
                    echo "✅ Certificate validity is good"
                fi
            fi
        else
            echo "❌ Could not retrieve certificate information"
        fi
    else
        echo "No Istio sidecar found"
    fi
    echo ""
done

echo "=== End of Report ==="
