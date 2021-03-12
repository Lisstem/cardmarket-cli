# frozen_string_literal: true
require 'typhoeus'
require_relative 'cardmarket_test'

##
# Tests which access the Cardmarket API
class APITest < Minitest::Test
  def setup
    Typhoeus::Expectation.clear
  end
end
