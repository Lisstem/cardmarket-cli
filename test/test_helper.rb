# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path('../lib', __dir__)
require 'cardmarket_cli'

require 'minitest/autorun'
require 'minitest/reporters'
require 'mocha/minitest'

require 'cardmarket_test'
require 'api_test'

##
# redefine LOGGER because it would mess up the output
module CardmarketCLI
  class LoggerDummy
    def method_missing(method, *args, &block); end

    def respond_to_missing?
      true
    end
  end
  remove_const :LOGGER
  LOGGER = LoggerDummy.new
end

Minitest::Reporters.use!
