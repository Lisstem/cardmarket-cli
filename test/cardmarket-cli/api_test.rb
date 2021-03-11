# frozen_string_literal: true

require 'minitest/autorun'
require 'typhoeus'

##
# Tests which access the Cardmarket API
class APITest < Minitest::Test
  def setup
    Typhoeus::Expectation.clear
  end
end
