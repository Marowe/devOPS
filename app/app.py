from flask import Flask
from prometheus_client import make_wsgi_app, Counter
from werkzeug.middleware.dispatcher import DispatcherMiddleware
import time
import threading

app = Flask(__name__)

# Counter that increments every minute
counter_value = 0
counter_lock = threading.Lock()

# Prometheus counter metric
prom_counter = Counter('app_counter', 'Counter that increments every minute')

def increment_counter():
    """Background thread that increments counter every minute"""
    global counter_value
    while True:
        time.sleep(60)  # Wait 60 seconds
        with counter_lock:
            counter_value += 1
            prom_counter.inc()  # Also increment Prometheus metric

@app.route('/')
def hello():
    with counter_lock:
        current_count = counter_value
    return f"""
    <!DOCTYPE html>
    <html>
    <head>
        <title>DevOps Stack Counter</title>
        <meta http-equiv="refresh" content="5">
        <style>
            body {{
                background-color: #000000;
                color: #ffffff;
                font-family: 'Arial', sans-serif;
                display: flex;
                justify-content: center;
                align-items: center;
                min-height: 100vh;
                margin: 0;
                padding: 20px;
            }}
            .container {{
                text-align: center;
                max-width: 600px;
            }}
            h1 {{
                font-size: 2.5em;
                margin-bottom: 30px;
                color: #ffffff;
            }}
            .counter-value {{
                font-size: 4em;
                font-weight: bold;
                color: #00ff00;
                margin: 20px 0;
            }}
            .info {{
                font-size: 1.2em;
                margin: 15px 0;
            }}
            .label {{
                color: #aaaaaa;
            }}
            .note {{
                color: #888888;
                font-style: italic;
                margin-top: 30px;
            }}
            .small {{
                color: #666666;
                font-size: 0.9em;
            }}
        </style>
    </head>
    <body>
        <div class="container">
            <h1>DevOps Stack - Minute Counter</h1>
            <div class="counter-value">{current_count}</div>
            <div class="info">
                <span class="label">Current Time:</span> {time.strftime('%Y-%m-%d %H:%M:%S')}
            </div>
            <div class="note">Counter increments by +1 every minute</div>
            <div class="small">Page auto-refreshes every 5 seconds</div>
        </div>
    </body>
    </html>
    """

# Add prometheus wsgi middleware to route /metrics requests
app.wsgi_app = DispatcherMiddleware(app.wsgi_app, {
    '/metrics': make_wsgi_app()
})

if __name__ == '__main__':
    # Start the counter thread
    counter_thread = threading.Thread(target=increment_counter, daemon=True)
    counter_thread.start()
    
    app.run(host='0.0.0.0', port=5000)
