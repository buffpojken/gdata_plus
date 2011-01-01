module GDataPlus
  module Authenticator
    module Common
      def client(*args)
        Client.new(self, *args)
      end
    end
  end
end