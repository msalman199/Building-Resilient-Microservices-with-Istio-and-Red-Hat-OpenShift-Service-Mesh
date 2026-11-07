#!/bin/bash

GATEWAY_URL=$1
DURATION=${2:-300}  # Default 5 minutes
END_TIME=$((SECONDS + DURATION))

echo "Generating traffic to $GATEWAY_URL for $DURATION seconds..."

while [ $SECONDS -lt $END_TIME ]; do
    # Normal user traffic
    curl -s -o /dev/null http://$GATEWAY_URL/productpage &
    
    # Jason user traffic (with faults)
    curl -s -o /dev/null -H "end-user: jason" http://$GATEWAY_URL/productpage &
    
    # Wait between requests
    sleep 2
done

wait
echo "Traffic generation completed"
