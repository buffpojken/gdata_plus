require 'helper'

class ExceptionTest < Test::Unit::TestCase
  should "initialize with unknown response" do
    e = ::GDataPlus::Exception.new(nil)
    assert_equal "no response provided", e.message
  end

  should "initialize with response" do
    response_stub = stub(:body => "foo bar message")
    e = ::GDataPlus::Exception.new(response_stub)
    assert_equal "foo bar message", e.message
    assert_equal response_stub, e.response
  end
end