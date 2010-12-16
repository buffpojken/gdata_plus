module GDataPlus
  autoload "Client", "gdata_plus/client"
  autoload "Exception", "gdata_plus/exception"
  autoload "Util", "gdata_plus/util"

  module Authenticator
    autoload "OAuth", "gdata_plus/authenticator/o_auth"
  end
end