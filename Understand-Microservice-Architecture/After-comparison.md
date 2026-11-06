# Simple service call - retry handled by service mesh
import requests

def call_payment_service(order_data):
    response = requests.post(
        "http://payment-service:8080/api/payments",
        json=order_data
    )
    return response.json()
