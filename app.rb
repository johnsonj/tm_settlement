require 'sinatra'
require 'redis'

redis = Redis.new(url: ENV['REDIS_URL'])
redis.set("test", "wicked sick")

get '/' do
    msg = redis.get("test")
    "Hello, World! Message: #{msg}"
end