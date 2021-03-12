# frozen_string_literal: true

require 'typhoeus'
require 'cardmarket_test'

module CardmarketCLI
  ##
  # Tests which access the Cardmarket API
  class APITest < CardmarketTest
    def setup
      Typhoeus::Expectation.clear
    end
  end
end
