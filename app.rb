require 'sinatra'
require 'redis'

redis = Redis.new(ur: ENV['REDIS_URL'], db: 0)
redis.set("test", "wicked sick")

get '/' do
    msg = redis.get("test")
    "Hello, World! Message: #{msg}"
end