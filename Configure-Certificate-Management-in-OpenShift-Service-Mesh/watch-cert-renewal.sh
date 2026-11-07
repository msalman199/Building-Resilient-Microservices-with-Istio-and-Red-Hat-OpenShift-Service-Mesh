#!/bin/bash

NAMESPACE="cert-management-demo"
echo "Monitoring certificate renewal in namespace: $NAMESPACE"
echo "Press Ctrl+C to stop monitoring"
echo ""

while true; do
    echo "=== $(date) ==="
    
    # Get current pod
    POD=$(oc get pods -n $NAMESPACE -l app=sample-app -o jsonpath='{.items[0].metadata.name}' 2>/dev/null)
    
    if [ -n "$POD" ]; then
        echo "Monitoring pod: $POD"
        
        # Get certificate serial number (unique identifier)
        SERIAL=$(oc exec -n $NAMESPACE $POD -c istio-proxy -- cat /etc/ssl/certs/cert-chain.pem 2>/dev/null | openssl x509 -serial -noout 2>/dev/null)
        
        if [ $? -eq 0 ]; then
            echo "Certificate Serial: $SERIAL"
            
            # Get certificate validity
            VALIDITY=$(oc exec -n $NAMESPACE $POD -c istio-proxy -- cat /etc/ssl/certs/cert-chain.pem 2>/dev/null | openssl x509 -dates -noout 2>/dev/null)
            echo "Certificate Validity: $VALIDITY"
        else
            echo "Could not retrieve certificate information"
        fi
    else
        echo "No pods found with label app=sample-app"
    fi
    
    echo ""
    sleep 60  # Check every minute
done
