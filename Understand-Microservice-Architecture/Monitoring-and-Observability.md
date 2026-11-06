# Custom metrics and tracing in each service
from prometheus_client import Counter, Histogram, start_http_server
import opentracing
import time

REQUEST_COUNT = Counter('requests_total', 'Total requests', ['method', 'endpoint'])
REQUEST_LATENCY = Histogram('request_duration_seconds', 'Request latency')

def process_order(order_data):
    start_time = time.time()
    span = opentracing.tracer.start_span('process_order')
    
    try:
        # Business logic here
        result = handle_order(order_data)
        REQUEST_COUNT.labels(method='POST', endpoint='/orders').inc()
        return result
    finally:
        REQUEST_LATENCY.observe(time.time() - start_time)
        span.finish()
# Clean business logic - metrics handled by service mesh
def process_order(order_data):
    # Pure business logic
    return handle_order(order_data)
