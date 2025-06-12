import http.server
import socketserver
import time
import random
import argparse

class MetricsHandler(http.server.BaseHTTPRequestHandler):
    """
    A simple HTTP request handler for serving Prometheus metrics.
    This handler generates dynamic CPU metrics for simulation purposes.
    """
    cpu_seconds_total = 0
    start_time = time.time()

    def do_GET(self):
        if self.path == '/metrics':
            self.send_response(200)
            self.send_header('Content-type', 'text/plain')
            self.end_headers()

            # Simulate CPU usage changing over time
            # Increment by a random amount to simulate a dynamic load
            MetricsHandler.cpu_seconds_total += random.uniform(0.1, 1.5)

            # Prometheus exposition format
            metrics = [
                '# HELP node_cpu_seconds_total Seconds the CPUs spent in each mode.',
                '# TYPE node_cpu_seconds_total counter',
                f'node_cpu_seconds_total{{cpu="0",mode="idle"}} {MetricsHandler.cpu_seconds_total * 0.6 + random.uniform(0, 10)}',
                f'node_cpu_seconds_total{{cpu="0",mode="system"}} {MetricsHandler.cpu_seconds_total * 0.1 + random.uniform(0, 2)}',
                f'node_cpu_seconds_total{{cpu="0",mode="user"}} {MetricsHandler.cpu_seconds_total * 0.3 + random.uniform(0, 5)}',
                '# HELP node_load1 1m load average.',
                '# TYPE node_load1 gauge',
                f'node_load1 {random.uniform(0.0, 2.0)}'
            ]
            self.wfile.write("\n".join(metrics).encode('utf-8'))
        else:
            self.send_response(404)
            self.end_headers()
            self.wfile.write(b'404 Not Found')

def main():
    """
    Main function to start the web server for the node exporter simulator.
    """
    parser = argparse.ArgumentParser(description="Fake Node Exporter for Prometheus simulation.")
    parser.add_argument('--port', type=int, default=8000, help="Port to run the web server on.")
    args = parser.parse_args()

    PORT = args.port
    with socketserver.TCPServer(("", PORT), MetricsHandler) as httpd:
        print(f"Serving at port {PORT}")
        print(f"Access metrics at http://localhost:{PORT}/metrics")
        httpd.serve_forever()

if __name__ == "__main__":
    main()
