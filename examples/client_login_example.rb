# Highline is required for this example: gem install highline

require 'rubygems'
require 'gdata_plus'
require 'highline/import'
require 'typhoeus'

# prompt for email/password
email = ask("Enter your email:  ")
password = ask("Enter your password:  ") { |q| q.echo = "x" }

# authenticate using email/password
authenticator = GDataPlus::Authenticator::ClientLogin.new(:service => "lh2", :source => "balexand-gdata_plus-1")
authenticator.authenticate(email, password)

# Make a signed request (fetch a list of Picasa albums in this case)
response = authenticator.client.get("https://picasaweb.google.com/data/feed/api/user/default")
puts response.inspect