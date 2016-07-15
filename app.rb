require 'sinatra'
require 'redis'
require 'haml'
require 'json'

redis = Redis.new(url: ENV['REDIS_URL'])
redis.set("test", "wicked sick")

EMAILS_HASH_NAME = "emails"

get '/' do
    msg = redis.get("test")
    haml :index, locals: { msg: msg }
end

post '/subscribe' do
    email = params[:email]
    redis.hincrby(EMAILS_HASH_NAME, email, 1)
    "Thanks"
end

get '/emails' do
    emails = redis.hkeys(EMAILS_HASH_NAME)
    "#{emails}"
end