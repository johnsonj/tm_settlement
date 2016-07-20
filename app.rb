require 'sinatra'
require 'redis'
require 'haml'
require 'json'

redis = Redis.new(url: ENV['REDIS_URL'])

EMAILS_HASH_NAME = "emails"

get '/' do
    haml :index
end

post '/subscribe' do
    email = params[:email]

    unless email.empty? or email.nil?
        redis.hincrby(EMAILS_HASH_NAME, email, 1)
        "Thanks"
    else
        redirect "/"
    end
end

get '/emails' do
    emails = redis.hkeys(EMAILS_HASH_NAME)
    "#{emails}"
end