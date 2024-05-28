from flask import Flask

# Dummy web UI

app = Flask(__name__)

@app.route('/')
def home():
    return "Welcome to the Web UI!"

if __name__ == '__main__':
    try:
        app.run(host='0.0.0.0', port=8080)
    except Exception as e:
        app.logger.error(f"Failed to start the Flask application: {e}", exc_info=True)