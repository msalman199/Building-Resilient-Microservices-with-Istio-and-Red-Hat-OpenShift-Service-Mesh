# Before and After Service Mesh Comparison

## Scenario 1: Service Communication Failure

### Before Service Mesh:
```python
# Custom retry logic in each service
import requests
import time
from functools import wraps

def retry_on_failure(max_retries=3, delay=1):
    def decorator(func):
        @wraps(func)
        def wrapper(*args, **kwargs):
            for attempt in range(max_retries):
                try:
                    return func(*args, **kwargs)
                except requests.exceptions.RequestException as e:
                    if attempt == max_retries - 1:
                        raise e
                    time.sleep(delay * (2 ** attempt))
            return None
        return wrapper
    return decorator

@retry_on_failure(max_retries=3, delay=2)
def call_payment_service(order_data):
    response = requests.post(
        "http://payment-service:8080/api/payments",
        json=order_data,
        timeout=30
    )
    return response.json()
