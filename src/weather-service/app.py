from flask import Flask, jsonify

# Dummy weather service

app = Flask(__name__)

# Sample static weather data
weather_data = {
    "city": "Sevilla",
    "temperature": "20",
    "condition": "Sunny",
    "humidity": "50%"
}

@app.route('/', methods=['GET'])
def home():
    return "Weather Service is running"

@app.route('/weather', methods=['GET'])
def get_weather():
    try:
        return jsonify(weather_data)
    except Exception as e:
        app.logger.error(f"Error fetching weather data: {e}")
        return jsonify({"error": "Unable to fetch weather data"}), 500

if __name__ == '__main__':
    try:
        app.run(host='0.0.0.0', port=8081)
    except Exception as e:
        app.logger.error(f"Error starting the application: {e}")