from flask import Flask, jsonify, abort
from redis import Redis, RedisError, WatchError
import time

TIMEOUT = 10

# Connect to Redis
redis = Redis(host="redis", db=0, socket_connect_timeout=TIMEOUT, socket_timeout=TIMEOUT)
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


def do_work(pipe, key, timeout=TIMEOUT):
    start = time.time()
    while time.time() - start < timeout:
        try:
            pipe.watch(key)
            data = fibonacci_count(pipe.get(key))
            pipe.multi()
            pipe.set(key, fibonacci_format(*data))
            pipe.execute()
            return data
        except WatchError:
            time.sleep(0.1)
            continue
    else:
        raise TimeoutError("Watcher timeout reached")


def reset(pipe, key, timeout=TIMEOUT):
    start = time.time()
    while time.time() - start < timeout:
        try:
            pipe.watch(key)
            pipe.multi()
            pipe.set(key, fibonacci_format(0, 1))
            pipe.execute()
            break
        except WatchError:
            time.sleep(0.1)
            continue
    else:
        raise TimeoutError("Watcher timeout reached")


@app.route("/reset", methods=['GET', 'POST'])
def reset_route():
    try:
        with redis.pipeline() as pipe:
            reset(pipe, "data")
            return jsonify(result="OK")
    except (RedisError, TimeoutError) as e:
        abort(500, "Redis Error: {error}".format(error=e))


@app.route("/raise", methods=['GET', 'POST'])
def raise_route():
    try:
        with redis.pipeline() as pipe:
            first, second = do_work(pipe, "data")
            return jsonify(first=first, second=second)
    except (RedisError, TimeoutError) as e:
        abort(500, "Redis Error: {error}".format(error=e))

if __name__ == "__main__":
    app.run(host='0.0.0.0', port=80)
