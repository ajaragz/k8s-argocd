from flask import Flask, jsonify, request

# Simple temperature conversion

app = Flask(__name__)

@app.route('/', methods=['GET'])
def home():
    return "Temperature Conversion Service is running"

@app.route('/convert', methods=['GET'])
def convert_temperature():
    try:
        temp = request.args.get('temp', type=float)
        scale = request.args.get('scale', type=str)

        if scale == 'C':
            converted_temp = (temp * 9/5) + 32  # Convert Celsius to Fahrenheit
        elif scale == 'F':
            converted_temp = (temp - 32) * 5/9  # Convert Fahrenheit to Celsius
        else:
            app.logger.error("Invalid scale provided. Use 'C' for Celsius and 'F' for Fahrenheit.")
            return jsonify({"error": "Invalid scale. Use 'C' for Celsius and 'F' for Fahrenheit."}), 400

        return jsonify({"converted_temp": converted_temp})
    except Exception as e:
        app.logger.error(f"Error converting temperature: {e}")
        return jsonify({"error": "Unable to convert temperature"}), 500

if __name__ == '__main__':
    try:
        app.run(host='0.0.0.0', port=8082)
    except Exception as e:
        app.logger.error(f"Error starting the application: {e}")