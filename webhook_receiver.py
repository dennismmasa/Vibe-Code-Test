from http.server import HTTPServer, BaseHTTPRequestHandler
import sys

class Handler(BaseHTTPRequestHandler):
    def do_POST(self):
        length = int(self.headers.get('content-length', 0))
        body = self.rfile.read(length)
        print('--- RECEIVED POST', self.path)
        try:
            print(body.decode())
        except Exception:
            print(body)
        sys.stdout.flush()
        self.send_response(200)
        self.end_headers()

    def log_message(self, format, *args):
        return

if __name__ == '__main__':
    port = 9000
    server = HTTPServer(('0.0.0.0', port), Handler)
    print(f'Webhook receiver listening on http://0.0.0.0:{port}')
    sys.stdout.flush()
    server.serve_forever()
