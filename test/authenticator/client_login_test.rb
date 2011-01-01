require 'helper'

# TODO more tests for ClientLogin
class ClientLoginTest < Test::Unit::TestCase
  should "authenticate" do
    GDataPlus::Authenticator::ClientLogin.new(:service => "lh2", :source => "balexand-gdata_plus-1")
  end
end