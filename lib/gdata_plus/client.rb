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

    [:delete, :get, :post, :put].each do |method|
      define_method(method) do |url, request_options = {}|
        request_options = request_options.merge(:method => method)
        request = ::Typhoeus::Request.new(url, request_options)
        submit request
      end
    end
  end
end