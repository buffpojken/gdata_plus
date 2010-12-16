module GDataPlus
  class Exception < StandardError
    attr_reader :response

    def initialize(response)
      @response = response

      if @response.respond_to? :body
        super(@response.body)
      else
        super("no response provided")
      end
    end
  end
end