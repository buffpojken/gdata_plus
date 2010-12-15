require 'typhoeus'

module GDataPlus
  class Client
    attr_reader :authenticator, :default_gdata_version

    def initialize(authenticator, default_gdata_version = "2.0")
      @authenticator = authenticator
      @default_gdata_version = default_gdata_version
    end

    def submit(request, options = {})
      options = ::GDataPlus::Util.prepare_options(options, [], [:gdata_version, :hydra])
      hydra = options[:hydra] || Typhoeus::Hydra.hydra

      request.headers.merge!("GData-Version" => options[:gdata_version] || default_gdata_version)
      @authenticator.sign_request(request)

      hydra.queue(request)
      hydra.run
      request.response
    end
  end
end