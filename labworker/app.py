from flask import Flask, jsonify, abort
from redis import Redis, RedisError
from redis_lock import Lock, NotAcquired
from os import getenv
from socket import gethostname


# Connect to Redis
redis = Redis(host="redis", db=0, socket_connect_timeout=10, socket_timeout=10)
# Redis Lock
lock = Lock(redis, "data", expire=5)
# Run app
app = Flask(__name__)
app.config.update(JSONIFY_PRETTYPRINT_REGULAR=False)


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


def fibonacci_format(*numbers):
    return " ".join(map(str, numbers))


def fibonacci_count(data):
    a, b = fibonacci_parse(data)
    return b, a + b

@app.route("/raise", methods=['GET', 'POST'])
def hello():
    try:
        if lock.acquire():
            data = fibonacci_count(redis.get("data"))
            redis.set("data", fibonacci_format(*data))
            lock.release()
            return jsonify(state=data, host=gethostname())
        else:
            abort(500, "Redis Locked")
    except RedisError as e:
        abort(500, "Redis Error: {error}".format(error=e))
    except NotAcquired as e:
        abort(500, "Redis Lock Error: {error}".format(error=e))

if __name__ == "__main__":
    app.run(host='0.0.0.0', port=80) 
