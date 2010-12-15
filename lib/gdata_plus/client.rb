require 'typhoeus'

module GDataPlus
  class Client
    HTTP_MOVED_PERMANENTLY  = 301
    HTTP_FOUND              = 302

    attr_reader :authenticator, :default_gdata_version

    def initialize(authenticator, default_gdata_version = "2.0")
      @authenticator = authenticator
      @default_gdata_version = default_gdata_version
    end

    # FIXME detect infinite redirect
    def submit(request, options = {})
      options = ::GDataPlus::Util.prepare_options(options, [], [:gdata_version, :hydra, :no_redirect])
      hydra = options[:hydra] || Typhoeus::Hydra.hydra

      request.headers.merge!("GData-Version" => options[:gdata_version] || default_gdata_version)
      @authenticator.sign_request(request)

      hydra.queue(request)
      hydra.run
      response = request.response

      # automatically follow redirects since some GData APIs (like Calendar) redirect GET requests
      if request.method.to_sym == :get && !options[:no_redirect] && (response.code == HTTP_MOVED_PERMANENTLY || response.code == HTTP_FOUND)
        response = submit ::Typhoeus::Request.new(response.headers_hash["Location"], :method => :get), options.merge(:no_redirect => true)
      end

      response
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