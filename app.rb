require 'sinatra'
require 'redis'

redis = Redis.new(host: "127.0.0.1", port: 6379, db: 0)
redis.set("test", "wicked sick")

get '/' do
    msg = redis.get("test")
    "Hello, World! Message: #{msg}"
end