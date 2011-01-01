require 'typhoeus'

module GDataPlus
  module Authenticator
    class ClientLogin
      include Common

      # {Account type GOOGLE}[http://code.google.com/apis/accounts/docs/AuthForInstalledApps.html#Request]
      TYPE_GOOGLE = "GOOGLE"
      # {Account type HOSTED}[http://code.google.com/apis/accounts/docs/AuthForInstalledApps.html#Request]
      TYPE_HOSTED = "HOSTED"
      # {Account type HOSTED_OR_GOOGLE}[http://code.google.com/apis/accounts/docs/AuthForInstalledApps.html#Request]
      TYPE_HOSTED_OR_GOOGLE = "HOSTED_OR_GOOGLE"

      attr_accessor :auth_token

      # === Options
      # [:service]
      #   (required) Name of service to which you are authenticating.
      #   {Click here for a list of possible values}[http://code.google.com/apis/gdata/faq.html#clientlogin].
      # [:source]
      #   (required) Short string identifying your application, for logging purposes. This string should take
      #   the form: "companyName-applicationName-versionID".
      # [:account_type]
      #   Account type to login. Defaults to TYPE_HOSTED_OR_GOOGLE.
      #   {Click here for details}[http://code.google.com/apis/accounts/docs/AuthForInstalledApps.html#Request].
      def initialize(options = {})
        options = Util.prepare_options(options, [:service, :source], [:account_type])
        options[:account_type] ||= TYPE_HOSTED_OR_GOOGLE

        @service = options[:service]
        @source = options[:source]
        @account_type = options[:account_type]
      end

      def authenticate(email, password, hydra = Typhoeus::Hydra.new)
        request = Typhoeus::Request.new("https://www.google.com/accounts/ClientLogin", :method => :post, :params => {
          :accountType => @accountType,
          :Email => email,
          :Passwd => password,
          :service => @service,
          :source => @source
        })

        hydra.queue request
        hydra.run
        response = request.response

        Util.raise_if_error(response)
        @auth_token = /Auth=(.+)$/.match(response.body)[1]
      end

      def sign_request(request)
        raise ArgumentError, "request must be a Typeoeus::Request" unless request.is_a? ::Typhoeus::Request
        request.headers["Authorization"] = "GoogleLogin auth=#{@auth_token}"
        request
      end
    end
  end
end