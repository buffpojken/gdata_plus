require 'active_support/core_ext/hash/keys'

module GDataPlus
  module Util
    module_function

    def prepare_options(options, required_keys, optional_keys = [])
      options = options.symbolize_keys
      options.assert_valid_keys(required_keys + optional_keys)
      required_keys.each do |key|
        raise ArgumentError, "#{key.inspect} option required" if options[key].nil?
      end
      options
    end
  end
end