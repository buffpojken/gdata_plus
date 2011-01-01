module GDataPlus
  autoload "Client", "gdata_plus/client"
  autoload "Exception", "gdata_plus/exception"
  autoload "Util", "gdata_plus/util"

  module Authenticator
    autoload "ClientLogin", "gdata_plus/authenticator/client_login"
    autoload "Common", "gdata_plus/authenticator/common"
    autoload "OAuth", "gdata_plus/authenticator/o_auth"
  end
end