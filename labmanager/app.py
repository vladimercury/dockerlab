from flask import Flask, jsonify, abort, render_template
from redis import Redis, RedisError
from os import getenv

# Connect to Redis
redis = Redis(host="redis", db=0, socket_connect_timeout=10, socket_timeout=10)
# Run app
app = Flask(__name__)
app.config.update(JSONIFY_PRETTYPRINT_REGULAR=False)
# Worker port
worker_port = getenv("WORKER_PORT", "7000")

def fibonacci_parse(data):
    numbers = None
    if data:
        try:
            numbers = tuple(map(int, data.split()))[:2]
        except ValueError:
            pass
    if not numbers or len(numbers) != 2:
        return 0, 1  # default
    return numbers


@app.route("/data", methods=['GET'])
def get_data():
    try:
        current = fibonacci_parse(redis.get("data"))[-1]
        return jsonify(result=str(current))
    except RedisError as e:
        abort(500, "Redis Error: {error}".format(error=e))


@app.route("/", methods=['GET'])
def main():
    return render_template("index.html", port=worker_port)

if __name__ == "__main__":
    app.run(host='0.0.0.0', port=80) 
