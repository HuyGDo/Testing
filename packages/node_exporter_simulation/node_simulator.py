import http.server
import socketserver
import time
import random
import argparse
import math
from threading import Thread, Lock

class VMMetrics:
    """
    Holds the state of a simulated VM and generates realistic-looking metrics.
    Includes a daily cycle (sine wave) and random jitter for realism.
    """
    def __init__(self, instance_name: str):
        self.instance_name = instance_name
        # Initial values
        self.cpu_util = random.uniform(10.0, 30.0)
        # Use a time-based seed for sine wave to create daily patterns
        self.start_time = time.time()
        self._lock = Lock()

    def update(self):
        """
        Updates metric values to simulate real-world fluctuations.
        This method is thread-safe.
        """
        with self._lock:
            # --- Daily Cycle Simulation (using a sine wave over 24 hours) ---
            time_elapsed = time.time() - self.start_time
            # The sine function creates a smooth daily high and low. Normalized to 0-1 range.
            daily_factor = (math.sin(2 * math.pi * time_elapsed / 86400) + 1) / 2
            
            # --- Metric-specific logic ---
            # CPU: Base + Daily Cycle + Random Jitter
            base_cpu = 15.0
            cpu_range = 70.0 # Max variation due to daily cycle
            self.cpu_util = base_cpu + (daily_factor * cpu_range) + random.uniform(-2.5, 2.5)

            # --- Clamp values within a realistic 0-100 range ---
            self.cpu_util = max(0, min(100, self.cpu_util))

    def to_prometheus_format(self) -> str:
        """
        Formats the current metrics into Prometheus text exposition format.
        This method is thread-safe.
        """
        with self._lock:
            # The HELP and TYPE lines describe the metric.
            # The final line is the metric itself with its labels and current value.
            return "\n".join([
                "# HELP cpu_util_pct CPU utilization as a percentage.",
                "# TYPE cpu_util_pct gauge",
                f'cpu_util_pct{{instance="{self.instance_name}"}} {self.cpu_util:.2f}',
            ])

# --- Global state required by the HTTP handler ---
vm_metrics = None

class MetricsHandler(http.server.SimpleHTTPRequestHandler):
    """
    An HTTP request handler that serves metrics on the /metrics endpoint.
    """
    def do_GET(self):
        if self.path == '/metrics':
            self.send_response(200)
            self.send_header('Content-type', 'text/plain; version=0.0.4; charset=utf-8')
            self.end_headers()
            metrics_text = vm_metrics.to_prometheus_format()
            self.wfile.write(metrics_text.encode('utf-8'))
        else:
            self.send_response(404)
            self.end_headers()
            self.wfile.write(b"Not Found. Use the /metrics endpoint.")

def update_metrics_periodically(metrics_state: VMMetrics, update_interval_sec: int):
    """
    A function to run in a background thread that updates metric values over time.
    """
    while True:
        metrics_state.update()
        time.sleep(update_interval_sec)

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Node Exporter Simulator for Prometheus.")
    parser.add_argument("--port", type=int, default=9100, help="Port to listen on.")
    parser.add_argument("--instance", type=str, required=True, help="Instance name for the VM simulation (e.g., 'prod-web-1').")
    parser.add_argument("--update-interval", type=int, default=5, help="Interval in seconds to update metric values.")
    args = parser.parse_args()
    
    # Initialize the global metrics state for the handler to use
    vm_metrics = VMMetrics(instance_name=args.instance)

    # Start a background thread to update metrics continuously
    update_thread = Thread(target=update_metrics_periodically, args=(vm_metrics, args.update_interval), daemon=True)
    update_thread.start()

    # Start the HTTP server to serve the metrics
    with socketserver.TCPServer(("", args.port), MetricsHandler) as httpd:
        print(f"Serving Node Exporter metrics for instance '{args.instance}' on port {args.port}...")
        print(f"Access metrics at: http://localhost:{args.port}/metrics")
        try:
            httpd.serve_forever()
        except KeyboardInterrupt:
            print("\nShutting down simulator.")
            httpd.server_close()
