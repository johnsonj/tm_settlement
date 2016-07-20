require 'sinatra'
require 'sinatra/flash'
require 'redis'
require 'haml'
require 'json'

enable :sessions

redis = Redis.new(url: ENV['REDIS_URL'])

EMAILS_HASH_NAME = "emails"

get '/' do
    haml :index
end

post '/subscribe' do
    email = params[:email]

    unless email.empty? or email.nil?
        redis.hincrby(EMAILS_HASH_NAME, email, 1)
        flash.next[:success] = "Successfully subscribed with #{email}"
    else
        flash.next[:error] = "There's only one field...how'd you mess that up?"
    end

    redirect "/"
end

get '/emails' do
    emails = redis.hkeys(EMAILS_HASH_NAME)
    "#{emails}"
end