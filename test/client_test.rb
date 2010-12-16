require 'helper'
require 'typhoeus'

class ClientTest < Test::Unit::TestCase
  # TODO add a test that ensures the If-Match: * is not added if there is already a conditional header
  should "automatically add If-Match header if an If-* header not already present" do
    url = "http://foo.com/bar"

    hydra = Typhoeus::Hydra.new
    hydra.stub(:get, url).and_return(
      Typhoeus::Response.new(:code => 200, :body => "the body", :time => 0.1)
    )

    # stub authenticator to do nothing
    authenticator = Object.new
    authenticator.expects(:sign_request).once

    client = ::GDataPlus::Client.new(authenticator)
    request = Typhoeus::Request.new(url, :method => :get)
    response = client.submit(request, :hydra => hydra)
    assert_equal 200, response.code

    assert_equal "*", request.headers["If-Match"]
  end

  should "automatically follow redirects" do
    # stub Tyhoeus hydra to return dummy responses
    hydra = Typhoeus::Hydra.new
    urls = ["http://example.com/foo", "http://example.com/bar"]
    hydra.stub(:get, urls[0]).and_return(
      Typhoeus::Response.new(:code => 301, :headers => "Location: #{urls[1]}", :body => "", :time => 0.1)
    )
    hydra.stub(:get, urls[1]).and_return(
      Typhoeus::Response.new(:code => 200, :body => "the body", :time => 0.1)
    )

    # stub authenticator to do nothing
    authenticator = Object.new
    authenticator.expects(:sign_request).twice

    client = ::GDataPlus::Client.new(authenticator)
    response = client.submit(Typhoeus::Request.new(urls[0], :method => :get), :hydra => hydra)
    assert_equal 200, response.code
    assert_equal "the body", response.body
  end

  should "prevent redirect loop by only automatically redirecting once" do
    # stub Tyhoeus hydra to return dummy responses
    hydra = Typhoeus::Hydra.new
    urls = ["http://example.com/foo", "http://example.com/bar"]
    urls.size.times do |index|
      response = Typhoeus::Response.new(:code => 302, :headers => "Location: #{urls[(index+1)%2]}", :body => "", :time => 0.1)
      hydra.stub(:get, urls[index]).and_return(response)
    end

    # stub authenticator to do nothing; if it's called more than two times then we're in a redirect loop
    authenticator = Object.new
    authenticator.expects(:sign_request).twice

    client = ::GDataPlus::Client.new(authenticator)
    client.submit(Typhoeus::Request.new(urls[0], :method => :get), :hydra => hydra)
  end
end