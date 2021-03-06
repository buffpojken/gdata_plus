require 'rubygems'
require 'gdata_plus'
require 'nokogiri'
require 'sinatra'
require 'typhoeus'

# NOTE: put your consumer key and secret here or set environment vars
CONSUMER_KEY = ENV["GDATA_CONSUMER_KEY"]
CONSUMER_SECRET = ENV["GDATA_CONSUMER_SECRET"]

set :sessions, true

# STEP #1: Obtain and store request token, and redirect browser to Google for authorization
get "/" do
  oauth_callback = "#{request.scheme}://#{request.host}:#{request.port}/callback"

  authenticator = GDataPlus::Authenticator::OAuth.new(:consumer_key => CONSUMER_KEY, :consumer_secret => CONSUMER_SECRET)
  request_token = authenticator.fetch_request_token(:scope => "https://picasaweb.google.com/data/", :oauth_callback => oauth_callback)

  session[:gdata_authenticator] = authenticator

  redirect request_token.authorize_url
end

# STEP #2: Exchange request token for access token when user is redirected back to your site
get "/callback" do
  authenticator = session[:gdata_authenticator]
  authenticator.fetch_access_token(params[:oauth_verifier])
  redirect "/picasa_album_list"
end

# STEP #3: Make a signed request (fetch a list of Picasa albums in this case)
get "/picasa_album_list" do
  authenticator = session[:gdata_authenticator]
  response = authenticator.client.get("https://picasaweb.google.com/data/feed/api/user/default")

  feed = Nokogiri::XML(response.body)
  album_titles = feed.xpath("//xmlns:entry/xmlns:title/text()").collect {|i| "#{i}"}
  album_titles.collect {|title| "<li>#{title}</li>"}
end