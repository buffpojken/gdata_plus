require 'helper'

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

  should "initialize new instance" do
    authenticator = GDataPlus::Authenticator::OAuth.new(valid_constructor_options)
    assert authenticator.consumer.is_a? OAuth::Consumer
  end

  should "raise if invalid options passed to initialize" do
    assert_raises(ArgumentError) do
      GDataPlus::Authenticator::OAuth.new(valid_constructor_options.merge(:consumer_key => nil))
    end

    assert_raises(ArgumentError) do
      GDataPlus::Authenticator::OAuth.new(valid_constructor_options.merge(:foo => 'bar'))
    end
  end

  should "raise if invalid options passed to fetch_request_token" do
    authenticator = GDataPlus::Authenticator::OAuth.new(valid_constructor_options)
    assert_raises(ArgumentError) do
      authenticator.fetch_request_token(valid_request_token_options.merge(:scope => nil))
    end

    assert_raises(ArgumentError) do
      authenticator.fetch_request_token(valid_request_token_options.merge(:foo => "bar"))
    end
  end
end