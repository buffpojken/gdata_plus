# you don't need the following line if you've installed the gem
$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)

require 'gdata_plus'
require 'sinatra'
require 'typhoeus'

# NOTE: put your consumer key and secret here or set environment vars
CONSUMER_KEY = ENV["GDATA_CONSUMER_KEY"]
CONSUMER_SECRET = ENV["GDATA_CONSUMER_SECRET"]

set :sessions, true # enable Sinatra sessions

get "/" do
  oauth_callback = "#{request.scheme}://#{request.host}:#{request.port}/callback"

  authenticator = GDataPlus::Authenticator::OAuth.new(:consumer_key => CONSUMER_KEY, :consumer_secret => CONSUMER_SECRET)
  request_token = authenticator.fetch_request_token(:scope => "https://picasaweb.google.com/data/", :oauth_callback => oauth_callback)

  # store authenticator in the session since we'll need it when exchanging request token for an access token
  session[:gdata_authenticator] = authenticator

  redirect request_token.authorize_url
end

get "/callback" do
  authenticator = session[:gdata_authenticator]
  authenticator.fetch_access_token(params[:oauth_verifier])
  redirect "/picasa_album_list"
end

get "/picasa_album_list" do
  authenticator = session[:gdata_authenticator]
  url = "https://picasaweb.google.com/data/feed/api/user/default"
  response = authenticator.client.submit Typhoeus::Request.new(url, :method => :get)

  response.inspect
end