require 'typhoeus'

module GDataPlus
  class Client
    def initialize(authenticator)
      @authenticator = authenticator
    end

    def submit(request, hydra = Typhoeus::Hydra.hydra)
      @authenticator.sign_request(request)
      hydra.queue(request)
      hydra.run
      request.response
    end
  end
end