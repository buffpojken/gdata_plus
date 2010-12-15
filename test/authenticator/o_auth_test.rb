require 'helper'
require 'typhoeus'

class OAuthTest < Test::Unit::TestCase
  def valid_constructor_options
    {
      :consumer_key => "1234",
      "consumer_secret" => "5678"
    }
  end

  def valid_request_token_options
    {
      :oauth_callback => "http://example.com/callback",
      :scope => "https://docs.google.com/feeds/"
    }
  end

  should "initialize" do
    authenticator = GDataPlus::Authenticator::OAuth.new(valid_constructor_options)
    assert authenticator.consumer.is_a? OAuth::Consumer
  end

  should "initialize raise if invalid options passed" do
    assert_raises(ArgumentError) do
      GDataPlus::Authenticator::OAuth.new(valid_constructor_options.merge(:consumer_key => nil))
    end

    assert_raises(ArgumentError) do
      GDataPlus::Authenticator::OAuth.new(valid_constructor_options.merge(:foo => 'bar'))
    end
  end

  should "fetch_request_token raise if invalid options passed" do
    authenticator = GDataPlus::Authenticator::OAuth.new(valid_constructor_options)
    assert_raises(ArgumentError) do
      authenticator.fetch_request_token(valid_request_token_options.merge(:scope => nil))
    end

    assert_raises(ArgumentError) do
      authenticator.fetch_request_token(valid_request_token_options.merge(:foo => "bar"))
    end
  end

  should "sign_request raise if invalid request passed" do
    authenticator = GDataPlus::Authenticator::OAuth.new(valid_constructor_options)
    exception = assert_raises(ArgumentError) do
      authenticator.sign_request("I'm not a request object")
    end
    assert_equal "request must be a Typeoeus::Request", exception.message
  end

  # uses "Example used in the OAuth Specification" from http://hueniverse.com/2008/10/beginners-guide-to-oauth-part-iv-signing-requests/
  should "complete oauth workflow" do
    authenticator = GDataPlus::Authenticator::OAuth.new(:consumer_key => "dpf43f3p2l4k3l03", :consumer_secret => "kd94hf93k423kf44")

    request_token_stub = stub(:token => "foo_request_token", :secret => "bar_request_token_secret")
    OAuth::Consumer.any_instance.expects(:get_request_token).once.returns(request_token_stub)

    request_token = authenticator.fetch_request_token(:scope => "https://picasaweb.google.com/data/", :oauth_callback => "http://mysite.com/callback")
    assert_equal request_token_stub, request_token

    access_token_stub = stub(:token => "nnch734d00sl2jdk", :secret => "pfkkdhi9sl3r4s00")
    OAuth::RequestToken.any_instance.expects(:get_access_token).once.returns(access_token_stub)

    access_token = authenticator.fetch_access_token("foo_oauth_verifier")
    assert_equal access_token_stub, access_token

    OAuth::Client::Helper.any_instance.expects(:nonce).once.returns("kllo9940pd9333jh")
    OAuth::Client::Helper.any_instance.expects(:timestamp).once.returns("1191242096")

    request = Typhoeus::Request.new("http://photos.example.net/photos?size=original&file=vacation.jpg")
    authenticator.sign_request(request)

    assert request.headers["Authorization"] =~ /oauth_signature="tR3%2BTy81lMeYAr%2FFid0kMTYa%2FWM%3D"/,
      "wrong oauth_signature in Authorization header"
  end

  # uses "Non-English Parameter" with some custom unicode params from
  # http://hueniverse.com/2008/10/beginners-guide-to-oauth-part-iv-signing-requests/
  should "sign_request with international characters" do
    authenticator = GDataPlus::Authenticator::OAuth.new(
      :consumer_key => "dpf43f3++p+#2l4k3l03",
      :consumer_secret => "kd9@4h%%4f93k423kf44",
      :access_token => "nnch734d(0)0sl2jdk",
      :access_secret => "pfkkd#hi9_sl-3r=4s00"
    )

    params = {
      :latin => "123abc\u00E7",
      :hebrew => "\u05DC\u05E9",
      :arabic => "\u0642\u0644"
    }
    param_string = params.collect {|k,v| "#{k}=#{CGI.escape(v)}"}.join("&")
    request = Typhoeus::Request.new("https://bar.example.net/foo?#{param_string}")

    # stub out nonce and timestamp methods
    OAuth::Client::Helper.any_instance.expects(:nonce).once.returns("kllo~9940~pd9333jh")
    OAuth::Client::Helper.any_instance.expects(:timestamp).once.returns("1191242096")

    authenticator.sign_request(request)
    assert request.headers["Authorization"] =~ /oauth_signature="dNDB%2Fb%2BPVt1mnLW0bJAhWo4Jkww%3D"/,
      "wrong oauth_signature in Authorization header"
  end
end