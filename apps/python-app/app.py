# CI trigger: enable build-python via paths-filter
from flask import Flask, jsonify
import os
import time

app = Flask(__name__)

@app.route('/api/health')
def health():
    return jsonify({"status": "UP", "service": "python-app"})

@app.route('/api/info')
def info():
    return jsonify({
        "app": "hybrid-python-app",
        "version": "1.0.0",
        "environment": os.getenv("APP_ENV", "local")
    })

@app.route('/api/data')
def get_data():
    return jsonify({
        "message": "Hello from Python Microservice",
        "timestamp": int(time.time() * 1000),
        "items": ["task1", "task2", "task3"]
    })

if __name__ == '__main__':
    port = int(os.getenv("PORT", 5000))
    app.run(host='0.0.0.0', port=port)
