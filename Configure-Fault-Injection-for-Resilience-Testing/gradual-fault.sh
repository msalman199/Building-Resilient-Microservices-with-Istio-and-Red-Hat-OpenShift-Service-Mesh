#!/bin/bash

echo "Implementing gradual fault injection..."

# Start with 10% failure rate
kubectl apply -f - << 'FAULT_10'
apiVersion: networking.istio.io/v1beta1
kind: VirtualService
metadata:
  name: ratings-gradual
spec:
  hosts:
  - ratings
  http:
  - fault:
      abort:
        percentage:
          value: 10.0
        httpStatus: 500
    route:
    - destination:
        host: ratings
        subset: v1
FAULT_10

echo "Applied 10% fault rate. Waiting 60 seconds..."
sleep 60

# Increase to 25% failure rate
kubectl apply -f - << 'FAULT_25'
apiVersion: networking.istio.io/v1beta1
kind: VirtualService
metadata:
  name: ratings-gradual
spec:
  hosts:
  - ratings
  http:
  - fault:
      abort:
        percentage:
          value: 25.0
        httpStatus: 500
    route:
    - destination:
        host: ratings
        subset: v1
FAULT_25

echo "Applied 25% fault rate. Waiting 60 seconds..."
sleep 60

# Increase to 50% failure rate
kubectl apply -f - << 'FAULT_50'
apiVersion: networking.istio.io/v1beta1
kind: VirtualService
metadata:
  name: ratings-gradual
spec:
  hosts:
  - ratings
  http:
  - fault:
      abort:
        percentage:
          value: 50.0
        httpStatus: 500
    route:
    - destination:
        host: ratings
        subset: v1
FAULT_50

echo "Applied 50% fault rate. Monitor the application behavior."
